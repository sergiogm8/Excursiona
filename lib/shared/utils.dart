import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

void nextScreen(context, page, PageTransitionType animation) {
  Navigator.push(context, PageTransition(child: page, type: animation));
}

void nextScreenReplace(context, page, PageTransitionType animation) {
  Navigator.pushReplacement(
      context, PageTransition(child: page, type: animation));
}

void showSnackBar(BuildContext context, Color color, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    ),
  );
}
