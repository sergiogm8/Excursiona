import 'package:excursiona/shared/constants.dart';
import 'package:flutter/material.dart';

class AddParticipantAvatar extends StatelessWidget {
  final Color color = Constants.lapisLazuli;
  final VoidCallback onTap;

  const AddParticipantAvatar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: SizedBox(
        height: 55,
        width: 80,
        child: IconButton(
          padding: const EdgeInsets.all(0),
          color: color,
          onPressed: onTap,
          icon: Column(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 35,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Añadir participantes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
