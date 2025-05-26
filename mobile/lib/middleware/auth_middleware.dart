import 'package:flutter/material.dart';
import 'package:calendar/providers/global/auth_provider.dart';
import 'package:provider/provider.dart';

import '../screen/login_screen.dart';

class AuthMiddleware extends StatelessWidget {
  final Widget child;
  const AuthMiddleware({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isChecking) {
          return Scaffold(
            backgroundColor: Colors.grey[200],
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (auth.isLoggedIn) {
          return child;
        }
        
        return const LoginScreen();
      },
    );
  }
}