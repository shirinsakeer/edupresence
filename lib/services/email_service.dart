import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _serviceId = 'service_vchknr2';
  static const String _templateId = 'template_ukwi087';
  static const String _publicKey = 'dva45dN9q3pwJsQyf';

  static Future<bool> sendStudentCredentials({
    required String studentEmail,
    required String studentName,
    required String password,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    // Build template params — variable names MUST match your EmailJS template exactly.
    // Common variable names in EmailJS "Student Credential" templates:
    final templateParams = {
      'subject': 'Your EduPresence Credentials', // {{subject}}
      'message': 'Hello $studentName,\n\n'
          'Your EduPresence account password is: $password\n\n'
          'Email: $studentEmail\n', // {{message}}
      'to_email': studentEmail, // {{to_email}}
      'name': 'EduPresence Admin', // {{name}} (used for From Name)
      'email': studentEmail, // {{email}} (used for Reply To)
    };

    debugPrint('📧 [EmailService] Sending credentials to: $studentEmail');
    debugPrint(
        '📧 [EmailService] Template params: ${json.encode(templateParams)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': templateParams,
        }),
      );

      debugPrint('📧 [EmailService] Response status: ${response.statusCode}');
      debugPrint('📧 [EmailService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ [EmailService] Email sent successfully to $studentEmail');
        return true;
      } else {
        debugPrint(
            '❌ [EmailService] Failed! Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e, stack) {
      debugPrint('❌ [EmailService] Exception: $e');
      debugPrint('❌ [EmailService] Stack: $stack');
      return false;
    }
  }
}
