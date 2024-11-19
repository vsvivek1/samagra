import 'package:flutter/material.dart';

class ApplicationStatusScreen extends StatelessWidget {
  final List<Map<String, dynamic>> applicationStatuses = [
    {
      'training_name': 'Advanced Electrical Systems',
      'statuses': [
        {
          'role': 'Controlling Officer',
          'status': 'Approved',
          'comment': 'Recommended for further processing.',
        },
        {
          'role': 'ARU Head',
          'status': 'Pending',
          'comment': 'Awaiting review.',
        },
        {
          'role': 'Training Center Head',
          'status': 'Pending',
          'comment': 'Not yet reviewed.',
        },
      ],
    },
    {
      'training_name': 'Safety in Electrical Installations',
      'statuses': [
        {
          'role': 'Controlling Officer',
          'status': 'Approved',
          'comment': 'Good to proceed.',
        },
        {
          'role': 'ARU Head',
          'status': 'Approved',
          'comment': 'Reviewed and approved.',
        },
        {
          'role': 'Training Center Head',
          'status': 'Pending',
          'comment': 'Pending final review.',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Application Status"),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/status_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Status List
          SafeArea(
            child: ListView.builder(
              itemCount: applicationStatuses.length,
              itemBuilder: (context, index) {
                final application = applicationStatuses[index];
                return Card(
                  margin: EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application['training_name'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        ...application['statuses'].map<Widget>((status) {
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    status['status'] == 'Approved'
                                        ? Icons.check_circle
                                        : status['status'] == 'Pending'
                                            ? Icons.hourglass_empty
                                            : Icons.cancel,
                                    color: status['status'] == 'Approved'
                                        ? Colors.green
                                        : status['status'] == 'Pending'
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          status['role'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text("Status: ${status['status']}"),
                                        Text("Comment: ${status['comment']}"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (status != application['statuses'].last)
                                Divider(), // Divider between statuses
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
