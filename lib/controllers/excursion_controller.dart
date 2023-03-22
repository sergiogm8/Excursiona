import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/services/excursion_service.dart';

class ExcursionController {
  final ExcursionService _excursionService = ExcursionService();

  Future createExcursion() async {
    return await _excursionService.createExcursion();
  }

  Future<bool> leaveExcursion(String excursionID) async {
    return await _excursionService.leaveExcursion(excursionID);
  }

  Future<bool> joinExcursion(String excursionID) async {
    return await _excursionService.joinExcursion(excursionID);
  }

  Future<bool> inviteUserToExcursion(
      String excursionId, String userId, String name) async {
    return await _excursionService.inviteUserToExcursion(
        excursionId, userId, name);
  }

  Future<bool> rejectExcursionInvitation(String excursionId) async {
    return await _excursionService.rejectExcursionInvitation(excursionId);
  }

  Future<bool> deleteUserFromExcursion(
      String excursionId, String userId) async {
    return await _excursionService.deleteUserFromExcursion(excursionId, userId);
  }

  List<Excursion>? getUserExcursions() {
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
}
