import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/enums/marker_type.dart';
import 'package:excursiona/model/image_model.dart';
import 'package:excursiona/model/marker_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/widgets/gallery_page_widgets.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExcImageGalleryPage extends StatefulWidget {
  final ExcursionController excursionController;
  const ExcImageGalleryPage({super.key, required this.excursionController});

  @override
  State<ExcImageGalleryPage> createState() => _ExcImageGalleryPageState();
}

class _ExcImageGalleryPageState extends State<ExcImageGalleryPage> {
  ExcursionController get _excursionController => widget.excursionController;

  Stream<List<ImageModel>> _getImagesFromExcursion() {
    return _excursionController.getImagesFromExcursion();
  }

  Stream<List<MarkerModel>> _getMarkers() {
    return _excursionController.getMarkers().map((markerList) =>
        markerList.where((marker) => _hasImage(marker)).toList());
  }

  _hasImage(MarkerModel marker) {
    return marker.imageUrl!.isNotEmpty &&
        marker.markerType != MarkerType.participant;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Galería de imágenes", style: GoogleFonts.inter()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Constants.darkWhite,
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Imágenes compartidas",
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                StreamBuilder(
                  stream: _getImagesFromExcursion(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return const Loader();
                    }
                    return snapshot.data!.isNotEmpty
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.6),
                            itemBuilder: (context, index) {
                              return SharedImageCard(
                                data: snapshot.data![index],
                              );
                            },
                          )
                        : const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "No se han compartido imágenes aún",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ));
                  },
                ),
                const SizedBox(height: 28),
                Text("Imágenes de marcadores",
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                StreamBuilder(
                  stream: _getMarkers(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return const Loader();
                    }
                    return snapshot.data != null && snapshot.data!.isNotEmpty
                        ? Column(children: [
                            for (var marker in snapshot.data!)
                              MarkerImageCard(marker: marker)
                          ])
                        : const Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "No hay marcadores con imagen aún",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                  },
                )
              ],
            ),
          )),
    );
  }
}
