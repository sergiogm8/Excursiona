import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  Reference _storage = FirebaseStorage.instance.ref();

  uploadMarkerImage(
      {required File image,
      required String excursionId,
      required String title}) async {
    String fileName = "${title.trim()}_${const Uuid().v1()}";
    Reference referenceDirImages = _storage.child('images');
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
