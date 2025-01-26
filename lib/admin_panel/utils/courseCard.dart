import 'package:flutter/material.dart';
import 'educatorCard.dart';

class CourseCardData {
  final String courseTitle;
  final String courseCode;
  final String courseId;
  String? assignedFaculty;

  CourseCardData({
    required this.courseTitle,
    required this.courseCode,
    required this.courseId,
    this.assignedFaculty,
  });
}

class CourseCard extends StatefulWidget {
  const CourseCard({
    required this.data,
    required this.onEdit,
    required this.onDelete,
    required this.onAssignFaculty,
    Key? key,
  }) : super(key: key);

  final CourseCardData data;
  final Function() onEdit;
  final Future<void> Function() onDelete;
  final Function(EducatorCardData) onAssignFaculty;

  @override
  _CourseCardState createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool isLoading = false;

  Future<void> handleDelete() async {
    setState(() {
      isLoading = true;
    });

    await widget.onDelete();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<EducatorCardData>(
      onAccept: (faculty) {
        widget.onAssignFaculty(faculty);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Theme.of(context).primaryColorLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.courseTitle,
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Course Code: ${widget.data.courseCode}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      if (widget.data.assignedFaculty != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Faculty: ${widget.data.assignedFaculty}',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: widget.onEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text('Edit', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : handleDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: isLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
