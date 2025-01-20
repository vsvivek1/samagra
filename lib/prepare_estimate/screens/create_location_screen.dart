import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/prepare_estimate/capture_lat_long.dart';
import 'package:samagra/prepare_estimate/screens/add_tasks.dart';
import 'package:samagra/prepare_estimate/screens/capture_photos_widget.dart';

class CreateLocation extends StatefulWidget {
  final String uuId;

  const CreateLocation({Key? key, required this.uuId}) : super(key: key);

  @override
  _CreateLocationState createState() => _CreateLocationState();
}

class _CreateLocationState extends State<CreateLocation> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  List<dynamic> locationList = [];
  int selectedLocationNumber = 1;

  Map<String, double>? geoCoordinates;
  double? accuracy;
  List<dynamic> photos = [];
  bool isCapturingLatLong = false;

  @override
  void initState() {
    super.initState();
    _loadEstimateData();
  }

  /// Load data from secure storage
  Future<void> _loadEstimateData() async {
    String? storedData = await _secureStorage.read(key: widget.uuId);


    if (storedData != null) {
      setState(() {
        locationList = json.decode(storedData)["locationList"] ?? [];

        if (locationList.isNotEmpty) {
          _loadLocationDataByNumber(selectedLocationNumber);
        }
      });
    }
  }

  /// Load location by locationNumber
  void _loadLocationDataByNumber(int locationNumber) {
    final location = locationList.firstWhere(
      (loc) => loc["locationNumber"] == locationNumber,
      orElse: () => {},
    );

    if (location.isNotEmpty) {
      setState(() {
        selectedLocationNumber = locationNumber;
        geoCoordinates = Map<String, double>.from(location["geoCoordinates"] ?? {});
        accuracy = location["accuracy"];
        photos = location["photos"] ?? [];
      });
    }
  }

  /// Capture Latitude and Longitude
  void _getLatLong() async {
    setState(() {
      isCapturingLatLong = true;
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
        SnackBar(content: Text('Failed to capture Lat-Long: $e')),
      );
    } finally {
      setState(() {
        isCapturingLatLong = false;
      });
    }
  }

  /// Save the current location data
  Future<void> _saveLocationData() async {
    Map<String, dynamic> updatedLocation = {
      "locationNumber": selectedLocationNumber,
      "geoCoordinates": geoCoordinates ??
          {
            "latitude": 0,
            "longitude": 0,
          },
      "accuracy": accuracy,
      "photos": photos,
      "name": "Location $selectedLocationNumber",
      "tasks": [],
    };

    int existingIndex = locationList.indexWhere(
      (loc) => loc["locationNumber"] == selectedLocationNumber,
    );

    if (existingIndex != -1) {
      locationList[existingIndex] = updatedLocation;
    } else {
      locationList.add(updatedLocation);
    }

    await _secureStorage.write(
      key: widget.uuId,
      value: json.encode({"locationList": locationList}),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location saved!')),
    );

    setState(() {});
  }

  /// Navigate to capture photos
  void _navigateToCapturePhotos() async {
    final capturedPhotos = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CapturePhotosWidget(uuid: widget.uuId)),
    );

    if (capturedPhotos != null) {
      setState(() {
        photos.addAll(capturedPhotos);
      });
    }
  }

  /// Add a new location
  void _addNewLocation() {
    int newLocationNumber = (locationList.isNotEmpty
        ? (locationList.map((loc) => loc["locationNumber"]).reduce((a, b) => a > b ? a : b) + 1)
        : 1);

    setState(() {
      selectedLocationNumber = newLocationNumber;
      geoCoordinates = null;
      accuracy = null;
      photos = [];
    });
  }

  /// Handle back button navigation
  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddTasksWidget(uuId: widget.uuId),
      ),
    );
    return false; // Prevent default back action
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage Locations'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTasksWidget(uuId: widget.uuId),
                ),
              );
            },
          ),
        ),
        body: Column(
          children: [
            // Scrollable Horizontal Vertical Location List
           Expanded(
  flex: 1,
  child: Container(
    color: Colors.grey[200],
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        // Iterate through location list and create circular avatars
        for (int i = 0; i < locationList.length + 1; i++)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: i < locationList.length
                  ? () => _loadLocationDataByNumber(locationList[i]["locationNumber"])
                  : _addNewLocation,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: i < locationList.length ? Colors.blue : Colors.green,
                child: i < locationList.length
                    ? Text(
                        '${locationList[i]["locationNumber"]}',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
      ],
    ),
  ),
)
,

            // Main Form for Create/Edit Location
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location $selectedLocationNumber',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),

                    // Latitude and Longitude Section
                    ElevatedButton(
                      onPressed: _getLatLong,
                      child: Text((geoCoordinates == null) ? 'Capture Lat-Long':'Update Geo'),
                    ),
                    if (geoCoordinates != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latitude: ${geoCoordinates!["latitude"]}, Longitude: ${geoCoordinates!["longitude"]}',
                          ),
                          if (accuracy != null)
                            Text('Accuracy: ±${accuracy!.toStringAsFixed(2)} meters'),
                        ],
                      ),
                    Divider(color: Colors.blue, thickness: 2),

                    // Photos Section
                    ElevatedButton(
                      onPressed: _navigateToCapturePhotos,
                      child: const Text('Capture Photos'),
                    ),
                    if (photos.isNotEmpty)
                      Text('${photos.length} Photo(s) Captured'),
                    Divider(color: Colors.blue, thickness: 2),

                    // Placeholder for Tasks
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: Placeholder()),
                        ],
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: _saveLocationData,
                      child: const Text('Save Location'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
