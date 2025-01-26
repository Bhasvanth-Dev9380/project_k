import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../auth/screens/login_screen.dart';
import '../../../models/usermodel.dart';
import '../eclassroom/classroom.dart'; // Make sure this is where your UserModel is located

class Drawersscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFBE92F6), // Matching background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Profile Section
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.yellow,
                  backgroundImage: NetworkImage(
                    UserModel.fromFirebaseUser(firebaseUser!).profileImage,
                  ),
                ),
              ),
              const SizedBox(width: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [],
              ),
              const SizedBox(height: 10),
              const Text(
                "View Profile",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 50),
              // Menu Items
              const MenuItemWidget(text: "Home"),
              const SizedBox(height: 30),
              GestureDetector(
                  child: const MenuItemWidget(text: "E-classroom"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClassHome(),
                        ));
                  }),
              const SizedBox(height: 30),
              /*TODO: project incharge should be able to divide
                 project batches based on form given to students
                  and assigning of the guide should
                 be done by coordinator alone */
              const MenuItemWidget(text: "Projects"),
              const SizedBox(height: 30),
              /*TODO: shift this to home page content as dashboard annconcements and assignmenyts */
              const MenuItemWidget(text: "Announcements"),
              const SizedBox(height: 30),
              const MenuItemWidget(text: "Assignment"),
              const SizedBox(height: 30),
              const MenuItemWidget(text: "Grades"),
              const SizedBox(height: 30),
              //TODO: Add preferences,subjects related to placement
              //TODO: admin  can subjects and the teacher can drag and drop based on their preference
              const MenuItemWidget(text: "Placement"),
              const Spacer(),
              // Logout Section
              GestureDetector(
                onTap: () async {
                  await _logout(context);
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // After successful sign out, navigate to the login screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(), // Redirect to Login Screen
        ),
      );
    } catch (e) {
      // Handle any errors that occur during logout
      print('Error logging out: $e');
    }
  }
}

class MenuItemWidget extends StatelessWidget {
  final String text;

  const MenuItemWidget({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
