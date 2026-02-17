import '../utils/constants.dart';

/// Input validation utilities for the app
class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Simple email regex pattern
    const String emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final RegExp regex = RegExp(emailPattern);

    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must not exceed ${AppConstants.maxPasswordLength} characters';
    }

    // Optional: Check for password strength (uppercase, lowercase, number, special char)
    // You can uncomment this for stronger validation
    /*
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    */

    return null;
  }

  /// Confirm password matches
  static String? validatePasswordConfirm(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate display name
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }

    if (value.length < AppConstants.minDisplayNameLength) {
      return 'Name must be at least ${AppConstants.minDisplayNameLength} characters';
    }

    if (value.length > AppConstants.maxDisplayNameLength) {
      return 'Name must not exceed ${AppConstants.maxDisplayNameLength} characters';
    }

    // Check if name contains only letters and spaces
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validate phone number (basic validation)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }

    // Simple phone validation: digits, spaces, hyphens, +
    if (!RegExp(r'^[+]?[0-9\s\-()]+$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    if (value.replaceAll(RegExp(r'[^\d]'), '').length < 10) {
      return 'Phone number must have at least 10 digits';
    }

    return null;
  }

  /// Validate bio/description
  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Bio is optional
    }

    if (value.length > 160) {
      return 'Bio must not exceed 160 characters';
    }

    return null;
  }

  /// Check if string is not empty
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Generic field validator
  static String? validateField(
    String? value, {
    required String fieldName,
    int? minLength,
    int? maxLength,
    String? pattern,
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (minLength != null && value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (maxLength != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    if (pattern != null && !RegExp(pattern).hasMatch(value)) {
      return '$fieldName format is invalid';
    }

    return null;
  }
}
