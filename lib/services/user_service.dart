import 'package:excursiona/enums/message_enums.dart';
import 'package:excursiona/model/chat_contact.dart';
import 'package:excursiona/model/contact.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/invitation.dart';
import 'package:excursiona/model/message.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/auth_service.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UserService {
  UserService({this.uid});
  AuthService authService = AuthService();

  final String? uid;
  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  ///
  /// FUNCIONALIDAD DE USUARIOS
  ///
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

  Future insertExcursionInvitation(Invitation invitation, String userId) async {
    try {
      await userCollection
          .doc(userId)
          .collection('invitations')
          .doc(invitation.excursionId)
          .set(invitation.toMap());
    } on FirebaseException {
      rethrow;
    }
  }

  Future deleteExcursionInvitation(String excursionId, String userId) async {
    try {
      await userCollection
          .doc(userId)
          .collection('invitations')
          .doc(excursionId)
          .delete();
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<List<Invitation>> getExcursionInvitations() {
    String userId = authService.firebaseAuth.currentUser!.uid;
    return userCollection
        .doc(userId)
        .collection('invitations')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Invitation.fromMap(doc.data()))
          .toList();
    });
  }

  /// ------------------- CHAT ------------------- ///
  void _saveMessageToContactsSubcollection(
      UserModel senderUserData,
      UserModel recieverUserData,
      String text,
      DateTime timeSent,
      String recieverUserID) async {
    // SAVE THE MESSAGE TO THE reciever'S CHAT COLLECTION
    var recieverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactID: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text);

    await userCollection
        .doc(recieverUserID)
        .collection('chats')
        .doc(authService.firebaseAuth.currentUser!.uid)
        .set(recieverChatContact.toMap());

    // SAVE THE MESSAGE TO THE SENDER'S CHAT COLLECTION

    var senderChatContact = ChatContact(
        name: recieverUserData.name,
        profilePic: recieverUserData.profilePic,
        contactID: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text);

    await userCollection
        .doc(authService.firebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserID)
        .set(senderChatContact.toMap());
  }

  void _saveMessageToMessageSubcollection(
      String recieverUserID,
      // String senderUserID,
      String senderUserName,
      String reciverUserName,
      String text,
      DateTime timeSent,
      String messageID,
      MessageEnum messageType) async {
    var message = Message(
        senderID: authService.firebaseAuth.currentUser!.uid,
        recieverID: recieverUserID,
        text: text,
        timeSent: timeSent,
        type: messageType,
        messageID: messageID,
        isRead: false);

    //SAVE THE MESSAGE TO THE SENDER'S MESSAGE COLLECTION (OUR MESSAGE)
    await userCollection
        .doc(authService.firebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserID)
        .collection('messages')
        .doc(messageID)
        .set(message.toMap());

    //SAVE THE MESSAGE TO THE RECEIVERS'S MESSAGE COLLECTION (OTHER'S MESSAGE)
    await userCollection
        .doc(recieverUserID)
        .collection('chats')
        .doc(authService.firebaseAuth.currentUser!.uid)
        .collection('messages')
        .doc(messageID)
        .set(message.toMap());
  }

  void sendTextMessage(
      {required BuildContext context,
      required String text,
      required String recieverUserID}) async {
    try {
      var timeSent = DateTime.now();
      UserModel recieverUserData;
      // User recieverUserData = getUserDataByID(recieverUserID) as User;

      var recieverUserDataMap = await userCollection.doc(recieverUserID).get();
      recieverUserData = UserModel.fromMap(
          recieverUserDataMap.data()! as Map<String, dynamic>);

      var messageID = const Uuid().v1();

      UserModel senderUserData = await getCurrentUserData() as UserModel;

      _saveMessageToContactsSubcollection(
          senderUserData, recieverUserData, text, timeSent, recieverUserID);

      _saveMessageToMessageSubcollection(recieverUserID, senderUserData.name,
          recieverUserData.name, text, timeSent, messageID, MessageEnum.text);
    } catch (e) {
      showSnackBar(context, Theme.of(context).primaryColor, e.toString());
    }
  }

  Stream<List<Message>> getUserMessages(String receiverUserId) {
    return userCollection
        .doc(authService.firebaseAuth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var doc in event.docs) {
        messages.add(Message.fromMap(doc.data()));
      }
      return messages;
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
}
