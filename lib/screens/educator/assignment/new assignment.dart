import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'colors_assignment.dart';
import 'model.dart';

class NewAssignmentPage extends StatefulWidget {
  final Function(Assignment) onSubmit;
  final String selectedSemester;
  final String educatorId;
  final Map<String, dynamic>? existingAssignment;

  NewAssignmentPage({
    required this.onSubmit,
    required this.selectedSemester,
    required this.educatorId,
    this.existingAssignment,
  });

  @override
  _NewAssignmentPageState createState() => _NewAssignmentPageState();
}

class _NewAssignmentPageState extends State<NewAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _questions = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  bool _isVisible = false;
  DateTime? _selectedDeadline;
  DateTime? _scheduledTime;

  void _addQuestion() {
    if (_questionController.text.isNotEmpty) {
      setState(() {
        _questions.add(_questionController.text);
        _questionController.clear();
      });
    }
  }

  void _submitAssignment() {
    if (_formKey.currentState!.validate() && _selectedDeadline != null) {
      final newAssignment = Assignment(
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        questions: _questions,
        deadline: _selectedDeadline!,
        postedTime: _scheduledTime ?? DateTime.now(),
        visible: _isVisible,
      );
      widget.onSubmit(newAssignment);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please fill all fields and select a deadline.')),
      );
    }
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDeadline = DateTime(
              picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Assignment', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AssignmentColors.primaryDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleInput(),
                SizedBox(height: 20),
                _buildDescriptionInput(),
                SizedBox(height: 20),
                _buildQuestionInput(),
                SizedBox(height: 20),
                _buildVisibilityToggle(),
                SizedBox(height: 20),
                _buildDeadlineButton(context),
                SizedBox(height: 20),
                _buildSubmitButton(),
                SizedBox(height: 20),
                if (_questions.isNotEmpty) _buildQuestionsList(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuestion,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple.shade300,
        tooltip: 'Add Question',
      ),
    );
  }

  Widget _buildTitleInput() {
    return TextFormField(
      controller: _titleController,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: 'Assignment Title',
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: AssignmentColors.primaryDark, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: _descriptionController,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      decoration: InputDecoration(
        labelText: 'Enter Description (Optional)',
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: AssignmentColors.primaryDark, width: 2),
        ),
      ),
    );
  }

  Widget _buildQuestionInput() {
    return TextFormField(
      controller: _questionController,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      decoration: InputDecoration(
        labelText: 'Enter Question',
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: AssignmentColors.primaryDark, width: 2),
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return SwitchListTile(
      title: Text('Visible', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      value: _isVisible,
      onChanged: (bool value) {
        setState(() {
          _isVisible = value;
        });
      },
      activeColor: AssignmentColors.primaryDark,
    );
  }

  Widget _buildDeadlineButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _selectDeadline(context),
      icon: Icon(Icons.calendar_today, color: AssignmentColors.primaryDark),
      label: Text(
        _selectedDeadline == null
            ? 'Select Deadline'
            : DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDeadline!),
        style: TextStyle(color: AssignmentColors.primaryDark),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AssignmentColors.primaryDark, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitAssignment,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text('Add Assignment', style: TextStyle(fontSize: 18)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AssignmentColors.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
        padding: EdgeInsets.symmetric(vertical: 15.0),
      ),
    );
  }

  Widget _buildQuestionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Added Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        SizedBox(height: 10),
        ListView.builder(
          itemCount: _questions.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AssignmentColors.primaryDark,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(_questions[index]),
              ),
            );
          },
        ),
      ],
    );
  }
}
