import 'package:flutter/material.dart';
import 'package:samagra/prepare_estimate/models/work_details.dart';

class ReviewDetailsPage extends StatefulWidget {
  final WorkDetails workDetails;

  ReviewDetailsPage({Key? key, required this.workDetails}) : super(key: key);

  @override
  _ReviewDetailsPageState createState() => _ReviewDetailsPageState();
}

class _ReviewDetailsPageState extends State<ReviewDetailsPage> {
  void _addLocation() async {
    // Navigate to a location form page (Replace with your actual location form screen)
    final newLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateLocationPage(), // Replace with actual screen
      ),
    );

    if (newLocation != null) {
      setState(() {
        widget.workDetails.locations.add(newLocation);
      });
    }
  }

  void _editLocation(int index) async {
    final editedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateLocationPage(
          location: widget.workDetails.locations[index],
        ), // Replace with actual screen
      ),
    );

    if (editedLocation != null) {
      setState(() {
        widget.workDetails.locations[index] = editedLocation;
      });
    }
  }

  void _deleteLocation(int index) {
    setState(() {
      widget.workDetails.locations.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location ${index + 1} deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locations = widget.workDetails.locations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, widget.workDetails);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLocation,
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
                'Scheme: ${widget.workDetails.scheme ?? "Not selected"}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'SubGroup: ${widget.workDetails.subGroup ?? "Not selected"}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Priority: ${widget.workDetails.priority ?? "Not selected"}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Work Name: ${widget.workDetails.workName ?? "Not provided"}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Work Remarks: ${widget.workDetails.workRemarks ?? "Not provided"}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20),
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
                            title: Text('Location ${location.locationNumber}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Lat: ${location.geoCoordinates?["latitude"] ?? "N/A"}'),
                                Text(
                                    'Long: ${location.geoCoordinates?["longitude"] ?? "N/A"}'),
                                Text(
                                    'Remarks: ${location.name ?? "No remarks"}'),
                                Text(
                                  'Tasks: ${location.tasks.isNotEmpty ? location.tasks.length : "No tasks"}',
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editLocation(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteLocation(index),
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

class CreateLocationPage extends StatelessWidget {
  final dynamic location;

  const CreateLocationPage({Key? key, this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Your form for creating or editing a location goes here
    // For now, just return a dummy location object
    return Scaffold(
      appBar: AppBar(
        title: Text(location == null ? 'Add Location' : 'Edit Location'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              {
                "locationNumber": 1,
                "geoCoordinates": {
                  "latitude": 12.971598,
                  "longitude": 77.594566
                },
                "name": "New Location",
                "tasks": []
              },
            );
          },
          child: const Text('Save Location'),
        ),
      ),
    );
  }
}
