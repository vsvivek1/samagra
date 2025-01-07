import 'package:flutter/material.dart';

class MainTaskMasterWidget extends StatefulWidget {
  final List<dynamic> taskList;
  final ValueChanged<List<String>> onTasksSelected;
  final List<String> selectedTaskIds;

  const MainTaskMasterWidget({
    Key? key,
    required this.taskList,
    required this.onTasksSelected,
    required this.selectedTaskIds,
  }) : super(key: key);

  @override
  MainTaskMasterWidgetState createState() => MainTaskMasterWidgetState();
}

class MainTaskMasterWidgetState extends State<MainTaskMasterWidget> {
  late List<String> selectedTaskIds;

  @override
  void initState() {
    super.initState();
    selectedTaskIds = List.from(widget.selectedTaskIds);
  }


void refreshState(){

  print('refresh state');

  setState(() {
    
  });
}
  void _toggleSelection(String taskId) {
    setState(() {
      if (selectedTaskIds.contains(taskId)) {
        selectedTaskIds.remove(taskId);
      } else {
        selectedTaskIds.add(taskId);
      }
      // Emit the updated list of selected task IDs
      widget.onTasksSelected(List.from(selectedTaskIds));
    });
  }

  void _showMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Select Tasks'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  children: widget.taskList.map((task) {
                    final taskId = task['id'].toString();
                    final isSelected = selectedTaskIds.contains(taskId);

                    return CheckboxListTile(
                      title: Text(task['main_task_name']),
                      value: isSelected,
                      onChanged: (_) {
                        setStateDialog(() {
                          _toggleSelection(taskId);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Tasks:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _showMultiSelectDialog,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedTaskIds.isEmpty
                      ? 'Select Tasks'
                      : '${selectedTaskIds.length} tasks selected',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
