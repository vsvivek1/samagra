import 'package:flutter/material.dart';

class CourseReviewScreen extends StatelessWidget {
  final String courseTitle;

  const CourseReviewScreen({
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _reviewController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Review - $courseTitle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Write your review",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Review Submitted!")),
                );
                Navigator.pop(context);
              },
              child: Text("Submit Review"),
            ),
          ],
        ),
      ),
    );
  }
}
