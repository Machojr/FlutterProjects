import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

// TODO: After running `flutterfire configure`, uncomment this import:
import 'firebase_options.dart';

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
        // Add providers here (AuthProvider, ChatProvider, etc.)
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppConstants.loginRoute,
        routes: {
          AppConstants.loginRoute: (context) => const Scaffold(body: Center(child: Text('Login Screen Placeholder'))),
          AppConstants.signupRoute: (context) => const Scaffold(body: Center(child: Text('Signup Screen Placeholder'))),
          AppConstants.homeRoute: (context) => const Scaffold(body: Center(child: Text('Home Screen Placeholder'))),
        },
      ),
    );
  }
}
