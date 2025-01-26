import 'package:flutter/material.dart';
import 'package:project_k/admin_panel/screens/subjects/subjectCard.dart';
import 'package:project_k/admin_panel/screens/subjects/subjectDatabase.dart';
import 'package:project_k/admin_panel/screens/subjects/subjectModel.dart';

class SubjectsPage extends StatefulWidget {
  final List<String> academicYears;
  final String initialAcademicYear;
  final List<String> semesters;
  final String initialSemester;

  const SubjectsPage({
    Key? key,
    required this.academicYears,
    required this.initialAcademicYear,
    required this.semesters,
    required this.initialSemester,
  }) : super(key: key);

  @override
  _SubjectsPageState createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final SubjectDatabase _subjectDatabase = SubjectDatabase();
  late Future<List<SubjectData>> _subjectsFuture;
  late String selectedYear;
  late String selectedSemester;
  List<SubjectData> _allSubjects = [];
  List<SubjectData> _filteredSubjects = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialAcademicYear;
    selectedSemester = widget.initialSemester;
    _loadSubjectsForYearAndSemester(selectedYear, selectedSemester);

    _searchController.addListener(_filterSubjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSubjectsForYearAndSemester(String academicYear, String semester) {
    setState(() {
      _subjectsFuture = _subjectDatabase.getSubjects(academicYear, semester);
    });

    _subjectsFuture.then((subjects) {
      setState(() {
        _allSubjects = subjects;
        _filteredSubjects = subjects;
      });
    });
  }

  void _filterSubjects() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSubjects = _allSubjects.where((subject) {
        final name = subject.subjectName.toLowerCase();
        final code = subject.subjectCode.toLowerCase();
        return name.contains(query) || code.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 160,
        backgroundColor: Colors.transparent,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.black), // Set input text color to black
                decoration: InputDecoration(
                  hintText: 'Search by course name or code',
                  hintStyle: TextStyle(color: Colors.grey), // Optional: Set hint color
                  prefixIcon: Icon(Icons.search, color: Colors.grey), // Optional: Set icon color
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),
            // Academic Year and Semester Dropdowns
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Academic Year Dropdown
                Container(
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
                        if (newValue != null && newValue != selectedYear) {
                          setState(() {
                            selectedYear = newValue;
                          });
                          _loadSubjectsForYearAndSemester(newValue, selectedSemester);
                        }
                      },
                      items: widget.academicYears.map<DropdownMenuItem<String>>((String year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(year, style: TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Semester Dropdown
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSemester,
                      icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 28),
                      dropdownColor: Theme.of(context).primaryColorDark,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      borderRadius: BorderRadius.circular(12),
                      onChanged: (String? newValue) {
                        if (newValue != null && newValue != selectedSemester) {
                          setState(() {
                            selectedSemester = newValue;
                          });
                          _loadSubjectsForYearAndSemester(selectedYear, newValue);
                        }
                      },
                      items: widget.semesters.map<DropdownMenuItem<String>>((String semester) {
                        return DropdownMenuItem<String>(
                          value: semester,
                          child: Text('Semester ${semester}', style: TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<SubjectData>>(
        future: _subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || _filteredSubjects.isEmpty) {
            return Center(child: Text('No subjects found for this academic year and semester.'));
          } else {
            return ListView.builder(
              itemCount: _filteredSubjects.length,
              itemBuilder: (context, index) {
                final subject = _filteredSubjects[index];
                return SubjectCard(subject: subject);
              },
            );
          }
        },
      ),
    );
  }
}
