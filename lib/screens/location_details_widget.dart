import 'package:flutter/material.dart';

class LocationDetailsWidget extends StatefulWidget {
  final String locationNo;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final List<String>? measurements;

  const LocationDetailsWidget({
    Key? key,
    required this.locationNo,
    this.locationName,
    this.latitude,
    this.longitude,
    this.measurements,
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

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Card(
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Location No: ${widget.locationNo}',
                  style: TextStyle(
                    fontSize: 30,
                    backgroundColor: Color.fromARGB(255, 229, 231, 235),
                  )),
              SizedBox(height: 8.0),
              if (widget.locationName != null) ...[
                Text(
                  'Location Name: ${widget.locationName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8.0),
              ],
              if (widget.latitude != null && widget.longitude != null) ...[
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
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
