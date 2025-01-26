import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../admindatabase/adminDatabase.dart';
import '../../homeScreen/homeScreen.dart';
import '../../utils/educatorCard.dart';
import '../../utils/semesterCard.dart';
import '../../utils/courseCard.dart';

class buildDashboardWidgets extends StatefulWidget {
  final String selectedYear;

  buildDashboardWidgets({required this.selectedYear});
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<buildDashboardWidgets> {
  final AdminDatabase adminDatabase = AdminDatabase();
  String? selectedSemester;
  List<CourseCardData> courses = [];
  List<EducatorCardData> educators = [];

  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _educatorsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _listenToEducatorsStream();
  }

  // Load educators
  void _listenToEducatorsStream() {
    adminDatabase.getEducators().listen((fetchedEducators) {
      setState(() {
        educators = fetchedEducators;
      });
    });
  }


  // Add a new course via dialog input
  void _addNewCourse() async {
    var uuid = Uuid();
    if (selectedSemester != null) {
      String courseTitle = '';
      String courseCode = '';

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add New Course'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Course Title'),
                  onChanged: (value) {
                    courseTitle = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Course Code'),
                  onChanged: (value) {
                    courseCode = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (courseTitle.isNotEmpty && courseCode.isNotEmpty) {
                    String courseId = uuid.v4();

                    await adminDatabase.createCourse(
                      selectedYear,
                      selectedSemester!,
                      courseId,
                      {
                        'courseTitle': courseTitle,
                        'courseCode': courseCode,
                        'courseId': courseId,
                      },
                    );
                    _loadCourses(selectedSemester!);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Add Course', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }
  }

  // Load courses when a semester is selected
  void _loadCourses(String semester) async {
    final fetchedCourses = await adminDatabase.getCourses(selectedYear, semester);
    setState(() {
      selectedSemester = semester;
      courses = fetchedCourses.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CourseCardData(
          courseId: doc.id,
          courseTitle: data['courseTitle'],
          courseCode: data['courseCode'],
          assignedFaculty: data['assignedFaculty'] ?? '',
        );
      }).toList();
    });
  }

  void _showEditCourseDialog(CourseCardData courseToEdit) async {
    String courseTitle = courseToEdit.courseTitle;
    String courseCode = courseToEdit.courseCode;
    String courseId = courseToEdit.courseId;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: courseTitle),
                decoration: InputDecoration(labelText: 'Course Title'),
                onChanged: (value) {
                  courseTitle = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: courseCode),
                decoration: InputDecoration(labelText: 'Course Code'),
                onChanged: (value) {
                  courseCode = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (courseTitle.isNotEmpty && courseCode.isNotEmpty) {
                  await adminDatabase.updateCourse(
                    academicYear: selectedYear,
                    semester: selectedSemester!,
                    courseCode: courseCode,
                    courseTitle: courseTitle,
                    docId: courseId,
                  );
                  _loadCourses(selectedSemester!);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _assignFacultyToCourse(EducatorCardData educator, CourseCardData course) async {
    await adminDatabase.updateCourse(
      academicYear: selectedYear,
      semester: selectedSemester!,
      docId: course.courseId,
      courseTitle: course.courseTitle,
      courseCode: course.courseCode,
      assignedFaculty: educator.email,
    );
    _loadCourses(selectedSemester!);
  }

  void _scrollMainList(DragUpdateDetails details) {
    if (_mainScrollController.hasClients) {
      double maxScrollExtent = _mainScrollController.position.maxScrollExtent;
      double minScrollExtent = _mainScrollController.position.minScrollExtent;
      double scrollOffset = _mainScrollController.offset;

      // Scroll up when dragging near the top
      if (details.localPosition.dy < 100 && scrollOffset > minScrollExtent) {
        _mainScrollController.jumpTo(scrollOffset - 10);
      }
      // Scroll down when dragging near the bottom
      else if (details.localPosition.dy > MediaQuery.of(context).size.height - 100 && scrollOffset < maxScrollExtent) {
        _mainScrollController.jumpTo(scrollOffset + 10);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _mainScrollController,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // First Column with Semester heading
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semester',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 10),
                  ...List.generate(8, (index) {
                    return FutureBuilder<int>(
                      future: adminDatabase.getCourseCount(selectedYear, 'Semester ${index + 1}'),
                      builder: (context, snapshot) {
                        int courseCount = snapshot.data ?? 0;
                        return SemesterCard(
                          data: SemesterCardData(
                            semesterTitle: 'Semester ${index + 1}',
                            courseCount: courseCount,
                          ),
                          onPressed: () => _loadCourses('Semester ${index + 1}'),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          // Divider
          Container(
            width: 1.5,
            height: MediaQuery.of(context).size.height,
            color: Colors.grey.shade400,
          ),

          // Second Column: Courses list or placeholder text
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedSemester == null
                        ? 'Select a Semester to view courses'
                        : '$selectedSemester Courses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 10),
                  if (selectedSemester != null)
                    Align(
                      alignment: Alignment.topCenter,
                      child: FloatingActionButton.extended(
                        onPressed: _addNewCourse,
                        label: Row(
                          children: [
                            Text("Add New Course", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(width: 8),
                            Icon(Icons.add),
                          ],
                        ),
                        backgroundColor: Color(0xFFA6ABFF),
                      ),
                    ),
                  SizedBox(height: 10),
                  Expanded(
                    child: courses.isEmpty
                        ? Center(
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No courses available. Add a new course using the button below.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    )
                        : ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return CourseCard(
                          data: course,
                          onEdit: () {
                            _showEditCourseDialog(course);
                          },
                          onDelete: () async {
                            await adminDatabase.deleteCourse(
                              selectedYear,
                              selectedSemester!,
                              course.courseId,
                            );
                            _loadCourses(selectedSemester!);
                          },
                          onAssignFaculty: (educator) async {
                            _assignFacultyToCourse(educator, course);
                            await adminDatabase.assignCourseToEducator(educator.email,selectedYear, course.courseCode,course.courseId);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          Container(
            width: 1.5,
            height: MediaQuery.of(context).size.height,
            color: Colors.grey.shade400,
          ),

          // Third Column with Faculty heading and auto-scroll on drag
          if (selectedSemester != null && courses.isNotEmpty)
            Expanded(
              child: GestureDetector(
                onPanUpdate: _scrollMainList,
                child: Column(
                  children: [
                    Text(
                      'Faculty',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          controller: _educatorsScrollController,
                          itemCount: educators.length,
                          itemBuilder: (context, index) {
                            final educator = educators[index];
                            return EducatorCard(
                              data: educator,
                              onTap: () {
                                print("Assigned courses: ${educator.courses}");
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
