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

  final Function emitLocDetailsToPolVarWidget;

  LocationDetailsWidget(
      {Key? key,
      required this.locationNo,
      this.measurements,
      required this.updateLocationDetailsArray,

      // ignore: non_constant_identifier_names
      required this.locationDetails,
      required this.emitLocDetailsToPolVarWidget})
      : super(key: key) {
    print(this.measurements);
    print('this.measurementsabove  loc det widget line 28');
  }

  @override
  _LocationDetailsWidgetState createState() => _LocationDetailsWidgetState();
}

class _LocationDetailsWidgetState extends State<LocationDetailsWidget>
    with SingleTickerProviderStateMixin {
  TextEditingController locationNameController = new TextEditingController();
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

  bool editMode = true;
  bool _gotLocation = false;

  late String locationName = '';
  late String latitude = '0';
  late String longitude = '0';

  Map<String, dynamic> locationDetails = {};
  @override
  void initState() {
    // this.locationNameController.text = widget.locationName!;

    super.initState();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: (widget.locationNo == '-1')
          ? Text("Select a Location to View details")
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (this.editMode) ...[
                    LocationButton(onLocationSelected: onLocationSelected),
                    Visibility(
                      visible: _gotLocation && locationName != '',
                      child: ElevatedButton(
                          onPressed: () => saveLocDetailsToPolVarWidget(),
                          child: Text('save ${_gotLocation.toString()}')),
                    )
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
                  if (this.locationName != '') ...[
                    Text(
                      'Location Name: ${this.locationName}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8.0),
                  ],
                  if (editMode) ...[
                    Text('Enter Location Name'),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: TextFormField(
                        initialValue: locationName,
                        onChanged: ((value) => updateLocationText(value)),
                        // controller: this.locationNameController,
                        // decoration: InputDecoration(
                        //   labelText: 'Enter Location Name',
                        //   hintText: 'Enter location name',
                        // )
                      ),
                    )
                  ],
                  if (widget.latitude != null && widget.longitude != null) ...[
                    Text(
                      'Latitude: ${widget.latitude}, Longitude: ${widget.longitude}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 5.0),
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
    );
  }

  saveLocDetailsToPolVarWidget() {
    locationDetails['locationNo'] = int.parse(widget.locationNo) + 1;
    locationDetails['latitude'] = widget.latitude;
    locationDetails['longitude'] = widget.longitude;

    locationDetails['locationName'] = this.locationName;

    print('this is location name here ${locationDetails['name']}');

    locationDetails['geoCordinates'] = {};
    locationDetails['geoCordinates']['lattitude'] = widget.latitude;
    locationDetails['geoCordinates']['longitude'] = widget.longitude;

    // Map a = {'id': 'inida'};

    widget.emitLocDetailsToPolVarWidget(locationDetails);

    setState(() {
      _gotLocation = false;
    });
  }

  Set<String> updateLocationText(String value) {
    setState(() {
      widget.locationDetails['locationName'] = value;
      this.locationName = value;

      this.locationNameController.text = value;

      // print(value);
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

  onLocationSelected(double p1, double p2, String name) {
    setState(() {
      widget.latitude = p1;
      widget.longitude = p2;
      widget.locationName = name;

      widget.locationDetails['lattitude'] = p1.toString();
      widget.locationDetails['longitude'] = p2.toString();
      widget.locationDetails['locationName'] = name.toString();

      this.locationName = name;
      widget.locationDetails['name'] = name.toString();

      _gotLocation = true;
    });

    print(
        'line 251 selected from loc det widget taking from loc det widget ${p1}');
    // print(widget.latitude);
    // print(widget.longitude);
    //  print('abo');

    widget.updateLocationDetailsArray(widget.locationDetails);
  }

  void _saveLocationDetails() {
    setState(() {
      // editMode = !editMode;
      _gotLocation = false;
      widget.updateLocationDetailsArray(widget.locationDetails);

      // if (editMode) {
      //   // this.locationName = this.locationNameController.text;
      // }

      print(widget.locationName);
    });
  }
}
