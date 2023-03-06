import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ExcursionService {
  final CollectionReference excursionCollection =
      FirebaseFirestore.instance.collection('excursions');

  Future createExcursion() async {
    var excursionID = const Uuid().v4();
    excursionCollection.doc(excursionID).set({'id': excursionID}).then((value) {
      excursionCollection
          .doc(excursionID)
          .collection('participants')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({'uid': FirebaseAuth.instance.currentUser?.uid});
    }).onError((error, stackTrace) {
      return;
    });
    return excursionID;
  }

  Future joinExcursion(String excursionID) async {
    var excursion = excursionCollection.doc(excursionID);
    excursion
        .collection('participants')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set({'uid': FirebaseAuth.instance.currentUser?.uid}).onError(
            (error, stackTrace) {
      return;
    });
    return true;
  }
}
