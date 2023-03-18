import 'package:excursiona/model/chat_contact.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  Stream<List<ChatContact>> getChatsContacts() {
    return UserService()
        .userCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((snapshot) async {
      List<ChatContact> chatContacts = [];
      for (var doc in snapshot.docs) {
        var chatContact = ChatContact.fromMap(doc.data());
        var userData =
            await UserService().userCollection.doc(chatContact.contactID).get();
        var user = UserModel.fromMap(userData.data()! as Map<String, dynamic>);

        chatContacts.add(ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactID: user.uid,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage));
      }
      return chatContacts;
    });
  }
}
