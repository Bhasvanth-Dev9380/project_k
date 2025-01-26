import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../auth/screens/login_screen.dart';
import '../../../utils/colors.dart';

class ParentScreen extends StatelessWidget {
  final String universityName;

  const ParentScreen({required this.universityName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,  // Ensure content extends behind the AppBar
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,  // Make the AppBar transparent
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.lightBeige, Colors.blueGrey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, color: Colors.white, size: 28),
                SizedBox(width: 10),
                Text(
                  'Hi, Parent!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Welcome to $universityName',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('assets/animations/parent.json', width: 400, height: 400),
              SizedBox(height: 30),
              Text(
                'Nothing added here yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightBeige,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
