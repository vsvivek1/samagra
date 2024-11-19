import 'package:flutter/material.dart';

class ExpressInterestScreen extends StatelessWidget {
  final int courseId;
  final String courseTitle;
  final String startDate;

  const ExpressInterestScreen({
    required this.courseId,
    required this.courseTitle,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Express Interest"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Course Details",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text("Course Title: $courseTitle", style: TextStyle(fontSize: 18)),
            Text("Start Date: $startDate", style: TextStyle(fontSize: 18)),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // API call or functionality to express interest
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Expressed interest in $courseTitle!"),
                    ),
                  );
                  Navigator.pop(context); // Return to the previous screen
                },
                child: Text("Express Interest"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
