import 'package:firebase_auth/firebase_auth.dart';

/// Service for handling Firebase Authentication
/// Provides methods for user sign up, login, logout, and password reset
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Get the current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Stream of user changes (emits null when user logs out)
  Stream<User?> get userChanges => _firebaseAuth.userChanges();

  /// Sign up with email and password
  /// Returns User object if successful, throws FirebaseAuthException on failure
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user account
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  /// Login with email and password
  /// Returns UserCredential if successful, throws FirebaseAuthException on failure
  Future<UserCredential> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  /// Send password reset email
  /// User can click link in email to reset their password
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }

  /// Delete the current user account
  /// WARNING: This action cannot be undone
  Future<void> deleteUser() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  /// Check if user is currently authenticated
  bool get isUserLoggedIn => _firebaseAuth.currentUser != null;

  /// Get current user's UID
  String? get currentUserUID => _firebaseAuth.currentUser?.uid;

  /// Get current user's email
  String? get currentUserEmail => _firebaseAuth.currentUser?.email;

  /// Get current user's display name
  String? get currentUserDisplayName => _firebaseAuth.currentUser?.displayName;

  /// Handle Firebase Auth exceptions and provide user-friendly error messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with that email address.';
      case 'wrong-password':
        return 'Invalid password. Please try again.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'operation-not-allowed':
        return 'Sign up is currently disabled.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'invalid-credential':
        return 'The credentials provided are invalid.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
