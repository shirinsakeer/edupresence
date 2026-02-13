import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupresence/providers/auth_provider.dart';
import 'package:edupresence/providers/student_provider.dart';
import 'package:edupresence/screens/teacher/add_student.dart';
import 'package:edupresence/screens/teacher/mark_attendance.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A56BE),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Students'),
          BottomNavigationBarItem(
              icon: Icon(Icons.how_to_reg_outlined),
              activeIcon: Icon(Icons.how_to_reg),
              label: 'Attendance'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Image.asset("assets/logo.png",
            height: 40, errorBuilder: (c, e, s) => const Text("EduPresence")),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${authProvider.userData?['name'] ?? 'Teacher'}',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
            const Text('Here is what\'s happening today',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            StreamBuilder<QuerySnapshot>(
              stream: studentProvider.getAllStudents(),
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
                String attendanceRate = totalStudents == 0
                    ? '0%'
                    : '${((presentToday / totalStudents) * 100).toStringAsFixed(0)}%';

                return Row(
                  children: [
                    _statCard('Total Students', totalStudents.toString(),
                        Colors.blue, Icons.people),
                    const SizedBox(width: 15),
                    _statCard('Today\'s Attendance', attendanceRate,
                        Colors.green, Icons.calendar_today),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              "Quick Actions",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 15),
            _quickActionCard(
              context,
              "Issue New Credentials",
              "Register a student and send login info",
              Icons.person_add_alt_1,
              Colors.orange,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddStudent())),
            ),
            _quickActionCard(
              context,
              "Mark Daily Attendance",
              "Update presence for your classes",
              Icons.assignment_turned_in,
              Colors.indigo,
              () {/* Navigate to attendance tab or screen */},
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 15),
            Text(value,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B))),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _quickActionCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey[200]!)),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Student Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddStudent())),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentProvider.getAllStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text('No students found.'));

          final students = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE2E8F0),
                      child: Icon(Icons.person, color: Color(0xFF64748B))),
                  title: Text(student['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${student['className']} • ID: ${student['rollNumber']}'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TeacherProfileTab extends StatelessWidget {
  const TeacherProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF1A56BE),
                    child: Icon(Icons.person, size: 50, color: Colors.white)),
                const SizedBox(height: 15),
                Text(authProvider.userData?['name'] ?? 'Teacher',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text(authProvider.userData?['email'] ?? 'N/A',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Divider(),
          _profileTile(Icons.notifications_outlined, "Notification Settings"),
          _profileTile(Icons.security_outlined, "Privacy & Security"),
          _profileTile(Icons.help_outline, "Help & Support"),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                elevation: 0),
            onPressed: () => authProvider.logout(),
            icon: const Icon(Icons.logout),
            label: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  Widget _profileTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}
