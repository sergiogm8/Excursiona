import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/model/user_model.dart';
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
      child: Column(
        children: [
          user.profilePic.isNotEmpty
              ? CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(user.profilePic),
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
              : Icon(
                  Icons.account_circle,
                  size: 60,
                  color: Colors.grey[600],
                ),
          const SizedBox(height: 5),
          Text(
            AuthController().isCurrentUser(uid: user.uid)
                ? 'Tú'
                : _getNameAbbreviation(),
            style: const TextStyle(fontSize: 12),
          ),
        ],
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
