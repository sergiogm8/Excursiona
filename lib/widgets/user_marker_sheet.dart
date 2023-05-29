import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/model/marker_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class UserMarkerSheet extends StatelessWidget {
  final MarkerModel markerModel;
  const UserMarkerSheet({super.key, required this.markerModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Constants.indigoDye,
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey,
                  //     spreadRadius: 1,
                  //     blurRadius: 5,
                  //     offset: Offset(2, 3),
                  //   ),
                  // ],
                ),
                child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.transparent,
                    backgroundImage: markerModel.ownerPic!.isNotEmpty
                        ? CachedNetworkImageProvider(markerModel.ownerPic!)
                        : null,
                    child: markerModel.ownerPic!.isEmpty
                        ? AccountAvatar(
                            radius: 30, name: markerModel.ownerName!)
                        : null),
              ),
              const SizedBox(width: 15),
              Text(markerModel.ownerName!,
                  style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Constants.indigoDye)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InfoItem(
                icon: MdiIcons.runFast,
                title: "Velocidad:",
                content: "${(markerModel.speed!).toStringAsFixed(1)} km/h",
              ),
              const SizedBox(width: 40),
              InfoItem(
                icon: MdiIcons.arrowUpDown,
                title: "Altitud:",
                content: "${(markerModel.altitude!).toStringAsFixed(0)} m",
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InfoItem(
                icon: MdiIcons.mapMarkerDistance,
                title: "Ha recorrido:",
                content: "${(markerModel.distance!).toStringAsFixed(1)} km",
              ),
              const SizedBox(width: 40),
              InfoItem(
                icon: MdiIcons.battery,
                title: "Batería:",
                content: "${(markerModel.batteryLevel!).toString()}%",
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Última ubicación: ${markerModel.position.latitude.toString()}, ${markerModel.position.latitude.toString()}',
                style: GoogleFonts.inter(
                    color: Constants.darkGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const InfoItem(
      {super.key,
      required this.icon,
      required this.title,
      required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Constants.lapisLazuli,
            size: 28,
          ),
          const SizedBox(width: 10),
          Row(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  content,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ]);
  }
}
