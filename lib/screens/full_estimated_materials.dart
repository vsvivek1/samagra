import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullEstimatedMaterialsScreen extends StatelessWidget {
  final Map<int, Map<dynamic, dynamic>> materials;

  FullEstimatedMaterialsScreen({required this.materials});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Estimated Materials'),
      ),
      body: Center(
        child: FullEstimatedMaterialsList(materials: materials),
      ),
    );
  }
}

class FullEstimatedMaterialsList extends StatelessWidget {
  final Map<int, Map<dynamic, dynamic>> materials;

  FullEstimatedMaterialsList({required this.materials});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          dataRowHeight: 75,
          columns: [
            DataColumn(label: Text('Material Name')),
            DataColumn(label: Text('Quantity')),
          ],
          rows: materials.entries
              .map(
                (entry) => DataRow(cells: [
                  DataCell(Container(
                      transformAlignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      child: Text(entry.value['material']['material_name']))),
                  DataCell(Text(entry.value['quantity'].toString())),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }
}
