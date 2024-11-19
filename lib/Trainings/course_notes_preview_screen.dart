import 'package:flutter/material.dart';

class CourseNotesPreviewScreen extends StatelessWidget {
  final String courseTitle;
  final String notesUrl;

  const CourseNotesPreviewScreen({
    required this.courseTitle,
    required this.notesUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes - $courseTitle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Downloading Notes...")),
            );
          },
          child: Text("Download Notes"),
        ),
      ),
    );
  }
}
