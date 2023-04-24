import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class LocationButton extends StatefulWidget {
  final Function(double, double) onLocationSelected;

  const LocationButton({Key? key, required this.onLocationSelected})
      : super(key: key);

  @override
  _LocationButtonState createState() => _LocationButtonState();
}

class _LocationButtonState extends State<LocationButton> {
  Position? _currentPosition;
  bool _loading = false;

  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    checkAndRequestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return ElevatedButton.icon(
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

            List<Placemark> placemarks = await placemarkFromCoordinates(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            );
            Placemark placemark = placemarks[0];

            print(placemark);

            print('placemark above');

            setState(() {
              _loading = false;
            });
            widget.onLocationSelected(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            );
          },
          icon:
              _loading ? Icon(Icons.label_important) : Icon(Icons.location_on),
          label: Text('Get Location'),
        );
      },
    );
  }

  // Check and request location permission
  Future<void> checkAndRequestLocationPermission() async {
    _permissionStatus = await Permission.location.status;

    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await Permission.location.request();

      if (_permissionStatus != PermissionStatus.granted) {
        throw Exception('Location permission denied.');
      }
    }
  }
}