import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_k/screens/educator/drawer/drawerscreen.dart';
import '../../../models/usermodel.dart';
import '../assignment/assignment_page.dart';
import 'Dashboard_screen.dart';
import 'chatscreen.dart';

class EducatorScreen extends StatefulWidget {
  @override
  _EducatorScreenState createState() => _EducatorScreenState();
}

class _EducatorScreenState extends State<EducatorScreen> with SingleTickerProviderStateMixin {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  bool isDrawerOpen = false;
  int _currentIndex = 0;
  bool _isExpanded = false; // Track if FAB is expanded

  late AnimationController _fabController; // Animation controller for FAB expansion
  late Animation<double> _fabAnimation; // FAB Animation

  final List<Widget> _pages = [
    HomeScreen(),
    ChatPage(), // Discussions page
  ];

  @override
  void initState() {
    super.initState();

    // Set drawer state to open by default on web
    if (kIsWeb) {
      xOffset = 200;
      yOffset = 100;
      isDrawerOpen = true;
    }

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? firebaseUser = FirebaseAuth.instance.currentUser;

    return Stack(
      children: [
        Drawersscreen(),
        AnimatedContainer(
          padding: isDrawerOpen ? const EdgeInsets.all(8.0) : const EdgeInsets.all(0.0),
          transform: Matrix4.translationValues(xOffset, yOffset, 0)
            ..scale(isDrawerOpen ? 0.85 : 1.00),
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isDrawerOpen ? BorderRadius.circular(40) : BorderRadius.circular(0),
          ),
          child: Padding(
            padding: isDrawerOpen ? const EdgeInsets.all(8.0) : EdgeInsets.all(0),
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: isDrawerOpen
                    ? (kIsWeb)?IconButton(
                  onPressed: () {

                  },
                  icon: Icon(
                    null
                  ),
                ):IconButton(
                  onPressed: () {
                    setState(() {
                      xOffset = 0;
                      yOffset = 0;
                      isDrawerOpen = false;
                    });
                  },
                  icon: Icon(
                    CupertinoIcons.back,
                    color: Colors.black,
                  ),
                )
                    : IconButton(
                  onPressed: () {
                    setState(() {
                      xOffset = 200;
                      yOffset = 100;
                      isDrawerOpen = true;
                    });
                  },
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                        UserModel.fromFirebaseUser(firebaseUser!).profileImage),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.black),
                    onPressed: () {
                      // Navigate to settings
                    },
                  ),
                ],
              ),
              body: Stack(
                children: [
                  _pages[_currentIndex],
                  if (_currentIndex != 1) _buildExpandedFAB(), // Show FAB only if not in "Discussions"
                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              floatingActionButton: _currentIndex != 1 ? _buildMainFAB() : null, // Hide FAB on "Discussions" page
              bottomNavigationBar: _buildBottomNavigationBar(),
            ),
          ),
        )
      ],
    );
  }

  // Main FAB that expands/collapses the other FABs
  Widget _buildMainFAB() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _isExpanded = !_isExpanded;
          if (_isExpanded) {
            _fabController.forward();
          } else {
            _fabController.reverse();
          }
        });
      },
      backgroundColor: Colors.purple.shade300,
      child: Icon(_isExpanded ? Icons.close : Icons.add),
    );
  }

  // Expanded FABs: Add Quiz, Upload Assignment, Upload Video with Labels
  Widget _buildExpandedFAB() {
    return Positioned(
      bottom: 50, // Adjust based on where you want the FABs
      right: MediaQuery.of(context).size.width / 2 - 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFABWithLabel(
            label: 'Add Quiz',
            icon: Icons.quiz,
            onPressed: () {
              print("Add Quiz");
            },
          ),
          const SizedBox(height: 8), // Adjust spacing between FABs
          _buildFABWithLabel(
            label: 'Create Assignment',
            icon: Icons.assignment,
            onPressed: () {
              print("Upload Assignment");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssignmentHomePage(),
                ),
              );
            },
          ),
          const SizedBox(height: 8), // Adjust spacing between FABs
          _buildFABWithLabel(
            label: 'Upload Video',
            icon: Icons.video_call,
            onPressed: () {
              print("Upload Video");
            },
          ),
        ],
      ),
    );
  }

  // Helper method to build a FAB with a label
  Widget _buildFABWithLabel({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ScaleTransition(
      scale: _fabAnimation,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: Colors.purple.shade300,
            mini: true,
            heroTag: label, // Use label as a unique heroTag for each FAB
            child: Icon(icon),
          ),
          const SizedBox(width: 10), // Space between FAB and label
          GestureDetector(
            onTap: onPressed,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.messenger_outline),
          label: 'Discussions',
        ),
      ],
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
    );
  }
}
