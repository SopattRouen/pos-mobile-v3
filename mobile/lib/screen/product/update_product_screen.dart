import 'package:another_flushbar/flushbar.dart';
import 'package:calendar/entity/enum/e_variable.dart';
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

class UpdateProductScreen extends StatefulWidget {
  const UpdateProductScreen({super.key, required this.id});
  final String id;

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String? selectedCategoryId;
  File? _selectedImage;
  String? _imageBase64;
  String? _existingImageUrl;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final provider = Provider.of<CreateProductProvider>(
        context,
        listen: false,
      );
      await provider.getProductDetails(widget.id);

      if (provider.productDetails != null &&
          provider.productDetails!['data'] is List &&
          provider.productDetails!['data'].isNotEmpty) {
        final detailsList = provider.productDetails!['data'][0]['details'];
        if (detailsList is List && detailsList.isNotEmpty) {
          final productData = detailsList[0]['product'];

          if (productData != null) {
            setState(() {
              _codeController.text = productData['code'] ?? '';
              _nameController.text = productData['name'] ?? '';
              _priceController.text =
                  (detailsList[0]['unit_price'] as num?)?.toString() ?? '';
              _categoryController.text = productData['type']?['name'] ?? '';
             selectedCategoryId = productData['type']?['id']?.toString();
              _existingImageUrl = mainUrlFile + (productData['image'] ?? '');
              if (_existingImageUrl != null &&
                  _existingImageUrl!.startsWith('data:image')) {
                _imageBase64 = _existingImageUrl!.split(',').last;
              }
            });
          }
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading product: $error')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
        final bytes = await File(pickedFile.path).readAsBytes();
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageBase64 = base64Encode(bytes);
          _existingImageUrl =
              null; // Clear existing URL when new image is selected
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _updateProduct() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('សូមបំពេញលេខកូដ')));
      return;
    }
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('សូមបំពេញឈ្មោះ')));
      return;
    }
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('សូមជ្រើសរើសប្រភេទផលិតផល')));
      return;
    }
    final price = int.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('សូមបញ្ចូលទឹកប្រាក់ជាចំនួនគត់វិជ្ជមាន')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<CreateProductProvider>(
        context,
        listen: false,
      );
      await provider.updateProduct(
        id: widget.id,
        name: _nameController.text,
        code: _codeController.text,
        typeId: int.parse(selectedCategoryId!),
        price: price,
        image: _imageBase64,
      );

      if (provider.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(provider.error!)));
      } else {
        Flushbar(
          message: 'Product updated successfully!',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.blueAccent,
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          icon: Icon(Icons.check_circle, size: 28.0, color: Colors.white),
          leftBarIndicatorColor: Colors.white,
        ).show(context);

        Provider.of<ProductProvider>(context, listen: false).getHome();

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating product: $error')));
    } finally {
      setState(() {
        _isLoading = false;
      });
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('កែប្រែផលិតផល'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              onPressed: _isLoading ? null : _updateProduct,
              icon: const Icon(Icons.check, color: Colors.blueAccent),
            ),
          ),
        ],
        bottom: const CustomHeader(),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (_selectedImage != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImage!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else if (_existingImageUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _existingImageUrl!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _imagePlaceholder(),
                                      ),
                                    )
                                  else
                                    _imagePlaceholder(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
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
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
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
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Category Dropdown
                          Consumer<CreateProductProvider>(
                            builder: (context, provider, _) {
                              // WidgetsBinding.instance.addPostFrameCallback((_) {
                              //   final categoryItems = buildSelectionMap(
                              //     apiData: provider.dataSetup,
                              //     dataKey: 'productTypes',
                              //   );
             
                              // });

                              // Show placeholder or cached items while waiting for next frame
                              final categoryItems = buildSelectionMap(
                                apiData: provider.dataSetup,
                                dataKey: 'productTypes',
                              );

                              return buildSelectionField(
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
                              );
                            },
                          ),
                          const SizedBox(height: 24),
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
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
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
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'Add Photo',
          style: TextStyle(color: HColors.darkgrey, fontSize: 12),
        ),
      ],
    );
  }
}
