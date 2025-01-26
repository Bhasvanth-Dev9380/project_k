import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/educatorCard.dart';

class AdminDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> _getUniversity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('instituteName') ?? 'default_university'; // Provide a default if necessary
  }

  // Update course details in Firebase
  Future<void> updateCourse({
    required String academicYear,
    required String semester,
    required String docId,
    required String courseTitle,
    required String courseCode,
    String? assignedFaculty, // Optional parameter for faculty
  }) async {
    try {
      String university = await _getUniversity();

      final courseRef = _db
          .collection('institutes')
          .doc(university)
          .collection(academicYear) // Direct academic year collection under university
          .doc(semester)
          .collection('courses')
          .doc(docId);

      Map<String, dynamic> updateData = {
        'courseTitle': courseTitle,
        'courseCode': courseCode,
      };

      if (assignedFaculty != null) {
        updateData['assignedFaculty'] = assignedFaculty;
      }

      await courseRef.update(updateData);
      print("Course updated successfully with docId $docId.");
    } catch (e) {
      print("Error updating course: $e");
      throw Exception("Error updating course: $e");
    }
  }

  // Get course count for a specific university, academic year, and semester
  Future<int> getCourseCount(String academicYear, String semester) async {
    String university = await _getUniversity();

    final snapshot = await _db
        .collection('institutes')
        .doc(university)
        .collection(academicYear)
        .doc(semester)
        .collection('courses')
        .get();
    return snapshot.size;
  }

  // Get courses for a given university, academic year, and semester
  Future<List<QueryDocumentSnapshot>> getCourses(String academicYear, String semester) async {
    String university = await _getUniversity();

    final snapshot = await _db
        .collection('institutes')
        .doc(university)
        .collection(academicYear)
        .doc(semester)
        .collection('courses')
        .get();
    return snapshot.docs;
  }

  // Create a new course
  Future<void> createCourse(String academicYear, String semester, String courseId, Map<String, dynamic> courseData) async {
    String university = await _getUniversity();

    await _db
        .collection('institutes')
        .doc(university)
        .collection(academicYear)
        .doc(semester)
        .collection('courses')
        .doc(courseId)
        .set(courseData);
  }

  // Delete a course
  Future<void> deleteCourse(String academicYear, String semester, String courseId) async {
    String university = await _getUniversity();

    // Reference to the course document
    final courseRef = _db
        .collection('institutes')
        .doc(university)
        .collection(academicYear)
        .doc(semester)
        .collection('courses')
        .doc(courseId);

    // Delete the course document
    await courseRef.delete();

    // Remove this course from any educator's assigned courses
    // Query educators who have this course assigned
    final educatorsSnapshot = await _db.collection('educators').get();

    for (var educatorDoc in educatorsSnapshot.docs) {
      List<dynamic> courses = educatorDoc.data()['courses'] ?? [];

      // Filter out the course with the matching courseId
      List<dynamic> updatedCourses = courses.where((course) {
        return course['courseId'] != courseId;
      }).toList();

      // Update the educator's courses array with the filtered list
      await educatorDoc.reference.update({
        'courses': updatedCourses,
      });
    }



    print("Course and references in educators deleted successfully.");
  }




  // Get all educators as a stream filtered by institution
  Stream<List<EducatorCardData>> getEducators() async* {
    String university = await _getUniversity();

    yield* _db.collection('educators').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Parse courses as a list of maps containing ay, courseCode, and courseId
        List<Map<String, String>> courses = (data['courses'] as List<dynamic>? ?? []).map((course) {
          return (course as Map<String, dynamic>).map((key, value) => MapEntry(key as String, value as String));
        }).toList();

        return EducatorCardData(
          email: data['email'] ?? '',
          institution: data['institution'] ?? '',
          courses: courses,
        );
      })
          .where((educator) => educator.institution.toLowerCase() == university.toLowerCase())
          .toList();
    });
  }




  Future<void> assignCourseToEducator(String educatorEmail, String academicYear, String courseCode, String courseId) async {
    final educatorRef = _db.collection('educators').where('email', isEqualTo: educatorEmail);

    // Get educator document by email
    final snapshot = await educatorRef.get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;

      // The data to add: a map with the academic year as the key
      // containing a list of course maps with code and id
      final courseMap = {
        'ay': academicYear,
        'courseCode': courseCode,
        'courseId': courseId,
      };

      // Update the educator document, adding the new course under the academic year
      await doc.reference.update({
        'courses': FieldValue.arrayUnion([courseMap]),
      });
      print("Course assigned to educator successfully.");
    } else {
      print("Educator not found.");
    }
  }

}
