import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum UserRole { teacher, student, none }

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserRole _role = UserRole.none;
  Map<String, dynamic>? _userData;

  User? get user => _user;
  UserRole get role => _role;
  Map<String, dynamic>? get userData => _userData;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchUserData();
      } else {
        _role = UserRole.none;
        _userData = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserData() async {
    if (_user == null) return;

    // Check teacher collection
    var teacherDoc =
        await _firestore.collection('teachers').doc(_user!.uid).get();
    if (teacherDoc.exists) {
      _role = UserRole.teacher;
      _userData = teacherDoc.data();
    } else {
      // Check student collection
      var studentDoc =
          await _firestore.collection('students').doc(_user!.uid).get();
      if (studentDoc.exists) {
        _role = UserRole.student;
        _userData = studentDoc.data();
      } else {
        _role = UserRole.none;
      }
    }
    notifyListeners();
  }

  Future<String?> signUpTeacher(
      String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _firestore.collection('teachers').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'teacher',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _fetchUserData();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
