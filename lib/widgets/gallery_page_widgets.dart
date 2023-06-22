import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/model/image_model.dart';
import 'package:excursiona/model/marker_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SharedImageCard extends StatelessWidget {
  final ImageModel data;
  const SharedImageCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Constants.border,
          color: Colors.white,
          boxShadow: Constants.boxShadow),
      child: GestureDetector(
        onTap: () => showFullscreenImage(context, data.imageUrl),
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
          border: Constants.border,
          color: Colors.white,
          boxShadow: Constants.boxShadow),
      height: 200,
      child: Row(mainAxisSize: MainAxisSize.max, children: [
        Expanded(
          flex: 5,
          child: marker.imageUrl!.isNotEmpty
              ? GestureDetector(
                  onTap: () => showFullscreenImage(context, marker.imageUrl!),
                  child: CachedNetworkImage(
                    imageUrl: marker.imageUrl!,
                    placeholder: (context, url) => const Loader(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
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
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Constants.lightGrey,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 30,
                      ),
                      Text(
                        'No hay imagen asociada',
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
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
