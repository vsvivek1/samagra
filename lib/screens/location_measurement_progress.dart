import 'package:flutter/material.dart';

class LocationMeasurementProgress extends StatelessWidget {
  final bool hasGeoLocations;
  final bool hasMeasurements;

  LocationMeasurementProgress(
      {required this.hasGeoLocations, required this.hasMeasurements});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Geo Coordinates',
              style: TextStyle(
                color: hasGeoLocations ? Colors.blue : Colors.black,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              hasGeoLocations ? Icons.check_circle : Icons.cancel,
              color: hasGeoLocations ? Colors.blue : Colors.red,
            ),
          ],
        ),
        Row(
          children: [
            Text(
              'Measurements',
              style: TextStyle(
                color: hasMeasurements ? Colors.blue : Colors.black,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              hasMeasurements ? Icons.check_circle : Icons.cancel,
              color: hasMeasurements ? Colors.blue : Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}
