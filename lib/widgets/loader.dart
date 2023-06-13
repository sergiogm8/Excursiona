import 'package:excursiona/shared/constants.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final Color? color;
  const Loader({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
        child:
            CircularProgressIndicator(color: color ?? Constants.lapisLazuli));
  }
}
