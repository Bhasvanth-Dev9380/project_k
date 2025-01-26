import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/educator/assignment/model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference for users
  final String usersCollection = 'users';

  // Check if the user is logging in for the first time by checking Firestore
  Future<bool> checkIfFirstLogin(String uid) async {
    DocumentSnapshot doc = await _db.collection(usersCollection).doc(uid).get();
    return !doc.exists; // If the document doesn't exist, it's the first login
  }

  // Store user data (including role and institution) in Firestore
  Future<void> storeUserData(String uid, String email, String role, String institution) async {
    // Create user document in 'users' collection
    await _db.collection(usersCollection).doc(uid).set({
      'uid': uid,
      'email': email,
      'role': role,
      'institution': institution,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Create separate collection based on the role (Educator, Student, or Parent)
    String collectionName;

    switch (role.toLowerCase()) {
      case 'educator':
        collectionName = 'educators';
        break;
      case 'student':
        collectionName = 'students';
        break;
      case 'parent':
        collectionName = 'parents';
        break;
      default:
        throw ('Invalid role'); // Throw an error for unsupported roles
    }

    // Store role-specific data in the respective collection
    await _db.collection(collectionName).doc(uid).set({
      'uid': uid,
      'email': email,
      'institution': institution,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Retrieve user's role and university from Firestore
  Future<Map<String, String?>> getUserData(String uid) async {
    DocumentSnapshot doc = await _db.collection(usersCollection).doc(uid).get();
    if (doc.exists) {
      return {
        'role': doc['role'],
        'university': doc['institution'],
      };
    }
    return {
      'role': null,
      'university': null,
    };
  }
}


// Assignment Service for retrieving educator's subjects
class AssignmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch semesters for the educator from Firestore
  Future<List<String>> getSemesters(String educatorId) async {
    if (educatorId == null) throw 'Educator ID is null';

    QuerySnapshot semesterSnapshot = await _db
        .collection('educators')
        .doc(educatorId)
        .collection('subjects')
        .get();

    return semesterSnapshot.docs.map((doc) => doc.id).toList();
  }

  // Fetch subjects based on the selected semester
  Future<List<Map<String, dynamic>>> getSubjects(String educatorId, String semester) async {
    if (educatorId == null) throw 'Educator ID is null';

    DocumentSnapshot semesterDoc = await _db
        .collection('educators')
        .doc(educatorId)
        .collection('subjects')
        .doc(semester)
        .get();

    if (semesterDoc.exists) {
      return List<Map<String, dynamic>>.from(semesterDoc['subjects']);
    }

    return [];
  }

  // Save assignment in the appropriate semester subcollection
  Future<void> saveAssignment(Assignment assignment, String educatorId, String selectedSemester, String subjectCode) async {
    await FirebaseFirestore.instance
        .collection('educators')
        .doc(educatorId)
        .collection('subjects')
        .doc(selectedSemester)
        .collection('assignments') // Create an 'assignments' subcollection under the selected semester
        .add({
      'title': assignment.title,
      'description': assignment.description,
      'questions': assignment.questions,
      'deadline': assignment.deadline,
      'postedTime': assignment.postedTime,
      'visible': assignment.visible,
      'subject_code': subjectCode, // Add subject code to each assignment
    });
  }

  // Function to delete an assignment
  Future<void> deleteAssignment(String assignmentId,String educatorId,String selectedSemester) async {
    await FirebaseFirestore.instance
        .collection('educators')
        .doc(educatorId)
        .collection('subjects')
        .doc(selectedSemester)
        .collection('assignments')
        .doc(assignmentId)
        .delete();
  }

}