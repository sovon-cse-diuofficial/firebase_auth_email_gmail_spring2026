import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Returns the currently logged-in user, or null if not logged in
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  // Returns null on success, or an error message string on failure
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getReadableError(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // Sign in with email and password
  // Returns null on success, or an error message string on failure
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getReadableError(e.code);
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // Sign in with Google
  // Returns null on success, or an error message string on failure
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User cancelled the sign-in flow
      if (googleUser == null) return 'Google sign-in was cancelled.';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _getReadableError(e.code);
    } catch (e) {
      return 'Google sign-in failed. Please try again.';
    }
  }

  // Sign out from both Firebase and Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Converts Firebase error codes into human-friendly messages
  String _getReadableError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
