import 'package:excursiona/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

class UserGalleryPage extends StatefulWidget {
  const UserGalleryPage({super.key});

  @override
  State<UserGalleryPage> createState() => _UserGalleryPageState();
}

class _UserGalleryPageState extends State<UserGalleryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tu galería de imágenes",
          style: GoogleFonts.inter(),
        ),
        backgroundColor: Constants.indigoDye,
        foregroundColor: Colors.white,
      ),
    );
  }
}
