import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../homeScreen/homeScreen.dart';
import 'credentials.dart';

String? loggedInInstitute;

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _instituteController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() async {
    final institute = _instituteController.text.trim();
    final password = _passwordController.text.trim();

    if (Credentials.validate(institute, password)) {
      // Navigate to HomeScreen on successful login
      loggedInInstitute = institute;

      // Set login status in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('instituteName', loggedInInstitute!);


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminHomeScreen()),
      );
    } else {
      // Show error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid institute name or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isDesktop = screenWidth > 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: isDesktop
              ? Container(
            padding: EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left Illustration Column
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height / 1.1,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFE8E0), // Background color
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Text(
                          "Project K",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEE3B6D),
                          ),
                        ),
                      ),
                    ),

                    // Right Login Form Column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Admin Login",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Email Input
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _instituteController,
                                cursorColor: Colors.black,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'Institute Name',
                                  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                                  prefixIcon: Icon(Icons.school_outlined, color: Colors.black54),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.orangeAccent, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.orangeAccent, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Password Input
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                cursorColor: Colors.black,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                                  prefixIcon: Icon(Icons.lock_outline, color: Colors.black54),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.orangeAccent, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.orangeAccent, width: 1.5),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 24),

                            // Login Button
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFF7A7B),
                                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 200),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Log In",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: screenWidth / 2.4,
                  top: 1,
                  child: Lottie.asset('assets/admin/admin.json', width: screenWidth / 1.54),
                ),
              ],
            ),
          )
              : _buildMobileView(context),
        ),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return Center(
      child: Text(
        'Please use a desktop to view this admin panel.',
        style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
        textAlign: TextAlign.center,
      ),
    );
  }
}
