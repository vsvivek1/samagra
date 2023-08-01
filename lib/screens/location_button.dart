import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:audioplayers/audioplayers.dart';

class LocationButton extends StatefulWidget {
  final Function(double, double, String) onLocationSelected;

  final bool editMode;

  const LocationButton(
      {Key? key, required this.onLocationSelected, required this.editMode})
      : super(key: key);

  @override
  _LocationButtonState createState() => _LocationButtonState();
}

class _LocationButtonState extends State<LocationButton> {
  Position? _currentPosition;
  bool _loading = false;
  late AudioCache audioCache;
  bool enableLocationButton = false;

  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    audioCache = AudioCache(prefix: 'assets/audio/');
    super.initState();
    checkAndRequestLocationPermission();
    enableLocationButton = true;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Row(children: [
          Visibility(
            visible: enableLocationButton,
            child: _loading
                ? Center(child: CircularProgressIndicator.adaptive())
                : ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        _loading = true;
                      });
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

                      List<Placemark> placemarks1;
                      try {
                        placemarks1 = await placemarkFromCoordinates(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        );
                      } on Exception catch (e) {
                        // TODO
                        placemarks1 = [];
                      }
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

                        enableLocationButton = false;

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
            visible: !enableLocationButton,
            child: ElevatedButton(
              child: Text('Edit'),
              onPressed: () {
                enableLocationButton = true;
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
