import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:herewego/pages/sign_in_page.dart';
import 'package:herewego/services/log_service.dart';

import 'hive_service.dart';

class AuthService {
  static const isTester = true;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> signUpUser(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      await user!.updateDisplayName(name);
      Log.d(user.toString());

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Log.d('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Log.d("The account already exists for that email.");
      }
    } catch (e) {
      Log.d(e.toString());
    }

    return null;
  }

  static Future<User?> signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      Log.d(user.toString());

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Log.d('No user found for email.');
      } else if (e.code == 'wrong-password') {
        Log.d("Wrong password provided for that user.");
      }
    } catch (e) {
      Log.d(e.toString());
    }

    return null;
  }

  static void signOutUser(BuildContext context) async {
    await _auth.signOut();
    HiveDB.removeUserId();
    Navigator.pushNamedAndRemoveUntil(context, SignInPage.id, (route) => false);
  }

  static Future<void> deleteUser(BuildContext context, String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password).then((value) async {
      await value.user!.delete().then((value) {
        HiveDB.removeUserId();
        Navigator.pushNamedAndRemoveUntil(context, SignInPage.id, (route) => false);
      });
    });
  }
}