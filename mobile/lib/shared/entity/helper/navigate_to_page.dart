// =======================>> Flutter Core
import 'package:flutter/material.dart';


Future<T?> navigateWithTransition<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return page; // The screen you're navigating to
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0); // Start position from bottom
      const end = Offset.zero; // End at the center
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  ));
}