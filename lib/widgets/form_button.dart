import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String btnText;
  final onTap;
  const FormButton({super.key, required this.btnText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 15),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 98, 98),
              borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: Text(
              btnText,
              style: const TextStyle(
                  fontSize: 24,
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
