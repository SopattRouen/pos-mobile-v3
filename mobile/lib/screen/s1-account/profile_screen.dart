import 'package:calendar/shared/component/bottom_appbar.dart';
import 'package:calendar/shared/widget/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:calendar/entity/helper/colors.dart';
import 'package:calendar/providers/global/auth_provider.dart';

import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = FlutterSecureStorage();
  String? userName;
  String? userAvatar;
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final AuthProvider authProvider = AuthProvider();
    try {
      final name = await authProvider.getUserName();
      final avatar = await authProvider.getUserAvatar();
      final role = await authProvider.getUserRole();

      if (mounted) {
        setState(() {
          userName = name ?? 'Unknown User';
          userAvatar = avatar;
          userRole = role ?? 'No Role';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userName = 'Unknown User';
          userRole = 'No Role';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              "គណនី",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
            centerTitle: true,
            bottom: CustomHeader(),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 35),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: UserProfileHeaderAcc(
                      authProvider: authProvider,
                      userName: userName,
                      userEmail: userRole,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'គណនីត្រូវបានបង្កើតឡើងនៅថ្ងៃទី 25 ខែកុម្ភៈ ឆ្នាំ 2025',
                          style: TextStyle(
                            fontSize: 12,
                            color: HColors.darkgrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Profile Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: HColors.darkgrey.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          // ProfileActionItem(
                          //   icon: Icons.credit_card,
                          //   text: 'ព័ត៌មានលម្អិត និងនាមប័ណ្ណ',
                          //   trailingText: '1 ថ្ងៃ',
                          //   onTap: () {},
                          // ),
                          ProfileActionItem(
                            icon: Icons.shield_outlined,
                            text: 'ពាក្យសម្ងាត់ និងសុវត្ថិភាព',
                            trailingIcon: Icons.check_circle,
                            isVerified: true,
                            onTap: () {},
                          ),
                          ProfileActionItem(
                            icon: Icons.notifications_active,
                            text: 'ការជូនដំណឹង',
                            onTap: () {},
                          ),
                          // ProfileActionItem(
                          //   icon: Icons.grid_view_outlined,
                          //   text: 'កម្មវិធីឌីជីថល',
                          //   onTap: () {},
                          // ),
                          ProfileActionItem(
                            icon: Icons.info_outline,
                            text: 'អំពីកម្មវិធី',
                            trailingText: 'ជំនាន់ 1.0.0',
                            onTap: () {},
                          ),
                          ProfileActionItem(
                            icon: Icons.logout,
                            text: 'ចាកចេញ',
                            onTap: () {
                              showConfirmDialog(
                                context,
                                'បញ្ជាក់ការចាកចេញ',
                                'តើអ្នកពិតជាប្រាកដចង់ចាកចេញមែនឬទេ?',
                                DialogType.primary,
                                () async {
                                  await authProvider.handleLogout();
                                  await storage.delete(key: 'checkIn');
                                },
                              );
                            },
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class UserProfileHeaderAcc extends StatefulWidget {
  final AuthProvider authProvider;
  final String? userName;
  final String? userEmail;

  const UserProfileHeaderAcc({
    super.key,
    required this.authProvider,
    this.userName,
    this.userEmail,
  });

  @override
  State<UserProfileHeaderAcc> createState() => _UserProfileHeaderAccState();
}

class _UserProfileHeaderAccState extends State<UserProfileHeaderAcc> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: HColors.darkgrey.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.userName ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.userEmail ?? 'Unknown Email',
                        style: TextStyle(fontSize: 12, color: HColors.darkgrey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HColors.darkgrey.withOpacity(0.5),
      ),
      child: const Center(
        child: Icon(Icons.person, size: 24.0, color: Colors.white),
      ),
    );
  }
}

class ProfileActionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? trailingText;
  final IconData? trailingIcon;
  final bool isVerified;
  final VoidCallback onTap;
  final bool isLast;

  const ProfileActionItem({
    super.key,
    required this.icon,
    required this.text,
    this.trailingText,
    this.trailingIcon,
    this.isVerified = false,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(icon, size: 24, color: HColors.darkgrey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(text, style: const TextStyle(fontSize: 16)),
                ),
                if (trailingIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Icon(
                      trailingIcon,
                      size: 16,
                      color: isVerified ? Colors.green : HColors.darkgrey,
                    ),
                  ),
                if (trailingText != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Text(
                      trailingText!,
                      style: TextStyle(fontSize: 14, color: HColors.darkgrey),
                    ),
                  ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: HColors.darkgrey,
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(height: 1, color: HColors.darkgrey.withOpacity(0.1)),
        ],
      ),
    );
  }
}
