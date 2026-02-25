import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmailService {
  // EmailJS Configuration
  static const String _serviceId = 'service_vchknr2';
  static const String _templateId = 'template_ukwi087';
  static const String _publicKey = 'dva45dN9q3pwJsQyf';

  /// Sends student credentials via EmailJS.
  /// Returns null on success, or an error message on failure.
  static Future<bool> sendStudentCredentials({
    required String studentEmail,
    required String studentName,
    required String password,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    // Build template params with many aliases to ensure compatibility with various templates
    final templateParams = {
      'to_email': studentEmail,
      'user_email': studentEmail,
      'email': studentEmail,
      'recipient_email': studentEmail,
      'to_name': studentName,
      'student_name': studentName,
      'user_name': studentName,
      'password': password,
      'student_password': password,
      'user_password': password,
      'message': 'Hello $studentName,\n\n'
          'Your EduPresence account credentials are ready.\n\n'
          'Email: $studentEmail\n'
          'Temporary Password: $password\n\n'
          'Please change your password after logging in.',
      'subject': 'Your EduPresence Digital ID Credentials',
    };

    debugPrint('📧 [EmailService] Sending to: $studentEmail');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'https://api.emailjs.com',
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey, // EmailJS Public Key
          'template_params': templateParams,
        }),
      );

      debugPrint('📧 [EmailService] Response Code: ${response.statusCode}');
      debugPrint('📧 [EmailService] Response Body: ${response.body}');

      if (response.statusCode == 200 || response.body == 'OK') {
        debugPrint('✅ [EmailService] Sent successfully');
        return true;
      } else {
        debugPrint('❌ [EmailService] Failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [EmailService] Error: $e');
      return false;
    }
  }

  /// Sends SOS notification (Optional/Support for previous feature)
  static Future<bool> sendSOSAlert({
    required String studentName,
    required List<String> emergencyEmails,
    required String location,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    for (String email in emergencyEmails) {
      final templateParams = {
        'to_email': email,
        'student_name': studentName,
        'location': location,
        'message':
            'EMERGENCY: $studentName has triggered an SOS alert! Current location: $location',
        'subject': '🚨 SOS ALERT: $studentName 🚨',
      };

      try {
        await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'service_id': _serviceId,
            'template_id': _templateId, // Using same template for now
            'user_id': _publicKey,
            'template_params': templateParams,
          }),
        );
      } catch (e) {
        debugPrint('📧 [EmailService] SOS Error for $email: $e');
      }
    }
    return true;
  }
}
