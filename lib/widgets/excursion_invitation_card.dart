import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/model/invitation.dart';
import 'package:excursiona/pages/excursion_page.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';

class ExcursionInvitationCard extends StatelessWidget {
  final Invitation invitation;
  const ExcursionInvitationCard({super.key, required this.invitation});

  _acceptInvitation(context) async {
    var result =
        await ExcursionController().joinExcursion(invitation.excursionId);
    if (!result) {
      showSnackBar(
          context, Colors.red, "Hubo un error al aceptar la invitación");
    }
    nextScreen(context, ExcursionPage(excursionId: invitation.excursionId),
        PageTransitionType.fade);
  }

  _rejectInvitation(context) async {
    var result = await ExcursionController()
        .rejectExcursionInvitation(invitation.excursionId);
    if (!result) {
      showSnackBar(
          context, Colors.red, "Hubo un error al rechazar la invitación");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Text("Nombre: ${invitation.excursionTitle}"),
          Text("Id: ${invitation.excursionId}"),
          ElevatedButton(
              onPressed: () => _acceptInvitation(context),
              child: Text("Aceptar")),
          ElevatedButton(
              onPressed: () => _rejectInvitation(context),
              child: Text("Rechazar")),
        ],
      ),
    );
  }
}
