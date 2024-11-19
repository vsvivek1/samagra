import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/configProviderSingleton.dart';
//import 'package:samagra/config_provider.dart';
import 'package:samagra/providers/config_provider.dart';

class SubordinatesCoursesScreen extends StatefulWidget {
  @override
  _SubordinatesCoursesScreenState createState() =>
      _SubordinatesCoursesScreenState();
}

class _SubordinatesCoursesScreenState extends State<SubordinatesCoursesScreen> {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: '${ConfigProviderSingleton.instance.liveAccessUrl}api/.trainings/',
    headers: {
      'Authorization': 'Bearer your_access_token',
      'Accept': 'application/json',
    },
  ));

  List<Map<String, dynamic>> subordinates = [];
  Map<String, dynamic> subordinateDetails = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubordinates();
  }

  Future<void> fetchSubordinates() async {
    try {
      final response = await _dio.get('subordinates');
      setState(() {
        subordinates =
            List<Map<String, dynamic>>.from(response.data['subordinates']);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        subordinates = _getDummySubordinates(); // Fallback dummy data
      });
      print("Error fetching subordinates: $e");
    }
  }

  Future<void> fetchSubordinateDetails(String employeeCode) async {
    try {
      final response =
          await _dio.get('subordinates/$employeeCode/courses'); // Fetch details
      setState(() {
        subordinateDetails = response.data;
      });
    } catch (e) {
      print("Error fetching subordinate details: $e");
      subordinateDetails = {
        'courses': [
          {
            'title': 'Electrical Safety Training',
            'status': 'Completed',
            'pdus_earned': 5,
            'marks_awarded': 90,
            'medals_awarded': 'Gold',
          },
          {
            'title': 'Advanced Circuit Design',
            'status': 'In Progress',
            'pdus_earned': 2,
            'marks_awarded': null,
            'medals_awarded': 'None',
          },
        ],
      }; // Fallback dummy data
    }
  }

  List<Map<String, dynamic>> _getDummySubordinates() {
    return [
      {'name': 'John Doe', 'employee_code': 'EMP001'},
      {'name': 'Jane Smith', 'employee_code': 'EMP002'},
      {'name': 'Michael Johnson', 'employee_code': 'EMP003'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subordinates' Courses"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: subordinates.length,
              itemBuilder: (context, index) {
                final subordinate = subordinates[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text(subordinate['name']),
                    subtitle:
                        Text("Employee Code: ${subordinate['employee_code']}"),
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await fetchSubordinateDetails(
                              subordinate['employee_code']);
                          _showSubordinateDetails(context, subordinate['name']);
                        },
                        child: Text("View Details"),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showSubordinateDetails(BuildContext context, String subordinateName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$subordinateName's Courses"),
          content: subordinateDetails.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: subordinateDetails['courses']
                      .map<Widget>((course) => ListTile(
                            title: Text(course['title']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Status: ${course['status']}"),
                                Text(
                                    "PDUs Earned: ${course['pdus_earned'] ?? 0}"),
                                Text(
                                    "Marks: ${course['marks_awarded'] ?? 'N/A'}"),
                                Text(
                                    "Medals: ${course['medals_awarded'] ?? 'None'}"),
                              ],
                            ),
                          ))
                      .toList(),
                )
              : Text("No course details available."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
