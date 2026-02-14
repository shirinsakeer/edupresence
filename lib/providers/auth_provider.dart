// Version: 1.0.1 - Fixed Stale Subscription Error
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
  StreamSubscription? _roleSubscription;

  User? get user => _user;
  UserRole get role => _role;
  Map<String, dynamic>? get userData => _userData;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _roleSubscription?.cancel();
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
    if (_user == null) return;

    _roleSubscription?.cancel();

    // Check teacher collection
    _roleSubscription = _firestore
        .collection('teachers')
        .doc(_user!.uid)
        .snapshots()
        .listen((teacherDoc) {
      if (teacherDoc.exists) {
        _role = UserRole.teacher;
        _userData = teacherDoc.data();
        notifyListeners();
      } else {
        // Not a teacher, check student
        _checkStudentData();
      }
    }, onError: (e) {
      print("AuthProvider Error: $e");
    });
  }

  void _checkStudentData() {
    if (_user == null) return;

    // We don't necessarily need to replace _roleSubscription here if we want to listen to both,
    // but the logic expects one active role listener.
    _roleSubscription?.cancel();
    _roleSubscription = _firestore
        .collection('students')
        .doc(_user!.uid)
        .snapshots()
        .listen((studentDoc) {
      if (studentDoc.exists) {
        _role = UserRole.student;
        _userData = studentDoc.data();
        notifyListeners();
      } else {
        _role = UserRole.none;
        _userData = null;
        notifyListeners();
      }
    }, onError: (e) {
      print("AuthProvider Student Error: $e");
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
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    _roleSubscription?.cancel();
    await _auth.signOut();
  }

  Future<String?> updateProfileImage(String imageUrl) async {
    if (_user == null) return "User not logged in";
    try {
      String collection = _role == UserRole.teacher ? 'teachers' : 'students';
      await _firestore.collection(collection).doc(_user!.uid).update({
        'profileImage': imageUrl,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  void dispose() {
    _roleSubscription?.cancel();
    super.dispose();
  }
}
