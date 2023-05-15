import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/enums/marker_type.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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

getIconByMarkerType(MarkerType markerType) {
  switch (markerType) {
    case MarkerType.info:
      return Constants.interestMarkerIcon;
    case MarkerType.rest:
      return Constants.restMarkerIcon;
    case MarkerType.warning:
      return Constants.warningMarkerIcon;
    case MarkerType.custom:
      return Constants.customMarkerIcon;
    default:
      return Constants.interestMarkerIcon;
  }
}

String getNameAbbreviation(String name) {
  // Get the user's name and the first letter of the second word,
  // if there is one
  return name.split(' ').length > 1
      ? '${name.split(' ')[0]} ${name.split(' ')[1][0]}.'
      : name;
}

bool isCurrentUser(String uid) {
  return AuthController().isCurrentUser(uid: uid);
}

Future<XFile?> pickImageFromCamera() async {
  final ImagePicker _picker = ImagePicker();
  var image =
      await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
  return image;
}
