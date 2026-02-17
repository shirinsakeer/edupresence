import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Add Student (Teacher only)
  Future<String?> addStudent({
    required String name,
    required String email,
    required String className,
    required String rollNumber,
    required String department,
    required String semester,
    required int totalDaysRequired,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Create temporary password
      String tempPassword = "Std${rollNumber}123";

      // 2. Check if student already exists in Firestore
      var existing = await _firestore
          .collection('students')
          .where('email', isEqualTo: email)
          .get();
      if (existing.docs.isNotEmpty) {
        throw "Student with this email already exists";
      }

      // 3. Create user in Firebase Auth using a secondary app instance
      // This avoids signing out the current teacher
      FirebaseApp secondaryApp;
      try {
        secondaryApp = Firebase.app('StudentCreationApp');
      } catch (e) {
        secondaryApp = await Firebase.initializeApp(
          name: 'StudentCreationApp',
          options: Firebase.app().options,
        );
      }

      UserCredential userCredential = await FirebaseAuth.instanceFor(
              app: secondaryApp)
          .createUserWithEmailAndPassword(email: email, password: tempPassword);

      String studentId = userCredential.user!.uid;

      // 4. Create internal record in Firestore using the UID from Auth
      await _firestore.collection('students').doc(studentId).set({
        'name': name,
        'email': email,
        'className': className,
        'rollNumber': rollNumber,
        'department': department,
        'semester': semester,
        'totalDaysRequired': totalDaysRequired,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
        'attendance': {},
      });

      // 5. Send Email via EmailJS
      await sendCredentialsEmail(
          email: email, name: name, password: tempPassword);

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> sendCredentialsEmail({
    required String email,
    required String name,
    required String password,
  }) async {
    const serviceId = 'service_default';
    const templateId = 'template_student_creds';
    const userId = 'YOUR_USER_ID';

    if (userId == 'YOUR_USER_ID') {
      debugPrint('WARNING: EmailJS not configured. Skipping email sending.');
      debugPrint('Mock Email to: $email');
      debugPrint(
          'Message: Your login credentials for EduPresence are:\nEmail: $email\nPassword: $password');
      return;
    }

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'to_email': email,
            'to_name': name,
            'message':
                'Your login credentials for EduPresence are:\nEmail: $email\nPassword: $password',
          },
        }),
      );
      debugPrint('Email response: ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('Failed to send email: $e');
    }
  }

  Stream<QuerySnapshot> getStudentsByClass(String className) {
    return _firestore
        .collection('students')
        .where('className', isEqualTo: className)
        .snapshots();
  }

  Stream<QuerySnapshot> getStudentsByDepartment(String department) {
    return _firestore
        .collection('students')
        .where('department', isEqualTo: department)
        .snapshots();
  }

  Stream<QuerySnapshot> getStudentsByDepartmentAndSemester(
      String department, String semester) {
    return _firestore
        .collection('students')
        .where('department', isEqualTo: department)
        .where('semester', isEqualTo: semester)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllStudents() {
    return _firestore.collection('students').snapshots();
  }

  Stream<List<String>> getAllClasses() {
    return _firestore.collection('students').snapshots().map((snapshot) {
      final classes = snapshot.docs
          .map((doc) => doc.data()['className'])
          .whereType<String>()
          .toSet()
          .toList();
      classes.sort();
      return classes;
    });
  }

  Future<void> markAttendance({
    required String studentId,
    required String date,
    required String status,
  }) async {
    await _firestore.collection('students').doc(studentId).update({
      'attendance.$date': status,
    });
  }

  // Set total days for a class
  Future<void> setTotalDays(String className, int totalDays) async {
    await _firestore.collection('classes').doc(className).set({
      'totalDays': totalDays,
    }, SetOptions(merge: true));
    notifyListeners();
  }

  // Get total days for a class
  Stream<DocumentSnapshot> getClassMetadata(String className) {
    return _firestore.collection('classes').doc(className).snapshots();
  }
}
