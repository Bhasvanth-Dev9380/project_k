// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:project_k/screens/educator/home_screen/educator_screen.dart';
// import 'auth/screens/login_screen.dart';
// import 'database/Database.dart'; // Import the LoginScreen
// import 'package:shimmer/shimmer.dart';
//
// import 'firebase_options.dart'; // Import shimmer package
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//     await Firebase.initializeApp(
//       options:DefaultFirebaseOptions.currentPlatform,
//     );
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: false,
//       ),
//       home: AuthWrapper(), // Check the auth status on app start
//     );
//   }
// }
//
// class AuthWrapper extends StatefulWidget {
//   @override
//   _AuthWrapperState createState() => _AuthWrapperState();
// }
//
// class _AuthWrapperState extends State<AuthWrapper> {
//   final DatabaseService _databaseService = DatabaseService(); // Instance of your database service
//   String? userRole; // To store user role
//   bool isLoading = true; // To manage loading state
//
//   @override
//   void initState() {
//     super.initState();
//     _checkUserRole(); // Check user's role on app startup
//   }
//
//   // This method checks if the user is authenticated and fetches the user role
//   Future<void> _checkUserRole() async {
//     User? user = FirebaseAuth.instance.currentUser;
//
//     if (user != null) {
//       // Fetch the role from the database
//       Map<String, String?> userData = await _databaseService.getUserData(user.uid);
//       setState(() {
//         userRole = userData['role']; // Get the role (e.g., 'Educator')
//         isLoading = false; // Stop loading after fetching the role
//       });
//     } else {
//       // If user is not authenticated, navigate to login screen
//       setState(() {
//         isLoading = false; // Stop loading, show login screen
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: _buildShimmerEffect(),
//         ), // Replace with the shimmer effect
//       );
//     }
//
//     User? user = FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       // If no user is logged in, show the login screen
//       return LoginScreen(); // Replace with your LoginScreen or MainScreen
//     }
//
//     // If the user is logged in, check the role
//     if (userRole == 'Educator') {
//       return EducatorScreen(); // Navigate to EducatorScreen if role is 'Educator'
//     } else {
//       return LoginScreen(); // Default or another screen for different roles
//     }
//   }
//
//   // Build shimmer effect placeholder
//   Widget _buildShimmerEffect() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: ListView.builder(
//         itemCount: 20, // Simulating 6 placeholders while loading
//         itemBuilder: (context, index) {
//           return Column(
//             children: [
//               SizedBox(height: 10,),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
//                 child: Container(
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }


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
