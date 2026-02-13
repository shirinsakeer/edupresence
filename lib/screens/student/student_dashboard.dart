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
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
    final attendance =
        authProvider.userData?['attendance'] as Map<String, dynamic>? ?? {};

    int totalDays = attendance.length;
    int presentDays = attendance.values.where((v) => v == 'Present').length;
    double percentage = totalDays == 0 ? 0 : (presentDays / totalDays) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF1976D2)]),
                ),
                child: Column(
                  children: [
                    const Text('Overall Attendance',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('$presentDays / $totalDays Days Present',
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Recent History',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Expanded(
              child: attendance.isEmpty
                  ? const Center(child: Text('No attendance records yet'))
                  : ListView.builder(
                      itemCount: attendance.length,
                      itemBuilder: (context, index) {
                        String date = attendance.keys.elementAt(index);
                        String status = attendance.values.elementAt(index);
                        return ListTile(
                          leading: Icon(
                            status == 'Present'
                                ? Icons.check_circle
                                : (status == 'Late'
                                    ? Icons.access_time_filled
                                    : Icons.cancel),
                            color: status == 'Present'
                                ? Colors.green
                                : (status == 'Late'
                                    ? Colors.orange
                                    : Colors.red),
                          ),
                          title: Text(date),
                          trailing: Text(status,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: status == 'Present'
                                      ? Colors.green
                                      : (status == 'Late'
                                          ? Colors.orange
                                          : Colors.red))),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentProfileTab extends StatelessWidget {
  const StudentProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            Text(authProvider.userData?['name'] ?? 'N/A',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(authProvider.userData?['email'] ?? 'N/A',
                style: const TextStyle(color: Colors.grey)),
            Text('Class: ${authProvider.userData?['className'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => authProvider.logout(),
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT'),
            ),
          ],
        ),
      ),
    );
  }
}
