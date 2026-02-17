import 'package:edupresence/providers/auth_provider.dart';
import 'package:edupresence/screens/student/chatbot.dart';
import 'package:edupresence/services/cloudinary_service.dart';
import 'package:edupresence/screens/student/edit_profile.dart';
import 'package:edupresence/screens/teacher/change_password.dart';
import 'package:edupresence/screens/teacher/appearance.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:edupresence/widgets/snackbar_utils.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const StudentHomeTab(),
    const ChatBotScreen(),
    const StudentProfileTab(),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_filled),
                label: 'Summary'),
            BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_outlined),
                activeIcon: Icon(Icons.auto_awesome),
                label: 'EduAI'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_pin_outlined),
                activeIcon: Icon(Icons.person_pin_rounded),
                label: 'Identity'),
          ],
        ),
      ),
    );
  }
}

class StudentHomeTab extends StatelessWidget {
  const StudentHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final attendance = userData?['attendance'] as Map<String, dynamic>? ?? {};
    final int totalDaysRequired = userData?['totalDaysRequired'] ?? 0;
    final String department = userData?['department'] ?? 'N/A';
    final String semester = userData?['semester'] ?? 'N/A';

    int presentDays = attendance.values.where((v) => v == 'Present').length;
    int absentDays = attendance.values.where((v) => v == 'Absent').length;
    int totalRecorded = attendance.length;

    // Calculate percentage based on totalDaysRequired if available, otherwise use recorded days
    double percentage = totalDaysRequired > 0
        ? (presentDays / totalDaysRequired) * 100
        : (totalRecorded == 0 ? 0 : (presentDays / totalRecorded) * 100);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Hero(
          tag: 'logo',
          child: Image.asset("assets/logo.png",
              height: 60, errorBuilder: (c, e, s) => const Text("EduPresence")),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.auto_awesome_rounded,
                  color: Theme.of(context).primaryColor),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChatBotScreen()))),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Aloha, ${userData?['name']?.split(' ')[0] ?? 'Student'}!',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.school_rounded,
                                size: 14,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              '$department • $semester',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8)
                          ]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10))
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('ATTENDANCE SCORE',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 12),
                        Text('${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 56,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _miniStat('PRESENT', '$presentDays'),
                              Container(
                                  width: 1, height: 20, color: Colors.white24),
                              _miniStat('ABSENT', '$absentDays'),
                              Container(
                                  width: 1, height: 20, color: Colors.white24),
                              _miniStat('REQUIRED', '$totalDaysRequired'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Activity Timeline",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color)),
                      TextButton(
                        onPressed: () {},
                        child: const Text("View All",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          attendance.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        const Text('No sessions logged yet.',
                            style: TextStyle(color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final sortedKeys = attendance.keys.toList()
                          ..sort((a, b) => b.compareTo(a));
                        String date = sortedKeys[index];
                        String status = attendance[date];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                          ),
                          child: ListTile(
                            leading: _statusIcon(status),
                            title: Text(date,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(status,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                      color: _statusColor(status))),
                            ),
                          ),
                        );
                      },
                      childCount: attendance.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900)),
        Text(label,
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statusIcon(String status) {
    IconData icon;
    Color color;
    if (status == 'Present') {
      icon = Icons.check_rounded;
      color = const Color(0xFF10B981);
    } else if (status == 'Late') {
      icon = Icons.timer_outlined;
      color = const Color(0xFFF59E0B);
    } else {
      icon = Icons.close_rounded;
      color = const Color(0xFFEF4444);
    }
    return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20));
  }

  Color _statusColor(String status) {
    if (status == 'Present') return const Color(0xFF10B981);
    if (status == 'Late') return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class StudentProfileTab extends StatefulWidget {
  const StudentProfileTab({super.key});

  @override
  State<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends State<StudentProfileTab> {
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
          SnackbarUtils.showError(context,
              "Failed to upload image. Please check your Cloudinary credentials.");
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, "Error: $e");
      }
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
        title: const Text('Digital ID'),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.iconTheme!.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]),
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
                          radius: 55,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl == null
                              ? const Icon(Icons.person_rounded,
                                  size: 60, color: Color(0xFF94A3B8))
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
                        onTap:
                            _isUploading ? null : () => _pickAndUploadImage(),
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
                  Text(userData?['name'] ?? 'Scholar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).textTheme.bodyLarge?.color)),
                  Text(userData?['email'] ?? 'N/A',
                      style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _idBadge("ROLL #", userData?['rollNumber'] ?? 'N/A',
                          Icons.badge_rounded, context),
                      const SizedBox(width: 16),
                      _idBadge("SEMESTER", userData?['semester'] ?? 'N/A',
                          Icons.calendar_today_rounded, context),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _idBadge("DEPARTMENT", userData?['department'] ?? 'N/A',
                          Icons.business_rounded, context),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _profileItem(
              context,
              Icons.edit_rounded,
              "Edit Profile",
              "Update your name",
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditStudentProfileScreen(),
                ),
              ),
            ),
            _profileItem(
              context,
              Icons.lock_outline_rounded,
              "Change Password",
              "Update your password",
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              ),
            ),
            _profileItem(
              context,
              Icons.color_lens_outlined,
              "Appearance",
              "Theme preferences",
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppearanceScreen(),
                ),
              ),
            ),
            _profileItem(
              context,
              Icons.assignment_outlined,
              "Download Report",
              "Get attendance PDF",
              () {
                SnackbarUtils.showSuccess(
                  context,
                  "Report generation coming soon!",
                );
              },
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
          ],
        ),
      ),
    );
  }

  Widget _idBadge(
      String label, String value, IconData icon, BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Theme.of(context).primaryColor),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }

  Widget _profileItem(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A56BE).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1A56BE), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF94A3B8),
        ),
        onTap: onTap,
      ),
    );
  }
}
