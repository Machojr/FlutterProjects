import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// UserProvider manages all user-related state and operations
/// Handles user profile management, discovery, search, and blocking functionality
/// Uses Provider pattern for global state management across the app
class UserProvider extends ChangeNotifier {
  // ==================== Services ====================
  final FirestoreService _firestoreService = FirestoreService();

  // ==================== State Variables ====================
  
  /// Current logged-in user's complete profile
  UserModel? _currentUser;

  /// List of users for the discovery/users browsing feature
  List<UserModel> _usersList = [];

  /// List of users from search results
  List<UserModel> _searchResults = [];

  /// Currently selected user for viewing their profile
  UserModel? _selectedUser;

  /// Indicates if data is being loaded from Firestore
  bool _isLoading = false;

  /// Indicates if a search operation is in progress
  bool _isSearching = false;

  /// Error messages from failed operations
  String? _errorMessage;

  /// Stores the name of the currently selected user for profile viewing
  String? _selectedUsername;

  // ==================== Getters ====================

  /// Get the current logged-in user
  UserModel? get currentUser => _currentUser;

  /// Get the list of all users for discovery
  List<UserModel> get usersList => _usersList;

  /// Get search results
  List<UserModel> get searchResults => _searchResults;

  /// Get the currently selected user being viewed
  UserModel? get selectedUser => _selectedUser;

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get searching state
  bool get isSearching => _isSearching;

  /// Get error message if any
  String? get errorMessage => _errorMessage;

  /// Get selected username
  String? get selectedUsername => _selectedUsername;

  /// Check if current user exists (logged in)
  bool get isCurrentUserSet => _currentUser != null;

  // ==================== Core Methods ====================

  /// Initialize user provider with current user data from Firestore
  /// Called right after authentication to load the user's profile
  Future<void> initializeCurrentUser(String uid) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Fetch user document from Firestore
      final user = await _firestoreService.getUser(uid);
      
      if (user != null) {
        _currentUser = user;
        _errorMessage = null;
      } else {
        _errorMessage = 'User profile not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to load user profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new user document in Firestore after successful authentication
  /// Called automatically from signup AuthProvider after user is created in Firebase Auth
  Future<bool> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create UserModel with initial data
      final newUser = UserModel(
        userId: uid,
        email: email,
        displayName: displayName,
        isOnline: true,
        blockedUsers: [],
        deviceTokens: [],
      );

      // Save to Firestore
      await _firestoreService.createUser(newUser);
      
      // Set as current user
      _currentUser = newUser;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create user profile: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Update current user's profile information
  /// Updates fields like displayName, bio, photoUrl, phoneNumber
  Future<bool> updateCurrentUserProfile({
    String? displayName,
    String? bio,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Build update map with only non-null values
      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['displayName'] = displayName;
      if (bio != null) updateData['bio'] = bio;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;

      // Update in Firestore
      await _firestoreService.updateUser(_currentUser!.userId, updateData);

      // Update local state
      _currentUser = _currentUser!.copyWith(
        displayName: displayName,
        bio: bio,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber,
      );

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Load all users for discovery feature
  /// Streams users from Firestore ordered by creation date (newest first)
  /// Used by UsersListScreen for the user discovery feature
  void loadAllUsers({int limit = 50}) {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Subscribe to users stream
      _firestoreService.streamUsers(limit: limit).listen(
        (users) {
          _usersList = users;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          _isLoading = false;
          _errorMessage = 'Failed to load users: ${error.toString()}';
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading users: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Search users by display name
  /// Provides real-time search as user types in search bar
  /// Supports prefix matching (e.g., searching "john" finds "John Doe")
  Future<void> searchUsers(String query, {int limit = 20}) async {
    // Clear results if query is empty
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    try {
      _isSearching = true;
      _errorMessage = null;
      notifyListeners();

      // Query Firestore for users matching the search term
      _searchResults = await _firestoreService.searchUsersByName(
        query,
        limit: limit,
      );

      _isSearching = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isSearching = false;
      _errorMessage = 'Search failed: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get a specific user's profile by UID
  /// Used for viewing other users' profiles
  Future<bool> loadUserProfile(String uid, String username) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Fetch user from Firestore
      final user = await _firestoreService.getUser(uid);
      
      if (user != null) {
        _selectedUser = user;
        _selectedUsername = username;
        _isLoading = false;
        _errorMessage = null;
      } else {
        _isLoading = false;
        _errorMessage = 'User not found';
      }
      
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load user profile: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Set user's online status
  /// Called when app comes to foreground (online=true) or background (online=false)
  /// Also updates lastSeen timestamp automatically via server
  Future<void> setUserOnlineStatus(bool isOnline) async {
    if (_currentUser == null) return;

    try {
      await _firestoreService.setUserOnlineStatus(
        _currentUser!.userId,
        isOnline,
      );

      // Update local state
      _currentUser = _currentUser!.copyWith(isOnline: isOnline);
      notifyListeners();
    } catch (e) {
      // Log error but don't disrupt user experience
      print('Error updating online status: $e');
    }
  }

  /// Block a user to prevent them from messaging/viewing profile
  /// Blocked users are stored in currentUser's blockedUsers list
  Future<bool> blockUser(String userIdToBlock) async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      return false;
    }

    try {
      _errorMessage = null;

      // Add user to blockedUsers list (avoid duplicates)
      final updatedBlockedUsers = _currentUser!.blockedUsers;
      if (!updatedBlockedUsers.contains(userIdToBlock)) {
        updatedBlockedUsers.add(userIdToBlock);
      }

      // Update in Firestore
      await _firestoreService.updateUser(
        _currentUser!.userId,
        {'blockedUsers': updatedBlockedUsers},
      );

      // Update local state
      _currentUser = _currentUser!.copyWith(
        blockedUsers: updatedBlockedUsers,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to block user: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Unblock a previously blocked user
  /// Removes user from currentUser's blockedUsers list
  Future<bool> unblockUser(String userIdToUnblock) async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      return false;
    }

    try {
      _errorMessage = null;

      // Remove user from blockedUsers list
      final updatedBlockedUsers = _currentUser!.blockedUsers;
      updatedBlockedUsers.removeWhere((id) => id == userIdToUnblock);

      // Update in Firestore
      await _firestoreService.updateUser(
        _currentUser!.userId,
        {'blockedUsers': updatedBlockedUsers},
      );

      // Update local state
      _currentUser = _currentUser!.copyWith(
        blockedUsers: updatedBlockedUsers,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to unblock user: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Check if a user is blocked by current user
  bool isUserBlocked(String userId) {
    return _currentUser?.blockedUsers.contains(userId) ?? false;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear selected user and reset selection
  void clearSelectedUser() {
    _selectedUser = null;
    _selectedUsername = null;
    notifyListeners();
  }

  /// Clear search results
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  /// Logout - clear all user data from provider
  void clearCurrentUser() {
    _currentUser = null;
    _usersList = [];
    _searchResults = [];
    _selectedUser = null;
    _selectedUsername = null;
    _errorMessage = null;
    _isLoading = false;
    _isSearching = false;
    notifyListeners();
  }
}
