import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/model/marker_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MarkerInfoSheet extends StatelessWidget {
  final MarkerModel markerModel;
  const MarkerInfoSheet({
    required this.markerModel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Constants.lightGrey,
                border: Border.all(
                  color: Constants.indigoDye,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: markerModel.imageUrl!.isNotEmpty
                  ? GestureDetector(
                      onTap: () =>
                          showFullscreenImage(context, markerModel.imageUrl!),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: markerModel.imageUrl!,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            placeholder: (context, url) => const Loader(),
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
                          const Positioned(
                              bottom: 10,
                              right: 10,
                              child: Icon(MdiIcons.arrowExpandAll,
                                  color: Constants.darkWhite))
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 50,
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
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                getIconByMarkerType(markerModel.markerType),
                color: Constants.indigoDye,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                markerModel.title!,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                "Coordenadas: ${markerModel.position.latitude}${markerModel.position.longitude}",
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Constants.darkGrey),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Constants.indigoDye),
                    child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.transparent,
                        backgroundImage: markerModel.ownerPic!.isNotEmpty
                            ? CachedNetworkImageProvider(markerModel.ownerPic!)
                            : null,
                        child: markerModel.ownerPic!.isEmpty
                            ? AccountAvatar(
                                radius: 20, name: markerModel.ownerName!)
                            : null),
                  ),
                  const SizedBox(width: 15),
                  Text(
                      isCurrentUser(markerModel.userId)
                          ? 'Tú'
                          : getNameAbbreviation(markerModel.ownerName!),
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Constants.indigoDye))
                ],
              )),
              Text(
                DateFormat('HH:mm').format(markerModel.timestamp),
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Constants.indigoDye),
              )
            ],
          )
        ],
      ),
    );
  }
}
