import 'package:flutter/material.dart';

class AddNewMaterial extends StatefulWidget {
  final List<Map<dynamic, dynamic>> tasks;
  final Function reflectQuantityDetails;
  final Map<int, Map<dynamic, dynamic>> estimatedQuantityOfmaterials;
  var measurementDetails;

  AddNewMaterial({
    required this.tasks,
    required this.reflectQuantityDetails,
    required this.estimatedQuantityOfmaterials,
    required this.measurementDetails,
  });

  @override
  _AddNewMaterialState createState() => _AddNewMaterialState();
}

class _AddNewMaterialState extends State<AddNewMaterial> {
  List<MaterialEntry> materialEntries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Material')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Displaying existing rows
          for (var entry in materialEntries) entry,
          // Button to add new row
          ElevatedButton(
            onPressed: () {
              setState(() {
                materialEntries.add(
                  MaterialEntry(
                    tasks: widget.tasks,
                    reflectQuantityDetails: widget.reflectQuantityDetails,
                    estimatedQuantityOfmaterials:
                        widget.estimatedQuantityOfmaterials,
                    measurementDetails: widget.measurementDetails,
                  ),
                );
              });
            },
            child: Text('Add New Row'),
          ),
        ],
      ),
    );
  }
}

class MaterialEntry extends StatefulWidget {
  List<Map<dynamic, dynamic>> tasks;
  final Function reflectQuantityDetails;
  final Map<int, Map<dynamic, dynamic>> estimatedQuantityOfmaterials;
  var measurementDetails;

  MaterialEntry({
    required this.tasks,
    required this.reflectQuantityDetails,
    required this.estimatedQuantityOfmaterials,
    required this.measurementDetails,
  });

  @override
  _MaterialEntryState createState() => _MaterialEntryState();
}

class _MaterialEntryState extends State<MaterialEntry> {
  String selectedMaterial = 'Material 1'; // Set a valid initial value
  String quantity = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Selectable field for materials
        DropdownButton<String>(
          value: selectedMaterial,
          onChanged: (newValue) {
            setState(() {
              selectedMaterial = newValue!;
            });
          },
          items: [
            DropdownMenuItem(
              child: Text('Material 1'),
              value: 'Material 1',
            ),
            DropdownMenuItem(
              child: Text('Material 2'),
              value: 'Material 2',
            ),
          ],
        ),
        // Field to enter quantity
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                quantity = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Quantity',
            ),
          ),
        ),
        // Edit, Delete, and Save buttons
        IconButton(
          onPressed: () {
            // Implement edit functionality
          },
          icon: Icon(Icons.edit),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              // Implement delete functionality
            });
          },
          icon: Icon(Icons.delete),
        ),
        IconButton(
          onPressed: () {
            // Implement save functionality
          },
          icon: Icon(Icons.save),
        ),
      ],
    );
  }
}
