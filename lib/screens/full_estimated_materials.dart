
import 'package:flutter/material.dart';
import 'package:samagra/screens/material_estimate_view.dart';
import 'package:samagra/screens/measured_materials_view.dart';

class FullEstimatedMaterialsScreen extends StatelessWidget {
  final Map<int, Map<dynamic, dynamic>> EstimatedMaterials;
  List<Map<dynamic, dynamic>> measurementDetails;
  List<Map<String, dynamic>> measuredMaterials;
  FullEstimatedMaterialsScreen(
      {required this.EstimatedMaterials,
      required this.measurementDetails,
      required this.measuredMaterials});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' \t\tMaterial Details\nMeasured vs Estimate'),
      ),
      body: Center(
        child: FullEstimatedMaterialsList(
          measuredMaterials: measuredMaterials,
          EstimatedMaterials: EstimatedMaterials,
          measurementDetails: this.measurementDetails,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class FullEstimatedMaterialsList extends StatefulWidget {
  List<Map<dynamic, dynamic>> measurementDetails;
  List<Map<String, dynamic>> measuredMaterials;
  final Map<int, Map<dynamic, dynamic>> EstimatedMaterials;

  FullEstimatedMaterialsList(
      {required this.EstimatedMaterials,
      required this.measurementDetails,
      required this.measuredMaterials});

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
    //var EstimatedMaterials = [];
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white10),
            child: Column(
              children: [
                Divider(),
                Text('Estimate of Materials'),
                Divider(),
              ],
            ),
          ),
          MaterialEstimateView(EstimatedMaterials: widget.EstimatedMaterials),
          Container(
            decoration: BoxDecoration(color: Colors.white10),
            child: Column(
              children: [
                Divider(),
                Text('Measured Vs Estimated'),
                Divider(),
              ],
            ),
          ),
          MeasuredMaterialsView(
            measuredMaterials: widget.measuredMaterials,
            estimatedMaterials: widget.EstimatedMaterials,
          )
        ],
      ),
    );
    return est();
  }

  SingleChildScrollView est() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          columns: [
            DataColumn(label: Text('Material\nName')),
            //  DataColumn(label: Text('Estimated\nQuantity')),
            DataColumn(label: Text('Measured\nQuantity')),
          ],
          rows: widget.EstimatedMaterials.entries
              //rows: widget.measuredMaterials.entries
              .map(
                (entry) => DataRow(cells: [
                  DataCell(Container(
                      width: 75,
                      transformAlignment: Alignment.center,
                      padding: EdgeInsets.all(5),
                      //child: Text(entry.value['material']['material_name']))),
                      child: Text(entry.value['material_name']))),
                  DataCell(Text(entry.value['quantity'].toString())),
                  // DataCell(Text('0')),
                  /*   DataCell(Text(getMeasuredQuantity(
                        entry.value['material']['material_name'])
                    .toString()))
 */
                  //*/
                ]),
              )
              .toList(),
        ),
      ),
    );
  }
}
