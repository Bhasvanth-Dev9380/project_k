import 'package:flutter/material.dart';

class EducatorCardData {
  final String email;
  final String institution;
  final List<Map<String, String>> courses;

  const EducatorCardData({
    required this.email,
    required this.institution,
    this.courses = const [],
  });
}

class EducatorCard extends StatelessWidget {
  final EducatorCardData data;
  final Function() onTap;

  const EducatorCard({
    Key? key,
    required this.data,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the indicator color: green if there are assigned courses, otherwise grey
    Color indicatorColor = data.courses.isNotEmpty ? Colors.lightGreen : Colors.grey;

    return Draggable<EducatorCardData>(
      data: data,
      feedback: Material(
        color: Colors.transparent,
        child: _buildEducatorCardContent(context, indicatorColor),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildEducatorCardContent(context, indicatorColor),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: _buildEducatorCardContent(context, indicatorColor),
      ),
    );
  }

  Widget _buildEducatorCardContent(BuildContext context, Color indicatorColor) {
    return Card(
      color: const Color.fromRGBO(128, 109, 255, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: indicatorColor,
                  radius: 5,
                ),
                SizedBox(width: 8),
                Text(
                  data.email,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Institution: ${data.institution}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 8),
            if (data.courses.isNotEmpty) ...[
              Text(
                'Assigned Courses:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.courses.map((course) {
                  // Format the display of course information based on keys in the map
                  final ay = course['ay'] ?? '';
                  final courseCode = course['courseCode'] ?? '';
                  return Text(
                    'AY: $ay - Code: $courseCode',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }).toList(),
              ),
          ] else ...[
              Text(
                'No assigned courses.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

