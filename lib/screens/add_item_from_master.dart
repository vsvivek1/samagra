import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class AddNewItemFromMaster extends StatefulWidget {
  final String itemTypeFlag;

  AddNewItemFromMaster({required this.itemTypeFlag});

  @override
  _AddNewItemFromMasterState createState() => _AddNewItemFromMasterState();
}

class _AddNewItemFromMasterState extends State<AddNewItemFromMaster> {
  late Future<List<Map<String, dynamic>>> _jsonFuture;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _jsonFuture = _loadJsonFromLocalStorage(widget.itemTypeFlag);
  }

  Future<List<Map<String, dynamic>>> _loadJsonFromLocalStorage(
      String itemTypeFlag) async {
    String jsonFilePath = '';

    // Choose the JSON file based on the itemTypeFlag
    if (itemTypeFlag == 'M') {
      jsonFilePath = 'path/to/material/json/file.json';
    } else if (itemTypeFlag == 'L') {
      jsonFilePath = 'path/to/labour/json/file.json';
    } else if (itemTypeFlag == 'T') {
      jsonFilePath = 'path/to/taken_back/json/file.json';
    } else {
      // Handle other cases or provide a default file
      jsonFilePath = 'path/to/default/json/file.json';
    }

    String jsonString = await File(jsonFilePath).readAsString();
    return json.decode(jsonString);
  }

  void _search(String query) {
    setState(() {
      _searchResults = _jsonFuture.then((json) => json
          .where((item) => item['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: _search,
          decoration: InputDecoration(labelText: 'Search'),
        ),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final item = _searchResults[index];
              return _buildItemWidget(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemWidget(Map<String, dynamic> item) {
    final itemName = item['name'].toString();
    final itemId = item['id'].toString();
    final itemType = item['type'].toString();

    return Column(
      children: [
        ListTile(
          title: Text(itemName),
          subtitle: Text('Type: $itemType'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Quantity:'),
            SizedBox(
              width: 50,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Handle the quantity change
                  // You can add your logic to save quantity to the desired place
                  debugPrint('Quantity: $value');
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle the button press
                // You can add your logic to save the selected item and its quantity
                debugPrint('Add to Cart: $itemName');
              },
              child: Text('Add to Cart'),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
