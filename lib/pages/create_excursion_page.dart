import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/widgets/participant_avatar.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateExcursionPage extends StatefulWidget {
  const CreateExcursionPage({super.key});

  @override
  State<CreateExcursionPage> createState() => _CreateExcursionPageState();
}

class _CreateExcursionPageState extends State<CreateExcursionPage> {
  List<UserModel> _participants = [];

  UserController _userController = UserController();

  _initializeParticipants() async {
    UserModel currentUser = await _userController.getUserBasicInfo();
    setState(() {
      _participants.add(currentUser);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeParticipants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear excursión",
            style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFAFAFA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Añadir participantes...',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Constants.indigoDye)),
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 28, color: Constants.indigoDye),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Participantes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),

                //TODO: Add the participants avatars
                // Horizontal list of participants
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _participants.length,
                    itemBuilder: (context, index) {
                      return ParticipantAvatar(
                        user: _participants[index],
                        onDelete: () {
                          setState(() {
                            _participants.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
