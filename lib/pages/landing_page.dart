import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/invitation.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/widgets/excursion_invitation_card.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Stream<List<Invitation>> _getExcursionNotifications() {
    return UserController().getExcursionInvitations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          bottom: MediaQuery.of(context).size.height * 0.3,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.3, 0.8],
                colors: [
                  Constants.indigoDye,
                  Color.fromARGB(255, 0, 120, 118),
                ],
              ),
            ),
            child: Center(
              child: Text("Landing Page"),
            ),
          ),
        ),
        Positioned.fill(
            child: DraggableScrollableSheet(
                minChildSize: 0.4,
                maxChildSize: 0.85,
                initialChildSize: 0.4,
                builder: (context, scrollController) {
                  return Container(
                      decoration: BoxDecoration(
                        color: Constants.darkWhite,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    height: 5,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Notificaciones",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              StreamBuilder(
                                stream: _getExcursionNotifications(),
                                builder: (context, snapshot) {
                                  if (snapshot.data == null) {
                                    return const Loader();
                                  }
                                  return snapshot.data!.isNotEmpty
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: snapshot.data!.length,
                                          itemBuilder: (context, index) {
                                            return ExcursionInvitationCard(
                                              invitation: snapshot.data![index],
                                            );
                                          },
                                        )
                                      : const Align(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              "No hay notificaciones recientes",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ));
                                },
                              )
                            ],
                          ),
                        ),
                      ));
                }))
      ]),
    );
  }
}
