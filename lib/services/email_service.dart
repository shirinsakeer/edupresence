import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmailService {
  // Replace these with your actual EmailJS credentials
  static const String _serviceId = 'service_edupresence';
  static const String _templateId = 'template_student_creds';
  static const String _publicKey =
      'USER_PUBLIC_KEY'; // Replace with your EmailJS Public Key

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
            'to_name': studentName,
            'user_password': password,
            'app_name': 'EduPresence',
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
