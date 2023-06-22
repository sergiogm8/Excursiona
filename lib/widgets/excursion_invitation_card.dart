import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/pages/excursion_page.dart';
import 'package:excursiona/services/user_service.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class ExcursionInvitationCard extends StatelessWidget {
  final Excursion excursion;
  const ExcursionInvitationCard({super.key, required this.excursion});

  _acceptInvitation(context) async {
    var result = await ExcursionController().joinExcursion(excursion.id);
    if (!result) {
      showSnackBar(
          context, Colors.red, "Hubo un error al aceptar la invitación");
    }
    await ExcursionController().saveExcursionSession(excursion.id);
    nextScreen(
        context,
        ExcursionPage(excursionId: excursion.id, excursion: excursion),
        PageTransitionType.fade);
    UserController().deleteExcursionInvitation(excursion.id);
  }

  _rejectInvitation(context) async {
    var result =
        await ExcursionController().rejectExcursionInvitation(excursion.id);
    if (!result) {
      showSnackBar(
          context, Colors.red, "Hubo un error al rechazar la invitación");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Constants.border,
        boxShadow: Constants.boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 15),
                child: excursion.ownerPic.isEmpty
                    ? AccountAvatar(radius: 25, name: excursion.ownerName)
                    : CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            CachedNetworkImageProvider(excursion.ownerPic),
                      ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      excursion.ownerName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Te ha invitado a: ',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: excursion.title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // const SizedBox(height: 15),
          if (excursion.description.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 5),
              child: Text(
                excursion.description,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          const SizedBox(height: 8),
          RichText(
              text: TextSpan(children: [
            TextSpan(
              text: 'Dificultad: ',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: excursion.difficulty,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ])),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => _rejectInvitation(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  fixedSize: const Size(105, 30),
                  side: const BorderSide(color: Colors.black, width: 1),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: Text('Rechazar',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              ElevatedButton(
                onPressed: () => _acceptInvitation(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  fixedSize: const Size(105, 30),
                  backgroundColor: Constants.indigoDye,
                  foregroundColor: Colors.white,
                ),
                child: Text('Aceptar',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
