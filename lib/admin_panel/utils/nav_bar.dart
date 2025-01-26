import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/adminlogin.dart';
import '../homeScreen/homeScreen.dart';
import '../screens/faculty/faculty.dart';
import '../screens/subjects/subjects.dart';

// Sidebar profile section

Future<String?> _getInstituteName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('instituteName');
}

Widget buildProfileSection(BuildContext context) {
  return FutureBuilder<String?>(
    future: _getInstituteName(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 20,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data ?? 'Unknown Institute',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                Text(
                  'Admin Login',
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}



Widget buildNavigationMenu(BuildContext context) {
  return Column(
    children: [
      ListTile(
        leading: Icon(Icons.home, color: Theme.of(context).iconTheme.color),
        title: Text('Home', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      ),
      ListTile(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubjectsPage(
                academicYears: academicYears, // list of available academic years
                initialAcademicYear: selectedYear,
                semesters: ['1','2','3','4','5','6'], initialSemester: '1',// the default academic year to show
              ),
            ),
          );

        },
        leading: Icon(Icons.book, color: Theme.of(context).iconTheme.color),
        title: Text('Subjects', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      ),
      ListTile(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FacultyPage(
                academicYears: academicYears,
                semesters:  ['1','2','3','4','5','6'],
              ),
            ),
          );
        },
        leading: Icon(Icons.person, color: Theme.of(context).iconTheme.color),
        title: Text('Faculty', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      ),
      ListTile(
        leading: Icon(Icons.school, color: Theme.of(context).iconTheme.color),
        title: Text('Students', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      ),
    ],
  );
}