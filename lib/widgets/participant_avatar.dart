import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class ParticipantAvatar extends StatelessWidget {
  final UserModel user;

  const ParticipantAvatar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          user.profilePic.isNotEmpty
              ? CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(user.profilePic),
                )
              : Icon(
                  Icons.account_circle,
                  size: 60,
                  color: Colors.grey[600],
                ),
          Text(
            AuthController().isCurrentUser(uid: user.uid)
                ? 'Tú'
                // Get the user's name and the first letter of the second word,
                // if there is one
                : _getNameAbbreviation(),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _getNameAbbreviation() {
    return user.name.split(' ').length > 1
        ? '${user.name.split(' ')[0]} ${user.name.split(' ')[1][0]}.'
        : user.name;
  }
}
