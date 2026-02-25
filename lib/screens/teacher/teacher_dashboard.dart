import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupresence/providers/auth_provider.dart';
import 'package:edupresence/providers/student_provider.dart';
import 'package:edupresence/screens/teacher/add_student.dart';
import 'package:edupresence/screens/teacher/manage_classes.dart';
import 'package:edupresence/screens/teacher/mark_attendance.dart';
import 'package:edupresence/services/cloudinary_service.dart';
import 'package:edupresence/screens/teacher/change_password.dart';
import 'package:edupresence/screens/teacher/appearance.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:edupresence/screens/teacher/student_detail.dart';
import 'package:edupresence/services/email_service.dart';
import 'package:edupresence/widgets/snackbar_utils.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TeacherHomeTab(),
    const TeacherStudentsTab(),
    const MarkAttendance(),
    const TeacherProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF1A56BE),
          unselectedItemColor: const Color(0xFF94A3B8),
          backgroundColor: Colors.white,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline_rounded),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Students'),
            BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment_rounded),
                label: 'Attendance'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                activeIcon: Icon(Icons.account_circle_rounded),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class TeacherHomeTab extends StatelessWidget {
  const TeacherHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Hero(
          tag: 'logo',
          child: Image.asset("assets/logo.png",
              height: 60, // Increased logo size in app bar
              errorBuilder: (c, e, s) => const Text("EduPresence")),
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${authProvider.userData?['name']?.split(' ')[0] ?? 'Teacher'} 👋',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            letterSpacing: -0.5),
                      ),
                      const Text('Ready to manage your scholars today?',
                          style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Department: ${authProvider.userData?['department'] ?? 'N/A'}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage:
                      authProvider.userData?['profileImage'] != null
                          ? NetworkImage(authProvider.userData!['profileImage'])
                          : null,
                  child: authProvider.userData?['profileImage'] == null
                      ? Icon(Icons.school_rounded,
                          color: Theme.of(context).primaryColor, size: 28)
                      : null,
                )
              ],
            ),
            const SizedBox(height: 32),
            // Department-based student count
            StreamBuilder<QuerySnapshot>(
              stream: authProvider.userData?['department'] != null
                  ? studentProvider.getStudentsByDepartment(
                      authProvider.userData!['department'])
                  : studentProvider.getAllStudents(),
              builder: (context, snapshot) {
                final totalStudents = snapshot.data?.docs.length ?? 0;
                int presentToday = 0;
                final todayKey =
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if ((data['attendance']?[todayKey] ?? '') == 'Present') {
                      presentToday++;
                    }
                  }
                }
                double rate =
                    totalStudents == 0 ? 0 : (presentToday / totalStudents);
                String rateText = '${(rate * 100).toStringAsFixed(0)}%';

                return Column(
                  children: [
                    // Unified Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Today\'s Performance',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(rateText,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                    DateFormat('EEEE, MMM d')
                                        .format(DateTime.now()),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          LinearProgressIndicator(
                            value: rate,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 12),
                          Text(
                              '$presentToday of $totalStudents students present',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _miniStatCard(
                            context,
                            'Total Registrations',
                            totalStudents.toString(),
                            Icons.people_rounded,
                            const Color(0xFF6366F1)),
                        const SizedBox(width: 16),
                        _miniStatCard(context, 'System Health', 'Optimal',
                            Icons.bolt_rounded, const Color(0xFF10B981)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            Text(
              "Management Suite",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 20),
            _actionTile(
              context,
              "Onboard New Student",
              "Generate digital ID & credentials",
              Icons.person_add_rounded,
              const Color(0xFFF59E0B),
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddStudent())),
            ),
            _actionTile(
              context,
              "Mark Session Attendance",
              "Verify presence for active classes",
              Icons.how_to_reg_rounded,
              const Color(0xFF10B981),
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MarkAttendance())),
            ),
            _actionTile(
              context,
              "Academic Config",
              "Set working hours & rules",
              Icons.settings_suggest_rounded,
              const Color(0xFF64748B),
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageClasses())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(BuildContext context, String title, String subtitle,
      IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherStudentsTab extends StatelessWidget {
  const TeacherStudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Student Directory'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.iconTheme!.color,
        actions: [
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentProvider.getAllStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text('No scholars registered yet.'));

          final students = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index].data() as Map<String, dynamic>;
              // Removed className
              final String department = student['department'] ?? 'N/A';
              final String semester = student['semester'] ?? 'N/A';
              final int totalWorkingHours = student['totalWorkingHours'] ?? 0;
              final attendance =
                  student['attendance'] as Map<String, dynamic>? ?? {};

              int present =
                  attendance.values.where((v) => v == 'Present').length;

              // Use totalWorkingHours if available
              // Assuming each present is 1 hour for simplicity, or just calculate pct based on sessions if hours session mapping exists.
              // But for attendance pct, usually it's Present Sessions / Total Sessions held.
              // If totalWorkingHours is the target, then maybe Hours Completed / Total Hours.
              // For now, keeping logic similar but replacing totalDaysRequired with totalWorkingHours if appropriate, or just sessions.
              // Reverting to session based percentage for safely since "Working Hours" might be just a valid static field.

              double pct = totalWorkingHours > 0
                  ? (present / totalWorkingHours) *
                      100 // Crude approximation if hours == sessions
                  : (attendance.length == 0
                      ? 0
                      : (present / attendance.length) * 100);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentDetailScreen(
                          student: student,
                          studentId: students[index].id,
                        ),
                      ),
                    );
                  },
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Hero(
                    tag: 'student_${students[index].id}',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        backgroundImage: student['profileImage'] != null
                            ? NetworkImage(student['profileImage'])
                            : null,
                        child: student['profileImage'] == null
                            ? Text(
                                student['name']?[0]?.toUpperCase() ?? 'S',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  title: Text(student['name'] ?? 'Unknown',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.business_rounded,
                              size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '$department',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: pct >= 75
                                  ? Colors.green.withOpacity(0.1)
                                  : (pct >= 50
                                      ? Colors.orange.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${pct.toStringAsFixed(1)}% Attendance',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: pct >= 75
                                    ? Colors.green[700]
                                    : (pct >= 50
                                        ? Colors.orange[700]
                                        : Colors.red[700]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$semester',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddStudent())),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Add Student',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}

class TeacherProfileTab extends StatefulWidget {
  const TeacherProfileTab({super.key});

  @override
  State<TeacherProfileTab> createState() => _TeacherProfileTabState();
}

class _TeacherProfileTabState extends State<TeacherProfileTab> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() => _isUploading = true);
        final String? imageUrl =
            await CloudinaryService.uploadImage(File(image.path));

        if (imageUrl != null) {
          final error = await authProvider.updateProfileImage(imageUrl);
          if (error != null && mounted) {
            SnackbarUtils.showError(context, error);
          } else if (mounted) {
            SnackbarUtils.showSuccess(context, "Profile updated successfully!");
          }
        } else if (mounted) {
          SnackbarUtils.showError(context, "Failed to upload image.");
        }
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final String? profileImageUrl = userData?['profileImage'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Account Portfolio'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.iconTheme!.color,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: profileImageUrl == null
                            ? Icon(Icons.school_rounded,
                                size: 40, color: Theme.of(context).primaryColor)
                            : null,
                      ),
                    ),
                    if (_isUploading)
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                    GestureDetector(
                      onTap: _isUploading ? null : _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(userData?['name'] ?? 'Teacher',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 4),
                Text(userData?['email'] ?? 'N/A',
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text("Verified Educator",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          _profileItem(
              context,
              Icons.security_rounded,
              "Account Security",
              "Manage your credentials",
              () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  )),
          _profileItem(
              context,
              Icons.color_lens_rounded,
              "Appearance",
              "Custom dashboard theme",
              () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppearanceScreen(),
                    ),
                  )),
          _profileItem(context, Icons.help_center_rounded, "Support Center",
              "Contact EduPresence team", () {}),
          _profileItem(
            context,
            Icons.email_outlined,
            "Test EmailJS",
            "Verify email configuration",
            () async {
              SnackbarUtils.showSuccess(context, "Sending test email...");
              final success = await EmailService.sendStudentCredentials(
                studentEmail: authProvider.userData?['email'] ?? '',
                studentName: authProvider.userData?['name'] ?? 'Tester',
                password: 'TestPassword123',
              );
              if (mounted) {
                if (success) {
                  SnackbarUtils.showSuccess(
                      context, "Test email sent! Check your inbox.");
                } else {
                  SnackbarUtils.showError(
                      context, "Test failed. Check terminal logs.");
                }
              }
            },
          ),
          // Department info
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.business_rounded,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Department",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      userData?['department'] ?? 'Not Set',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFFEE2E2)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(16)),
              onPressed: () => authProvider.logout(),
              icon: const Icon(Icons.power_settings_new_rounded),
              label: const Text('LOGOUT SESSION',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _profileItem(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: Color(0xFF94A3B8)),
      ),
    );
  }
}
