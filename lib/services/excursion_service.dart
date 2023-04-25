import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/excursion_participant.dart';
import 'package:excursiona/model/invitation.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/notification_service.dart';
import 'package:excursiona/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class ExcursionService {
  final CollectionReference excursionCollection =
      FirebaseFirestore.instance.collection('excursions');

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future createExcursion(Excursion excursion, UserModel userInfo) async {
    try {
      await excursionCollection.doc(excursion.id).set(excursion.toMap());
      await joinExcursion(excursion.id, userInfo);
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
    Invitation invitation = Invitation(
        excursionTitle: excursion.title,
        excursionId: excursion.id,
        ownerName: excursion.ownerName,
        ownerPic: excursion.ownerPic);
    try {
      for (var participant in participants) {
        if (participant.uid == currentUserId) continue;
        await UserService()
            .insertExcursionInvitation(invitation, participant.uid);
        NotificationService()
            .sendExcursionNotificationToUser(excursion, participant.uid);
      }
      return true;
    } on FirebaseException {
      return false;
    }
  }

  Future<bool> inviteUserToExcursion(Excursion excursion, String userId) async {
    Invitation invitation = Invitation(
        excursionTitle: excursion.title,
        excursionId: excursion.id,
        ownerName: excursion.ownerName,
        ownerPic: excursion.ownerPic);
    try {
      UserService().insertExcursionInvitation(invitation, userId);
      return true;
    } on FirebaseException {
      return false;
    }
  }

  Future<bool> rejectExcursionInvitation(String excursionId) async {
    try {
      UserService().deleteExcursionInvitation(excursionId, currentUserId!);
      return true;
    } on FirebaseException {
      return false;
    }
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

  Future<bool> joinExcursion(String excursionID, UserModel userInfo) async {
    try {
      var excursion = excursionCollection.doc(excursionID);
      var userInfoMap = userInfo.toMapShort();
      userInfoMap.addAll({'isInExcursion': true});
      await excursion
          .collection('participants')
          .doc(currentUserId)
          .set(userInfoMap);
      return true;
    } on FirebaseException {
      return false;
    }
  }

  Future<List<QueryDocumentSnapshot>> getParticipantsData(
      String excursionId) async {
    try {
      var excursion = excursionCollection.doc(excursionId);
      QuerySnapshot participants =
          await excursion.collection('participants').get();
      return participants.docs;
    } on FirebaseException catch (e) {
      return [];
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

  shareCurrentLocation(Position coords, String excursionId) async {
    print("Sharing location: ${coords.latitude}, ${coords.longitude}");
    try {
      await excursionCollection
          .doc(excursionId)
          .collection('participants')
          .doc(currentUserId)
          .update({
        'currentLocation': GeoPoint(coords.latitude, coords.longitude),
      });
    } on FirebaseFirestore catch (e) {
      print(e);
    }
  }

  Stream<List<ExcursionParticipant>> getOthersLocation(String excursionId) {
    return excursionCollection
        .doc(excursionId)
        .collection('participants')
        .snapshots()
        .map((snapshot) {
      List<ExcursionParticipant> participantsInfo = [];
      for (var doc in snapshot.docs) {
        participantsInfo.add(ExcursionParticipant.fromMap(doc.data()));
      }
      return participantsInfo;
    });
  }
}
