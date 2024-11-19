import 'package:flutter/material.dart';
import 'apply_course_screen.dart';

class AvailableCoursesScreen extends StatefulWidget {
  @override
  _AvailableCoursesScreenState createState() => _AvailableCoursesScreenState();
}

class _AvailableCoursesScreenState extends State<AvailableCoursesScreen> {
  List<Map<String, dynamic>> availableCourses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableCourses();
  }

  Future<void> fetchAvailableCourses() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate API delay
    setState(() {
      availableCourses = [
        {
          'id': 1,
          'title': 'Advanced Electrical Systems',
          'start_date': '2023-12-01',
          'end_date': '2023-12-05',
          'last_date': '2023-11-25',
          'seat_availability': 30,
          'pdus': 5,
          'training_center': 'PETARC, Moolamattom',
        },
        {
          'id': 2,
          'title': 'Safety in Electrical Installations',
          'start_date': '2023-11-20',
          'end_date': '2023-11-22',
          'last_date': '2023-11-15',
          'seat_availability': 20,
          'pdus': 3,
          'training_center': 'KSEB Training Centre, Kozhikode',
        },
        {
          'id': 3,
          'title': 'Energy Management and Audit',
          'start_date': '2024-01-10',
          'end_date': '2024-01-15',
          'last_date': '2024-01-05',
          'seat_availability': 25,
          'pdus': 6,
          'training_center': 'PETARC, Moolamattom',
        },
      ];
      isLoading = false;
    });
  }

  int calculateDays(String startDate, String endDate) {
    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);
    return end.difference(start).inDays + 1; // Include start day
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Courses"),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/available_courses.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Course List
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: availableCourses.length,
                  itemBuilder: (context, index) {
                    final course = availableCourses[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['training_center'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              course['title'],
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Start Date: ${course['start_date']}"),
                            Text("End Date: ${course['end_date']}"),
                            Text(
                                "Days of Training: ${calculateDays(course['start_date'], course['end_date'])}"),
                            Text("Last Date to Apply: ${course['last_date']}"),
                            Text(
                                "Seats Available: ${course['seat_availability']}"),
                            if (course['pdus'] != null)
                              Text("PDUs: ${course['pdus']}"),

                            //RITU_connect*1103
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ApplyCourseScreen(
                                  courseId: course['id'],
                                  courseTitle: course['title'],
                                  trainingCenter: course['training_center'],
                                ),
                              ),
                            );
                          },
                          child: Text("Apply"),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
