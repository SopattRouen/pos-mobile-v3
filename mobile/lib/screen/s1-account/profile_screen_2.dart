// =======================>> Flutter Core
import 'package:calendar/screen/s1-account/profile_screen.dart';
import 'package:calendar/shared/entity/enum/e_variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

// =======================>> Providers Components
import 'package:calendar/providers/global/auth_provider.dart';
import 'package:provider/provider.dart';

// =======================>> Shared Components
import 'package:calendar/shared/component/bottom_appbar.dart';
import 'package:calendar/shared/widget/helper.dart';
import 'package:calendar/shared/entity/helper/colors.dart';

// ::: Class-p1 > ProfileScreen2 (StatefulWidget)
class ProfileScreen2 extends StatefulWidget {
  const ProfileScreen2({super.key});

  @override
  State<ProfileScreen2> createState() => _ProfileScreen2State();
}

// ::: Class-sp1 > _ProfileScreen2State (State<ProfileScreen2>)
class _ProfileScreen2State extends State<ProfileScreen2> {
  final storage = FlutterSecureStorage();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    // // Load initial data without calling setState during build
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
    //   authProvider.handleCheckAuth().catchError((e) {
    //     if (mounted) {
    //       _scaffoldMessengerKey.currentState?.showSnackBar(
    //         SnackBar(content: Text('Error loading user data: $e')),
    //       );
    //     }
    //   });
    // });
  }

  void showEditOptions() {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: false,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: Icon(Icons.edit, color: HColors.darkgrey),
                  title: Text('កែប្រែគណនី'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/update-profile');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock_outline, color: HColors.darkgrey),
                  title: Text('កែប្រែពាក្យសម្ងាត់'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/update-password');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ScaffoldMessenger(
          key: _scaffoldMessengerKey,
          child: Scaffold(
            backgroundColor: Colors.white,
            // appBar
            appBar: AppBar(
              title: Text(
                "គណនី",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
              centerTitle: true,
            ),
            body:
                authProvider.isChecking
                    ? Center(child: CircularProgressIndicator())
                    : SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            CustomHeader(),
                            FutureBuilder<Map<String, String?>>(
                              future: Future.wait([
                                authProvider.getUserName(),
                                authProvider.getUserEmail(),
                                authProvider.getUserPhone(),
                                authProvider.getUserAvatar(),
                                authProvider.getUserRole(),
                                authProvider.getLastUpdated(),
                              ]).then(
                                (results) => {
                                  'name': results[0],
                                  'email': results[1],
                                  'phone': results[2],
                                  'avatar': results[3],
                                  'role': results[4],
                                  'lastLogin': results[5],
                                },
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${snapshot.error ?? 'Unknown'}',
                                    ),
                                  );
                                }
                                final userData =
                                    snapshot.data ??
                                    {
                                      'name': 'Unknown User',
                                      'email': 'No Email',
                                      'phone': 'No Phone',
                                      'avatar': null,
                                      'role': 'No Role',
                                      'lastLogin': 'Unknown',
                                    };
                                return UserProfileHeaderAcc(
                                  authProvider: authProvider,
                                  userName: userData['name'],
                                  userEmail: userData['email'],
                                  userPhone: userData['phone'],
                                  userAvatar: userData['avatar'],
                                  userRole: userData['role'],
                                  lastLogin: userData['lastLogin'],
                                  onEditPressed: showEditOptions,
                                );
                              },
                            ),
                            SizedBox(height: 4),
                            // Profile Actions
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                    // Security
                                    ProfileActionItem(
                                      icon: Icons.shield_outlined,
                                      text: 'ពាក្យសម្ងាត់ និងសុវត្ថិភាព',
                                      trailingIcon: Icons.check_circle,
                                      isVerified: true,
                                      onTap: () {},
                                    ),
                                    // Notifications
                                    ProfileActionItem(
                                      icon: Icons.notifications_active,
                                      text: 'ការជូនដំណឹង',
                                      onTap: () {},
                                    ),
                                    // App Version
                                    ProfileActionItem(
                                      icon: Icons.info_outline,
                                      text: 'អំពីកម្មវិធី',
                                      trailingText: 'ជំនាន់ 1.0.0',
                                      onTap: () {},
                                    ),
                                    // Log Out
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
                                            await storage.delete(
                                              key: 'checkIn',
                                            );
                                            context.go('/login');
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
          ),
        );
      },
    );
  }
}

