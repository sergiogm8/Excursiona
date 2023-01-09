import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final String hintText;
  final IconData icon;

  const TextInput({super.key, required this.hintText, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 38),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 1),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                color: const Color.fromARGB(255, 255, 153, 153), width: 2)),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: TextField(
            style: const TextStyle(fontSize: 18),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              prefixIcon:
                  Icon(icon, color: const Color.fromARGB(255, 255, 98, 98)),
              //tamaño de letra 16
            ),
          ),
        ),
      ),
    );
  }
}
