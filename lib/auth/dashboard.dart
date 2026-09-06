import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  void _fetchUser() async {
    final data = await _authService.getUser();
    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  void _handleLogout() async {
  await _authService.logout();
  if (mounted) {
    // Clear route history and direct to WelcomeScreen
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saturn Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${_userData!['name']}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Email: ${_userData!['email']}'),
                      const SizedBox(height: 8),
                      const Text(
                        'Status: Authenticated via Sanctum API Token',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Text('Failed to load user data. Unauthenticated.'),
                ),
    );
  }
}