import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:project_k/screens/educator/assignment/colors_assignment.dart';
import '../../../database/Database.dart';
import 'new assignment.dart';

class AssignmentHomePage extends StatefulWidget {
  @override
  _AssignmentHomePageState createState() => _AssignmentHomePageState();
}

class _AssignmentHomePageState extends State<AssignmentHomePage> {
  List<Map<String, dynamic>> subjects =
      []; // List of subjects for the selected semester
  String? selectedSemester; // The selected semester from the dropdown
  String? selectedSubject; // The selected subject from the subject dropdown
  List<String> semesters = []; // List of semesters fetched from Firestore

  final AssignmentService assignmentService = AssignmentService();
  final User? firebaseUser = FirebaseAuth.instance.currentUser;
  String? educatorId;
  bool isLoading = true; // To control the loading state

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  // Initialize the page by fetching the educator's ID and semesters
  Future<void> _initializePage() async {
    setState(() {
      isLoading = true; // Start loading
    });

    educatorId = firebaseUser?.uid;

    if (educatorId != null) {
      // Fetch semesters for the educator
      await _fetchSemesters();
      if (semesters.isNotEmpty) {
        // Fetch subjects for the first semester by default
        selectedSemester = semesters[0];
        await _fetchSubjects(selectedSemester!);
      }
    }

    setState(() {
      isLoading = false; // End loading
    });
  }

  // Fetch semesters for the educator
  Future<void> _fetchSemesters() async {
    if (educatorId == null) return;

    List<String> fetchedSemesters =
        await assignmentService.getSemesters(educatorId!);

    setState(() {
      semesters = fetchedSemesters;
    });
  }

  // Fetch subjects based on the selected semester
  Future<void> _fetchSubjects(String semester) async {
    if (educatorId == null) return;

    List<Map<String, dynamic>> fetchedSubjects =
        await assignmentService.getSubjects(educatorId!, semester);

    setState(() {
      subjects = fetchedSubjects;
      selectedSubject =
          null; // Reset subject selection when a new semester is selected
    });
  }

  // StreamBuilder to fetch and display assignments based on dropdown selection
  Widget _buildAssignments() {
    if (selectedSemester == null || selectedSubject == null) {
      return Center(child: Text('Please select a semester and subject'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('educators')
          .doc(educatorId)
          .collection('subjects')
          .doc(selectedSemester)
          .collection('assignments')
          .where('subject_code',
              isEqualTo: selectedSubject) // Filter by subject code
          .where('visible', isEqualTo: true) // Only show visible assignments
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No assignments available'));
        }

        final assignments = snapshot.data!.docs;

        return ListView.builder(
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            final assignment = assignments[index];

            // Define the possible gradient colors
            final List<List<Color>> gradients = [
              [Colors.pinkAccent.shade200, Colors.deepOrangeAccent],
              [Colors.deepPurpleAccent.shade200, Colors.blueAccent],
              [Colors.indigo.shade200, Colors.lightBlueAccent.shade400],
            ];

            // Pick a random gradient from the list for each card
            final randomGradient =
                gradients[Random().nextInt(gradients.length)];

            return Dismissible(
              key: Key(assignment.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) async {
                // Handle delete action
                await AssignmentService().deleteAssignment(
                    assignment.id, educatorId!, selectedSemester!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Assignment deleted')),
                );
              },
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white, size: 30),
              ),
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 8, // Add shadow for a modern look
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    // Handle onTap if needed
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors:
                            randomGradient, // Apply the random gradient to each card
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment['title'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .white, // White font to contrast with gradient
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Posted: ${DateFormat('yyyy-MM-dd – HH:mm').format(assignment['postedTime'].toDate())}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Deadline: ${DateFormat('yyyy-MM-dd – HH:mm').format(assignment['deadline'].toDate())}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.yellowAccent, // Highlighted deadline
                          ),
                        ),
                        if (assignment['description'] != null) ...[
                          SizedBox(height: 10),
                          Text(
                            'Description:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            assignment['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                        if (assignment['questions'] != null &&
                            assignment['questions'].isNotEmpty) ...[
                          SizedBox(height: 10),
                          Text(
                            'Questions:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          ...List.generate(assignment['questions'].length,
                              (qIndex) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                'Q${qIndex + 1}: ${assignment['questions'][qIndex]}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments by Semester and Subject'),
        backgroundColor: AssignmentColors.primaryDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSemesterFilter(),
            SizedBox(height: 16),
            if (subjects.isNotEmpty)
              _buildSubjectFilter(), // Show subject dropdown only if subjects are loaded
            SizedBox(height: 16),
            Expanded(
                child:
                    _buildAssignments()), // Display the assignments based on dropdowns
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewAssignmentPage(
              onSubmit: (assignment) async {
                // When the assignment is submitted, save it to Firestore
                await AssignmentService().saveAssignment(assignment,
                    educatorId!, selectedSemester!, selectedSubject!);
              },
              selectedSemester: selectedSemester!, // Pass the selected semester
              educatorId: educatorId!, // Pass the educator's ID
            ),
          ),
        ),
        child: Icon(Icons.add),
        backgroundColor: Colors.purple.shade300,
      ),
    );
  }

  // Build the filter dropdown for selecting a semester
  Widget _buildSemesterFilter() {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            value: selectedSemester,
            onChanged: (value) async {
              setState(() {
                selectedSemester = value!;
                isLoading = true; // Start loading while fetching subjects
              });

              await _fetchSubjects(value!);

              setState(() {
                isLoading = false; // End loading
              });
            },
            items: semesters.map((semester) {
              return DropdownMenuItem<String>(
                value: semester,
                child: Text(semester),
              );
            }).toList(),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down),
          ),
        ),
      ],
    );
  }

  // Build the filter dropdown for selecting a subject
  Widget _buildSubjectFilter() {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            value: selectedSubject,
            onChanged: (value) {
              setState(() {
                selectedSubject = value!;
              });
            },
            items: subjects.map((subject) {
              return DropdownMenuItem<String>(
                value: subject['subject_code'], // Use subject code as value
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['subject_name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(subject['subject_code']),
                  ],
                ),
              );
            }).toList(),
            hint: Text('Select Subject'), // Placeholder for the dropdown
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down),
          ),
        ),
      ],
    );
  }
}
