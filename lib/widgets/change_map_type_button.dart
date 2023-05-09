import 'package:excursiona/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTypeButton extends StatelessWidget {
  const MapTypeButton(
      {super.key,
      required this.selectedMapType,
      required this.onTap,
      required this.mapType,
      required this.icon,
      required this.label});

  final IconData icon;
  final String label;
  final MapType mapType;
  final Function onTap;
  final MapType selectedMapType;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(mapType),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(
                color: selectedMapType == mapType
                    ? Constants.steelBlue
                    : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: selectedMapType == mapType
                ? Constants.lapisLazuli
                : Colors.white),
        width: 85,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 30,
                color: selectedMapType == mapType ? Colors.white : Colors.black,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: selectedMapType == mapType
                        ? Colors.white
                        : Colors.black),
              )
            ]),
      ),
    );
  }
}
