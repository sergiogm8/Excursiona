import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class ParticipantAvatar extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDelete;

  const ParticipantAvatar(
      {super.key, required this.user, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            user.profilePic.isNotEmpty
                ? CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        CachedNetworkImageProvider(user.profilePic),
                    child: !AuthController().isCurrentUser(uid: user.uid)
                        ? Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: onDelete,
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : null,
                  )
                : CircleAvatar(
                    radius: 25,
                    foregroundColor: Colors.grey,
                    backgroundColor: Colors.transparent,
                    child: !AuthController().isCurrentUser(uid: user.uid)
                        ? Stack(
                            children: [
                              AccountAvatar(
                                radius: 25,
                                name: user.name,
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: onDelete,
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : AccountAvatar(radius: 25, name: user.name)),
            const SizedBox(height: 5),
            Text(
              AuthController().isCurrentUser(uid: user.uid)
                  ? 'Tú'
                  : _getNameAbbreviation(),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getNameAbbreviation() {
    // Get the user's name and the first letter of the second word,
    // if there is one
    return user.name.split(' ').length > 1
        ? '${user.name.split(' ')[0]} ${user.name.split(' ')[1][0]}.'
        : user.name;
  }
}
