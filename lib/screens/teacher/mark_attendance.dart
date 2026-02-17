import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupresence/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:edupresence/widgets/snackbar_utils.dart';

class MarkAttendance extends StatefulWidget {
  const MarkAttendance({super.key});

  @override
  State<MarkAttendance> createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {
  String? selectedClass;
  String? selectedSemester;
  DateTime selectedDate = DateTime.now();

  final List<String> semesters = [
    'All',
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8',
  ];

  @override
  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.iconTheme?.color,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedDepartment,
                        dropdownColor: Theme.of(context).cardColor,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Select Department',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.business_rounded,
                              color: Theme.of(context).primaryColor),
                          filled: true,
                          fillColor: isDark
                              ? Theme.of(context).scaffoldBackgroundColor
                              : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
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
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => selectedDepartment = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedSemester,
                        dropdownColor: Theme.of(context).cardColor,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Select Semester',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.school_rounded,
                              color: Theme.of(context).primaryColor),
                          filled: true,
                          fillColor: isDark
                              ? Theme.of(context).scaffoldBackgroundColor
                              : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: semesters
                            .where((s) => s != 'All')
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedSemester = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: isDark
                                ? ColorScheme.dark(
                                    primary: Theme.of(context).primaryColor,
                                    onPrimary: Colors.white,
                                    surface: const Color(0xFF1E293B))
                                : ColorScheme.light(
                                    primary: Theme.of(context).primaryColor),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) setState(() => selectedDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('EEEE, dd MMM yyyy').format(selectedDate),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (selectedDepartment != null && selectedSemester != null)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: studentProvider.getStudentsByDepartmentAndSemester(
                    selectedDepartment!, selectedSemester!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_off_rounded,
                              size: 64, color: Theme.of(context).dividerColor),
                          const SizedBox(height: 16),
                          Text('No students found',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.6))),
                        ],
                      ),
                    );
                  }

                  final students = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final studentData =
                          student.data() as Map<String, dynamic>;
                      final dateKey =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                      final currentStatus =
                          (studentData['attendance'] ?? {})[dateKey] ?? 'None';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            backgroundImage: studentData['profileImage'] != null
                                ? NetworkImage(studentData['profileImage'])
                                : null,
                            child: studentData['profileImage'] == null
                                ? Text(studentData['name']?[0] ?? 'S',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold))
                                : null,
                          ),
                          title: Text(studentData['name'],
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(currentStatus),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  currentStatus == 'None'
                                      ? 'Not marked'
                                      : currentStatus,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: _getStatusColor(currentStatus),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Simplified UI for space
                              Transform.scale(
                                scale: 0.9,
                                child: Switch(
                                  value: currentStatus == 'Present',
                                  activeColor: const Color(0xFF10B981),
                                  inactiveThumbColor: const Color(0xFFEF4444),
                                  inactiveTrackColor:
                                      const Color(0xFFEF4444).withOpacity(0.3),
                                  activeTrackColor:
                                      const Color(0xFF10B981).withOpacity(0.3),
                                  onChanged: (value) async {
                                    final dateKey = DateFormat('yyyy-MM-dd')
                                        .format(selectedDate);
                                    try {
                                      await Provider.of<StudentProvider>(
                                              context,
                                              listen: false)
                                          .markAttendance(
                                        studentId: student.id,
                                        date: dateKey,
                                        status: value ? 'Present' : 'Absent',
                                      );
                                    } catch (e) {
                                      if (context.mounted) {
                                        SnackbarUtils.showError(
                                            context, "Failed: $e");
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_upward_rounded,
                        size: 48, color: Theme.of(context).dividerColor),
                    const SizedBox(height: 16),
                    Text('Select department and semester',
                        style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.6))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? selectedDepartment; // Added variable

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFF10B981);
      case 'Absent':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }
}
