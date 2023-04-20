import 'package:flutter/material.dart';
import 'package:samagra/screens/location_button.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationDetailsWidget extends StatefulWidget {
  String locationNo;
  String? locationName;
  double? latitude;
  double? longitude;
  List<String>? measurements;
  Map<String, String> locationDetails;

  final Function updateLocationDetailsArray;

  TextEditingController locationNameController = new TextEditingController();

  LocationDetailsWidget({
    Key? key,
    required this.locationNo,
    this.measurements,
    required this.updateLocationDetailsArray,

    // ignore: non_constant_identifier_names
    required this.locationDetails,
  }) : super(key: key);

  @override
  _LocationDetailsWidgetState createState() => _LocationDetailsWidgetState();
}

class _LocationDetailsWidgetState extends State<LocationDetailsWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0.0, 1.0),
    end: const Offset(0.0, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ));

  bool editMode = false;

  late String locationName = '';
  late String latitude = '0';
  late String longitude = '0';
  @override
  void initState() {
    // widget.locationNameController.text = widget.locationName!;
    super.initState();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: (widget.locationNo == '-1')
          ? Card(
              color: Colors.redAccent[100],
              child: Text("Select a Location to View details"))
          : Card(
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (this.editMode) ...[
                      LocationButton(onLocationSelected: onLocationSelected),
                    ],
                    RichText(
                      text: TextSpan(
                        text: 'Location No ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: widget.locationNo,
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 24.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Text('Location No: ${widget.locationNo}',
                    //     style: TextStyle(
                    //       fontSize: 30,
                    //       backgroundColor: Color.fromARGB(255, 229, 231, 235),
                    //     )),
                    SizedBox(height: 8.0),
                    if (this.locationName != null) ...[
                      Text(
                        'Location Name: ${this.locationName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8.0),
                    ],
                    if (editMode) ...[
                      TextFormField(
                          onChanged: ((value) => updateLocationText(value)),
                          // controller: widget.locationNameController,
                          decoration: InputDecoration(
                            labelText: 'Enter Location Name',
                            hintText: 'Enter location name',
                          ))
                    ],
                    if (widget.latitude != null &&
                        widget.longitude != null) ...[
                      Text(
                        'Latitude: ${widget.latitude}, Longitude: ${widget.longitude}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16.0),
                    ],
                    if (widget.measurements != null &&
                        widget.measurements!.isNotEmpty) ...[
                      Text(
                        'Measurements:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var measurement in widget.measurements!)
                            Text(
                              '- $measurement',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          !editMode
                              ? IconButton(
                                  color: Colors.yellow,
                                  onPressed: () => _saveLocationDetails(),
                                  icon: Icon(Icons.edit))
                              : IconButton(
                                  onPressed: () => _saveLocationDetails(),
                                  icon: Icon(Icons.save))
                        ],
                      )
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Set<String> updateLocationText(String value) {
    setState(() {
      widget.locationDetails['locationName'] = value;
      this.locationName = value;

      print(value);
    });

    return {value};
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

// Check and request location permission
  Future<void> checkAndRequestLocationPermission() async {
    PermissionStatus permissionStatus = await Permission.location.status;

    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await Permission.location.request();

      if (permissionStatus != PermissionStatus.granted) {
        throw Exception('Location permission denied.');
      }
    }
  }

  onLocationSelected(double p1, double p2) {
    setState(() {
      widget.latitude = p1;
      widget.longitude = p2;

      widget.locationDetails['lattitude'] = p1.toString();
      widget.locationDetails['longitude'] = p2.toString();
    });

    // print('selected');
    // print(widget.latitude);
    // print(widget.longitude);
    //  print('abo');
  }

  void _saveLocationDetails() {
    setState(() {
      editMode = !editMode;

      widget.updateLocationDetailsArray(widget.locationDetails);

      // if (editMode) {
      //   // this.locationName = widget.locationNameController.text;
      // }

      print(widget.locationName);
    });
  }
}
