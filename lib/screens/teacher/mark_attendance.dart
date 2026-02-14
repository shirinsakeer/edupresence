import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupresence/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MarkAttendance extends StatefulWidget {
  const MarkAttendance({super.key});

  @override
  State<MarkAttendance> createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {
  String? selectedClass;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<String>>(
                        stream: studentProvider.getAllClasses(),
                        builder: (context, snapshot) {
                          final classes = snapshot.data ?? [];
                          return DropdownButtonFormField<String>(
                            value: selectedClass,
                            decoration: InputDecoration(
                              hintText: 'Choose Class',
                              prefixIcon: const Icon(Icons.school_rounded,
                                  color: Color(0xFF1A56BE)),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: classes
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => selectedClass = v),
                          );
                        },
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
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF1A56BE),
                            ),
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
                      color: const Color(0xFF1A56BE).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF1A56BE).withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 18, color: Color(0xFF1A56BE)),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('EEEE, dd MMM yyyy').format(selectedDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A56BE),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (selectedClass != null)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: studentProvider.getStudentsByClass(selectedClass!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF1A56BE)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_off_rounded,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('No students found in this class',
                              style: TextStyle(color: Color(0xFF64748B))),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                const Color(0xFF1A56BE).withOpacity(0.1),
                            backgroundImage: studentData['profileImage'] != null
                                ? NetworkImage(studentData['profileImage'])
                                : null,
                            child: studentData['profileImage'] == null
                                ? Text(studentData['name']?[0] ?? 'S',
                                    style: const TextStyle(
                                        color: Color(0xFF1A56BE),
                                        fontWeight: FontWeight.bold))
                                : null,
                          ),
                          title: Text(studentData['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B))),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Current: $currentStatus',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _getStatusColor(currentStatus),
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _statusAction(student.id, 'Present',
                                  const Color(0xFF10B981), currentStatus),
                              const SizedBox(width: 8),
                              _statusAction(student.id, 'Late',
                                  const Color(0xFFF59E0B), currentStatus),
                              const SizedBox(width: 8),
                              _statusAction(student.id, 'Absent',
                                  const Color(0xFFEF4444), currentStatus),
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
                        size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('Select a class to start marking',
                        style: TextStyle(color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFF10B981);
      case 'Late':
        return const Color(0xFFF59E0B);
      case 'Absent':
        return const Color(0xFFEF4444);
      default:
        return Color(0xFF94A3B8);
    }
  }

  Widget _statusAction(
      String studentId, String status, Color color, String currentStatus) {
    bool isSelected = currentStatus == status;
    return GestureDetector(
      onTap: () {
        final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
        Provider.of<StudentProvider>(context, listen: false).markAttendance(
          studentId: studentId,
          date: dateKey,
          status: status,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          status == 'Present'
              ? Icons.check_rounded
              : (status == 'Late'
                  ? Icons.access_time_rounded
                  : Icons.close_rounded),
          size: 20,
          color: isSelected ? Colors.white : color,
        ),
      ),
    );
  }
}
