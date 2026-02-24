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

    // Build template params — using multiple common names to ensure compatibility with various EmailJS templates
    final templateParams = {
      'to_email': studentEmail, // Best practice for "To Email" field
      'user_email': studentEmail, // Common alternative
      'email': studentEmail, // Common alternative
      'to_name': studentName, // Best practice for recipient name
      'student_name': studentName, // Specific to our template
      'password': password, // The dynamic password
      'message': 'Hello $studentName,\n\n'
          'Your EduPresence account credentials are ready.\n\n'
          'Email: $studentEmail\n'
          'Temporary Password: $password\n\n'
          'Please change your password after logging in.',
      'subject': 'Your EduPresence Digital ID Credentials',
    };

    debugPrint(
        '📧 [EmailService] Attempting to send credentials to: $studentEmail');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': templateParams,
        }),
      );

      debugPrint('📧 [EmailService] Status: ${response.statusCode}');
      debugPrint('📧 [EmailService] Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ [EmailService] Credentials sent successfully');
        return true;
      } else {
        debugPrint(
            '❌ [EmailService] Send failed. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [EmailService] Error occurred: $e');
      return false;
    }
  }
}
