import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  Reference referenceDirImages = FirebaseStorage.instance.ref().child('images');

  uploadMarkerImage(
      {required File image,
      required String excursionId,
      required String title}) async {
    String fileName = "${title.trim()}_${const Uuid().v1()}";
    Reference referenceDirExcursion = referenceDirImages.child(excursionId);
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
    String fileName = "${const Uuid().v1()}";
    Reference referenceDirExcursion = referenceDirImages.child(excursionId);
    Reference referenceUploadImage = referenceDirExcursion.child(fileName);

    try {
      await referenceUploadImage.putFile(image);
      return await referenceUploadImage.getDownloadURL();
    } on FirebaseException {
      return '';
    }
  }
}
