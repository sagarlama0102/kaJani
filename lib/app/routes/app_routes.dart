import 'package:flutter/material.dart';

/// Simple navigation utility class
class AppRoutes {
  AppRoutes._();

  /// Push a new route onto the stack
 static Future<T?> push<T>(BuildContext context, Widget page) {
  return Navigator.push<T>(context, MaterialPageRoute(builder: (_) => page));
}

  /// Replace current route with a new one
  static void pushReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Push a new route and remove all previous routes
  static void pushAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  /// Pop the current route
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  /// Pop to first route (root)
  static void popToFirst(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
  /// Push a new route onto the stack

}
