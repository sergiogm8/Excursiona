import 'package:excursiona/helper/helper_functions.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/notification_service.dart';
import 'package:excursiona/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future registerWithEmailAndPassword(
      String name, String email, String password) async {
    bool result = false;
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;
      var userModel = UserModel(uid: user.uid, name: name, email: email);
      await UserService(uid: user.uid).saveUserData(userModel);
      // NotificationService().initializeNotificationService();
      if (user != null) {
        result = true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
    return result;
  }

  Future signOut() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      var isSignedInWithGoogle = await googleSignIn.isSignedIn();
      if (isSignedInWithGoogle) {
        await googleSignIn.signOut();
        // await googleSignIn.disconnect();
      }
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      return;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        QuerySnapshot snapshot =
            await UserService(uid: firebaseAuth.currentUser!.uid)
                .getUserDataByEmail(email);
        // NotificationService().initializeNotificationService();
        return snapshot.docs[0];
      }
    } on FirebaseException catch (e) {
      rethrow;
    }
  }

  Future<QueryDocumentSnapshot> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          var userModel = UserModel(
              uid: user.uid,
              name: user.displayName!,
              email: user.email!,
              profilePic: user.photoURL!);
          await UserService(uid: user.uid).saveUserData(userModel);
        }
      }
      QuerySnapshot snapshot =
          await UserService(uid: firebaseAuth.currentUser!.uid)
              .getUserDataByEmail(user!.email!);
      // NotificationService().initializeNotificationService();
      return snapshot.docs[0];
      // } on FirebaseAuthException catch (e) {
      //   return e.message;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  Future sendEmailVerification() async {
    try {
      await firebaseAuth.currentUser!.sendEmailVerification();
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  reloadAuthInstance() async {
    await firebaseAuth.currentUser!.reload();
  }

  bool isEmailVerified() {
    return firebaseAuth.currentUser!.emailVerified;
  }

  Future<bool> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }
}
