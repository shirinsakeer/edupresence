import 'package:edupresence/login.dart';
import 'package:edupresence/providers/auth_provider.dart';
import 'package:edupresence/providers/student_provider.dart';
import 'package:edupresence/providers/chat_provider.dart';
import 'package:edupresence/screens/teacher/teacher_dashboard.dart';
import 'package:edupresence/screens/student/student_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduPresence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A56BE),
          primary: const Color(0xFF1A56BE),
          secondary: const Color(0xFF2C3E50),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.w800),
          iconTheme: IconThemeData(color: Color(0xFF1E293B)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE2E8F0))),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A56BE),
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
      return const Login();
    }

    if (authProvider.role == UserRole.teacher) {
      return const TeacherDashboard();
    } else if (authProvider.role == UserRole.student) {
      return const StudentDashboard();
    } else {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF1A56BE)),
              SizedBox(height: 16),
              Text("Syncing your dashboard...",
                  style: TextStyle(
                      color: Color(0xFF64748B), fontWeight: FontWeight.w500))
            ],
          ),
        ),
      );
    }
  }
}
