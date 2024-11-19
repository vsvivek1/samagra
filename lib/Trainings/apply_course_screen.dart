import 'package:flutter/material.dart';

class ApplyCourseScreen extends StatelessWidget {
  final int courseId;
  final String courseTitle;
  final String trainingCenter;

  const ApplyCourseScreen({
    required this.courseId,
    required this.courseTitle,
    required this.trainingCenter,
  });

  Future<void> submitApplication(BuildContext context) async {
    // Simulate API response
    await Future.delayed(Duration(seconds: 2));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Application submitted for $courseTitle!")),
    );

    Navigator.pop(context); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm Application"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Confirm Your Application",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Course: $courseTitle",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "Training Center: $trainingCenter",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  submitApplication(context);
                },
                child: Text("Submit Application"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
