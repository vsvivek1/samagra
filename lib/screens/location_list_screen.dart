import 'package:flutter/material.dart';

class LocationListScreen extends StatelessWidget {
  /// class to update materials labour and takenb backs

  final List<dynamic> measurementDetails;

  LocationListScreen({required this.measurementDetails});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: measurementDetails.length,
      itemBuilder: (context, locationIndex) {
        final location = measurementDetails[locationIndex];
        final locationNo = location['locationNo'];
        final locationName = location['locationName'];
        final tasks = location['tasks'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Location $locationNo: $locationName'),
            ),
            Divider(),
            if (tasks != null && tasks.isNotEmpty)
              Column(
                children: tasks.map<Widget>((taskItem) {
                  final taskIndex = tasks.indexOf(taskItem);
                  final taskName = taskItem['task_name'];
                  final structures = taskItem['structures'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text('Task ${taskIndex + 1}: $taskName'),
                      ),
                      if (structures != null && structures.isNotEmpty)
                        ...structures.map<Widget>((structureItem) {
                          final structureIndex =
                              structures.indexOf(structureItem);
                          final materialName = structureItem['material_name'];
                          final labourName = structureItem['labour_name'];
                          final takenBack = structureItem['taken_back'];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text('Structure ${structureIndex + 1}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (materialName != null)
                                      Text('Material Name: $materialName'),
                                    if (labourName != null)
                                      Text('Labour Name: $labourName'),
                                    Text('Taken Back: ${takenBack ?? 'N/A'}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  color: Colors.green,
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        String newQuantity = takenBack ?? '';

                                        return AlertDialog(
                                          title: Text('Edit Quantity'),
                                          content: TextFormField(
                                            initialValue: newQuantity,
                                            onChanged: (value) {
                                              newQuantity = value;
                                            },
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Save'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                onQuantityChanged(
                                                  locationIndex,
                                                  taskIndex,
                                                  structureIndex,
                                                  newQuantity,
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              Divider(),
                            ],
                          );
                        }).toList(),
                      if (structures == null || structures.isEmpty)
                        ListTile(
                          title: Text('No items in this structure'),
                        ),
                    ],
                  );
                }).toList(),
              ),
            if (tasks == null || tasks.isEmpty)
              ListTile(
                title: Text('No tasks in this location'),
              ),
          ],
        );
      },
    );
  }

  void onQuantityChanged(int locationIndex, int taskIndex, int structureIndex,
      String newQuantity) {
    // Implement your logic to handle the quantity change here
    print(
        'Quantity changed: Location $locationIndex, Task $taskIndex, Structure $structureIndex, New Quantity: $newQuantity');
  }
}
