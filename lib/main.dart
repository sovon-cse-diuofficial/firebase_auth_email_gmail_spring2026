import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBw41sTHYFFfIVeprNHIJveadMrPvahnR4",
      authDomain: "fir-auth-app-76ba6.firebaseapp.com",
      projectId: "fir-auth-app-76ba6",
      storageBucket: "fir-auth-app-76ba6.appspot.com",
      messagingSenderId: "531758375463",
      appId: "1:531758375463:web:6531a8606bee9ae572a402",
      measurementId: "G-E6QRBE91JF",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String message = "";

  // ✅ Signup
  Future<void> signUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      setState(() {
        message = "Signup Success ✅";
      });
    } catch (e) {
      setState(() {
        message = e.toString();
      });
    }
  }

  // ✅ Login
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      setState(() {
        message = "Login Success ✅";
      });
    } catch (e) {
      setState(() {
        message = e.toString();
      });
    }
  }

  // ✅ Google Login (WEB FIXED)
  Future<void> signInWithGoogle() async {
    try {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      await FirebaseAuth.instance.signInWithPopup(authProvider);

      setState(() {
        message = "Google Login Success ✅";
      });
    } catch (e) {
      setState(() {
        message = e.toString();
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Auth")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: login,
              child: const Text("Login"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: signUp,
              child: const Text("Signup"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: signInWithGoogle,
              child: const Text("Login with Google"),
            ),

            const SizedBox(height: 20),

            Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}