import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excursiona/enums/marker_type.dart';
import 'package:excursiona/model/emergency_alert.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/excursion_participant.dart';
import 'package:excursiona/model/image_model.dart';
import 'package:excursiona/model/marker_model.dart';
import 'package:excursiona/model/recap_models.dart';
import 'package:excursiona/model/route.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/notification_service.dart';
import 'package:excursiona/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ExcursionService {
  final CollectionReference excursionCollection =
      FirebaseFirestore.instance.collection('excursions');

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Future createExcursion(
      Excursion excursion, ExcursionParticipant userInfo) async {
    try {
      await excursionCollection.doc(excursion.id).set(excursion.toMap());
      await joinExcursion(excursion.id, userInfo);
      return true;
    } on FirebaseException {
      return false;
    }
  }

  Future<Excursion> getExcursion(String excursionId) async {
    try {
      var excursion = await excursionCollection.doc(excursionId).get().then(
          (value) => Excursion.fromMap(value.data()! as Map<String, dynamic>));
      return excursion;
    } catch (e) {
      rethrow;
    }
  }

  Future inviteUsersToExcursion(
      Excursion excursion, Set<UserModel> participants) async {
    try {
      for (var participant in participants) {
        if (participant.uid == currentUserId) continue;
        await UserService()
            .insertExcursionInvitation(excursion, participant.uid);
        // NotificationService()
        //     .sendExcursionNotificationToUser(excursion, participant.uid);
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

  Future<bool> rejectExcursionInvitation(String excursionId) async {
    try {
      UserService().deleteExcursionInvitation(excursionId);
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

  Future<bool> joinExcursion(
      String excursionID, ExcursionParticipant userInfo) async {
    try {
      var excursion = excursionCollection.doc(excursionID);
      await excursion
          .collection('participants')
          .doc(currentUserId)
          .set(userInfo.toMap());
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

  Future<ExcursionParticipant> getParticipantData(String excursionId,
      {String? userId}) {
    userId ??= currentUserId;
    return excursionCollection
        .doc(excursionId)
        .collection('participants')
        .doc(userId)
        .get()
        .then((doc) {
      return ExcursionParticipant.fromMap(doc.data()!);
    });
  }

  Future<bool> leaveExcursion(String excursionID) async {
    try {
      await excursionCollection
          .doc(excursionID)
          .collection('participants')
          .doc(currentUserId)
          .update({
        'isInExcursion': false,
        'leftAt': DateTime.now().millisecondsSinceEpoch
      });
      await excursionCollection
          .doc(excursionID)
          .collection('markers')
          .doc(currentUserId)
          .delete();
      return true;
    } on FirebaseException {
      return false;
    }
  }

  shareCurrentLocation(MarkerModel marker, String excursionId) async {
    try {
      excursionCollection
          .doc(excursionId)
          .collection('markers')
          .doc(marker.id)
          .set(marker.toMap());
    } catch (e) {
      print(e);
    }
  }

  saveUserRoute(RouteModel route, String excursionId) async {
    try {
      excursionCollection
          .doc(excursionId)
          .collection('routes')
          .doc(currentUserId)
          .set(route.toMap());
    } catch (e) {
      print(e);
    }
  }

  Future<RouteModel> getUserRoute(String excursionId, {String? userId}) async {
    userId ??= currentUserId;
    return await excursionCollection
        .doc(excursionId)
        .collection('routes')
        .doc(userId)
        .get()
        .then((doc) {
      return RouteModel.fromMap(doc.data()!);
    });
  }

  Stream<List<MarkerModel>> getMarkers(String excursionId) {
    return excursionCollection
        .doc(excursionId)
        .collection('markers')
        .snapshots()
        .map((snapshot) {
      List<MarkerModel> markers = [];
      for (var doc in snapshot.docs) {
        markers.add(MarkerModel.fromMap(doc.data()));
      }
      return markers;
    });
  }

  Future<List<MarkerModel>> getUserMarkers(String excursionId) async {
    return await excursionCollection
        .doc(excursionId)
        .collection('markers')
        .get()
        .then((query) {
      var data = query.docs;
      var markers = data.map((e) => MarkerModel.fromMap(e.data())).toList();
      return markers
          .where((element) =>
              element.userId == currentUserId &&
              element.markerType != MarkerType.participant)
          .toList();
    });
  }

  addMarkerToExcursion({
    required MarkerModel marker,
    required String excursionId,
  }) async {
    try {
      await excursionCollection
          .doc(excursionId)
          .collection('markers')
          .doc(marker.id)
          .set(marker.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addImageToExcursion(
      {required String excursionId, required ImageModel imageModel}) async {
    try {
      await excursionCollection
          .doc(excursionId)
          .collection('images')
          .add(imageModel.toMap());
      return true;
    } on FirebaseException {
      return false;
    }
  }

  Stream<List<ImageModel>> getImagesFromExcursion(String excursionId) {
    try {
      return excursionCollection
          .doc(excursionId)
          .collection('images')
          .orderBy('timestamp')
          .snapshots()
          .map((snapshots) {
        List<ImageModel> images = [];
        for (var doc in snapshots.docs) {
          images.add(ImageModel.fromMap(doc.data()));
        }
        return images;
      });
    } catch (e) {
      return Stream.empty();
    }
  }

  Future<int> getNumberOfMarkers(String excursionId) async {
    return await excursionCollection
        .doc(excursionId)
        .collection('markers')
        .get()
        .then((query) {
      var data = query.docs;
      var markers = data.map((e) => MarkerModel.fromMap(e.data())).toList();
      markers = markers
          .where((element) => element.markerType != MarkerType.participant)
          .toList();
      return markers.length;
    }).catchError((e) {
      throw e;
    });
  }

  Future<bool> sendEmergencyAlert(
      String excursionId, EmergencyAlert alert) async {
    try {
      await excursionCollection
          .doc(excursionId)
          .collection('alerts')
          .doc(alert.id)
          .set(alert.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<EmergencyAlert>> getEmergencyAlert(String excursionId) {
    return excursionCollection
        .doc(excursionId)
        .collection('alerts')
        .snapshots()
        .map((snapshot) {
      List<EmergencyAlert> alerts = [];
      for (var doc in snapshot.docs) {
        alerts.add(EmergencyAlert.fromMap(doc.data()));
      }
      return alerts;
    });
  }

  Future<bool> cancelEmergencyAlert(String excursionId) async {
    try {
      var alertId = currentUserId;
      await excursionCollection
          .doc(excursionId)
          .collection('alerts')
          .doc(alertId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  saveExcursionToTL(ExcursionRecap excursion) async {
    try {
      final CollectionReference TLCollection =
          FirebaseFirestore.instance.collection('timeline');
      await TLCollection.add(excursion.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> getTLExcursions(
      int docsPerPage, QueryDocumentSnapshot? lastDoc) async {
    try {
      final CollectionReference TLCollection =
          FirebaseFirestore.instance.collection('timeline');
      var snapshot = lastDoc == null
          ? await TLCollection.where('userId', isNotEqualTo: currentUserId)
              .orderBy('userId')
              .orderBy('date', descending: true)
              .limit(docsPerPage)
              .get()
          : await TLCollection.where('userId', isNotEqualTo: currentUserId)
              .orderBy('userId')
              .orderBy('date', descending: true)
              .startAfterDocument(lastDoc)
              .limit(docsPerPage)
              .get();
      return snapshot.docs;
    } catch (e) {
      rethrow;
    }
  }
}
