import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Constants {
  static const Color indigoDye = Color(0xFF004C6D);
  static const Color lapisLazuli = Color(0xFF05668D);
  static const Color steelBlue = Color(0xFF4B89B6);
  static const Color redColor = Color(0xFFFF4848);
  static const Color aliceBlue = Color(0xFFEBF2FA);
  static const Color darkWhite = Color(0xFFFAFAFA);

  static const Color warningMarkerColor = Color(0xFFFFEA7E);
  static const Color interestMarkerColor = Color(0xFFDBF0FF);
  static const Color restMarkerColor = Color(0xFFE8FFA5);
  static const Color customMarkerColor = Color(0xFFE2CCFF);

  static const Color lightChatColor = Color.fromARGB(255, 255, 210, 210);
  static const Color darkGrey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFE0E0E0);

  static const IconData warningMarkerIcon = Icons.warning_rounded;
  static const IconData restMarkerIcon = MdiIcons.bed;
  static const IconData interestMarkerIcon = Icons.info_rounded;
  static const IconData customMarkerIcon = MdiIcons.flagVariant;

  static const String warningMarkerText = 'Zona de peligro';
  static const String restMarkerText = 'Zona de descanso';
  static const String interestMarkerText = 'Punto de interés';
  static const String customMarkerText = 'Punto personalizado';

  static const String openWeatherMapKey = "cf7d04d95242f493cc2da8f6ea4af65d";

  static const List<BoxShadow> boxShadow = [
    BoxShadow(
      color: Colors.black12,
      offset: Offset(0, 2),
      blurRadius: 6.0,
    ),
  ];

  static Border border = Border.all(color: Colors.grey[300]!, width: 2);
}
