import 'package:flutter/material.dart';

import 'course_attendance_preview_screen.dart';
import 'course_certificate_preview_screen.dart';
import 'course_notes_preview_screen.dart';
import 'course_ta_bill_preview_screen.dart';
import 'course_review_screen.dart';

class CoursesAttendedScreen extends StatefulWidget {
  @override
  _CoursesAttendedScreenState createState() => _CoursesAttendedScreenState();
}

class _CoursesAttendedScreenState extends State<CoursesAttendedScreen> {
  List<Map<String, dynamic>> attendedCourses = [];

  @override
  void initState() {
    super.initState();
    fetchAttendedCourses();
  }

  Future<void> fetchAttendedCourses() async {
    // Simulated dummy data
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      attendedCourses = [
        {
          'id': 1,
          'title': 'Advanced Electrical Systems',
          'status': 'Completed',
          'pdus_earned': 5,
          'marks_awarded': 95,
          'grade': 'A',
          'certificate_url': 'https://example.com/certificate1.pdf',
          'attendance_url': 'https://example.com/attendance1.pdf',
          'ta_bill_url': 'https://example.com/ta1.pdf',
          'notes_url': 'https://example.com/notes1.pdf',
        },
        {
          'id': 2,
          'title': 'Safety in Electrical Installations',
          'status': 'Completed',
          'pdus_earned': 3,
          'marks_awarded': 85,
          'grade': 'B',
          'certificate_url': 'https://example.com/certificate2.pdf',
          'attendance_url': 'https://example.com/attendance2.pdf',
          'ta_bill_url': 'https://example.com/ta2.pdf',
          'notes_url': 'https://example.com/notes2.pdf',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Courses I Attended"),
      ),
      body: attendedCourses.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/courses_attended.webp'),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView.builder(
                itemCount: attendedCourses.length,
                itemBuilder: (context, index) {
                  final course = attendedCourses[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: Text(
                        course['title'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Status: ${course['status']}"),
                          Text("PDUs Earned: ${course['pdus_earned']}"),
                          Text("Marks: ${course['marks_awarded']}"),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.count(
                            crossAxisCount: 2, // Two buttons per row
                            shrinkWrap: true,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            children: [
                              _buildGradientButton(
                                context: context,
                                text: "Certificate",
                                colors: [Colors.blue, Colors.lightBlueAccent],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CourseCertificatePreviewScreen(
                                        courseTitle: course['title'],
                                        grade: course['grade'],
                                        certificateUrl:
                                            course['certificate_url'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildGradientButton(
                                context: context,
                                text: "Attendance",
                                colors: [Colors.green, Colors.lightGreenAccent],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CourseAttendancePreviewScreen(
                                        courseTitle: course['title'],
                                        attendanceUrl: course['attendance_url'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildGradientButton(
                                context: context,
                                text: "Notes & Materials",
                                colors: [
                                  Colors.orange,
                                  Colors.deepOrangeAccent
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CourseNotesPreviewScreen(
                                        courseTitle: course['title'],
                                        notesUrl: course['notes_url'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildGradientButton(
                                context: context,
                                text: "TA Bill & Progress",
                                colors: [
                                  Colors.purple,
                                  Colors.deepPurpleAccent
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CourseTABillPreviewScreen(
                                        courseTitle: course['title'],
                                        taBillUrl: course['ta_bill_url'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildGradientButton(
                                context: context,
                                text: "Review",
                                colors: [Colors.red, Colors.redAccent],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CourseReviewScreen(
                                        courseTitle: course['title'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String text,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50, // Explicit height control
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(12.0), // Rounded edges
        ),
        padding:
            EdgeInsets.symmetric(horizontal: 16), // Reduced vertical padding
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14, // Adjust text size to match reduced height
            ),
          ),
        ),
      ),
    );
  }
}
