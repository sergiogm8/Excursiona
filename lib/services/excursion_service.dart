import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ExcursionService {
  final CollectionReference excursionCollection =
      FirebaseFirestore.instance.collection('excursions');

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future createExcursion() async {
    try {
      var excursionID = const Uuid().v4();
      await excursionCollection
          .doc(excursionID)
          .set({'id': excursionID}).then((value) async {
        await excursionCollection
            .doc(excursionID)
            .collection('participants')
            .doc(currentUserId)
            .set({
          'uid': currentUserId,
        });
      });
      return excursionID;
    } on FirebaseException {
      return false;
    }
  }

  Future<bool> inviteUserToExcursion(
      String excursionId, String userId, String name) async {
    try {
      var excursion = excursionCollection.doc(excursionId);
      var user = await excursion.collection('participants').doc(userId).get();
      if (user.data() == null) {
        await excursion.collection('participants').doc(userId).set({
          'uid': userId,
          'name': name,
          'isInExcursion': false,
        });
      }
      return true;
    } on FirebaseException {
      return false;
    }
  }

  Future<bool> rejectExcursionInvitation(String excursionId) async {
    return await deleteUserFromExcursion(excursionId, currentUserId!);
  }

  Future<bool> deleteUserFromExcursion(
      String excursionId, String userId) async {
    try {
      var excursion = excursionCollection.doc(excursionId);
      await excursion.collection('participants').doc(userId).delete();
      return true;
    } on FirebaseException {
      return false;
    }
  }

  Future<bool> joinExcursion(String excursionID) async {
    try {
      var excursion = excursionCollection.doc(excursionID);
      await excursion.collection('participants').doc(currentUserId).set({
        'isInExcursion': true,
      });
      return true;
    } on FirebaseException {
      return false;
    }
  }

  Future<List<QueryDocumentSnapshot>> getUserExcursions() async {
    String participantsSubcollection = 'participants';
    QuerySnapshot querySnapshot = await excursionCollection
        .where('$participantsSubcollection.$currentUserId', isEqualTo: true)
        .get();
    return querySnapshot.docs;
  }

  Future<bool> leaveExcursion(String excursionID) async {
    try {
      await excursionCollection
          .doc(excursionID)
          .collection('participants')
          .doc(currentUserId)
          .set({'isInExcursion': false});
      return true;
    } on FirebaseException {
      return false;
    }
  }
}
