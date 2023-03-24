import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class AddParticipantAvatar extends StatelessWidget {
  final Color color = Constants.lapisLazuli;
  final VoidCallback onTap;

  const AddParticipantAvatar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: SizedBox(
          height: 60,
          width: 80,
          child: IconButton(
            padding: const EdgeInsets.all(0),
            color: color,
            onPressed: onTap,
            icon: Column(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Añadir participante",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                  ),
                )
              ],
            ),
            // child: Container(
            //   margin: const EdgeInsets.only(bottom: 17),
            //   width: 60,
            //   height: 60,
            //   decoration: const BoxDecoration(
            //       color: Color.fromARGB(169, 158, 158, 158),
            //       shape: BoxShape.circle,
            //       // Dotted border
            //       // border: Border.fromBorderSide(BorderSide(
            //       //   color: Color.fromARGB(255, 158, 158, 158),
            //       //   width: 1,
            //       //   style: BorderStyle.,
            //       // ))),
            //   ),
            //   child: const Icon(
            //     Icons.add,
            //     size: 30,
            //     color: Colors.white,
            //   ),
            // ),
          )),
    );
  }
}
