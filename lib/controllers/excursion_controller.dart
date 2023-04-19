import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/excursion_participant.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/excursion_service.dart';
import 'package:geolocator/geolocator.dart';

class ExcursionController {
  final ExcursionService _excursionService = ExcursionService();

  Future createExcursion(
      Excursion excursion, Set<UserModel> participants) async {
    bool result = false;
    result = await _excursionService.createExcursion(
        excursion, await UserController().getUserBasicInfo());
    if (!result) return 'Hubo un error al crear la excursión';

    result =
        await _excursionService.inviteUsersToExcursion(excursion, participants);
    if (!result) return 'Hubo un error al enviar las invitaciones';

    return result;
  }

  Future<bool> leaveExcursion(String excursionID) async {
    return await _excursionService.leaveExcursion(excursionID);
  }

  Future<bool> joinExcursion(String excursionID) async {
    return await _excursionService.joinExcursion(
        excursionID, await UserController().getUserBasicInfo());
  }

  Future<bool> inviteUserToExcursion(Excursion excursion, String userId) async {
    return await _excursionService.inviteUserToExcursion(excursion, userId);
  }

  Future<bool> rejectExcursionInvitation(String excursionId) async {
    return await _excursionService.rejectExcursionInvitation(excursionId);
  }

  Future<bool> deleteUserFromExcursion(
      String excursionId, String userId) async {
    return await _excursionService.deleteUserFromExcursion(excursionId, userId);
  }

  Future getParticipantsData(String excursionId) async {
    List<UserModel> participants = [];
    await _excursionService.getParticipantsData(excursionId).then((query) {
      for (var participant in query) {
        participants
            .add(UserModel.fromMap(participant.data() as Map<String, dynamic>));
      }
    });
    return participants;
  }

  List<Excursion>? getUserExcursions() {
    //TODO: Review later with the method of the service
    List<Excursion>? excursions = [];
    _excursionService.getUserExcursions().then((excursionsQuery) {
      for (var excursion in excursionsQuery) {
        excursions
            ?.add(Excursion.fromMap(excursion.data() as Map<String, dynamic>));
      }
    }).catchError((error) {
      excursions = null;
    });
    return excursions;
  }

  shareCurrentLocation(Position coords, String excursionId) async {
    await _excursionService.shareCurrentLocation(coords, excursionId);
  }

  Stream<List<ExcursionParticipant>> getOthersLocation(String excursionId) {
    return _excursionService.getOthersLocation(excursionId);
  }
}
