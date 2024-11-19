import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class InterestApprovalScreen extends StatefulWidget {
  @override
  _InterestApprovalScreenState createState() => _InterestApprovalScreenState();
}

class _InterestApprovalScreenState extends State<InterestApprovalScreen> {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://your-api-url.com/api',
    headers: {
      'Authorization': 'Bearer your_access_token',
      'Accept': 'application/json',
    },
  ));

  List<Map<String, dynamic>> pendingRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    try {
      final response = await _dio.get('/course-requests/office-head');
      setState(() {
        pendingRequests =
            List<Map<String, dynamic>>.from(response.data['requests']);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching pending requests: $e");
    }
  }

  Future<void> approveOrRejectRequest(
      int requestId, String status, String? comment) async {
    try {
      await _dio.put('/course-requests/$requestId/approve/office-head', data: {
        'status': status,
        'comment': comment ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request $status successfully")),
      );

      fetchPendingRequests(); // Refresh list
    } catch (e) {
      print("Error updating request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to $status the request.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Interest Approval"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final request = pendingRequests[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(request['course_title']),
                    subtitle: Text("Requested by: ${request['user_name']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            approveOrRejectRequest(
                                request['id'], 'approved', null);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            approveOrRejectRequest(
                                request['id'], 'rejected', null);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
