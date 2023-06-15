import 'dart:io';

import 'package:banner_carousel/banner_carousel.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ShareImagePage extends StatefulWidget {
  final ExcursionController excursionController;
  const ShareImagePage({super.key, required this.excursionController});

  @override
  State<ShareImagePage> createState() => _ShareImagePageState();
}

class _ShareImagePageState extends State<ShareImagePage> {
  final List<XFile> _images = [];
  ExcursionController get _excursionController => widget.excursionController;

  @override
  void initState() {
    super.initState();
  }

  _addImage() async {
    PermissionStatus cameraPermissions = await Permission.camera.request();
    if (cameraPermissions.isGranted) {
      var image = await pickImageFromCamera();
      if (image != null) {
        setState(() {
          _images.add(image);
        });
      }
    } else {
      showSnackBar(context, Colors.red,
          "Es necesario dar permisos de cámara para poder tomar una foto");
    }
  }

  _uploadImages() async {
    if (_images.isEmpty) {
      showSnackBar(context, Colors.red, "No hay imágenes para subir");
      return;
    }
    showDialog(
      barrierColor: Constants.darkWhite.withOpacity(0.9),
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Loader(),
              const SizedBox(height: 20),
              Text("Subiendo imágenes...",
                  style: GoogleFonts.inter(
                      fontSize: 24, fontWeight: FontWeight.w400)),
            ]),
          ),
        );
      },
    );
    try {
      await _excursionController.uploadImages(_images);
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      showSnackBar(context, Colors.red, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compartir imágenes', style: GoogleFonts.inter()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.indigoDye,
        child: const Icon(Icons.upload_rounded, size: 28),
        onPressed: () => _uploadImages(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: _images.isNotEmpty
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              if (_images.isNotEmpty)
                BannerCarousel(
                  height: MediaQuery.of(context).size.height * 0.65,
                  spaceBetween: 20,
                  activeColor: Constants.indigoDye,
                  disableColor: Colors.grey,
                  viewportFraction: 0.90,
                  customizedBanners: [
                    for (var image in _images)
                      GestureDetector(
                        onTap: () => showFullscreenImage(context, image.path),
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: FileImage(File(image.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                    icon: Icon(Icons.cancel),
                                    iconSize: 32,
                                    color: Colors.red,
                                    onPressed: () {
                                      setState(() {
                                        _images.remove(image);
                                      });
                                      setState(() {});
                                    })),
                          ],
                        ),
                      )
                  ],
                ),
              if (_images.isNotEmpty) const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => _addImage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.indigoDye,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_a_photo_rounded,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Añadir imagen",
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
