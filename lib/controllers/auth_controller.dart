import 'package:excursiona/helper/helper_functions.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/auth_service.dart';
import 'package:excursiona/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future registerWithEmailAndPassword(
      String name, String email, String password) async {
    HelperFunctions.saveUserEmail(email);
    HelperFunctions.saveUserName(name);
    return await _authService.registerWithEmailAndPassword(
        name, email, password);
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    bool result = false;
    try {
      var user = await _authService.signInWithEmailAndPassword(email, password);
      HelperFunctions.saveUserEmail(email);
      HelperFunctions.saveUserName(user.get("name"));
      HelperFunctions.saveUserProfilePic(user.get("profilePic"));
      HelperFunctions.saveUserUID(user.get("uid"));
      if (isEmailVerified()) {
        result = true;
        HelperFunctions.saveUserLoggedInStatus(true);
      } else {
        result = false;
      }
    } on FirebaseException catch (e) {
      return e.message;
    }
    return result;
  }

  Future signOut() async {
    try {
      await _authService.signOut();
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
    await HelperFunctions.clearSharedPreferences();
    return true;
  }

  Future signInWithGoogle() async {
    try {
      var snapshot = (await _authService.signInWithGoogle());
      UserModel user =
          UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      HelperFunctions.saveUserLoggedInStatus(true);
      HelperFunctions.saveUserEmail(user.email);
      HelperFunctions.saveUserName(user.name);
      HelperFunctions.saveUserUID(user.uid);
      HelperFunctions.saveUserProfilePic(user.profilePic);
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "No se pudo iniciar sesión con Google";
    }
  }

  bool isEmailVerified() {
    return _authService.isEmailVerified();
  }

  Future sendEmailVerification() async {
    return await _authService.sendEmailVerification();
  }

  reloadAuthInstance() async {
    await _authService.reloadAuthInstance();
  }

  Future resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }

  setUserLoggedIn() async {
    await HelperFunctions.saveUserLoggedInStatus(true);
  }

  bool isCurrentUser({required String uid}) {
    return _authService.firebaseAuth.currentUser?.uid == uid;
  }
}
