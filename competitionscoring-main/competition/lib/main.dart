import 'package:competition/pages/admin_college_info.dart';
import 'package:competition/pages/admin_score_rules.dart';
import 'package:competition/pages/forgot_password_page.dart';
import 'package:competition/pages/student_home_page.dart';
import 'package:competition/pages/teacher_home_page.dart';
import 'package:competition/pages/login_page.dart';
import 'package:competition/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'pages/admin_home_page.dart';

void main() => runApp(const ScoreSystemApp());

class ScoreSystemApp extends StatelessWidget {
  const ScoreSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '比赛评分系统',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/teacherHome': (context) => const TeacherHomePage(),
        '/studentHome': (context) => const StudentHomePage(),
        '/forgotPassword': (context) => const ForgotPasswordPage(),
        '/register': (context) => const UserRegisterPage(),
        '/adminHome': (context) => const AdminHomePage(),
        '/adminCollegeInfo': (context) => const CollegeInfoPage(),
        '/adminScoreRules': (context) => const ScoreRulesPage(),
      },
    );
  }
}

