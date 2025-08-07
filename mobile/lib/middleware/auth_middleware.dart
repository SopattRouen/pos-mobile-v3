// import 'package:flutter/material.dart';
// import 'package:calendar/providers/global/auth_provider.dart';
// import 'package:provider/provider.dart';

// import '../screen/s1-account/login_screen.dart';

// class AuthMiddleware extends StatelessWidget {
//   final Widget child;
//   const AuthMiddleware({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(
//       builder: (context, auth, _) {
//         if (auth.isChecking) {
//           return Scaffold(
//             backgroundColor: Colors.grey[200],
//             body: const Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }
        
//         if (auth.isLoggedIn) {
//           return child;
//         }
        
//         return const LoginScreen();
//       },
//     );
//   }
// }
// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Providers Components
import 'package:calendar/providers/global/auth_provider.dart';
import 'package:calendar/providers/global/setting_provider.dart';
import 'package:provider/provider.dart';

// =======================>> Screens
import 'package:calendar/screen/onboading/onboarding3.dart';
import 'package:calendar/screen/s1-account/login_screen.dart';

// =======================>> Shared Components
import 'package:calendar/shared/entity/helper/colors.dart';


class AuthMiddleware extends StatelessWidget {
  final Widget child;
  const AuthMiddleware({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SettingProvider>(
      builder: (context, auth, setting, _) {
        // Show loading screen while checking authentication
        if (auth.isChecking) {
          return Scaffold(
            backgroundColor: HColors.blue,
            body: Stack(
              children: [
                Positioned(
                  left: -50,
                  top: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/f.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 200,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: AssetImage('assets/logo/posmobile1.png'),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 20),
                      // const CircularProgressIndicator(
                      //   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      // ),
                      // const SizedBox(height: 16),
                      // const Text(
                      //   'Checking authentication...',
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 16,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Positioned(
                  right: -50,
                  bottom: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/f.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Check onboarding first
        if (!setting.hasSeenOnboarding) {
          return const Onboarding3();
        }

        // If user is logged in, show the main app
        if (auth.isLoggedIn) {
          return child;
        }

        // Otherwise, show login screen
        return const LoginScreen();
      },
    );
  }
}


// import 'package:calendar/providers/global/auth_provider.dart';
// import 'package:calendar/providers/global/setting_provider.dart';
// import 'package:calendar/screen/onboading/onboarding3.dart';
// import 'package:calendar/screen/s1-account/login_screen.dart';
// import 'package:calendar/shared/entity/helper/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';

// class AuthMiddleware extends StatelessWidget {
//   final Widget child;
//   final List<String>? allowedRoles; // Add this parameter for role checking
  
//   const AuthMiddleware({
//     super.key, 
//     required this.child,
//     this.allowedRoles,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<AuthProvider, SettingProvider>(
//       builder: (context, auth, setting, _) {
//         // Show loading screen while checking authentication
//         if (auth.isChecking) {
//           return _buildLoadingScreen();
//         }

//         // Check onboarding first
//         if (!setting.hasSeenOnboarding) {
//           return const Onboarding3();
//         }

//         // If user is not logged in, show login screen
//         if (!auth.isLoggedIn) {
//           return const LoginScreen();
//         }

//         // If route has role restrictions, check them
//         if (allowedRoles != null && allowedRoles!.isNotEmpty) {
//           return FutureBuilder<String?>(
//             future: auth.getUserRole(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return _buildLoadingScreen();
//               }
              
//               final userRole = snapshot.data;
              
//               if (userRole == null || !allowedRoles!.contains(userRole)) {
//                 // Redirect to appropriate home based on role
//                 Future.microtask(() => _redirectToRoleHome(context, auth));
//                 return _buildUnauthorizedScreen();
//               }
              
//               return child;
//             },
//           );
//         }

//         // No role restrictions, show the child
//         return child;
//       },
//     );
//   }

//   Widget _buildLoadingScreen() {
//     return Scaffold(
//       backgroundColor: HColors.blue,
//       body: Stack(
//         children: [
//           Positioned(
//             left: -50,
//             top: -50,
//             child: Container(
//               width: 150,
//               height: 150,
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/images/f.png'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.center,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   height: 200,
//                   decoration: const BoxDecoration(
//                     image: DecorationImage(
//                       fit: BoxFit.contain,
//                       image: AssetImage('assets/logo/posmobile1.png'),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             right: -50,
//             bottom: -50,
//             child: Container(
//               width: 150,
//               height: 150,
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/images/f.png'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUnauthorizedScreen() {
//     return Scaffold(
//       backgroundColor: HColors.blue,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               height: 200,
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   fit: BoxFit.contain,
//                   image: AssetImage('assets/logo/posmobile1.png'),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'You don\'t have permission to access this page',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _redirectToRoleHome(BuildContext context, AuthProvider auth) async {
//     final role = await auth.getUserRole();
    
//     if (role == 'admin') {
//       if (ModalRoute.of(context)?.settings.name != AppRoutes.adminHome) {
//         context.go(AppRoutes.adminHome);
//       }
//     } else if (role == 'cashier') {
//       if (ModalRoute.of(context)?.settings.name != AppRoutes.cashierHome) {
//         context.go(AppRoutes.cashierHome);
//       }
//     } else {
//       context.go(AppRoutes.home);
//     }
//   }
// }