import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationButton extends StatefulWidget {
  final Function(double, double) onLocationSelected;

  const LocationButton({Key? key, required this.onLocationSelected})
      : super(key: key);

  @override
  _LocationButtonState createState() => _LocationButtonState();
}

class _LocationButtonState extends State<LocationButton> {
  Position? _currentPosition;

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
            widget.onLocationSelected(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            );
          },
          icon: Icon(Icons.location_on),
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
