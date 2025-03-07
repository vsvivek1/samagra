import 'package:flutter/material.dart';

class TaskMultiSelect extends StatefulWidget {
  final List<Map<String, dynamic>> tasks; // List of tasks
  final Function(List<Map<String, dynamic>>) onSelectionChanged; // Callback function

  const TaskMultiSelect({Key? key, required this.tasks, required this.onSelectionChanged}) : super(key: key);

  @override
  _TaskMultiSelectState createState() => _TaskMultiSelectState();
}

class _TaskMultiSelectState extends State<TaskMultiSelect> {
  List<Map<String, dynamic>> selectedTasks = [];

  void _onTaskSelected(bool? selected, Map<String, dynamic> task) {
    setState(() {
      if (selected == true) {
        selectedTasks.add(task);
      } else {
        selectedTasks.removeWhere((t) => t['id'] == task['id']);
      }
    });

    // Trigger callback with updated selection
    widget.onSelectionChanged(selectedTasks);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        final isSelected = selectedTasks.any((t) => t['id'] == task['id']);

        return CheckboxListTile(
          title: Text(task['task_name'] ?? 'Unknown Task'),
          value: isSelected,
          onChanged: (bool? selected) {
            _onTaskSelected(selected, task);
          },
        );
      },
    );
  }
}
