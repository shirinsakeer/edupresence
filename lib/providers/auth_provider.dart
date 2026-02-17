// Version: 1.0.2 - Added Persistent Login with SharedPreferences
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { teacher, student, none }

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserRole _role = UserRole.none;
  Map<String, dynamic>? _userData;
  StreamSubscription? _roleSubscription;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  User? get user => _user;
  UserRole get role => _role;
  Map<String, dynamic>? get userData => _userData;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Check if user was previously logged in
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      _roleSubscription?.cancel();
      if (user != null) {
        await _saveLoginState(true);
        _listenToUserData();
      } else {
        await _saveLoginState(false);
        _role = UserRole.none;
        _userData = null;
        _isInitialized = true;
        notifyListeners();
      }
    });

    // If previously logged in and Firebase has a current user, data will load via auth state listener
    // Mark as initialized after first check
    if (!isLoggedIn || _auth.currentUser == null) {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
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
        _isInitialized = true;
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
        _isInitialized = true;
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
      String name, String email, String password, String department) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _firestore.collection('teachers').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'department': department,
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
    await _saveLoginState(false);
    _role = UserRole.none;
    _userData = null;
    notifyListeners();
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

  Future<String?> changePassword(
      String currentPassword, String newPassword) async {
    if (_user == null) return "User not logged in";
    try {
      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: currentPassword,
      );
      await _user!.reauthenticateWithCredential(credential);

      // Update password
      await _user!.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return "Current password is incorrect";
      } else if (e.code == 'weak-password') {
        return "New password is too weak";
      }
      return e.message ?? "Failed to change password";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateProfile({String? name, String? department}) async {
    if (_user == null) return "User not logged in";
    try {
      String collection = _role == UserRole.teacher ? 'teachers' : 'students';
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (department != null && _role == UserRole.teacher)
        updates['department'] = department;

      if (updates.isNotEmpty) {
        await _firestore.collection(collection).doc(_user!.uid).update(updates);
      }
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
