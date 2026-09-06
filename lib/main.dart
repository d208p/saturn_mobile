import 'package:flutter/material.dart';
import 'package:saturn_app/auth/dashboard.dart';
import 'package:saturn_app/auth/login.dart';
import 'package:saturn_app/auth/register.dart';
import 'package:saturn_app/services/auth_service.dart';
import 'package:saturn_app/theme/colors.dart';
import 'package:saturn_app/welcome.dart';
import 'package:saturn_app/widgets/saturn_theme.dart';

void main() {
  runApp(const SaturnApp());
}

class SaturnApp extends StatelessWidget {
  const SaturnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saturn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthCheckScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _authService.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.midnight,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.gold,
              ),
            ),
          );
        }

        // Logged-in user -> Dashboard
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }

        // Unauthenticated -> Welcome choice screen
        return const WelcomeScreen();
      },
    );
  }
}