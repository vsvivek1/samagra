import 'package:flutter/material.dart';
import 'package:samagra/prepare_estimate/models/work_details.dart';

class ReviewDetailsPage extends StatelessWidget {
  final WorkDetails workDetails;

  ReviewDetailsPage({Key? key, required this.workDetails}) : super(key: key);

  List<Map<String, dynamic>> _getLocations() {
    // Generate dummy data if no locations exist
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

    // Convert `LocationDetails` to a list of maps for display
    return workDetails.locations.map((location) {
      return {
        "locationNo": location.locationNumber,
        "lat": location.geoCoordinates?["latitude"] ?? "N/A",
        "long": location.geoCoordinates?["longitude"] ?? "N/A",
        "remarks": location.name ?? "No remarks",
        "existingPoleNumber":
            location.tasks.isNotEmpty ? location.tasks[0].name ?? "N/A" : "N/A",
        "tasks": location.tasks.map((task) => task.name).toList(),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final locations = _getLocations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context, workDetails); // Return data to previous screen
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a location form page to add a new location
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Add Location functionality coming soon!')),
          );
        },
        tooltip: 'Add Location',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scheme: ${workDetails.scheme ?? "Not selected"}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'SubGroup: ${workDetails.subGroup ?? "Not selected"}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Priority: ${workDetails.priority ?? "Not selected"}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Work Name: ${workDetails.workName ?? "Not provided"}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Work Remarks: ${workDetails.workRemarks ?? "Not provided"}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20), // Horizontal Partition
              const Text(
                'Locations:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              locations.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        final location = locations[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                                'Location ${location['locationNo'] ?? "N/A"}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Lat: ${location['lat']}'),
                                Text('Long: ${location['long']}'),
                                Text('Remarks: ${location['remarks']}'),
                                Text(
                                    'Pole No: ${location['existingPoleNumber']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Logic to edit location
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Edit Location ${location['locationNo']}')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    // Logic to delete location
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Delete Location ${location['locationNo']}')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Text(
                      'No locations added yet.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
