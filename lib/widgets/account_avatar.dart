import 'package:excursiona/shared/constants.dart';
import 'package:flutter/material.dart';

class AccountAvatar extends StatelessWidget {
  final double radius;
  final String name;
  const AccountAvatar({super.key, required this.radius, required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Constants.indigoDye.withOpacity(0.1),
      child: Text(
        _getInitials(),
        style: TextStyle(
          color: Constants.indigoDye,
          fontSize: radius * 0.85,
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
