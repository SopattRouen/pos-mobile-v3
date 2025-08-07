// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:provider/provider.dart';

// =======================>> Providers Components
import 'package:calendar/providers/global/auth_provider.dart';

// =======================>> Shared Components
import 'package:calendar/shared/component/bottom_appbar.dart';
import 'package:calendar/shared/entity/helper/colors.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _updatePassword() async {
    // Validation
    if (_newPasswordController.text.trim().isEmpty) {
      _showError('សូមបញ្ចូលពាក្យសម្ងាត់ថ្មី');
      return;
    }

    if (_newPasswordController.text.trim().length < 6) {
      _showError('ពាក្យសម្ងាត់ថ្មីត្រូវតែមានយ៉ាងតិច ៦ តួអក្សរ');
      return;
    }

    if (_newPasswordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      _showError('ពាក្យសម្ងាត់ថ្មី និងការបញ្ជាក់មិនត្រូវគ្នាទេ');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      await provider.updatePassword(
        password: _newPasswordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (!mounted) return;

      if (provider.error != null) {
        _showError(provider.error!);
      } else {
        Navigator.pop(context);

        // ✅ Show success SnackBar instead of Flushbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('ពាក្យសម្ងាត់ត្រូវបានធ្វើបច្ចុប្បន្នភាពជោគជ័យ'),
                ),
              ],
            ),
            backgroundColor: Colors.blueAccent,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        _showError('កំហុសក្នុងការធ្វើបច្ចុប្បន្នភាពពាក្យសម្ងាត់: $error');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('កែប្រែពាក្យសម្ងាត់'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              onPressed: _isLoading ? null : _updatePassword,
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
                          // New Password Field
                          _buildTextField(
                            controller: _newPasswordController,
                            label: 'ពាក្យសម្ងាត់ថ្មី *',
                            hint: 'បញ្ចូលពាក្យសម្ងាត់ថ្មី',
                            obscureText: true,
                          ),
                          const SizedBox(height: 24),
                          // Confirm Password Field
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'បញ្ជាក់ពាក្យសម្ងាត់ថ្មី *',
                            hint: 'បញ្ចូលពាក្យសម្ងាត់ថ្មីម្តងទៀត',
                            obscureText: true,
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
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: HColors.darkgrey)),
        TextField(
          controller: controller,
          obscureText: obscureText,
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
}
