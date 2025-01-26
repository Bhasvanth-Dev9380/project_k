import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../auth/screens/login_screen.dart';
import '../../../../models/usermodel.dart';
import '../../../../utils/colors.dart';

class AccountPage extends StatelessWidget {
  final UserModel user;

  AccountPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.profileImage),
            ),
            SizedBox(height: 40), // Increased spacing for better alignment
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Email :',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.brightOrange,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '${user.email}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.brightOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15), // Adjusted size
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut(); // Sign out from Firebase
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(), // Redirect to Login Screen
                  ),
                );
              },
              child: Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Handle report problem
              },
              child: Text(
                'Report a problem',
                style: TextStyle(
                  color: AppColors.brightOrange,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