class UserProfileHeaderAcc extends StatelessWidget {
  final AuthProvider authProvider;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? userAvatar;
  final String? userRole;
  final String? lastLogin;
  final VoidCallback? onEditPressed;

  const UserProfileHeaderAcc({
    super.key,
    required this.authProvider,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userAvatar,
    this.userRole,
    this.lastLogin,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.045; 
    final textSize = screenWidth * 0.035; 
    final paddingSize = screenWidth * 0.02; 

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Background image
            Container(
              height:
                  screenWidth *
                  0.5, 
              width: screenWidth,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/pos1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Profile avatar
            Positioned(
              left: paddingSize * 2, 
              bottom: -screenWidth * 0.1, 
              child: _buildAvatar(screenWidth),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.12), 
        // Info and action
        Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingSize * 2), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + Icon Buttons Row
              Row(
                children: [
                  Text(
                    userName ?? 'Unknown User',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06, 
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: onEditPressed,
                    icon: Icon(
                      Icons.edit,
                      size: screenWidth * 0.05, 
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: paddingSize), 
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.settings,
                      size: screenWidth * 0.05, 
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              SizedBox(height: paddingSize * 2), 
              // Contact Row (Scrollable)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Phone number
                    _buildContactItem(
                      context: context, // Pass context
                      icon: Icons.phone,
                      text: userPhone ?? 'No Phone',
                      iconSize: iconSize,
                      textSize: textSize,
                      paddingSize: paddingSize,
                    ),
                    _buildSeparator(paddingSize, textSize),
                    // Email
                    _buildContactItem(
                      context: context, // Pass context
                      icon: Icons.email,
                      text: userEmail ?? 'No Email',
                      iconSize: iconSize,
                      textSize: textSize,
                      paddingSize: paddingSize,
                    ),
                    _buildSeparator(paddingSize, textSize),
                    // Last login
                    _buildContactItem(
                      context: context, // Pass context
                      icon: Icons.access_time,
                      text: lastLogin ?? 'Unknown',
                      iconSize: iconSize,
                      textSize: textSize,
                      paddingSize: paddingSize,
                    ),
                  ],
                ),
              ),

              SizedBox(height: paddingSize * 2), // ~16px
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build contact item
  Widget _buildContactItem({
    required BuildContext context, // Add context parameter
    required IconData icon,
    required String text,
    required double iconSize,
    required double textSize,
    required double paddingSize,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingSize),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: Colors.grey[700]),
          SizedBox(width: paddingSize * 0.75), // ~6px
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width * 0.3, // Use passed context
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: textSize, color: Colors.grey[800]),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build separator
  Widget _buildSeparator(double paddingSize, double textSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingSize),
      child: Text(
        '|',
        style: TextStyle(
          fontSize: textSize * 1.1, // Slightly larger for separator
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildAvatar(double screenWidth) {
    Widget avatarImage;

    if (userAvatar != null && userAvatar!.isNotEmpty) {
      if (userAvatar!.startsWith('http')) {
        avatarImage = Image.network(
          userAvatar!,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _buildDefaultAvatar(screenWidth),
        );
      } else {
        avatarImage = Image.network(
          '$mainUrlFile$userAvatar',
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _buildDefaultAvatar(screenWidth),
        );
      }
    } else {
      avatarImage = _buildDefaultAvatar(screenWidth);
    }

    final double avatarSize = screenWidth * 0.25; // ~100px
    final double borderSize = 4.0;

    return Container(
      padding: EdgeInsets.all(borderSize),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white, // Background color
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          width: avatarSize,
          height: avatarSize,
          color: Colors.white,
          child: avatarImage,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(double screenWidth) {
    return Container(
      width: screenWidth * 0.25, 
      height: screenWidth * 0.25, 
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(0.5),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: screenWidth * 0.125, 
          color: Colors.white,
        ),
      ),
    );
  }
}
