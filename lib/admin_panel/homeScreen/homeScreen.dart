import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/adminlogin.dart';
import '../screens/home/home.dart';
import '../utils/nav_bar.dart';

String selectedYear = 'AY 2021-2022';
final List<String> academicYears = ['AY 2021-2022', 'AY 2022-2023', 'AY 2023-2024', 'AY 2024-2025'];


class AdminHomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<AdminHomeScreen> {
  // Define the academic years

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Check if the screen is wide enough to be considered "desktop"
    bool isDesktop = screenWidth > 1000;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedYear,
                    icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 28),
                    dropdownColor: Theme.of(context).primaryColorDark,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    borderRadius: BorderRadius.circular(12),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedYear = newValue!;
                      });
                    },
                    items: academicYears.map<DropdownMenuItem<String>>((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year, style: TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).canvasColor,
      body: isDesktop ? _buildDesktopView(context) : _buildMobileView(context),
    );
  }

  // Desktop view layout
  Widget _buildDesktopView(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 300,
          color: Theme.of(context).cardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildProfileSection(context),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Divider(),
              ),

              buildNavigationMenu(context),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Divider(),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent, // Set button color to red
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Main Content Area
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  buildDashboardWidgets(selectedYear: selectedYear), // Pass `selectedYear` here
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Mobile view layout
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

void _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false); // Reset login status

  // Navigate back to the login screen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => AdminLoginScreen()),
  );
}