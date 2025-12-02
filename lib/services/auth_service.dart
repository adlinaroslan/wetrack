import 'package:firebase_auth/firebase_auth.dart';

/// A service class to handle all Firebase Authentication operations.
///
/// This class encapsulates the logic for signing in and signing up,
/// keeping the UI clean and focusing on presentation.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Attempts to sign in a user with email and password.
  /// Returns "success" on success, or the error message string on failure.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } on FirebaseAuthException catch (e) {
      // Return a user-friendly error message from Firebase.
      return e.message ?? "An unknown login error occurred.";
    }
  }

  /// Attempts to create a new user with email and password (registration).
  /// Returns "success" on success, or the error message string on failure.
  Future<String> register({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } on FirebaseAuthException catch (e) {
      // Return a user-friendly error message from Firebase.
      return e.message ?? "An unknown registration error occurred.";
    }
  }

  // You can add more methods here, like:
  // Future<void> signOut() => _firebaseAuth.signOut();
  // Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
