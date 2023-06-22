import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/image_model.dart';
import 'package:excursiona/model/recap_models.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/auth_service.dart';
import 'package:excursiona/services/excursion_service.dart';
import 'package:excursiona/services/storage_service.dart';

class UserService {
  UserService({this.uid});
  AuthService authService = AuthService();

  final String? uid;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference imagesCollection =
      FirebaseFirestore.instance.collection('images');

  Future saveUserData(UserModel user) async {
    return await userCollection.doc(uid).set(user.toMap());
  }

  Future getUserDataByEmail(String email) async {
    try {
      QuerySnapshot snapshot =
          await userCollection.where('email', isEqualTo: email).get();
      return snapshot;
    } on Exception catch (e) {
      rethrow;
    }
  }

  getUserData() async {
    try {
      var snapshot = await userCollection
          .doc(authService.firebaseAuth.currentUser?.uid)
          .get();
      return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future insertExcursionInvitation(Excursion invitation, String userId) async {
    try {
      await userCollection
          .doc(userId)
          .collection('invitations')
          .doc(invitation.id)
          .set(invitation.toMap());
    } on FirebaseException {
      rethrow;
    }
  }

  Future deleteExcursionInvitation(String excursionId) async {
    try {
      var currentUserId = authService.firebaseAuth.currentUser!.uid;
      await userCollection
          .doc(currentUserId)
          .collection('invitations')
          .doc(excursionId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<List<Excursion>> getExcursionInvitations() {
    String userId = authService.firebaseAuth.currentUser!.uid;
    return userCollection
        .doc(userId)
        .collection('invitations')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Excursion.fromMap(doc.data())).toList();
    });
  }

  Future<List<UserModel>> getAllUsersBasicInfo(String name) async {
    List<UserModel> users = [];
    QuerySnapshot snapshot =
        await userCollection.orderBy('name').limit(25).get();
    for (var doc in snapshot.docs) {
      if (doc['name'].toString().toLowerCase().contains(name.toLowerCase())) {
        users.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
      }
    }
    return users;
  }

  saveExcursion(ExcursionRecap excursion, File mapSnapshot) async {
    String mapUrl = await StorageService().uploadMapSnapshot(
        excursion.id, mapSnapshot, authService.firebaseAuth.currentUser!.uid);
    if (mapUrl.isNotEmpty) {
      excursion.mapSnapshotUrl = mapUrl;
      try {
        await ExcursionService().saveExcursionToTL(excursion);
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<List<QueryDocumentSnapshot>> getUserExcursions(
      int docsPerPage, QueryDocumentSnapshot? lastDoc) async {
    var userId = authService.firebaseAuth.currentUser!.uid;
    try {
      CollectionReference tlCollection =
          FirebaseFirestore.instance.collection('timeline');
      var data = lastDoc == null
          ? await tlCollection
              .where('userId', isEqualTo: userId)
              .orderBy('date', descending: true)
              .limit(docsPerPage)
              .get()
          : await tlCollection
              .where('userId', isEqualTo: userId)
              .orderBy('date', descending: true)
              .startAfterDocument(lastDoc)
              .limit(docsPerPage)
              .get();
      return data.docs;
    } catch (e) {
      rethrow;
    }
  }

  updateProfilePic(String url) async {
    try {
      await userCollection
          .doc(authService.firebaseAuth.currentUser!.uid)
          .update({'profilePic': url});
    } catch (e) {
      rethrow;
    }
  }

  void updateUserStatistics(StatisticRecap statistics) {
    final DocumentReference userRef =
        userCollection.doc(authService.firebaseAuth.currentUser!.uid);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      final DocumentSnapshot snapshot = await transaction.get(userRef);

      if (snapshot.exists) {
        var data = snapshot.data()! as Map<String, dynamic>;
        final currentKilometers = data['totalDistance'] ?? 0.0;
        final newKilometers = currentKilometers + statistics.distance;

        final currentExcursions = data['nExcursions'] ?? 0;
        final newExcursions = currentExcursions + 1;

        final currentTime = Duration(minutes: data['totalTime'] ?? 00);
        final newTime = currentTime + statistics.duration;

        final currentAvgSpeed = data['avgSpeed'] ?? 0.0;
        double newSum =
            currentAvgSpeed * currentExcursions + statistics.avgSpeed;
        final newAvgSpeed = newSum / newExcursions;

        transaction.update(userRef, {
          'totalDistance': newKilometers,
          'nExcursions': newExcursions,
          'totalTime': newTime.inMinutes,
          'avgSpeed': newAvgSpeed
        });
      }
    });
  }

  void updateUserPhotos(int nNewPhotos, List<ImageModel> uploadedImages) {
    final DocumentReference userRef =
        userCollection.doc(authService.firebaseAuth.currentUser!.uid);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      final DocumentSnapshot snapshot = await transaction.get(userRef);

      if (snapshot.exists) {
        var data = snapshot.data()! as Map<String, dynamic>;
        int currentPhotos = data['nPhotos'] ?? 0;
        int newPhotos = currentPhotos + nNewPhotos;

        transaction.update(userRef, {
          'nPhotos': newPhotos,
        });
      }
    }).catchError((error) {
      throw Exception(error.toString());
    });

    try {
      saveImages(uploadedImages);
    } catch (e) {
      rethrow;
    }
  }

  saveImages(List<ImageModel> images) async {
    for (var image in images) {
      try {
        await saveImage(image);
      } catch (e) {
        rethrow;
      }
    }
  }

  saveImage(ImageModel image) async {
    try {
      await imagesCollection.add(image.toMapForGallery());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> getGalleryImages(
      int docsPerPage, QueryDocumentSnapshot? lastDoc) async {
    var userId = authService.firebaseAuth.currentUser!.uid;
    try {
      var data = lastDoc == null
          ? await imagesCollection
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .limit(docsPerPage)
              .get()
          : await imagesCollection
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .startAfterDocument(lastDoc)
              .limit(docsPerPage)
              .get();
      return data.docs;
    } catch (e) {
      rethrow;
    }
  }

  void updateUserMarkers(int nNewMarkers) {
    final DocumentReference userRef =
        userCollection.doc(authService.firebaseAuth.currentUser!.uid);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      final DocumentSnapshot snapshot = await transaction.get(userRef);

      if (snapshot.exists) {
        var data = snapshot.data()! as Map<String, dynamic>;
        int currentMarkers = data['nMarkers'] ?? 0;
        int newMarkers = currentMarkers + nNewMarkers;

        transaction.update(userRef, {
          'nMarkers': newMarkers,
        });
      }
    }).catchError((error) {
      throw Exception(error.toString());
    });
  }

  getUserPic(String userId) async {
    try {
      var user = await userCollection.doc(userId).get();
      var data = user.data()! as Map<String, dynamic>;
      return data['profilePic'];
    } catch (e) {
      rethrow;
    }
  }
}
