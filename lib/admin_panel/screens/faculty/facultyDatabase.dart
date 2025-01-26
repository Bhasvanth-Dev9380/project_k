import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'facultyModel.dart';

class FacultyDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Helper function to retrieve the university/institute name from shared preferences
  Future<String> _getUniversity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('instituteName')?.toLowerCase() ?? 'default_university';
  }

  Future<List<FacultyData>> getFacultyData(String academicYear, String semester) async {
    String university = await _getUniversity();
    final snapshot = await _db.collection('educators').get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      List<CourseAssignment> courses = [];

      // Check if the educator is from the specified university (case-insensitive)
      if (data['institution'] != null && data['institution'].toString().toLowerCase() == university) {
        if (data['courses'] != null) {
          for (var course in data['courses']) {
            // Only add courses that match the specified academic year
            if (course['ay'] == academicYear) {
              courses.add(
                CourseAssignment(
                  academicYear: course['ay'],
                  courseCode: course['courseCode'],
                  courseId: course['courseId'],
                ),
              );
            }
          }
        }

        // Return the FacultyData only if there are matching courses
        return FacultyData(
          email: data['email'] ?? '',
          institution: data['institution'] ?? '',
          courses: courses,
        );
      }
    }).where((facultyData) => facultyData != null && facultyData!.courses.isNotEmpty).toList().cast<FacultyData>();
  }
}
