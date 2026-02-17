import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

/// UserProfileScreen displays a user's profile information
/// Features:
/// - View user profile (photo, name, bio, phone, joined date)
/// - Edit profile for current user (photo, name, bio, phone)
/// - Block/unblock users
/// - Show online status and last seen
/// - Display user activity and statistics
class UserProfileScreen extends StatefulWidget {
  /// The user whose profile is being displayed
  final UserModel user;

  /// Whether this is the current user's profile (allows editing)
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.user,
    this.isCurrentUser = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // ==================== Controllers ====================
  /// Controller for display name input in edit mode
  late TextEditingController _displayNameController;

  /// Controller for bio input in edit mode
  late TextEditingController _bioController;

  /// Controller for phone number input in edit mode
  late TextEditingController _phoneController;

  // ==================== State Variables ====================
  /// Flag to toggle between view and edit mode
  bool _isEditMode = false;

  /// Flag to track if profile update is in progress
  bool _isSaving = false;

  /// Holds the selected image path during edit mode (before upload)
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with current user data
    _displayNameController = TextEditingController(text: widget.user.displayName);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ==================== Image Picker ====================

  /// Open image picker to select new profile photo
  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress image to reduce file size
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  // ==================== Profile Update ====================

  /// Save profile changes and update Firestore
  /// Called when user taps "Save" in edit mode
  Future<void> _saveProfileChanges() async {
    // Validate that display name is not empty
    if (_displayNameController.text.trim().isEmpty) {
      _showErrorSnackBar('Display name cannot be empty');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userProvider = context.read<UserProvider>();

      // Prepare updated user data
      final updatedUser = widget.user.copyWith(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        // Note: Photo URL update would require uploading image to storage
        // For now, this is a placeholder for future image upload functionality
      );

      // Call provider to update user profile in Firestore
      final success = await userProvider.updateCurrentUserProfile(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (mounted) {
        if (success) {
          _showSuccessSnackBar('Profile updated successfully');
          setState(() {
            _isEditMode = false;
            _selectedImagePath = null;
          });
        } else {
          _showErrorSnackBar('Failed to update profile');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error updating profile: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Cancel edit mode and reset form
  void _cancelEditing() {
    // Reset controllers to original values
    _displayNameController.text = widget.user.displayName;
    _bioController.text = widget.user.bio ?? '';
    _phoneController.text = widget.user.phoneNumber ?? '';
    _selectedImagePath = null;

    setState(() {
      _isEditMode = false;
    });
  }

  // ==================== Block/Unblock User ====================

  /// Handle blocking the displayed user
  Future<void> _blockUser(UserProvider userProvider) async {
    final confirmed = await _showConfirmDialog(
      title: 'Block User',
      message:
          'Block ${widget.user.displayName}? They won\'t be able to message you or find your profile.',
    );

    if (!confirmed) return;

    final success = await userProvider.blockUser(widget.user.userId);
    if (mounted) {
      if (success) {
        _showSuccessSnackBar('User blocked successfully');
        // Navigate back after successful block
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _showErrorSnackBar('Failed to block user');
      }
    }
  }

  /// Handle unblocking the displayed user
  Future<void> _unblockUser(UserProvider userProvider) async {
    final confirmed = await _showConfirmDialog(
      title: 'Unblock User',
      message:
          'Unblock ${widget.user.displayName}? They will be able to message you again.',
    );

    if (!confirmed) return;

    final success = await userProvider.unblockUser(widget.user.userId);
    if (mounted) {
      if (success) {
        _showSuccessSnackBar('User unblocked successfully');
      } else {
        _showErrorSnackBar('Failed to unblock user');
      }
    }
  }

  // ==================== UI Helpers ====================

  /// Show confirmation dialog for block/unblock actions
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

  /// Show success message via snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  /// Show error message via snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  /// Build profile header with photo and name
  /// In edit mode, allows changing photo
  Widget _buildProfileHeader() {
    // Use selected image if available (preview), otherwise use existing photo
    final imageUrl = _selectedImagePath ?? widget.user.photoUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Stack(
      children: [
        // Background container
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // Profile photo circle
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: hasImage
                        ? NetworkImage(imageUrl!)
                        : null,
                    backgroundColor: Colors.white,
                    child: !hasImage
                        ? Text(
                            widget.user.displayName?.characters.first
                                    .toUpperCase() ??
                                'U',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          )
                        : null,
                  ),
                  // Online status indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: widget.user.isOnline
                              ? AppTheme.onlineBadgeColor
                              : AppTheme.greyColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  // Edit photo button (only in edit mode)
                  if (_isEditMode)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 16),

              // Display name and status
              _isEditMode
                  ? TextField(
                      controller: _displayNameController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter display name',
                        hintStyle: const TextStyle(color: Colors.white70),
                        underline: Container(
                          height: 1,
                          color: Colors.white,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      widget.user.displayName ?? 'Unknown User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

              SizedBox(height: 6),

              // Online/offline status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.user.isOnline
                          ? AppTheme.onlineBadgeColor
                          : AppTheme.greyColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    widget.user.isOnline ? 'Online' : 'Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Edit/Done button (only for current user)
        if (widget.isCurrentUser)
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () {
                if (_isEditMode) {
                  _saveProfileChanges();
                } else {
                  setState(() => _isEditMode = true);
                }
              },
              backgroundColor: Colors.white,
              child: Icon(
                _isEditMode ? Icons.check : Icons.edit,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  /// Build editable/readable bio section
  Widget _buildBioSection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bio',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8),
          _isEditMode && widget.isCurrentUser
              ? TextField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add a bio...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              : Text(
                  widget.user.bio ?? 'No bio added yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
        ],
      ),
    );
  }

  /// Build phone number section
  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8),
          if (_isEditMode && widget.isCurrentUser)
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Phone number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.phone, size: 18),
                SizedBox(width: 8),
                Text(
                  widget.user.phoneNumber ?? 'Not provided',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Build joined date and member info section
  Widget _buildMemberInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Member since
          Column(
            children: [
              Text(
                'Member Since',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 4),
              Text(
                widget.user.createdAt != null
                    ? _formatDate(widget.user.createdAt!)
                    : 'N/A',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          // Last seen
          Column(
            children: [
              Text(
                'Last Seen',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 4),
              Text(
                widget.user.isOnline
                    ? 'Now'
                    : _formatDate(widget.user.lastSeen ??
                        widget.user.updatedAt ??
                        DateTime.now()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build action buttons (block/unblock, call, message, etc.)
  Widget _buildActionButtons(UserProvider userProvider) {
    // Only show action buttons for other users
    if (widget.isCurrentUser) return const SizedBox.shrink();

    final isBlocked = userProvider.isUserBlocked(widget.user.userId);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Message button
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to chat screen with this user
              _showErrorSnackBar('Chat feature coming soon');
            },
            icon: const Icon(Icons.message),
            label: const Text('Send Message'),
          ),

          SizedBox(height: 12),

          // Block/Unblock button
          ElevatedButton.icon(
            onPressed: () {
              if (isBlocked) {
                _unblockUser(userProvider);
              } else {
                _blockUser(userProvider);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isBlocked ? AppTheme.successColor : AppTheme.errorColor,
            ),
            icon: Icon(isBlocked ? Icons.block_outlined : Icons.block),
            label: Text(isBlocked ? 'Unblock User' : 'Block User'),
          ),
        ],
      ),
    );
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).round()}w ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          // Cancel button when editing
          if (_isEditMode && widget.isCurrentUser)
            TextButton(
              onPressed: _cancelEditing,
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile header with photo and name
                    _buildProfileHeader(),

                    // Divider
                    const Divider(),

                    // Bio section
                    _buildBioSection(),

                    // Divider
                    const Divider(),

                    // Contact/phone section
                    _buildContactSection(),

                    // Divider
                    const Divider(),

                    // Member info section
                    _buildMemberInfoSection(),

                    // Divider
                    const Divider(),

                    // Action buttons (for other users only)
                    _buildActionButtons(userProvider),

                    // Extra padding at bottom
                    SizedBox(height: 16),
                  ],
                ),
              ),

              // Loading overlay during save
              if (_isSaving)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
