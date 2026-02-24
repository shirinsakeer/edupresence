import 'package:edupresence/services/email_service.dart';
import 'package:edupresence/widgets/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  final String studentId;

  const StudentDetailScreen({
    super.key,
    required this.student,
    required this.studentId,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  bool _isIssuing = false;

  Future<void> _issueCredentials() async {
    final String name = widget.student['name'] ?? 'Student';
    final String? email = widget.student['email'];
    final String rollNumber = widget.student['rollNumber'] ?? '000';

    if (email == null || email.isEmpty) {
      SnackbarUtils.showError(context, "Student email not found.");
      return;
    }

    setState(() => _isIssuing = true);

    try {
      // Formula used during creation: Std${rollNumber}123
      String tempPassword = "Std${rollNumber}123";

      bool success = await EmailService.sendStudentCredentials(
        studentEmail: email,
        studentName: name,
        password: tempPassword,
      );

      if (success && mounted) {
        SnackbarUtils.showSuccess(
            context, "Credentials sent to $email successfully!");
      } else if (mounted) {
        SnackbarUtils.showError(context,
            "Failed to send credentials. Please check EmailJS config.");
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isIssuing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.student['name'] ?? 'Unknown';
    final String email = widget.student['email'] ?? 'N/A';
    final String rollNumber = widget.student['rollNumber'] ?? 'N/A';
    final String department = widget.student['department'] ?? 'N/A';
    final String semester = widget.student['semester'] ?? 'N/A';
    final int totalWorkingHours = widget.student['totalWorkingHours'] ?? 0;
    final String? profileImage = widget.student['profileImage'];
    final Map<String, dynamic> attendance =
        widget.student['attendance'] as Map<String, dynamic>? ?? {};

    int presentCount = attendance.values.where((v) => v == 'Present').length;
    int absentCount = attendance.values.where((v) => v == 'Absent').length;
    double attendancePercentage = totalWorkingHours > 0
        ? (presentCount / totalWorkingHours) * 100
        : (attendance.isEmpty ? 0 : (presentCount / attendance.length) * 100);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF1A56BE),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (profileImage != null)
                    Image.network(
                      profileImage,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      color: const Color(0xFF1A56BE),
                      child: Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 100,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Basic Information'),
                      if (_isIssuing)
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        TextButton.icon(
                          onPressed: _issueCredentials,
                          icon: const Icon(Icons.vpn_key_outlined, size: 18),
                          label: const Text(
                            'Issue Credentials',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1A56BE),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(context, [
                    _buildInfoTile(Icons.email_outlined, 'Email', email),
                    _buildInfoTile(
                        Icons.numbers_rounded, 'Roll Number', rollNumber),
                    _buildInfoTile(
                        Icons.business_rounded, 'Department', department),
                    _buildInfoTile(
                        Icons.calendar_month_outlined, 'Semester', semester),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Attendance Summary'),
                  const SizedBox(height: 16),
                  _buildAttendanceSummaryCard(
                    context,
                    attendancePercentage,
                    presentCount,
                    absentCount,
                    totalWorkingHours,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Attendance History'),
                  const SizedBox(height: 16),
                  if (attendance.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No attendance records found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    _buildAttendanceHistory(attendance),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1E293B),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A56BE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF1A56BE)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummaryCard(
    BuildContext context,
    double percentage,
    int present,
    int absent,
    int total,
  ) {
    final color = percentage >= 75
        ? Colors.green
        : (percentage >= 50 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryText('Present', present.toString()),
                const SizedBox(height: 8),
                _buildSummaryText('Absent', absent.toString()),
                const SizedBox(height: 8),
                _buildSummaryText('Total Hours', total.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryText(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceHistory(Map<String, dynamic> attendance) {
    final sortedDates = attendance.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDates.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final status = attendance[date];
        final isPresent = status == 'Present';

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            DateFormat('MMMM dd, yyyy').format(DateTime.parse(date)),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPresent
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isPresent ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}
