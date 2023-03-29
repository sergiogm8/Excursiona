import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  const FormButton(
      {super.key, required this.text, required this.onPressed, this.icon});

  final IconData? icon;
  final onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          fixedSize: Size(MediaQuery.of(context).size.width, 50),
        ),
        child: icon == null
            ? Text(
                text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Icon(icon, size: 30),
                ],
              ));
  }
}
