import 'package:edupresence/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edupresence/widgets/snackbar_utils.dart';

class ManageClasses extends StatefulWidget {
  const ManageClasses({super.key});

  @override
  State<ManageClasses> createState() => _ManageClassesState();
}

class _ManageClassesState extends State<ManageClasses> {
  final TextEditingController _daysController = TextEditingController();
  bool _isLoading = false;
  String? _selectedDepartment;
  String? _selectedSemester;

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Academic Hours')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Academic Config",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Set total working hours for a Department and Semester.",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(
                  labelText: "Department",
                  prefixIcon:
                      Icon(Icons.business_rounded, color: Color(0xFF475569)),
                ),
                items: [
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
                ]
                    .map((dept) =>
                        DropdownMenuItem(value: dept, child: Text(dept)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDepartment = v),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: const InputDecoration(
                  labelText: "Semester",
                  prefixIcon: Icon(Icons.calendar_month_outlined,
                      color: Color(0xFF475569)),
                ),
                items: [
                  'Semester 1',
                  'Semester 2',
                  'Semester 3',
                  'Semester 4',
                  'Semester 5',
                  'Semester 6',
                  'Semester 7',
                  'Semester 8',
                ]
                    .map(
                        (sem) => DropdownMenuItem(value: sem, child: Text(sem)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSemester = v),
              ),
              const SizedBox(height: 20),
              _buildField(
                controller: _daysController,
                label: "Total Working Hours", // Changed label
                icon: Icons.access_time_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_selectedDepartment == null ||
                              _selectedSemester == null ||
                              _daysController.text.trim().isEmpty) {
                            SnackbarUtils.showError(
                                context, "Please fill all fields");
                            return;
                          }

                          int? hours =
                              int.tryParse(_daysController.text.trim());
                          if (hours == null || hours <= 0) {
                            SnackbarUtils.showError(
                                context, "Please enter a valid number");
                            return;
                          }

                          setState(() => _isLoading = true);
                          try {
                            // Fetch students
                            var snapshot = await studentProvider
                                .getStudentsByDepartmentAndSemester(
                                    _selectedDepartment!, _selectedSemester!)
                                .first;

                            if (snapshot.docs.isEmpty) {
                              if (mounted) {
                                SnackbarUtils.showError(context,
                                    "No students found for this selection");
                              }
                            } else {
                              // Update all students
                              // Note: This is a batch operation on client side, ideal would be a cloud function but this works for valid number of students
                              for (var doc in snapshot.docs) {
                                await studentProvider.updateStudentWorkingHours(
                                    doc.id, hours);
                              }
                              if (mounted) {
                                SnackbarUtils.showSuccess(context,
                                    "Updated working hours for ${snapshot.docs.length} students");
                                _daysController.clear();
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              SnackbarUtils.showError(
                                  context, "Error updating: $e");
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A56BE),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
                      : const Text("UPDATE STUDENTS",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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
    );
  }
}
