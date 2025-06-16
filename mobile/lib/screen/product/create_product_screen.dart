import 'package:another_flushbar/flushbar.dart';
import 'package:calendar/entity/helper/colors.dart';
import 'package:calendar/providers/local/product/create_product_provider.dart';
import 'package:calendar/providers/local/product_provider.dart';
import 'package:calendar/shared/component/bottom_appbar.dart';
import 'package:calendar/shared/component/bottom_selection.dart';
import 'package:calendar/shared/component/build_selection_map.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

import 'package:provider/provider.dart';

class CreateProductsScreen extends StatefulWidget {
  const CreateProductsScreen({super.key});

  @override
  State<CreateProductsScreen> createState() => _CreateProductsScreenState();
}

class _CreateProductsScreenState extends State<CreateProductsScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String? selectedCategoryId;
  File? _selectedImage;
  String? _imageBase64;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'ជ្រើសរើសរូបភាព',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    // color: HColors.darkgrey,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blueAccent),
                title: Text('រូបភាព'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blueAccent),
                title: Text('កាមេរ៉ា'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Convert to base64
        final bytes = await _selectedImage!.readAsBytes();
        _imageBase64 = base64Encode(bytes);

        print(
          'Image converted to base64: ${_imageBase64?.substring(0, 50)}...',
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateProductProvider>(
      builder: (context, provider, child) {
        final categoryItems = buildSelectionMap(
          apiData: provider.dataSetup,
          dataKey: 'productTypes',
        );
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('បង្កើតផលិតផល'),
            centerTitle: true,
            actions: [
              Padding(
                padding: EdgeInsets.all(8),
                child: IconButton(
                  onPressed: () async {
                    if (_codeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('សូមបំពេញលេខកូដ')),
                      );
                      return;
                    }
                    // Validate inputs
                    if (_nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('សូមបំពេញឈ្មោះ')),
                      );
                      return;
                    }
                    if (selectedCategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('សូមជ្រើសរើសប្រភេទផលិតផល')),
                      );
                      return;
                    }
                    if (_imageBase64 == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('សូមបញ្ចូលរូបភាព')),
                      );
                      return;
                    }
    
                    // Parse price
                    final price = int.tryParse(_priceController.text);
                    if (price == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('សូមបញ្ចូលទឹកប្រាក់ជាចំនួនគត់'),
                        ),
                      );
                      return;
                    }
    
                    // Call createProducts
                    // showConfirmDialog(
                    //   context,
                    //   'បង្កើតផលិតផល',
                    //   "តើអ្នកចង់បង្កើតផលិតផលពិតមែនទេ",
                    //   DialogType.primary,
                    //   () async {
    
                    //   },
                    // );
                    await provider.createProducts(
                      name: _nameController.text,
                      code: _codeController.text,
                      typeId: int.parse(selectedCategoryId!),
                      price: price,
                      image: _imageBase64!,
                    );
    
                    // Show feedback
                    if (provider.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.error!)),
                      );
                    } else {
                      Flushbar(
                        message: 'Product created successfully!',
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.blueAccent,
                        flushbarPosition: FlushbarPosition.TOP,
                        margin: EdgeInsets.all(8),
                        borderRadius: BorderRadius.circular(8),
                        icon: Icon(
                          Icons.check_circle,
                          size: 28.0,
                          color: Colors.white,
                        ),
                        leftBarIndicatorColor: Colors.white,
                      ).show(context);
                      // Optionally reset form
                      setState(() {
                        _codeController.clear();
                        _nameController.clear();
                        _priceController.clear();
                        _categoryController.clear();
                        selectedCategoryId = null;
                        _selectedImage = null;
                        _imageBase64 = null;
                      });
                      Provider.of<ProductProvider>(context,listen: false).getHome();
                    }
                  },
                  icon: Icon(Icons.check, color: Colors.blueAccent),
                ),
              ),
            ],
            bottom: CustomHeader(),
          ),
          body:
              provider.isLoading
                  ? Center(child: Text('Loading...'))
                  : GestureDetector(
                    onTap:
                        () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: SafeArea(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Product Image Section
                              GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Image display or placeholder
                                      _selectedImage != null
                                          ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.file(
                                              _selectedImage!,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                size: 40,
                                                color: Colors.grey[400],
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Add Photo',
                                                style: TextStyle(
                                                  color: HColors.darkgrey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 32),
    
                              // Product Code Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'លេខកូដ *',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: HColors.darkgrey,
                                    ),
                                  ),
                                  TextField(
                                    controller: _codeController,
                                    decoration: InputDecoration(
                                      hintText: 'ឧទាហរណ៍ BV0002',
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),
    
                              // Product Name Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ឈ្មោះ *',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: HColors.darkgrey,
                                    ),
                                  ),
                                  TextField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      hintText: 'ឧទាហរណ៍ Coca-Cola',
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),
    
                              // Category Dropdown
                              buildSelectionField(
                                controller: _categoryController,
                                label: 'ប្រភេទ *',
                                items: categoryItems,
                                context: context,
                                selectedId: selectedCategoryId,
                                onSelected: (String id, String value) {
                                  setState(() {
                                    selectedCategoryId = id;
                                    _categoryController.text = value;
                                  });
                                },
                                hint: 'សូមជ្រើសរើសប្រភេទផលិតផល',
                              ),
                              SizedBox(height: 24),
    
                              // Price Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'តម្លៃ(រៀល) *',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: HColors.darkgrey,
                                    ),
                                  ),
                                  TextField(
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'ឧទាហរណ៍ 3000',
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
        );
      },
    );
  }
}
