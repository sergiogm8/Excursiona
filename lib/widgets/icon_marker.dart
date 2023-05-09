import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';

class IconMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  const IconMarker({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      width: 75,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: DecoratedIcon(
                icon: Icon(icon, color: color, size: 46),
                decoration: IconDecoration(border: IconBorder(width: 2))),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: DecoratedIcon(
                  icon: Icon(Icons.arrow_drop_down, color: color, size: 38),
                  decoration: IconDecoration(border: IconBorder(width: 2)))),
        ],
      ),
    );
  }
}
