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

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
                validator: (v) => v!.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: classController,
                decoration: const InputDecoration(
                    labelText: 'Class/Subject', prefixIcon: Icon(Icons.class_)),
                validator: (v) => v!.isEmpty ? 'Enter class' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: rollController,
                decoration: const InputDecoration(
                    labelText: 'Roll Number/ID',
                    prefixIcon: Icon(Icons.numbers)),
                validator: (v) => v!.isEmpty ? 'Enter roll number' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: studentProvider.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            String? error = await studentProvider.addStudent(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              className: classController.text.trim(),
                              rollNumber: rollController.text.trim(),
                            );
                            if (error != null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(error)));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Student added and credentials sent!')),
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                  child: studentProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ADD STUDENT',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
