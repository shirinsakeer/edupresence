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
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedClass,
                    hint: const Text('Select Class'),
                    items: [
                      'Class A',
                      'Class B',
                      'Class C'
                    ] // In real app, fetch from classes collection
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedClass = v),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => selectedDate = date);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('dd-MM-yyyy').format(selectedDate)),
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No students found in this class'));
                  }

                  final students = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final studentData =
                          student.data() as Map<String, dynamic>;
                      final dateKey =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                      final currentStatus =
                          (studentData['attendance'] ?? {})[dateKey] ?? 'None';

                      return ListTile(
                        title: Text(studentData['name']),
                        subtitle: Text('Status: $currentStatus'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _statusButton(student.id, 'Present', Colors.green,
                                currentStatus),
                            _statusButton(student.id, 'Late', Colors.orange,
                                currentStatus),
                            _statusButton(student.id, 'Absent', Colors.red,
                                currentStatus),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusButton(
      String studentId, String status, Color color, String currentStatus) {
    bool isSelected = currentStatus == status;
    return IconButton(
      icon: Icon(
        status == 'Present'
            ? Icons.check_circle
            : (status == 'Late' ? Icons.access_time_filled : Icons.cancel),
        color: isSelected ? color : Colors.grey,
      ),
      onPressed: () {
        final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
        Provider.of<StudentProvider>(context, listen: false).markAttendance(
          studentId: studentId,
          date: dateKey,
          status: status,
        );
      },
    );
  }
}
