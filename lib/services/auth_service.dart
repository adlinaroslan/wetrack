import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A service class to handle all Firebase Authentication operations.
///
/// This class encapsulates the logic for signing in and signing up,
/// keeping the UI clean and focusing on presentation.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  /// Sign in with Google.
  /// Returns "success" on success, or the error message string on failure.
  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return "Google sign in cancelled";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      return "success";
    } on FirebaseAuthException catch (e) {
      // Log full exception for debugging and return detailed text
      // so the UI can show the precise error while you debug.
      // Remove or simplify these messages for production.
      // ignore: avoid_print
      print('Google sign-in FirebaseAuthException: ${e.code} ${e.message}');
      return e.message ?? e.toString();
    } catch (e, st) {
      // ignore: avoid_print
      print('Google sign-in error: $e\n$st');
      return e.toString();
    }
  }

  /// Sign out the user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
  // Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
