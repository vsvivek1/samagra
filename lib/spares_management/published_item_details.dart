import 'package:flutter/material.dart';

class PublishedItemDetail extends StatelessWidget {
  final Map<String, dynamic> item;

  PublishedItemDetail({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['spare_name'] ?? "Item Details"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['images'] != null && item['images'].isNotEmpty)
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: item['images'].length,
                  itemBuilder: (context, imageIndex) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        item['images'][imageIndex],
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            Text(
              item['spare_name'] ?? "No Name",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Description: ${item['description'] ?? 'No Description'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Make: ${item['make'] ?? 'Unknown'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "KVA Rating: ${item['kva_rating'] ?? 'N/A'} KVA",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Quantity Available: ${item['quantity_available'] ?? 'N/A'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Location: ${item['location'] ?? 'N/A'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Contact Person: ${item['contact_person'] ?? 'N/A'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Contact CUG: ${item['contact_cug'] ?? 'N/A'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Condition: ${item['condition'] ?? 'N/A'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            if (item['test_values'] != null)
              Text(
                "Test Values: ${item['test_values']}",
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
