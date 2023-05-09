import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawerItem extends StatelessWidget {
  const DrawerItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.onTap});

  final IconData icon;
  final Function onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: Colors.black,
          ),
          minLeadingWidth: 0,
          title: Text(title,
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400)),
          onTap: () => onTap(),
        ),
        Divider(
          color: Colors.grey,
          thickness: 0.5,
          endIndent: MediaQuery.of(context).size.width * 0.05,
          indent: MediaQuery.of(context).size.width * 0.05,
          height: 3,
        ),
      ],
    );
  }
}
