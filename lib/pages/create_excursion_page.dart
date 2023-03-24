import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/pages/search_participants_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/add_participant_avatar.dart';
import 'package:excursiona/widgets/participant_avatar.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

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

  _addParticipant() {
    nextScreen(
        context, const SearchParticipantsPage(), PageTransitionType.fade);
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
                const Text(
                  "Participantes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 120,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _participants.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _participants.length) {
                        return AddParticipantAvatar(onTap: _addParticipant);
                      }
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
