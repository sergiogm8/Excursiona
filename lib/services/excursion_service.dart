import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ExcursionService {
  final CollectionReference excursionCollection =
      FirebaseFirestore.instance.collection('excursions');

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future createExcursion(Excursion excursion) async {
    try {
      await excursionCollection.doc(excursion.id).set(excursion.toMap());
      await joinExcursion(excursion.id);
      // await excursionCollection.doc(excursion.id).collection('participants').doc(currentUserId).set({
      //   'isInExcursion': true,
      // });
      return true;
    } on FirebaseException {
      return false;
    }
  }

  Future inviteUsersToExcursion(
      Excursion excursion, Set<UserModel> participants) async {
    try {
      for (var participant in participants) {
        await UserService()
            .insertExcursionInvitation(excursion, participant.uid);
        sendExcursionNotificationToUser(excursion, participant.uid);
      }
      return true;
    } on FirebaseException {
      return false;
    }
  }

  Future<bool> inviteUserToExcursion(Excursion excursion, String userId) async {
    try {
      UserService().insertExcursionInvitation(excursion, userId);
      return true;
    } on FirebaseException {
      return false;
    }
  }

  sendExcursionNotificationToUser(Excursion excursion, String userId) async {
    //TODO: Implement the emission of a notification to the user
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
    //TODO: Modify this, it won't work
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
