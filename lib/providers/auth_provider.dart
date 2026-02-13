import 'dart:async';
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

  StreamSubscription? _userSubscription;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _userSubscription?.cancel();
      if (user != null) {
        _listenToUserData();
      } else {
        _role = UserRole.none;
        _userData = null;
        notifyListeners();
      }
    });
  }

  void _listenToUserData() {
    // We don't know if it's a teacher or student first, so we try teacher collection
    // In a real optimized app, you might have a 'users' collection with a role field
    _userSubscription = _firestore
        .collection('teachers')
        .doc(_user!.uid)
        .snapshots()
        .listen((teacherDoc) {
      if (teacherDoc.exists) {
        _role = UserRole.teacher;
        _userData = teacherDoc.data();
        notifyListeners();
      } else {
        // Not a teacher, try student
        _firestore
            .collection('students')
            .doc(_user!.uid)
            .snapshots()
            .listen((studentDoc) {
          if (studentDoc.exists) {
            _role = UserRole.student;
            _userData = studentDoc.data();
            notifyListeners();
          }
        });
      }
    });
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
      // _listenToUserData() is called automatically via authStateChanges listener
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
