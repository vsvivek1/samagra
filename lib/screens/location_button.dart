import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:audioplayers/audioplayers.dart';

class LocationButton extends StatefulWidget {
  final Function(double, double, String) onLocationSelected;

  const LocationButton({Key? key, required this.onLocationSelected})
      : super(key: key);

  @override
  _LocationButtonState createState() => _LocationButtonState();
}

class _LocationButtonState extends State<LocationButton> {
  Position? _currentPosition;
  bool _loading = false;
  late AudioCache audioCache;
  bool enableLocatiopnButton = false;

  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    audioCache = AudioCache(prefix: 'assets/audio/');
    super.initState();
    checkAndRequestLocationPermission();
    enableLocatiopnButton = true;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Row(children: [
          Visibility(
            visible: enableLocatiopnButton,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (_permissionStatus != PermissionStatus.granted) {
                  setState(() {
                    _loading = true;
                  });

                  // Show a dialog to inform the user that location permission is required
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Location Permission Required'),
                        content: Text(
                            'Please grant location permission to use this feature.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              setState(() {
                                _loading = false;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                _currentPosition = await Geolocator.getCurrentPosition();

                List<Placemark> placemarks1 = await placemarkFromCoordinates(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                );
                // Placemark placemark = placemarks[0];

                List<Placemark> placemarks =
                    placemarks1; // list of Placemark objects

                List<Map<String, dynamic>> placemarkArray =
                    placemarks.map((placemark) {
                  return {
                    'name': placemark.name,
                    'thoroughfare': placemark.thoroughfare,
                    // add more properties as needed
                  };
                }).toList();

                // print(placemarks.runtimeType);

                print(placemarks[0]);

                print('placemark above');

                String? name = placemarks[0].name ?? '';

                setState(() {
                  _loading = false;

                  audioCache.play('press_save_location_button.wav');

                  enableLocatiopnButton = false;

                  //  this.userDirections =
                  // 'Now Select any Location to Starting with  L, Ensure correct location ';
                });

                widget.onLocationSelected(_currentPosition!.latitude,
                    _currentPosition!.longitude, name);
              },
              icon: _loading
                  ? Icon(Icons.label_important)
                  : Icon(Icons.location_on),
              label: Text('Get Location'),
            ),
          ),
          Visibility(
            visible: !enableLocatiopnButton,
            child: ElevatedButton(
              child: Text('Edit'),
              onPressed: () {
                enableLocatiopnButton = true;
              },
            ),
          )
        ]);
      },
    );
  }

  // Check and request location permission
  Future<void> checkAndRequestLocationPermission() async {
    _permissionStatus = await Permission.location.status;
    if (_permissionStatus != PermissionStatus.granted) {
      audioCache.play('provide_permision.wav');
    }

    if (_permissionStatus == PermissionStatus.granted) {
      audioCache.play('press_get_location.wav');
    }

    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await Permission.location.request();

      if (_permissionStatus != PermissionStatus.granted) {
        throw Exception('Location permission denied.');
      }
    }
  }
}
