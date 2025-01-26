import 'package:flutter/material.dart';
import 'package:project_k/admin_panel/screens/subjects/subjectModel.dart';

class SubjectCard extends StatelessWidget {
  final SubjectData subject;

  const SubjectCard({Key? key, required this.subject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)], // Darker blue-purple gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display course name and code with icons
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.book, color: Colors.white, size: 28),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.subjectName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Brighter text color for better contrast
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Course Code: ${subject.subjectCode}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70, // Softer white for subtitle text
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Divider for visual separation
            Divider(thickness: 1, color: Colors.white24),

            SizedBox(height: 8),

            // Assigned Faculty information with a subtle shadow
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subject.assignedFaculty.isNotEmpty
                        ? 'Assigned Faculty: ${subject.assignedFaculty}'
                        : 'No Faculty Assigned',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: subject.assignedFaculty.isNotEmpty ? Colors.white : Colors.redAccent,
                      fontWeight: subject.assignedFaculty.isNotEmpty ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
