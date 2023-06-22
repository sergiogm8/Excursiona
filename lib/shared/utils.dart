import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/enums/marker_type.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

Future nextScreen(context, page, PageTransitionType animation) {
  return Navigator.push(context, PageTransition(child: page, type: animation));
}

void nextScreenReplace(context, page, PageTransitionType animation) {
  Navigator.pushReplacement(
      context, PageTransition(child: page, type: animation));
}

heroNextScreen(context, page) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
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

final textInputDecoration = InputDecoration(
  hintStyle: GoogleFonts.inter(
      color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w300),
  contentPadding: const EdgeInsets.symmetric(vertical: 15),
  enabledBorder: const UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 1.5),
  ),
  focusedBorder: const UnderlineInputBorder(
    borderSide: BorderSide(color: Constants.lapisLazuli, width: 2.0),
  ),
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

getMarkerText(MarkerType markerType) {
  switch (markerType) {
    case MarkerType.info:
      return Constants.interestMarkerText;
    case MarkerType.rest:
      return Constants.restMarkerText;
    case MarkerType.warning:
      return Constants.warningMarkerText;
    case MarkerType.custom:
      return Constants.customMarkerText;
    default:
      return Constants.interestMarkerText;
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

  return await _picker.pickImage(source: ImageSource.camera, imageQuality: 65);
}

void showFullscreenImage(BuildContext context, String imagePath) {
  showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                imagePath.contains("https://") || imagePath.contains("http://")
                    ? CachedNetworkImage(imageUrl: imagePath)
                    : Image.file(File(imagePath)),
          ),
        );
      });
}

Future<Position> getCurrentPosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('La ubicación no está activada');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Permisos de ubicación denegados');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Permisos de ubicación denegados permanentemente, no se pueden solicitar los permisos.');
  }

  return await Geolocator.getCurrentPosition();
}
