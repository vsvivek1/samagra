import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/spares_management/edit_item_screen.dart';

class MyListingsTab extends StatelessWidget {
  // Dummy data for the listings
  final List<Map<String, dynamic>> listings = [
    {
      "id": 1,
      "image": "https://via.placeholder.com/150",
      "description": "Spare Part 1 - Description",
    },
    {
      "id": 2,
      "image": "https://via.placeholder.com/150",
      "description": "Spare Part 2 - Description",
    },
  ];

  final Dio _dio = Dio();

  // Function to delete item from server
  Future<void> _deleteItem(int id) async {
    try {
      final response =
          await _dio.delete("https://your-server-api-endpoint.com/items/$id");
      if (response.statusCode == 200) {
        print("Item deleted successfully!");
      }
    } catch (e) {
      print("Failed to delete item: $e");
    }
  }

  // Navigate to the edit screen
  void _editItem(BuildContext context, Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemScreen(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final item = listings[index];
        return Card(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(item['image']),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    Text(item['description'], style: TextStyle(fontSize: 16)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _editItem(context, item),
                    child: Text("Edit"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _deleteItem(item['id']);
                      // You may want to refresh the list after deletion
                    },
                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
