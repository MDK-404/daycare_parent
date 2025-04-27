import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService = AuthService();

  Future<String?> signUp(String name, String email, String password) async {
    try {
      await _authService.signUp(name: name, email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already in use.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Try a stronger one.';
        default:
          return 'Sign up failed. Please try again.';
      }
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _authService.signIn(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found for this email.';
        case 'wrong-password':
          return 'Invalid password. Please try again.';
        case 'invalid-email':
          return 'Invalid email format.';
        case 'user-disabled':
          return 'This account has been disabled.';
        default:
          return 'Login failed. Please try again.';
      }
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }
}
