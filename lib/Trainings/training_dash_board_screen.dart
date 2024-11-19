import 'package:flutter/material.dart';
import 'package:samagra/Trainings/express_intrest_screen.dart';
import 'available_course_screen.dart';
import 'courses_i_attended.dart';
import 'intrest_approval.dart';
import 'publish_course_screen.dart';
import 'publish_final_list_screen.dart';
import 'subordinate_courses_screen.dart';

class TrainingDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/training.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Notifications list
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      NotificationTile(
                        title: "New Training Available: Leadership 101",
                        subtitle: "Starts: 2023-12-01",
                        courseId: 1,
                        onExpressInterest: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExpressInterestScreen(
                                courseId: 1,
                                courseTitle: "Leadership 101",
                                startDate: "2023-12-01",
                              ),
                            ),
                          );
                        },
                      ),
                      NotificationTile(
                        title: "Advanced Data Analytics",
                        subtitle: "Starts: 2023-11-20",
                        courseId: 2,
                        onExpressInterest: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExpressInterestScreen(
                                courseId: 2,
                                courseTitle: "Advanced Data Analytics",
                                startDate: "2023-11-20",
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
          ),
          // Semi-Circular Menu Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Menu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SemiCircularMenuButton(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => MenuOptions(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int courseId;
  final VoidCallback onExpressInterest;

  const NotificationTile({
    required this.title,
    required this.subtitle,
    required this.courseId,
    required this.onExpressInterest,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onExpressInterest,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          leading: Icon(Icons.notifications, color: Colors.blue),
          trailing: IconButton(
            icon: Icon(Icons.info, color: Colors.blue),
            onPressed: onExpressInterest,
          ),
        ),
      ),
    );
  }
}

class SemiCircularMenuButton extends StatelessWidget {
  final VoidCallback onTap;

  const SemiCircularMenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        width: 180,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(90),
            topRight: Radius.circular(90),
          ),
        ),
        child: Center(
          child: Icon(Icons.menu, color: Colors.white, size: 40),
        ),
      ),
    );
  }
}

class MenuOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            "Training Options",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text("Trainings I Attended"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CoursesAttendedScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.book_online),
            title: Text("Available Trainings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AvailableCoursesScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text("Courses My Colleagues Attended"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubordinatesCoursesScreen(),
                ),
              );
            },
          ),
          Divider(),
          Text(
            "Administration",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: Icon(Icons.approval),
            title: Text("Interest Approval"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InterestApprovalScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.publish),
            title: Text("Publish Training"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PublishCourseScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text("Publish Final List"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PublishFinalListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
