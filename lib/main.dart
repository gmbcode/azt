import 'package:azt/features/auth/presentation/pages/auth_page.dart';
import 'package:azt/features/auth/presentation/pages/login_page.dart';
import 'package:azt/features/auth/presentation/pages/register_page.dart';
import 'package:azt/theme/dark_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:azt/firebase_options.dart';
void main() async {
  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthPage(),
      theme: darkMode,
    );
  }
}
