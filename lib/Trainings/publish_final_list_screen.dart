import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class PublishFinalListScreen extends StatefulWidget {
  @override
  _PublishFinalListScreenState createState() => _PublishFinalListScreenState();
}

class _PublishFinalListScreenState extends State<PublishFinalListScreen> {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://your-api-url.com/api',
    headers: {
      'Authorization': 'Bearer your_access_token',
      'Accept': 'application/json',
    },
  ));

  List<Map<String, dynamic>> courseRequests = [];
  bool isLoading = true;
  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    fetchCourseRequests();
  }

  Future<void> fetchCourseRequests() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _dio.get('/course-requests');
      setState(() {
        courseRequests =
            List<Map<String, dynamic>>.from(response.data['requests']);
        isExpandedList = List<bool>.filled(courseRequests.length, false);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching course requests: $e");

      // Use dummy data on failure
      setState(() {
        courseRequests = _getDummyCourseRequests();
        isExpandedList = List<bool>.filled(courseRequests.length, false);
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getDummyCourseRequests() {
    return [
      {
        'id': 1,
        'title': 'Advanced Electrical Systems',
        'participant_count': 25,
        'details':
            'Duration: 5 days\nStart Date: 2023-12-01\nEnd Date: 2023-12-05',
      },
      {
        'id': 2,
        'title': 'Safety in Electrical Installations',
        'participant_count': 20,
        'details':
            'Duration: 3 days\nStart Date: 2023-11-20\nEnd Date: 2023-11-22',
      },
      {
        'id': 3,
        'title': 'Energy Management and Audit',
        'participant_count': 30,
        'details':
            'Duration: 6 days\nStart Date: 2024-01-10\nEnd Date: 2024-01-15',
      },
    ];
  }

  Future<void> publishList(int courseId) async {
    try {
      await _dio.put('/courses/$courseId/finalize');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Final list published successfully!")),
      );
    } catch (e) {
      print("Error publishing final list: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to publish final list.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Publish Final List"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ExpansionPanelList(
                expansionCallback: (index, isExpanded) {
                  setState(() {
                    isExpandedList[index] = !isExpanded;
                  });
                },
                children: courseRequests.map<ExpansionPanel>((course) {
                  final index = courseRequests.indexOf(course);
                  return ExpansionPanel(
                    isExpanded: isExpandedList[index],
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text(course['title']),
                        subtitle: Text(
                            "Participants: ${course['participant_count']}"),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['details'],
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              publishList(course['id']);
                            },
                            child: Text("Publish Final List"),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
