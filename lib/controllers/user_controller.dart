import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excursiona/helper/helper_functions.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/recap_models.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/excursion_service.dart';
import 'package:excursiona/services/user_service.dart';

class UserController {
  final UserService _userService = UserService();

  var _lastDocumentFetched = null;

  Future<UserModel> getUserBasicInfo() async {
    var name = await HelperFunctions.getUserName();
    var profilePic = await HelperFunctions.getUserProfilePic();
    var uid = await HelperFunctions.getUserUID();
    return UserModel(name: name!, profilePic: profilePic!, uid: uid!);
  }

  Future<List<UserModel>> getAllUsersBasicInfo(String name) async {
    return await _userService.getAllUsersBasicInfo(name);
  }

  Stream<List<Excursion>> getExcursionInvitations() {
    return _userService.getExcursionInvitations();
  }

  deleteExcursionInvitation(String invitationId) {
    _userService.deleteExcursionInvitation(invitationId);
  }

  saveExcursion(ExcursionRecap excursion, File mapSnapshot) async {
    try {
      await _userService.saveExcursion(excursion, mapSnapshot);
    } catch (e) {
      throw Exception(
          "Hubo un error al guardar la excursión en el sistema: $e");
    }
  }

  Future<List<ExcursionRecap>> getUserExcursions(int docsLimit) async {
    List<ExcursionRecap> excursions = [];
    try {
      var docs =
          await _userService.getUserExcursions(docsLimit, _lastDocumentFetched);
      docs.forEach((e) {
        excursions
            .add(ExcursionRecap.fromMap(e.data() as Map<String, dynamic>));
      });
      _lastDocumentFetched = docs.last;
      return excursions;
    } catch (e) {
      if (e.toString().contains("Bad state: No element")) {
        return [];
      }
      throw Exception("Hubo un error al obtener las excursiones: $e");
    }
  }
}
