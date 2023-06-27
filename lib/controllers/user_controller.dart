import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excursiona/helper/helper_functions.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/image_model.dart';
import 'package:excursiona/model/recap_models.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/excursion_service.dart';
import 'package:excursiona/services/storage_service.dart';
import 'package:excursiona/services/user_service.dart';
import 'package:screenshot/screenshot.dart';

class UserController {
  final UserService _userService = UserService();

  var _lastDocumentFetched = null;

  Future<UserModel> getUserBasicInfo() async {
    var name = await HelperFunctions.getUserName();
    var profilePic = await HelperFunctions.getUserProfilePic();
    var uid = await HelperFunctions.getUserUID();
    var email = await HelperFunctions.getUserEmail();
    return UserModel(
        name: name!, profilePic: profilePic!, uid: uid!, email: email!);
  }

  Future<UserModel> getUserData() async {
    try {
      return await _userService.getUserData();
    } catch (e) {
      throw Exception("Hubo un error al obtener los datos del usuario: $e");
    }
  }

  Future<List<UserModel>> getAllUsersBasicInfo(String name) async {
    return await _userService.getAllUsersBasicInfo(name);
  }

  Stream<List<Excursion>> getExcursionInvitations() {
    return _userService.getExcursionInvitations();
  }

  deleteExcursionInvitation(String invitationId) async {
    await _userService.deleteExcursionInvitation(invitationId);
  }

  saveExcursion(ExcursionRecap excursion, File mapSnapshot) async {
    try {
      var uid = await HelperFunctions.getUserUID();
      String mapUrl = await StorageService()
          .uploadMapSnapshot(excursion.id, mapSnapshot, uid!);
      if (mapUrl.isNotEmpty) {
        excursion.mapSnapshotUrl = mapUrl;
        try {
          await ExcursionService().saveExcursionToTL(excursion);
        } catch (e) {
          rethrow;
        }
      }
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

  updateProfilePic(String filePath) async {
    try {
      var userId = await HelperFunctions.getUserUID();
      var file = File(filePath);
      var url = await StorageService().uploadProfilePic(file, userId!);
      await _userService.updateProfilePic(url);
      await HelperFunctions.saveUserProfilePic(url);
      return url;
    } catch (e) {
      throw Exception("Hubo un error al actualizar la foto de perfil: $e");
    }
  }

  updateUserPhotos(int nNewPhotos, List<ImageModel> uploadedImages) async {
    try {
      _userService.updateUserPhotos(nNewPhotos, uploadedImages);
    } catch (e) {
      throw Exception("Hubo un error al subir las fotos: $e");
    }
  }

  saveImages(List<ImageModel> images) async {
    try {
      await _userService.saveImages(images);
    } catch (e) {
      throw Exception("Hubo un error al guardar las fotos: $e");
    }
  }

  saveImage(ImageModel image) async {
    try {
      await _userService.saveImage(image);
    } catch (e) {
      throw Exception("Hubo un error al guardar la foto: $e");
    }
  }

  Future<List<ImageModel>> getGalleryImages(int docsLimit) async {
    List<ImageModel> images = [];
    try {
      var docs =
          await _userService.getGalleryImages(docsLimit, _lastDocumentFetched);
      docs.forEach((e) {
        images.add(
            ImageModel.fromMapForGallery(e.data() as Map<String, dynamic>));
      });
      _lastDocumentFetched = docs.last;
      return images;
    } catch (e) {
      if (e.toString().contains("Bad state: No element")) {
        return [];
      }
      throw Exception("Hubo un error al obtener las imágenes: $e");
    }
  }

  updateUserMarkers(int nNewMarkers) async {
    try {
      _userService.updateUserMarkers(nNewMarkers);
    } catch (e) {
      throw Exception(
          "Hubo un error al actualizar la cantidad de marcadores: $e");
    }
  }

  Future getUserPic(String userId) async {
    try {
      return await _userService.getUserPic(userId);
    } catch (e) {
      throw Exception("Hubo un error al obtener la foto de perfil: $e");
    }
  }
}
