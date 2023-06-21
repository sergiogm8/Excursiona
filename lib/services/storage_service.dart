import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  Reference referenceDirImages = FirebaseStorage.instance.ref().child('images');
  Reference referenceDirAudios = FirebaseStorage.instance.ref().child('audios');
  final String excursionsFolder = 'excursions';
  final String profilePicsFolder = 'profile_pics';
  final String userPicsFolder = 'user_pics';
  final String mapSnapshotsFolder = 'map_snapshots';

  uploadMarkerImage(
      {required File image,
      required String excursionId,
      required String title}) async {
    String fileName = "${title.trim()}_${const Uuid().v1()}";
    Reference referenceDirExcursion =
        referenceDirImages.child(excursionsFolder).child(excursionId);
    Reference referenceUploadImage = referenceDirExcursion.child(fileName);

    try {
      await referenceUploadImage.putFile(image);
      return await referenceUploadImage.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  uploadExcursionImage(
      {required File image, required String excursionId}) async {
    String fileName = const Uuid().v1();
    Reference referenceDirExcursion =
        referenceDirImages.child(excursionsFolder).child(excursionId);
    Reference referenceUploadImage = referenceDirExcursion.child(fileName);

    try {
      await referenceUploadImage.putFile(image);
      return await referenceUploadImage.getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  uploadAudioFile({required File audio, required String excursionId}) async {
    String fileName = const Uuid().v4() + ".aac";
    Reference referenceDirExcursion =
        referenceDirAudios.child(excursionsFolder).child(excursionId);
    Reference referenceUploadAudio = referenceDirExcursion.child(fileName);

    try {
      await referenceUploadAudio.putFile(audio);
      var path = await referenceUploadAudio.getDownloadURL();
      return path;
    } catch (e) {
      return '';
    }
  }

  getNumberOfImages(String excursionId) async {
    Reference referenceDirExcursion =
        referenceDirImages.child(excursionsFolder).child(excursionId);
    try {
      var list = await referenceDirExcursion.listAll();
      return list.items.length;
    } catch (e) {
      return 0;
    }
  }

  uploadMapSnapshot(String excursionId, File mapSnapshot, String userId) async {
    Reference referenceDirUserMapImages =
        referenceDirImages.child(mapSnapshotsFolder);
    final fileName = '${excursionId}_${userId}';
    Reference referenceUploadImage = referenceDirUserMapImages.child(fileName);
    try {
      await referenceUploadImage.putFile(mapSnapshot);
      return await referenceUploadImage.getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  uploadProfilePic(File profilePic, String userId) async {
    Reference referenceDirUserPics =
        referenceDirImages.child(profilePicsFolder);
    final fileName = userId;
    Reference referenceUploadImage = referenceDirUserPics.child(fileName);
    try {
      await referenceUploadImage.putFile(profilePic);
      return await referenceUploadImage.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}
