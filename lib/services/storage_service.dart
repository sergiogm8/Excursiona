import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  Reference referenceDirImages = FirebaseStorage.instance.ref().child('images');
  Reference referenceDirAudios = FirebaseStorage.instance.ref().child('audios');
  final String excursionsFolder = 'excursions';
  final String profilePicsFolder = 'profile_pics';

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
    } on FirebaseException {
      return '';
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
    } on FirebaseException {
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
      print(path);
      return path;
    } on FirebaseException {
      return '';
    }
  }
}
