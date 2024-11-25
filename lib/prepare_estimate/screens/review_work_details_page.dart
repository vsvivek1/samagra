import 'package:flutter/material.dart';
import 'package:samagra/prepare_estimate/models/work_details.dart';

class ReviewDetailsPage extends StatelessWidget {
  final WorkDetails workDetails;

  const ReviewDetailsPage({Key? key, required this.workDetails})
      : super(key: key);

  List<Map<String, dynamic>> _getLocations() {
    // Check if locations are empty and populate dummy data if needed
    if (workDetails.locations.isEmpty) {
      return [
        {
          "locationNo": 1,
          "lat": 12.971598,
          "long": 77.594566,
          "remarks": "Dummy location 1 - Near market area",
          "existingPoleNumber": "PO123",
          "tasks": []
        },
        {
          "locationNo": 2,
          "lat": 13.082680,
          "long": 80.270718,
          "remarks": "Dummy location 2 - Main road junction",
          "existingPoleNumber": "PO456",
          "tasks": []
        },
      ];
    }
    return workDetails.locations;
  }

  @override
  Widget build(BuildContext context) {
    final locations = _getLocations();

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context,
                workDetails); // Return data back to the previous screen
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic to add a new location
          // Navigate to a location form page or add directly in a modal
        },
        tooltip: 'Add Location',
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scheme: ${workDetails.scheme ?? "Not selected"}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'SubGroup: ${workDetails.subGroup ?? "Not selected"}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Priority: ${workDetails.priority ?? "Not selected"}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Work Name: ${workDetails.workName ?? "Not provided"}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Work Remarks: ${workDetails.workRemarks ?? "Not provided"}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Divider(height: 20), // Horizontal Partition
              Text(
                'Locations:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              locations.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        final location = locations[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                                'Location ${location['locationNo'] ?? "N/A"}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Lat: ${location['lat'] ?? "N/A"}'),
                                Text('Long: ${location['long'] ?? "N/A"}'),
                                Text(
                                    'Remarks: ${location['remarks'] ?? "N/A"}'),
                                Text(
                                    'Pole No: ${location['existingPoleNumber'] ?? "N/A"}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    // Logic to edit location
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    // Logic to delete location
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Text(
                      'No locations added yet.'), // Shouldn't reach here due to dummy data
            ],
          ),
        ),
      ),
    );
  }
}
