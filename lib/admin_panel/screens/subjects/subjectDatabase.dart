import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_k/admin_panel/screens/subjects/subjectModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<SubjectData>> getSubjects(String academicYear, String semester) async {
    Future<String> _getUniversity() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('instituteName') ?? 'default_university'; // Provide a default if necessary
    }
    String university = await _getUniversity(); // Fetch the university from shared preferences or other global storage.

    final snapshot = await _db
        .collection('institutes')
        .doc(university)
        .collection(academicYear)
        .doc("Semester ${semester}")
        .collection('courses')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SubjectData(
        subjectId: data['courseId'] ?? doc.id,
        subjectName: data['courseTitle'] ?? 'Unknown Subject',
        assignedFaculty: data['assignedFaculty'] ?? 'Not Assigned', subjectCode: data['courseCode'] ?? 'N/A',
      );
    }).toList();
  }
}
