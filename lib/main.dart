import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/users/users_list_screen.dart';
import 'screens/users/user_profile_screen.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // UserProvider must be created first since AuthProvider depends on it
        ChangeNotifierProvider(create: (_) => UserProvider()),
        
        // AuthProvider depends on UserProvider, so it's created after
        // AuthProvider automatically initializes user profile when auth state changes
        ChangeNotifierProxyProvider<UserProvider, AuthProvider>(
          create: (context) => AuthProvider(
            context.read<UserProvider>(),
          ),
          update: (context, userProvider, authProvider) =>
              authProvider ?? AuthProvider(userProvider),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const _HomeRouter(),
        routes: {
          // Authentication routes
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.signupRoute: (context) => const SignupScreen(),
          // User discovery and profile routes
          AppConstants.usersRoute: (context) => const UsersListScreen(),
          // Home screen placeholder
          AppConstants.homeRoute: (context) => const HomeScreen(),
        },
        // Use onGenerateRoute to handle dynamic routes with parameters
        onGenerateRoute: (settings) {
          // Handle user profile route with userId parameter
          if (settings.name?.startsWith('/user/') ?? false) {
            final userId = settings.name!.replaceFirst('/user/', '');
            // Try to get user from arguments if provided
            final user = settings.arguments;
            return MaterialPageRoute(
              builder: (context) => user != null
                  ? UserProfileScreen(
                      user: user,
                      isCurrentUser:
                          user.userId == context.read<UserProvider>().currentUser?.userId,
                    )
                  : const Scaffold(
                      body: Center(child: Text('User not found')),
                    ),
            );
          }
          return null;
        },
      ),
    );
  }
}

/// Router widget to handle navigation based on auth state
/// Authentication check: If user is logged in, shows home; otherwise shows login
class _HomeRouter extends StatelessWidget {
  const _HomeRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // If user is logged in, go to home, otherwise go to login
        if (authProvider.isUserLoggedIn) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

/// HomeScreen displays main navigation for authenticated users
/// Currently shows options to:
/// - View and manage user profile
/// - Discover other users
/// - View messages/chats (coming soon)
/// - Access settings (coming soon)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        elevation: 0,
        actions: [
          // Settings button (placeholder)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon')),
              );
            },
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final currentUser = userProvider.currentUser;

          if (currentUser == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: [
              // Current User Preview Card
              Card(
                margin: const EdgeInsets.all(AppConstants.defaultPadding),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: currentUser.photoUrl != null
                        ? NetworkImage(currentUser.photoUrl!)
                        : null,
                    backgroundColor: AppTheme.primaryColor,
                    child: currentUser.photoUrl == null
                        ? Text(
                            currentUser.displayName?.characters.first
                                    .toUpperCase() ??
                                'U',
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  title: Text(currentUser.displayName ?? 'User'),
                  subtitle: const Text('Your Profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          user: currentUser,
                          isCurrentUser: true,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Divider(),

              // Navigation Sections
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Navigation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 12),
                    // Discover Users
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppConstants.usersRoute,
                        );
                      },
                      icon: const Icon(Icons.people),
                      label: const Text('Discover Users'),
                    ),
                    SizedBox(height: 12),
                    // Messages/Chats (coming soon)
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Messaging feature coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Messages (Coming Soon)'),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Quick Stats (optional)
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Info',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoCard(
                          context,
                          label: 'Email',
                          value: currentUser.email,
                        ),
                        _buildInfoCard(
                          context,
                          label: 'Member Since',
                          value: _formatDate(
                            currentUser.createdAt ?? DateTime.now(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build info card for displaying account information
  Widget _buildInfoCard(BuildContext context,
      {required String label, required String value}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Show logout confirmation dialog
  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
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
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // Call logout from auth provider
      if (context.mounted) {
        await context.read<AuthProvider>().signOut();
      }
    }
  }
}

