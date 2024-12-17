import 'package:flutter/material.dart';
import 'package:samagra/prepare_estimate/capture_lat_long.dart';
import 'package:samagra/prepare_estimate/screens/add_tasks.dart';
import 'package:samagra/prepare_estimate/screens/capture_photos_widget.dart';

class CreateLocation extends StatefulWidget {
  final List<dynamic>? locationList; // Accept list of locations
  final dynamic location;

  const CreateLocation({Key? key, this.locationList, this.location, required List tasks})
      : super(key: key);

  @override
  _CreateLocationState createState() => _CreateLocationState();
}

class _CreateLocationState extends State<CreateLocation> {
  Map<String, double>? geoCoordinates;
  bool isCapturingLatLong = false; // Status of capturing Lat-Long
  double? accuracy; // Accuracy of the captured location

  void _getLatLong() async {
    setState(() {
      isCapturingLatLong = true; // Show capturing status
    });

    try {
      final coordinates = await captureLatLong(context);
      if (coordinates.isNotEmpty) {
        setState(() {
          geoCoordinates = coordinates;
          accuracy = coordinates["accuracy"];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture Lat-Long: $e'),
        ),
      );
    } finally {
      setState(() {
        isCapturingLatLong = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch current location number
    int locationNumber =
        (widget.locationList?.length ?? 0) + 1; // New location number

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location == null ? 'Create Location' : 'Edit Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Circular Avatar for Location Number
                CircleAvatar(
                  radius: 24,
                  child: Text(
                    '$locationNumber',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  widget.location == null
                      ? 'Create a New Location'
                      : 'Edit Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getLatLong,
              child: const Text('Capture Lat-Long'),
            ),
            if (isCapturingLatLong)
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Capturing Lat-Long...',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
            if (geoCoordinates != null) ...[
              SizedBox(height: 10),
              Text(
                'Latitude: ${geoCoordinates!["latitude"]}, Longitude: ${geoCoordinates!["longitude"]}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (accuracy != null)
                Text(
                  'Accuracy: ±${accuracy!.toStringAsFixed(2)} meters',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
            ],
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CapturePhotosWidget(),
                  ),
                );
              },
              child: const Text('Capture Photos'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.locationList?.length ?? 0,
                itemBuilder: (context, index) {
                  final loc = widget.locationList![index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text('Location ${index + 1}'),
                    subtitle: Text(
                        'Lat: ${loc['latitude']}, Long: ${loc['longitude']}'),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    "locationNumber": locationNumber,
                    "geoCoordinates": geoCoordinates ??
                        {
                          "latitude": 12.971598,
                          "longitude": 77.594566,
                        },
                    "name": "New Location",
                    "tasks": []
                  });
                },
                child: const Text('Save Location'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTasksWidget(categoryId: '1'),
            ),
          );
        },
        child: Icon(Icons.add_task),
        tooltip: 'Add New Task',
      ),
    );
  }
}
