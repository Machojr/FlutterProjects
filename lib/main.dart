import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
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
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.signupRoute: (context) => const SignupScreen(),
          AppConstants.homeRoute: (context) => const Scaffold(
            body: Center(
              child: Text('Home Screen Placeholder'),
            ),
          ),
        },
      ),
    );
  }
}

/// Router widget to handle navigation based on auth state
class _HomeRouter extends StatelessWidget {
  const _HomeRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // If user is logged in, go to home, otherwise go to login
        if (authProvider.isUserLoggedIn) {
          return const Scaffold(
            body: Center(
              child: Text('Home Screen Placeholder'),
            ),
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
