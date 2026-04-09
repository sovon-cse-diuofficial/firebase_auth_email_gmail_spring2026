import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  final AuthService authService = AuthService();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),

      body: Center(
        child: Column(
          children: [
            Text("HomePage"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authService.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              },

              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
