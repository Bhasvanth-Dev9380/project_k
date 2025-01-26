import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/usermodel.dart';
User? firebaseUser = FirebaseAuth.instance.currentUser;
var name = UserModel.fromFirebaseUser(firebaseUser!).name;
class HomeScreen extends StatelessWidget {
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "HI ${UserModel.fromFirebaseUser(firebaseUser!).name}",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                ActivityCard(
                  subject: 'Science',
                  assignments: 3,
                  icon: Icons.science,
                  backgroundColor: Colors.purple.shade50,
                ),
                ActivityCard(
                  subject: 'Math',
                  assignments: 4,
                  icon: Icons.calculate,
                  backgroundColor: Colors.blue.shade50,
                ),
                ActivityCard(
                  subject: 'History',
                  assignments: 2,
                  icon: Icons.history,
                  backgroundColor: Colors.green.shade50,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String subject;
  final int assignments;
  final IconData icon;
  final Color backgroundColor;

  ActivityCard({
    required this.subject,
    required this.assignments,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: backgroundColor,
              child: Icon(icon, size: 32, color: Colors.black54),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$assignments Assignment${assignments > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}