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
        title: const Text('Issue Student Credentials'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Student Information",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 5),
              const Text(
                "Enter details to create an account and automatically send credentials via email.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) => v!.isEmpty || !v.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: classController,
                      decoration: const InputDecoration(
                        labelText: 'Class/Subject',
                        prefixIcon: Icon(Icons.class_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? 'Enter class' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: rollController,
                      decoration: const InputDecoration(
                        labelText: 'Roll Number/ID',
                        prefixIcon: Icon(Icons.numbers_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? 'Enter ID' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                            if (error != null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(error)));
                            } else {
                              _showSuccessDialog(email, "Std${roll}123");
                            }
                          }
                        },
                  child: studentProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('ISSUE CREDENTIALS',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Note: Credentials will be sent via EmailJS service",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
