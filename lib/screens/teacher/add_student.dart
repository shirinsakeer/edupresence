import 'package:edupresence/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddStudent extends StatefulWidget {
  const AddStudent({super.key});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final classController = TextEditingController();
  final rollController = TextEditingController();

  void _showSuccessDialog(String email, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text('Credentials Issued!', textAlign: TextAlign.center),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'The student has been successfully registered. Login credentials have been sent to:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Text(
                email,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF1A56BE)),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Password format: Std[ID]123',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to student list
                },
                child: const Text('DONE'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Issue Credentials'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Issue Credentials",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Onboard a new scholar with their digital ID.",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                _buildField(
                  controller: nameController,
                  label: "Full Name",
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v!.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 20),
                _buildField(
                  controller: emailController,
                  label: "Email Address",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty || !v.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: classController,
                        label: "Class/Subject",
                        icon: Icons.school_outlined,
                        validator: (v) => v!.isEmpty ? 'Enter class' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(
                        controller: rollController,
                        label: "Roll Number/ID",
                        icon: Icons.numbers_rounded,
                        validator: (v) => v!.isEmpty ? 'Enter ID' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A56BE),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: studentProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              String email = emailController.text.trim();
                              String roll = rollController.text.trim();
                              String? error = await studentProvider.addStudent(
                                name: nameController.text.trim(),
                                email: email,
                                className: classController.text.trim(),
                                rollNumber: roll,
                              );
                              if (error != null && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)));
                              } else if (mounted) {
                                _showSuccessDialog(email, "Std${roll}123");
                              }
                            }
                          },
                    child: studentProvider.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3))
                        : const Text('ISSUE CREDENTIALS',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    "Note: Credentials will be sent via EmailJS service",
                    style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, color: const Color(0xFF475569)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1A56BE), width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
