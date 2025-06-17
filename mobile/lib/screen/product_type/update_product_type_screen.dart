import 'package:another_flushbar/flushbar.dart';
import 'package:calendar/entity/enum/e_variable.dart';
import 'package:calendar/entity/helper/colors.dart';
import 'package:calendar/providers/local/product_provider.dart';
import 'package:calendar/providers/local/product_type/create_product_type_provider.dart';
import 'package:calendar/providers/local/product_type_provider.dart';
import 'package:calendar/shared/component/bottom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class UpdateProductTypeScreen extends StatefulWidget {
  const UpdateProductTypeScreen({
    super.key,
    required this.id,
    required this.image,
    required this.name,
  });
  final String id;
  final String image;
  final String name;

  @override
  State<UpdateProductTypeScreen> createState() =>
      _UpdateProductTypeScreenState();
}

class _UpdateProductTypeScreenState extends State<UpdateProductTypeScreen> {
  final TextEditingController _nameController = TextEditingController();

  File? _selectedImage;
  String? _imageBase64;
  String? _existingImageUrl; // Store existing image URL
  final ImagePicker _imagePicker = ImagePicker();

  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWithPassedData();
  }

  // Initialize form with data passed through route parameters
  void _initializeWithPassedData() {
    setState(() {
      _nameController.text = Uri.decodeComponent(widget.name);
      _existingImageUrl = Uri.decodeComponent(mainUrlFile+ widget.image); // Use widget.image directly
      isInitialized = true;
    });
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
              if (_existingImageUrl != null || _selectedImage != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.redAccent),
                  title: Text('Remove Image'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _imageBase64 = null;
                      _existingImageUrl = null;
                    });
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
          _existingImageUrl = null; // Clear existing image when new one is selected
        });

        // Convert to base64 with data URI prefix
        final bytes = await _selectedImage!.readAsBytes();
        _imageBase64 = "data:image/png;base64,${base64Encode(bytes)}";
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  // Fetch existing image from URL and convert to base64
  Future<String?> _convertImageUrlToBase64(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final contentType = response.headers['content-type'] ?? 'image/png';
        if (!contentType.contains('image/png') && !contentType.contains('image/jpeg')) {
          throw Exception('Unsupported image format: $contentType');
        }
        return "data:$contentType;base64,${base64Encode(bytes)}";
      } else {
        throw Exception('Failed to fetch image: HTTP ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error fetching existing image: $e');
      return null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
      backgroundColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(Icons.check_circle, size: 28.0, color: Colors.white),
      leftBarIndicatorColor: Colors.white,
    ).show(context);
  }

  Future<void> _updateProductType(CreateProductTypeProvider provider) async {
    // Validate inputs
    if (_nameController.text.isEmpty) {
      _showError('សូមបំពេញឈ្មោះ');
      return;
    }

    // For updates, image is optional if there's an existing image
    if (_imageBase64 == null && _existingImageUrl == null) {
      _showError('សូមបញ្ចូលរូបភាព');
      return;
    }

    try {
      String? imageToSend;

      if (_imageBase64 != null) {
        // Use new image if selected
        imageToSend = _imageBase64;
      } else if (_existingImageUrl != null) {
        // Convert existing image URL to base64
        imageToSend = await _convertImageUrlToBase64(_existingImageUrl!);
        if (imageToSend == null) {
          return; // Error already shown in _convertImageUrlToBase64
        }
      }

      // Call the updateProductType method
      await provider.updateProductType(
        id: widget.id,
        name: _nameController.text,
        image: imageToSend,
      );

      if (provider.error != null) {
        _showError(provider.error!);
      } else {
        _showSuccess('Product type updated successfully!');

        // Refresh the product type list
        Provider.of<ProductTypeProvider>(context, listen: false).getHome();
        Provider.of<ProductProvider>(context, listen: false).getHome();
        // Schedule navigation after build
      _existingImageUrl =null;
      _nameController.text = '';
      }
    } catch (e) {
      _showError('Error updating product type: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreateProductTypeProvider(),
      child: Consumer<CreateProductTypeProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text('កែប្រែប្រភេទផលិតផល'),
              centerTitle: true,
              actions: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: IconButton(
                    onPressed: provider.isLoading
                        ? null
                        : () => _updateProductType(provider),
                    icon: provider.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.check, color: Colors.blueAccent),
                  ),
                ),
              ],
              bottom: CustomHeader(),
            ),
            body: GestureDetector(
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
                                // Image display priority: new selected > existing > placeholder
                                _selectedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selectedImage!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : _existingImageUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              _existingImageUrl!,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.error,
                                                      size: 40,
                                                      color: Colors.red[400],
                                                    ),
                                                    Text(
                                                      'Image Error',
                                                      style: TextStyle(
                                                        color: Colors.red[400],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
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
                                // Edit overlay
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 32),

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
                                hintText: 'ឧទាហរណ៍ Beverages',
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}