// =======================>> Dart Core
import 'dart:convert';
import 'dart:io';

// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:another_flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// =======================>> Providers Components
import 'package:calendar/providers/local/product_provider.dart';
import 'package:calendar/providers/local/product/create_product_provider.dart';

// =======================>> Shared Components
import 'package:calendar/shared/component/bottom_appbar.dart';
import 'package:calendar/shared/component/bottom_selection.dart';
import 'package:calendar/shared/component/build_selection_map.dart';
import 'package:calendar/shared/entity/enum/e_variable.dart';
import 'package:calendar/shared/entity/helper/colors.dart';


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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductDetails();
    });
  }

  Future<void> _loadProductDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<CreateProductProvider>(
        context,
        listen: false,
      );
      // Note: The line below does nothing useful; it’s just accessing dataSetup without action.
      // If dataSetup needs to be loaded, you should call a method like provider.loadDataSetup().
      if (provider.dataSetup == null) {
        provider
            .dataSetup; // This should be replaced with actual loading logic if needed
      }
      await provider.getProductDetails(widget.id);

      if (!mounted) return;

      if (provider.productDetails != null &&
          provider.productDetails!['data'] is List &&
          (provider.productDetails!['data'] as List).isNotEmpty) {
        final detailsList = provider.productDetails!['data'][0]['details'];
        if (detailsList is List && detailsList.isNotEmpty) {
          final productData = detailsList[0]['product'];

          if (productData != null) {
            // Get the category name from product details
            final categoryName = productData['type']?['name']?.toString();

            // Find the matching category ID from dataSetup
            String newSelectedCategoryId = '';
            if (categoryName != null && provider.dataSetup != null) {
              final productTypes =
                  provider.dataSetup?['productTypes'] as List<dynamic>?;
              if (productTypes != null) {
                final matchingCategory = productTypes.firstWhere(
                  (type) => type['name']?.toString() == categoryName,
                  orElse: () => null,
                );
                if (matchingCategory != null) {
                  newSelectedCategoryId =
                      matchingCategory['id']?.toString() ?? '';
                }
              }
            }

            setState(() {
              _codeController.text = productData['code']?.toString() ?? '';
              _nameController.text = productData['name']?.toString() ?? '';
              _priceController.text =
                  (detailsList[0]['unit_price'] as num?)?.toString() ?? '';
              _categoryController.text = categoryName ?? '';
              selectedCategoryId = newSelectedCategoryId; // Use the matched ID

              // Handle image URL (unchanged)
              final imageUrl = productData['image']?.toString();
              if (imageUrl != null && imageUrl.isNotEmpty) {
                if (imageUrl.startsWith('data:image')) {
                  _existingImageUrl = imageUrl;
                  _imageBase64 =
                      imageUrl.split(',').length > 1
                          ? imageUrl.split(',').last
                          : null;
                } else {
                  _existingImageUrl = mainUrlFile + imageUrl;
                  _imageBase64 = null;
                }
              } else {
                _existingImageUrl = null;
                _imageBase64 = null;
              }
            });
          }
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading product: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  // Fetch existing image from URL and convert to base64
  Future<String?> _convertImageUrlToBase64(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final contentType = response.headers['content-type'] ?? 'image/png';
        if (!contentType.contains('image/png') &&
            !contentType.contains('image/jpeg')) {
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
          _existingImageUrl =
              null; // Clear existing image when new one is selected
        });

        // Convert to base64 with data URI prefix
        final bytes = await _selectedImage!.readAsBytes();
        _imageBase64 = "data:image/png;base64,${base64Encode(bytes)}";
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _updateProduct() async {
    // Validation
    if (_codeController.text.trim().isEmpty) {
      _showError('សូមបំពេញលេខកូដ');
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      _showError('សូមបំពេញឈ្មោះ');
      return;
    }

    if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
      _showError('សូមជ្រើសរើសប្រភេទផលិតផល');
      return;
    }

    final priceText = _priceController.text.trim();
    final price = int.tryParse(priceText);
    if (price == null || price <= 0) {
      _showError('សូមបញ្ចូលទឹកប្រាក់ជាចំនួនគត់វិជ្ជមាន');
      return;
    }

    // For updates, image is optional if there's an existing image
    if (_imageBase64 == null && _existingImageUrl == null) {
      _showError('សូមបញ្ចូលរូបភាព');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<CreateProductProvider>(
        context,
        listen: false,
      );
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

      await provider.updateProduct(
        id: widget.id,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        typeId: int.parse(selectedCategoryId!),
        price: price,
        image: imageToSend,
      );

      if (!mounted) return;

      if (provider.error != null) {
        _showError(provider.error!);
      } else {
        // Refresh the product list
        if (mounted) {
          Provider.of<ProductProvider>(context, listen: false).getHome();

          Navigator.pop(context);
        }
        await Flushbar(
          message: 'Product updated successfully!',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.blueAccent,
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.check_circle, size: 28.0, color: Colors.white),
          leftBarIndicatorColor: Colors.white,
        ).show(context);
      }
    } catch (error) {
      if (mounted) {
        _showError('Error updating product: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              ? Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                    Text(
                      'សូមរងចាំ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              )
              : Consumer<CreateProductProvider>(
                builder: (context, provider, _) {
                  if (provider.dataSetup == null) {
                    return Center(child: Text('Loading categories...'));
                  }
                  final categoryItems = buildSelectionMap(
                    apiData: provider.dataSetup,
                    dataKey: 'productTypes',
                  );
                  if (categoryItems.isEmpty) {
                    return Center(child: Text('No categories available'));
                  }
                  return GestureDetector(
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
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (_selectedImage != null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            _selectedImage!,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      else if (_existingImageUrl != null &&
                                          _existingImageUrl!.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            _existingImageUrl!,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
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
                                                  value:
                                                      loadingProgress
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
                              _buildTextField(
                                controller: _codeController,
                                label: 'លេខកូដ *',
                                hint: 'ឧទាហរណ៍ BV0002',
                              ),
                              const SizedBox(height: 24),
                              // Product Name Field
                              _buildTextField(
                                controller: _nameController,
                                label: 'ឈ្មោះ *',
                                hint: 'ឧទាហរណ៍ Coca-Cola',
                              ),
                              const SizedBox(height: 24),
                              // Category Dropdown
                              buildSelectionField(
                                controller: _categoryController,
                                label: 'ប្រភេទ *',
                                items: categoryItems,
                                context: context,
                                selectedId: selectedCategoryId,
                                onSelected: (String id, String value) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) {
                                      setState(() {
                                        selectedCategoryId = id;
                                        _categoryController.text = value;
                                      });
                                    }
                                  });
                                },
                                hint: 'សូមជ្រើសរើសប្រភេទផលិតផល',
                              ),
                              const SizedBox(height: 24),
                              // Price Field
                              _buildTextField(
                                controller: _priceController,
                                label: 'តម្លៃ(រៀល) *',
                                hint: 'ឧទាហរណ៍ 3000',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: HColors.darkgrey)),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
          ),
        ),
      ],
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
