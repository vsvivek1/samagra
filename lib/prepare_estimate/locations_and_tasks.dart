import 'package:flutter/material.dart';
import 'models/work_details.dart'; // Import WorkDetails model

class LocationAndTasksPage extends StatelessWidget {
  final WorkDetails workDetails;

  const LocationAndTasksPage({Key? key, required this.workDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location and Tasks'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context,
                workDetails); // Return data back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scheme: ${workDetails.scheme ?? "Not selected"}'),
            Text('SubGroup: ${workDetails.subGroup ?? "Not selected"}'),
            Text('Priority: ${workDetails.priority ?? "Not selected"}'),
            Text('Work Name: ${workDetails.workName ?? "Not provided"}'),
            Text('Work Remarks: ${workDetails.workRemarks ?? "Not provided"}'),
            // Display additional details if necessary
          ],
        ),
      ),
    );
  }
}
