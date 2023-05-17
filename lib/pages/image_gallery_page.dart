import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/enums/marker_type.dart';
import 'package:excursiona/model/image_model.dart';
import 'package:excursiona/model/marker_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ImageGalleryPage extends StatefulWidget {
  final ExcursionController excursionController;
  const ImageGalleryPage({super.key, required this.excursionController});

  @override
  State<ImageGalleryPage> createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
  ExcursionController get _excursionController => widget.excursionController;

  Stream<List<ImageModel>> _getImagesFromExcursion() {
    return _excursionController.getImagesFromExcursion();
  }

  Stream<List<MarkerModel>> _getMarkers() {
    /// I need to filter this stream _excursionController.getMarkers() to only return markers that are not
    /// of type MarkerType.participant and those that have an imageUrl
    ///
    ///
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

class SharedImageCard extends StatelessWidget {
  final ImageModel data;
  const SharedImageCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Constants.indigoDye, width: 1),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(2, 3),
          )
        ],
      ),
      // height: 250,
      child: GestureDetector(
        onTap: () => showFullscreenImage(
            context, data.imageUrl), //TODO: Implementar vista de imagen
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: data.imageUrl,
                placeholder: (context, url) => const Loader(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            // const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Row(
                    children: [
                      data.ownerPic.isEmpty
                          ? AccountAvatar(radius: 14, name: data.ownerName)
                          : CircleAvatar(
                              backgroundImage: NetworkImage(data.ownerPic),
                              radius: 14,
                            ),
                      const SizedBox(width: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isCurrentUser(data.ownerId)
                              ? 'Tú'
                              : getNameAbbreviation(data.ownerName),
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Constants.indigoDye),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      DateFormat("HH:mm").format(data.timestamp),
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Constants.darkGrey),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MarkerImageCard extends StatelessWidget {
  final MarkerModel marker;
  const MarkerImageCard({super.key, required this.marker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Constants.indigoDye, width: 1),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(2, 3),
          )
        ],
      ),
      height: 200,
      child: Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: () => showFullscreenImage(context, marker.imageUrl!),
            child: CachedNetworkImage(
              imageUrl: marker.imageUrl!,
              placeholder: (context, url) => const Loader(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              imageBuilder: (context, imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(marker.title!,
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        getIconByMarkerType(marker.markerType),
                        color: Constants.lapisLazuli,
                        size: 28,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        getMarkerText(marker.markerType),
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Constants.darkGrey),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                    "Coordenadas: ${marker.position.latitude}, ${marker.position.longitude}",
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Constants.darkGrey)),
                const SizedBox(height: 14),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        marker.ownerPic!.isEmpty
                            ? AccountAvatar(radius: 14, name: marker.ownerName!)
                            : CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    marker.ownerPic!),
                                radius: 14,
                              ),
                        const SizedBox(width: 8),
                        Text(
                            isCurrentUser(marker.userId)
                                ? 'Tú'
                                : getNameAbbreviation(marker.ownerName!),
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Constants.indigoDye)),
                      ],
                    ),
                    Text(
                      DateFormat("HH:mm").format(marker.timestamp).toString(),
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Constants.darkGrey),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ]),
    );
  }
}
