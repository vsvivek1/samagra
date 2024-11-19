import 'package:flutter/material.dart';

class CourseAttendancePreviewScreen extends StatelessWidget {
  final String courseTitle;
  final String attendanceUrl;

  const CourseAttendancePreviewScreen({
    required this.courseTitle,
    required this.attendanceUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance - $courseTitle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Signed by: Head of Training Center",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Downloading Attendance...")),
                );
              },
              child: Text("Download Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}
