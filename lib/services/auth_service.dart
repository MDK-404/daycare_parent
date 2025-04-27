import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parent_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final UserCredential userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final token = await FirebaseMessaging.instance.getToken();

    ParentModel parent = ParentModel(
      uid: userCred.user!.uid,
      name: name,
      email: email,
      deviceToken: token ?? '',
    );

    await _firestore.collection("Parents").doc(userCred.user!.uid).set(parent.toMap());
    return userCred.user;
  }

  Future<User?> signIn(String email, String password) async {
    final UserCredential userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final token = await FirebaseMessaging.instance.getToken();
    await _firestore.collection("Parents").doc(userCred.user!.uid).update({
      'deviceToken': token,
    });

    return userCred.user;
  }
}
