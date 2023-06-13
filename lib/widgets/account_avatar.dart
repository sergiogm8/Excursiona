import 'package:excursiona/shared/constants.dart';
import 'package:flutter/material.dart';

class AccountAvatar extends StatelessWidget {
  final double? radius;
  final double? minRadius;
  final double? maxRadius;
  final String name;
  const AccountAvatar(
      {super.key,
      this.radius,
      required this.name,
      this.minRadius,
      this.maxRadius})
      : assert(radius == null || (minRadius == null && maxRadius == null));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Constants.darkWhite, shape: BoxShape.circle),
      child: CircleAvatar(
        radius: radius,
        minRadius: minRadius,
        maxRadius: maxRadius,
        backgroundColor: Constants.indigoDye.withOpacity(0.1),
        child: Text(
          _getInitials(),
          style: TextStyle(
            color: Constants.indigoDye,
            fontSize: radius != null ? radius! * 0.85 : maxRadius! * 0.85,
          ),
        ),
      ),
    );
  }

  _getInitials() {
    return name.split(' ').length > 1
        ? name.split(' ')[0][0] + name.split(' ')[1][0]
        : name.substring(0, 2);
  }
}
