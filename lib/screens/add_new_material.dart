import 'package:flutter/material.dart';
import 'package:samagra/screens/material_entry.dart';

class AddNewMaterial extends StatefulWidget {
  final List<Map<dynamic, dynamic>> tasks;
  final Function reflectQuantityDetails;
  final Map<int, Map<dynamic, dynamic>> estimatedQuantityOfmaterials;
  var measurementDetails;
  var taskId;
  var structureId;

  var locationNo;

  int seletedLocationIndex;

  var mst_scheme_id;

  AddNewMaterial({
    required this.tasks,
    required this.reflectQuantityDetails,
    required this.estimatedQuantityOfmaterials,
    required this.measurementDetails,
    required this.taskId,
    required this.structureId,
    required int this.seletedLocationIndex,
    required this.mst_scheme_id,
  });

  @override
  _AddNewMaterialState createState() => _AddNewMaterialState();
}

class _AddNewMaterialState extends State<AddNewMaterial> {
  List<MaterialEntry> materialEntries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          automaticallyImplyLeading: false, title: Text('Add New Material')),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            /* showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text('Please use Save Button to go back'),
                  );
                }); */
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Displaying existing rows
                Center(
                    child: Text(
                        "MST SCHEME ID: " + widget.mst_scheme_id.toString())),
                MaterialEntry(
                    tasks: widget.tasks,
                    reflectQuantityDetails: widget.reflectQuantityDetails,
                    estimatedQuantityOfmaterials:
                        widget.estimatedQuantityOfmaterials,
                    measurementDetails: widget.measurementDetails,
                    taskId: widget.taskId,
                    structureId: widget.structureId,
                    mst_scheme_id: widget.mst_scheme_id

                    // taskId: widget.taskId, structureId: structureId
                    )
                // for (var entry in materialEntries) entry,
                // Button to add new row
                /*  ElevatedButton(
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
                ), */
              ],
            ),
          ),
        ),
      ),
    );
  }
}





/* DropdownButton<String>(
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
        ), */