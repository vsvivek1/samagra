import 'package:flutter/material.dart';
import 'package:samagra/prepare_estimate/capture_lat_long.dart';
import 'package:samagra/prepare_estimate/screens/capture_photos_widget.dart';

class CreateLocation extends StatefulWidget {
  final dynamic location;

  const CreateLocation({Key? key, this.location}) : super(key: key);

  @override
  _CreateLocationState createState() => _CreateLocationState();
}

class _CreateLocationState extends State<CreateLocation> {
  Map<String, double>? geoCoordinates;

  void _getLatLong() async {
    final coordinates = await captureLatLong(context);
    if (coordinates.isNotEmpty) {
      setState(() {
        geoCoordinates = coordinates;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location == null ? 'Add Location' : 'Edit Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.location == null
                  ? 'Create a New Location'
                  : 'Edit Location',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getLatLong,
              child: const Text('Capture Lat-Long'),
            ),
            if (geoCoordinates != null) ...[
              const SizedBox(height: 10),
              Text(
                'Latitude: ${geoCoordinates!["latitude"]}, Longitude: ${geoCoordinates!["longitude"]}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CapturePhotosWidget(),
                    ));

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Photo Captured!'),
                  ),
                );
              },
              child: const Text('Capture Photos'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                /*    ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tasks Added!'),
                  ),
                ); */
              },
              child: const Text('Add Tasks'),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    {
                      "locationNumber": 1,
                      "geoCoordinates": geoCoordinates ??
                          {
                            "latitude": 12.971598,
                            "longitude": 77.594566,
                          },
                      "name": "New Location",
                      "tasks": []
                    },
                  );
                },
                child: const Text('Save Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
