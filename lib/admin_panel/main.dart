import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_k/admin_panel/auth/adminlogin.dart';
import 'package:project_k/admin_panel/homeScreen/homeScreen.dart';
import 'package:project_k/admin_panel/theme/appTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if the user is already logged in
  final bool isLoggedIn = await _checkIfLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> _checkIfLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.basic,
      home: isLoggedIn ? AdminHomeScreen() : AdminLoginScreen(),
    );
  }
}
