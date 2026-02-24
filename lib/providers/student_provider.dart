import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:edupresence/services/email_service.dart';

class StudentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Add Student (Teacher only)
  Future<String?> addStudent({
    required String name,
    required String email,
    required String rollNumber,
    required String department,
    required String semester,
    required int totalWorkingHours,
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
        'rollNumber': rollNumber,
        'department': department,
        'semester': semester,
        'totalWorkingHours': totalWorkingHours,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
        'attendance': {},
      });

      // 5. Send Email via EmailJS
      await EmailService.sendStudentCredentials(
        studentEmail: email,
        studentName: name,
        password: tempPassword,
      );

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
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

  Future<void> markAttendance({
    required String studentId,
    required String date,
    required String status,
  }) async {
    final batch = _firestore.batch();

    // Update attendance
    final studentRef = _firestore.collection('students').doc(studentId);
    batch.update(studentRef, {
      'attendance.$date': status,
    });

    // Create notification
    final notificationRef = studentRef.collection('notifications').doc();
    batch.set(notificationRef, {
      'title': 'Attendance Update',
      'message': 'Your attendance for $date has been marked as $status.',
      'type': 'attendance',
      'status': status,
      'date': date,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> updateStudentWorkingHours(String studentId, int hours) async {
    await _firestore.collection('students').doc(studentId).update({
      'totalWorkingHours': hours,
    });
    notifyListeners();
  }

  // Get total days for a class
  Stream<DocumentSnapshot> getClassMetadata(String className) {
    return _firestore.collection('classes').doc(className).snapshots();
  }
}
