import 'package:flutter/material.dart';
import 'facultyCard.dart';
import 'facultyDashboard.dart';
import 'facultyDatabase.dart';
import 'facultyModel.dart';

class FacultyPage extends StatefulWidget {
  final List<String> academicYears;
  final List<String> semesters;

  const FacultyPage({
    Key? key,
    required this.academicYears,
    required this.semesters,
  }) : super(key: key);

  @override
  _FacultyPageState createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  final TextEditingController _searchController = TextEditingController();
  final FacultyDatabase _facultyDatabase = FacultyDatabase();
  String selectedYear = '';
  String selectedSemester = '';
  List<FacultyData> facultyList = [];
  List<FacultyData> filteredList = [];
  FacultyData? selectedFaculty;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.academicYears.first;
    selectedSemester = widget.semesters.first;
    _loadFacultyData();
  }

  void _loadFacultyData() async {
    final data = await _facultyDatabase.getFacultyData(selectedYear, selectedSemester);
    setState(() {
      facultyList = data;
      filteredList = data;
    });
  }

  void _filterFaculty() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredList = facultyList.where((faculty) {
        final email = faculty.email.toLowerCase();
        return email.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: Colors.transparent,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Faculty", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDropdown("Academic Year", widget.academicYears, selectedYear, (value) {
                  setState(() {
                    selectedYear = value!;
                    _loadFacultyData();
                  });
                }),
               ],
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // First Column for Faculty List
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _filterFaculty(),
                    decoration: InputDecoration(
                      hintText: 'Search faculty by email',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final faculty = filteredList[index];
                      return FacultyCard(
                        faculty: faculty,
                        onPressed: () {
                          setState(() {
                            selectedFaculty = faculty;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Second Column for Faculty Dashboard
          if (selectedFaculty != null)
            Expanded(
              flex: 2,
              child: FacultyDashboard(),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue, ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 28),
          dropdownColor: Theme.of(context).primaryColorDark,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(fontSize: 16)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
