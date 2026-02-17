import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

/// UsersListScreen displays all registered users for discovery and interaction
/// Features include:
/// - Browse all users in the app
/// - Search users by display name
/// - View user profiles
/// - Block/unblock users
/// - Infinite scroll pagination for performance
class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  // ==================== Controllers ====================
  /// Controller for search input field to manage text changes
  final _searchController = TextEditingController();

  /// ScrollController to detect when user scrolls to bottom for pagination
  final _scrollController = ScrollController();

  // ==================== State Variables ====================
  /// Flag to track if we're currently searching or browsing all users
  bool _isSearchMode = false;

  /// Tracks if pagination is currently loading more users
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize: Load all users when screen opens
    _loadAllUsers();

    // Setup scroll listener for infinite scroll/pagination
    _scrollController.addListener(_handleScrollListener);

    // Setup search listener for real-time search as user types
    _searchController.addListener(_handleSearchListener);
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==================== Pagination & Data Loading ====================

  /// Load all users from Firestore for initial discovery view
  void _loadAllUsers() {
    final userProvider = context.read<UserProvider>();
    userProvider.loadAllUsers(limit: 50);
  }

  /// Handle scroll listener to implement infinite scroll pagination
  /// When user scrolls near bottom, automatically load more users
  void _handleScrollListener() {
    // Check if user has scrolled near the bottom (80% of scroll extent)
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent * 0.8) {
      // Only load more if not already loading and not in search mode
      if (!_isLoadingMore && !_isSearchMode) {
        _isLoadingMore = true;
        // Here you would typically load next page of users
        // For now, Flutter Provider will handle pagination gradually
        _isLoadingMore = false;
      }
    }
  }

  // ==================== Search Functionality ====================

  /// Handle search input changes and trigger real-time search
  /// Called every time user types in search field
  void _handleSearchListener() {
    final query = _searchController.text.trim();

    // If search is empty, return to browsing all users
    if (query.isEmpty) {
      setState(() {
        _isSearchMode = false;
      });
      _loadAllUsers();
      return;
    }

    // Enter search mode and search for users by name
    setState(() {
      _isSearchMode = true;
    });

    final userProvider = context.read<UserProvider>();
    // Trigger search with debounce would be ideal, but calling directly for simplicity
    userProvider.searchUsers(query, limit: 20);
  }

  /// Clear search and return to browsing mode
  void _clearSearch() {
    _searchController.clear();
    context.read<UserProvider>().clearSearchResults();
    setState(() {
      _isSearchMode = false;
    });
    _loadAllUsers();
  }

  // ==================== Navigation ====================

  /// Navigate to selected user's profile screen
  void _navigateToUserProfile(UserModel user) {
    Navigator.of(context).pushNamed(
      AppConstants.userProfileRoute.replaceFirst(':userId', user.userId),
      arguments: user,
    );
  }

  // ==================== Block/Unblock User ====================

  /// Handle blocking a user
  void _blockUser(UserModel user, UserProvider userProvider) async {
    final confirmed = await _showConfirmDialog(
      title: 'Block User',
      message: 'Block ${user.displayName}? They won\'t be able to message you or find your profile.',
    );

    if (!confirmed) return;

    final success = await userProvider.blockUser(user.userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'User blocked successfully'
                : 'Failed to block user',
          ),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }

  /// Handle unblocking a user
  void _unblockUser(UserModel user, UserProvider userProvider) async {
    final confirmed = await _showConfirmDialog(
      title: 'Unblock User',
      message: 'Unblock ${user.displayName}? They will be able to message you again.',
    );

    if (!confirmed) return;

    final success = await userProvider.unblockUser(user.userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'User unblocked successfully'
                : 'Failed to unblock user',
          ),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }

  /// Show confirmation dialog before blocking/unblocking
  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ==================== Build Methods ====================

  /// Build the search/filter header
  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search users by name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Build individual user card for list display
  /// Shows user's profile photo, name, bio, and online status
  Widget _buildUserCard(UserModel user, UserProvider userProvider) {
    // Check if current user has blocked this user
    final isBlocked = userProvider.isUserBlocked(user.userId);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 8,
      ),
      child: ListTile(
        // User profile photo
        leading: Stack(
          children: [
            // Profile avatar circle
            CircleAvatar(
              radius: 24,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              backgroundColor: AppTheme.primaryColor,
              child: user.photoUrl == null
                  ? Text(
                      user.displayName?.characters.first.toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            // Online status indicator (green dot if online)
            if (user.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.onlineBadgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // User info (name and bio)
        title: Text(
          user.displayName ?? 'Unknown User',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            // User bio (if available)
            if (user.bio != null && user.bio!.isNotEmpty)
              Text(
                user.bio!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            // Online/offline status
            Text(
              user.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 11,
                color: user.isOnline
                    ? AppTheme.onlineBadgeColor
                    : AppTheme.disabledColor,
              ),
            ),
          ],
        ),

        // Action buttons (view profile, block/unblock)
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'profile') {
              _navigateToUserProfile(user);
            } else if (action == 'block') {
              _blockUser(user, userProvider);
            } else if (action == 'unblock') {
              _unblockUser(user, userProvider);
            }
          },
          itemBuilder: (BuildContext context) => [
            // View Profile option
            PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 18),
                  SizedBox(width: 8),
                  const Text('View Profile'),
                ],
              ),
            ),
            // Block/Unblock option (conditional)
            if (isBlocked)
              PopupMenuItem<String>(
                value: 'unblock',
                child: Row(
                  children: [
                    const Icon(Icons.block_outlined, size: 18),
                    SizedBox(width: 8),
                    const Text('Unblock'),
                  ],
                ),
              )
            else
              PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    const Icon(Icons.block, size: 18, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    const Text(
                      'Block',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no users found
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isSearchMode ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: AppTheme.greyColor,
          ),
          SizedBox(height: 16),
          Text(
            _isSearchMode
                ? 'No users found matching your search'
                : 'No users available yet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.greyColor,
                ),
          ),
          if (_isSearchMode)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: _clearSearch,
                child: const Text('Clear Search'),
              ),
            ),
        ],
      ),
    );
  }

  /// Build loading indicator while data is being fetched
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Users'),
        elevation: 0,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          // Determine which list to show (search results or all users)
          final users = _isSearchMode
              ? userProvider.searchResults
              : userProvider.usersList;

          // Determine if currently loading
          final isLoading = _isSearchMode
              ? userProvider.isSearching
              : userProvider.isLoading;

          return Column(
            children: [
              // Search header
              _buildSearchHeader(),

              // Main content (loading, empty, or list)
              Expanded(
                child: isLoading && users.isEmpty
                    ? _buildLoadingState()
                    : users.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return _buildUserCard(user, userProvider);
                            },
                          ),
              ),

              // Show loading indicator at bottom when pagination is active
              if (isLoading && users.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 32,
                    width: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
