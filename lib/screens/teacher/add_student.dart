import 'package:edupresence/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edupresence/widgets/snackbar_utils.dart';

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
  final totalDaysController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedSemester;

  final List<String> _departments = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
    'Electrical',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Other',
  ];

  final List<String> _semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8',
  ];

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
                const SizedBox(height: 20),
                // Department Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: const InputDecoration(
                      labelText: "Department",
                      labelStyle: TextStyle(color: Color(0xFF64748B)),
                      prefixIcon: Icon(Icons.business_rounded,
                          color: Color(0xFF475569)),
                      filled: true,
                      fillColor: Color(0xFFF8FAFC),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide:
                            BorderSide(color: Color(0xFF1A56BE), width: 2),
                      ),
                    ),
                    items: _departments
                        .map((dept) => DropdownMenuItem(
                              value: dept,
                              child: Text(dept),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedDepartment = value),
                    validator: (value) =>
                        value == null ? 'Select department' : null,
                  ),
                ),
                const SizedBox(height: 20),
                // Semester Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedSemester,
                    decoration: const InputDecoration(
                      labelText: "Semester",
                      labelStyle: TextStyle(color: Color(0xFF64748B)),
                      prefixIcon: Icon(Icons.calendar_month_outlined,
                          color: Color(0xFF475569)),
                      filled: true,
                      fillColor: Color(0xFFF8FAFC),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide:
                            BorderSide(color: Color(0xFF1A56BE), width: 2),
                      ),
                    ),
                    items: _semesters
                        .map((sem) => DropdownMenuItem(
                              value: sem,
                              child: Text(sem),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSemester = value),
                    validator: (value) =>
                        value == null ? 'Select semester' : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildField(
                  controller: totalDaysController,
                  label: "Total Days Required",
                  icon: Icons.event_available_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty || int.tryParse(v) == null
                      ? 'Enter valid number'
                      : null,
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
                                department: _selectedDepartment!,
                                semester: _selectedSemester!,
                                totalDaysRequired:
                                    int.parse(totalDaysController.text.trim()),
                              );
                              if (error != null && mounted) {
                                SnackbarUtils.showError(context, error);
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
