import 'package:edupresence/providers/auth_provider.dart';
import 'package:edupresence/screens/student/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A56BE),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined),
              activeIcon: Icon(Icons.smart_toy),
              label: 'AI Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
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

    int totalDays = attendance.length;
    int presentDays = attendance.values.where((v) => v == 'Present').length;
    double percentage = totalDays == 0 ? 0 : (presentDays / totalDays) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Image.asset("assets/logo.png",
            height: 40, errorBuilder: (c, e, s) => const Text("EduPresence")),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, ${userData?['name'] ?? 'Student'}',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B))),
                  const Text('Here is your academic summary',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF1A56BE), Color(0xFF3B82F6)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF1A56BE).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('Attendance Score',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 10),
                        Text('${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _miniStat('Present', '$presentDays'),
                            const SizedBox(width: 20),
                            _miniStat('Total Days', '$totalDays'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  const Text("Recent Records",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B))),
                ],
              ),
            ),
          ),
          attendance.isEmpty
              ? const SliverFillRemaining(
                  child: Center(child: Text('No attendance records found.')))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      String date = attendance.keys.elementAt(index);
                      String status = attendance.values.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                          child: ListTile(
                            leading: _statusIcon(status),
                            title: Text(date,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            trailing: Text(status,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _statusColor(status))),
                          ),
                        ),
                      );
                    },
                    childCount: attendance.length,
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
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _statusIcon(String status) {
    IconData icon;
    Color color;
    if (status == 'Present') {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (status == 'Late') {
      icon = Icons.access_time_filled;
      color = Colors.orange;
    } else {
      icon = Icons.cancel;
      color = Colors.red;
    }
    return CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20));
  }

  Color _statusColor(String status) {
    if (status == 'Present') return Colors.green;
    if (status == 'Late') return Colors.orange;
    return Colors.red;
  }
}

class StudentProfileTab extends StatelessWidget {
  const StudentProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF1A56BE),
                child: Icon(Icons.school, size: 50, color: Colors.white)),
            const SizedBox(height: 20),
            Text(userData?['name'] ?? 'Student',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(userData?['email'] ?? 'N/A',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            _infoCard(
                "Class/Section", userData?['className'] ?? 'N/A', Icons.class_),
            _infoCard(
                "Student ID", userData?['rollNumber'] ?? 'N/A', Icons.badge),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0),
                onPressed: () => authProvider.logout(),
                icon: const Icon(Icons.logout),
                label: const Text('SIGN OUT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1A56BE)),
        title: Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B))),
      ),
    );
  }
}
