import 'dart:io';

import 'package:excursiona/enums/message_type.dart';
import 'package:excursiona/model/chat_contact.dart';
import 'package:excursiona/model/contact.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/excursion_recap.dart';
import 'package:excursiona/model/message.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/auth_service.dart';
import 'package:excursiona/services/storage_service.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UserService {
  UserService({this.uid});
  AuthService authService = AuthService();

  final String? uid;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future saveUserData(String name, String email, [String photoUrl = '']) async {
    return await userCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'profilePic': photoUrl,
      'contacts': [],
    });
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

  Stream<UserModel> getUserDataByID(String userId) {
    return userCollection.doc(userId).snapshots().map(
        (event) => UserModel.fromMap(event.data()! as Map<String, dynamic>));
  }

  Future<UserModel> getFutureUserDataByID(String userId) async {
    var userData = await userCollection.doc(userId).get();
    return UserModel.fromMap(userData.data()! as Map<String, dynamic>);
  }

  Future<UserModel?> getCurrentUserData() async {
    var userData =
        await userCollection.doc(FirebaseAuth.instance.currentUser?.uid).get();
    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()! as Map<String, dynamic>);
    }
    return user;
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

  void updateKilometers(String userId, double additionalKilometers) {
    final DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      final DocumentSnapshot snapshot = await transaction.get(userRef);

      if (snapshot.exists) {
        var data = snapshot.data()! as Map<String, dynamic>;
        final currentKilometers = data['kilometers'] ?? 0.0;
        final newKilometers = currentKilometers + additionalKilometers;
        transaction.update(userRef, {'kilometers': newKilometers});
      }
    }).then((value) {
      print('Kilometers updated successfully.');
    }).catchError((error) {
      print('Failed to update kilometers: $error');
    });
  }

  Future<List<UserModel>> getAllUsersBasicInfo(String name) async {
    //if a name is given filter by name
    //if no name is given return all users
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

  saveExcursionToUser(ExcursionRecap excursion, File mapSnapshot) async {
    String mapUrl = await StorageService().uploadMapSnapshot(
        excursion.id, mapSnapshot, authService.firebaseAuth.currentUser!.uid);
    if (mapUrl.isNotEmpty) {
      excursion.mapSnapshotUrl = mapUrl;
      await userCollection
          .doc(authService.firebaseAuth.currentUser!.uid)
          .collection('excursions')
          .doc(excursion.id)
          .set(excursion.toMap());
    }
  }
}
