import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmailService {
  // Replace these with your actual EmailJS credentials
  static const String _serviceId = 'service_vchknr2';
  static const String _templateId = 'template_ukwi087';
  static const String _publicKey = 'dva45dN9q3pwJsQyf';

  static Future<bool> sendStudentCredentials({
    required String studentEmail,
    required String studentName,
    required String password,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

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
          'template_params': {
            'to_email': studentEmail,
            'name': studentName,
            'email': studentEmail, // Used for Reply To in user's template
            'subject': 'Your EduPresence Credentials',
            'message': 'Welcome to EduPresence! Your account has been created.\n\n'
                'Email: $studentEmail\n'
                'Password: $password\n\n'
                'Please change your password after logging in for the first time.',
          },
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Email sent successfully!');
        return true;
      } else {
        debugPrint(
            'Failed to send email: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
      return false;
    }
  }
}
