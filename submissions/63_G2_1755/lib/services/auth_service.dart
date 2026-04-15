import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServiceException implements Exception {
  const AuthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String _mapGooglePlatformError(PlatformException error) {
    final String details = '${error.code} ${error.message ?? ''}'.toLowerCase();

    if (details.contains('10:') || details.contains('sign_in_failed')) {
      return 'Google Sign-In configuration error (ApiException 10). Add SHA-1 and SHA-256 in Firebase for this Android app, then download and replace google-services.json.';
    }

    if (details.contains('12500') || details.contains('12501')) {
      return 'Google Sign-In was canceled or blocked. Please try again.';
    }

    return 'Google Sign-In failed. Please check Firebase and Google Sign-In configuration.';
  }

  Future<void> signUp(
    String email,
    String password, {
    String? fullName,
  }) async {
    final UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final String? trimmedName = fullName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      await userCredential.user?.updateDisplayName(trimmedName);
      await userCredential.user?.reload();
    }
  }

  Future<void> signIn(String email, String password) async {
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user?.reload();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthServiceException('Google signup was cancelled.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;

      if (!isNewUser) {
        await _googleSignIn.signOut();
        throw const AuthServiceException(
          'This Google account is already registered. Please sign in instead.',
        );
      }
    } on AuthServiceException {
      rethrow;
    } on FirebaseAuthException {
      rethrow;
    } on PlatformException catch (error) {
      throw AuthServiceException(_mapGooglePlatformError(error));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthServiceException('Google login was cancelled.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        await userCredential.user?.delete();
        await signOut();
        throw const AuthServiceException(
          'This Google account is not registered. Please sign up with Google first.',
        );
      }
    } on AuthServiceException {
      rethrow;
    } on FirebaseAuthException {
      rethrow;
    } on PlatformException catch (error) {
      throw AuthServiceException(_mapGooglePlatformError(error));
    }
  }
}
