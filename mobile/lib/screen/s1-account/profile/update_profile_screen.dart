// =======================>> Dart Core
import 'dart:convert';
import 'dart:io';

// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// =======================>> Providers Components
import 'package:calendar/providers/global/auth_provider.dart';

// =======================>> Shared Components
import 'package:calendar/shared/component/bottom_appbar.dart';
import 'package:calendar/shared/entity/enum/e_variable.dart';
import 'package:calendar/shared/entity/helper/colors.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;
  String? _imageBase64;
  String? _existingImageUrl;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserDetails();
    });
  }

  Future<void> _loadUserDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      final name = await provider.getUserName();
      final email = await provider.getUserEmail();
      final phone = await provider.getUserPhone();
      final avatar = await provider.getUserAvatar();

      if (!mounted) return;

      setState(() {
        _nameController.text = name ?? '';
        _emailController.text = email ?? '';
        _phoneController.text = phone ?? '';
        if (avatar != null && avatar.isNotEmpty) {
          if (avatar.startsWith('data:image')) {
            _existingImageUrl = avatar;
            _imageBase64 =
                avatar.split(',').length > 1 ? avatar.split(',').last : null;
          } else {
            _existingImageUrl = mainUrlFile + avatar;
            _imageBase64 = null;
          }
        } else {
          _existingImageUrl = null;
          _imageBase64 = null;
        }
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('កំហុសក្នុងការផ្ទុកទិន្នន័យអ្នកប្រើប្រាស់: $error'),
          ),
        );
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
                  title: Text('លុបរូបភាព'),
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
          _existingImageUrl =
              null; // Clear existing image when new one is selected
        });

        // Convert to base64 with data URI prefix
        final bytes = await _selectedImage!.readAsBytes();
        _imageBase64 = "data:image/png;base64,${base64Encode(bytes)}";
      }
    } catch (e) {
      _showError('កំហុសក្នុងការជ្រើសរើសរូបភាព: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _updateProfile() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showError('សូមបញ្ចូលឈ្មោះ');
      return;
    }

    final email = _emailController.text.trim();
    if (email.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError('សូមបញ្ចូលអ៊ីមែលត្រឹមត្រូវ');
      return;
    }

    if (_phoneController.text.trim().isEmpty ||
        !RegExp(
          r'^(\+855|0)[1-9]\d{7,8}$',
        ).hasMatch(_phoneController.text.trim())) {
      _showError('សូមបញ្ចូលលេខទូរស័ព្ទត្រឹមត្រូវ (លេខកម្ពុជា)');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      await provider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        imageBase64:
            _selectedImage != null
                ? _imageBase64
                : null, // Send only if new image
      );

      if (!mounted) return;

      if (provider.error != null) {
        _showError(provider.error!);
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('ព័ត៌មានគណនីត្រូវបានធ្វើបច្ចុប្បន្នភាពជោគជ័យ'),
                ),
              ],
            ),
            backgroundColor: Colors.blueAccent,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        _showError('កំហុសក្នុងការធ្វើបច្ចុប្បន្នភាពគណនី: $error');
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('កែប្រែគណនី'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              onPressed: _isLoading ? null : _updateProfile,
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
              : GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Profile Image Section
                          GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: CircleAvatar(
                              radius: 60, // Same as width/height (120/2)
                              backgroundColor: Colors.grey[100],
                              child: ClipOval(
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (_selectedImage != null)
                                        Image.file(
                                          _selectedImage!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )
                                      else if (_existingImageUrl != null &&
                                          _existingImageUrl!.isNotEmpty)
                                        Image.network(
                                          _existingImageUrl!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
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
                                        )
                                      else
                                        _imagePlaceholder(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Name Field
                          _buildTextField(
                            controller: _nameController,
                            label: 'ឈ្មោះ *',
                            hint: 'បញ្ចូលឈ្មោះ',
                          ),
                          const SizedBox(height: 24),
                          // Email Field
                          _buildTextField(
                            controller: _emailController,
                            label: 'អ៊ីមែល',
                            hint: 'បញ្ចូលអ៊ីមែល',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),
                          // Phone Field
                          _buildTextField(
                            controller: _phoneController,
                            label: 'លេខទូរស័ព្ទ *',
                            hint: 'បញ្ចូលលេខទូរស័ព្ទ',
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
          'បន្ថែមរូបភាព',
          style: TextStyle(color: HColors.darkgrey, fontSize: 12),
        ),
      ],
    );
  }
}
