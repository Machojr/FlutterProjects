import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'user_provider.dart';

/// State management provider for authentication
/// Manages user login/signup state and provides auth methods to the app
/// Coordinates with UserProvider to create/initialize user profiles in Firestore
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserProvider _userProvider;

  // State variables
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSigningUp = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSigningUp => _isSigningUp;
  bool get isUserLoggedIn => _user != null;
  String? get userUID => _user?.uid;
  String? get userEmail => _user?.email;
  String? get userDisplayName => _user?.displayName;

  /// Constructor: requires UserProvider for coordinated user management
  AuthProvider(this._userProvider) {
    // Listen to auth state changes and initialize user profile
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      
      // If user logged in, initialize their profile from Firestore
      if (user != null) {
        _userProvider.initializeCurrentUser(user.uid);
      } else {
        // If user logged out, clear user data from UserProvider
        _userProvider.clearCurrentUser();
      }
      
      notifyListeners();
    });
  }

  /// Sign up with email, password, and display name
  /// Creates Firebase Auth account, then creates user profile in Firestore
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _isSigningUp = true;
      _errorMessage = null;
      notifyListeners();

      // Step 1: Create user in Firebase Authentication
      final userCredential = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Step 2: Create user profile in Firestore
      final profileCreated = await _userProvider.createUserProfile(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
      );

      if (!profileCreated) {
        _errorMessage = 'Failed to create user profile. Please try again.';
        _isLoading = false;
        _isSigningUp = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      _isSigningUp = false;
      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _isSigningUp = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  /// Authenticates with Firebase Auth, UserProvider initializes profile automatically
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Authenticate with Firebase
      final userCredential = await _authService.logIn(
        email: email,
        password: password,
      );

      // UserProvider.initializeCurrentUser will be called automatically
      // via authStateChanges listener in constructor

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Sign out the current user
  /// Logs out from Firebase Auth and clears user data from UserProvider
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();

      _user = null;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      // UserProvider.clearCurrentUser will be called automatically
      // via authStateChanges listener
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Send password reset email
  /// User can click link in email to reset their password
  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email: email);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
