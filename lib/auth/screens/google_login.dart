import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../database/Database.dart';
import '../../utils/colors.dart';
import '../../utils/institutes.dart';// Import the database service
import '../../screens/educator/home_screen/educator_screen.dart'; // Import the EducatorScreen

class GoogleLoginScreen extends StatefulWidget {
  final String selectedUniversity;

  const GoogleLoginScreen({required this.selectedUniversity});

  @override
  _GoogleLoginScreenState createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  bool _isSigningIn = false;
  final DatabaseService _databaseService = DatabaseService(); // Instance of DatabaseService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(180),
                    bottomRight: Radius.circular(180),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 50.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/universities/oxford.png', // Path to the logo
                        width: 150,
                        height: 150,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Almost there!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "You selected ${widget.selectedUniversity}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.lightBeige,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,  // Align to the bottom
                  children: [
                    _isSigningIn
                        ? CircularProgressIndicator(color: AppColors.brightOrange)
                        : _buildGoogleSignInButton(context),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if it's the user's first time logging in
        bool isFirstLogin = await _databaseService.checkIfFirstLogin(user.uid);
        if (isFirstLogin) {
          // Store user data in Firestore
          await _databaseService.storeUserData(
            user.uid,
            user.email!,
            'Educator',  // Use 'Educator' as the role since it's the educator screen
            widget.selectedUniversity,  // Store the selected university
          );
        }
      }

      return user;

    } catch (e) {
      print('Google sign-in failed: $e');
      return null;
    }
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.orange,
        backgroundColor: AppColors.white, // Text color
        minimumSize: Size(double.infinity, 50), // Button size
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5, // Button shadow/elevation
      ),
      onPressed: () async {
        setState(() {
          _isSigningIn = true; // Show progress indicator
        });

        User? user = await _signInWithGoogle();

        setState(() {
          _isSigningIn = false; // Hide progress indicator
        });

        if (user != null) {
          // Get the user's email
          final userEmail = user.email;

          // Validate the email against the selected university's pattern
          String? pattern = institutes[widget.selectedUniversity];
          if (pattern != null && RegExp(pattern).hasMatch(userEmail!)) {
            // Email is valid, proceed to home screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => EducatorScreen()),
                  (route) => false, // Remove all previous routes
            );
          } else {
            // Show Snackbar on email validation failure
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid email domain for ${widget.selectedUniversity}.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        } else {
          // Show Snackbar on sign-in failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign in with Google'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      icon: Image.asset(
        'assets/google_logo.png', // Path to the Google logo
        width: 24,
        height: 24,
      ),
      label: Text(
        'Sign in with Google',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
