import 'package:banner_carousel/banner_carousel.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ShareImagePage extends StatefulWidget {
  const ShareImagePage({super.key});

  @override
  State<ShareImagePage> createState() => _ShareImagePageState();
}

class _ShareImagePageState extends State<ShareImagePage> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  @override
  void initState() {
    _openCamera();
    super.initState();
  }

  _openCamera() async {
    var image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image == null) {
      Navigator.pop(context);
    }
    setState(() {
      _images.add(image!);
    });
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
        backgroundColor: Constants.lapisLazuli,
        child: const Icon(Icons.upload_rounded, size: 28),
        onPressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: _images.isNotEmpty
            ? Column(
                children: [
                  BannerCarousel(
                    height: MediaQuery.of(context).size.height * 0.65,
                    spaceBetween: 5,
                    activeColor: Constants.indigoDye,
                    disableColor: Colors.grey,
                    onTap: (id) {
                      showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.9),
                          builder: (context) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Image.asset(_images[int.parse(id)].path),
                              ),
                            );
                          });
                    },
                    banners: [
                      for (var image in _images)
                        BannerModel(
                            imagePath: image.path,
                            id: _images.indexOf(image).toString(),
                            boxFit: BoxFit.cover),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () async {
                      final XFile? image = await _picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      image != null
                          ? setState(() {
                              _images.add(image);
                            })
                          : null;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.indigoDye,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
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
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
