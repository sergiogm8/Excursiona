import 'package:excursiona/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

Future nextScreen(context, page, PageTransitionType animation) {
  return Navigator.push(context, PageTransition(child: page, type: animation));
}

void nextScreenReplace(context, page, PageTransitionType animation) {
  Navigator.pushReplacement(
      context, PageTransition(child: page, type: animation));
}

void showSnackBar(BuildContext context, Color color, String message,
    [int duration = 3]) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      duration: Duration(seconds: duration),
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

final blueTextInputDecoration = InputDecoration(
  hintStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
  enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Constants.indigoDye),
      borderRadius: BorderRadius.circular(15)),
  focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Constants.steelBlue, width: 2),
      borderRadius: BorderRadius.circular(15)),
);
