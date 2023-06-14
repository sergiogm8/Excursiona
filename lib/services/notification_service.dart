// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:excursiona/model/excursion.dart';
// import 'package:excursiona/services/user_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class NotificationService {
//   final FirebaseMessaging _instance = FirebaseMessaging.instance;
//   final CollectionReference _tokensCollection =
//       FirebaseFirestore.instance.collection('tokens');

//   initializeNotificationService() {
//     var userId = FirebaseAuth.instance.currentUser?.uid;
//     _instance.getToken().then((token) {
//       _tokensCollection.doc(userId).set({
//         'token': token,
//       });
//     });
//   }

//   sendExcursionNotificationToUser(Excursion excursion, String userId) async {
//     //TODO: Implement the emission of a notification to the user
//     // HttpsCallable callable =
//     //     FirebaseFunctions.instance.httpsCallable('sendNotification');
//     // _tokensCollection.doc(userId).get().then((snapshot) {
//     //   var token = snapshot.data() as Map<String, dynamic>;
//     //   callable.call({
//     //     'token': token['token'],
//     //     'title': 'Invitation to ${excursion.title}',
//     //     'body': '${excursion.ownerName} invited you to join ${excursion.title}',
//     //   });
//     // });
//   }
// }
