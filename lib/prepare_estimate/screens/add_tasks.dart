import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: MainScreen()));
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final List<String> tasks = [
              'Task 1',
              'Task 2',
              'Task 3',
              'Task 4',
              'Task 5',
            ];

            // Navigate to TaskSelectionScreen and get the selected tasks
            final selectedTasks = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskSelectionScreen(tasks: tasks),
              ),
            );

            if (selectedTasks != null && selectedTasks.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected Tasks: ${selectedTasks.join(", ")}'),
                ),
              );
            }
          },
          child: const Text('Select Tasks'),
        ),
      ),
    );
  }
}
