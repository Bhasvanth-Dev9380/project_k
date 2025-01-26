import 'package:flutter/material.dart';
import 'facultyModel.dart';

class FacultyCard extends StatelessWidget {
  final FacultyData faculty;
  final VoidCallback onPressed;

  const FacultyCard({
    Key? key,
    required this.faculty,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      child: GestureDetector(
        onTap: onPressed,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: faculty.courses.isNotEmpty ? Colors.orangeAccent : Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text(
                            faculty.email,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '${faculty.courses.length} Courses Assigned',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueAccent),
                ),
              ),
              SizedBox(height: 10),
              // Display assigned courses
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: faculty.courses.map((course) {
                    return Text(
                      '${course.courseCode} - ${course.academicYear}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    child: Text('More', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
