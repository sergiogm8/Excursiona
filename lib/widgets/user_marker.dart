import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:flutter/material.dart';

class UserMarker extends StatelessWidget {
  const UserMarker({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      width: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Constants.darkWhite,
            ),
            child: user.profilePic.isEmpty
                ? MediaQuery(
                    data: new MediaQueryData(),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: AccountAvatar(radius: 25, name: user.name),
                    ),
                  )
                : MediaQuery(
                    data: new MediaQueryData(),
                    child: CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            CachedNetworkImageProvider(user.profilePic)),
                  ),
          ),
          const Align(
              alignment: Alignment.bottomCenter,
              child: Icon(Icons.arrow_drop_down,
                  color: Constants.darkWhite, size: 36)),
        ],
      ),
    );
  }
}
