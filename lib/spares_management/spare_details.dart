import 'package:flutter/material.dart';

class SpareDetailsPage extends StatelessWidget {
  final Map<String, dynamic> spare;

  SpareDetailsPage({required this.spare});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(spare['spare_name'] ?? 'Spare Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display spare image
            spare['image_url'] != null
                ? Image.network(spare['image_url'],
                    height: 200, fit: BoxFit.cover)
                : Icon(Icons.image, size: 100),

            SizedBox(height: 20),

            // Display spare name
            Text(
              'Name: ${spare['spare_name'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Display spare type
            Text(
              'Type: ${spare['spare_type'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),

            // Display spare quantity
            Text(
              'Quantity Available: ${spare['quantity_available'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),

            // Display location
            Text(
              'Location: ${spare['location'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 16),
            ),

            // Add more spare details as required
          ],
        ),
      ),
    );
  }
}
