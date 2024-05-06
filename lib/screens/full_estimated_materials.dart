import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullEstimatedMaterialsScreen extends StatelessWidget {
  final Map<int, Map<dynamic, dynamic>> EstimatedMaterials;
  var measurementDetails;
  FullEstimatedMaterialsScreen(
      {required this.EstimatedMaterials, required this.measurementDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' \t\tMaterial Details\nMeasured vs Estimate'),
      ),
      body: Center(
        child: FullEstimatedMaterialsList(
          EstimatedMaterials: EstimatedMaterials,
          measurementDetails: this.measurementDetails,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class FullEstimatedMaterialsList extends StatefulWidget {
  var measurementDetails;
  final Map<int, Map<dynamic, dynamic>> EstimatedMaterials;

  FullEstimatedMaterialsList(
      {required this.EstimatedMaterials, required this.measurementDetails});

  @override
  State<FullEstimatedMaterialsList> createState() =>
      _FullEstimatedMaterialsListState();
}

class _FullEstimatedMaterialsListState
    extends State<FullEstimatedMaterialsList> {
  var material;

  List measuredMaterials = [];

  @override
  void initState() {
    // listUniqueMaterials();
    super.initState();
    // ignore: todo
    // TODO: implement initState
  }

  int getMeasuredQuantity(String materialName) {
    int totalQuantity = 0;
    // Iterate through the list
    for (var location in widget.measurementDetails) {
      // Iterate through tasks
      for (var task in location['tasks']) {
        // Iterate through structures
        for (var structure in task['structures']) {
          // Iterate through materials
          for (var material in structure['materials']) {
            //  String name = material['material']['material_name'];
            String name = material['material_name'];
            if (name == materialName) {
              //totalQuantity += int.parse(material['material']['quantity']);
              totalQuantity += int.parse(material['quantity']);
            }
          }
        }
      }
    }
    // Return total quantity if material name found, otherwise return -1
    return totalQuantity > 0 ? totalQuantity : 0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          dataRowHeight: 75,
          columns: [
            DataColumn(label: Text('Material\nName')),
            DataColumn(label: Text('Estimated\nQuantity')),
            DataColumn(label: Text('Measured\nQuantity')),
          ],
          rows: widget.EstimatedMaterials.entries
              .map(
                (entry) => DataRow(cells: [
                  DataCell(Container(
                      transformAlignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      child: Text(entry.value['material']['material_name']))),
                  DataCell(Text(entry.value['quantity'].toString())),
                  // DataCell(Text('0')),
                  DataCell(Text(getMeasuredQuantity(
                          entry.value['material']['material_name'])
                      .toString()))

                  //*/
                ]),
              )
              .toList(),
        ),
      ),
    );
  }
}
