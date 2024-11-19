import 'package:flutter/material.dart';

class CourseTABillPreviewScreen extends StatelessWidget {
  final String courseTitle;
  final String taBillUrl;

  const CourseTABillPreviewScreen({
    required this.courseTitle,
    required this.taBillUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TA Bill & Progress - $courseTitle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Course: $courseTitle",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Here you can view or download the TA Bill and Progress Card for this course.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            taBillUrl != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Previewing TA Bill...")),
                          );
                        },
                        child: Text("Preview TA Bill"),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Generating PDF...")),
                          );
                        },
                        child: Text("Generate PDF"),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Downloading TA Bill...")),
                          );
                        },
                        child: Text("Download TA Bill"),
                      ),
                    ],
                  )
                : Text(
                    "No TA Bill or Progress Card available.",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }
}
