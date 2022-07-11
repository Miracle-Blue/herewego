import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:herewego/services/log_service.dart';
import 'package:herewego/ui/pages/sign_in_page.dart';

import 'hive_service.dart';

class AuthService {
  static const isTester = true;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> signUpUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      await user!.updateDisplayName(name);
      user.toString().d;

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        'The password provided is too weak.'.e;
      } else if (e.code == 'email-already-in-use') {
        "The account already exists for that email.".e;
      }
    } catch (e) {
      e.toString().e;
    }

    return null;
  }

  static Future<User?> signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;
      user.toString().d;

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        'No user found for email.'.e;
      } else if (e.code == 'wrong-password') {
        "Wrong password provided for that user.".e;
      }
    } catch (e) {
      e.toString().e;
    }

    return null;
  }

  static void signOutUser(BuildContext context) async {
    await _auth.signOut();
    HiveDB.removeUserId();
    Navigator.pushNamedAndRemoveUntil(context, SignInPage.id, (route) => false);
  }

  static Future<void> deleteUser(BuildContext context) async {
    await _auth.currentUser!.delete().then((value) {
      HiveDB.removeUserId();
      Navigator.pushNamedAndRemoveUntil(
        context,
        SignInPage.id,
        (route) => false,
      );
    });
  }
}
