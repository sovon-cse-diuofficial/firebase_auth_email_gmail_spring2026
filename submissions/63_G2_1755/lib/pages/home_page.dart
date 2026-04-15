import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthService authService = AuthService();

  bool _hasProvider(User? user, String providerId) {
    if (user == null) {
      return false;
    }

    return user.providerData.any((provider) => provider.providerId == providerId);
  }

  String _formatNameFromEmail(String? email) {
    if (email == null || !email.contains('@')) {
      return 'User';
    }

    final String localPart = email.split('@').first;
    if (localPart.isEmpty) {
      return 'User';
    }

    final List<String> parts = localPart
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'User';
    }

    return parts
        .map(
          (part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _fullName(User? user) {
    final String? displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    // For email/password users, use only the saved registration name.
    if (_hasProvider(user, 'password')) {
      return 'User';
    }

    return _formatNameFromEmail(user?.email);
  }

  Future<void> _logout(BuildContext context) async {
    await authService.signOut();

    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showProfileDialog(BuildContext context, User? user, String fullName) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Full Name: $fullName'),
              const SizedBox(height: 8),
              Text('Email: ${user?.email ?? 'No email'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String fullName = _fullName(user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth App'),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(fullName),
              accountEmail: Text(user?.email ?? 'No email'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _showProfileDialog(context, user, fullName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Welcome, $fullName!',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}