import 'package:flutter/material.dart';

class CourseCertificatePreviewScreen extends StatelessWidget {
  final String courseTitle;
  final String grade;
  final String certificateUrl;

  const CourseCertificatePreviewScreen({
    required this.courseTitle,
    required this.grade,
    required this.certificateUrl,
  });

  @override
  Widget build(BuildContext context) {
    Color gradeColor = grade == 'A'
        ? Colors.amber
        : grade == 'B'
            ? Colors.grey
            : Colors.brown;

    return Scaffold(
      appBar: AppBar(
        title: Text("Certificate - $courseTitle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Grade: $grade",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: gradeColor,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Downloading Certificate...")),
                );
              },
              child: Text("Download Certificate"),
            ),
          ],
        ),
      ),
    );
  }
}
