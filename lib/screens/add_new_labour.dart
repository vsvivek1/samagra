import 'package:flutter/material.dart';
import 'package:samagra/screens/labour_entry.dart';

class AddNewLabour extends StatefulWidget {
  final List<Map<dynamic, dynamic>> tasks;
  final Function reflectQuantityDetails;
  final Map<int, Map<dynamic, dynamic>> estimatedQuantityOfLabour;
  var measurementDetails;
  var taskId;
  var structureId;
  var locationNo;
  int selectedLocationIndex;
  var mst_scheme_id;

  AddNewLabour({
    required this.tasks,
    required this.reflectQuantityDetails,
    required this.estimatedQuantityOfLabour,
    required this.measurementDetails,
    required this.taskId,
    required this.structureId,
    required this.selectedLocationIndex,
    required this.mst_scheme_id,
  });

  @override
  _AddNewLabourState createState() => _AddNewLabourState();
}

class _AddNewLabourState extends State<AddNewLabour> {
  List<LabourEntry> labourEntries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Add New Labour'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: WillPopScope(
          onWillPop: () async {
            // Prevent back navigation without using Save button
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text('Please use Save Button to go back'),
              ),
            );
            return false; // Prevent default back navigation
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "MST SCHEME ID: ${widget.mst_scheme_id.toString()}",
                  ),
                ),
                // Displaying existing rows
                LabourEntry(
                  tasks: widget.tasks,
                  reflectQuantityDetails: widget.reflectQuantityDetails,
                  estimatedQuantityOfLabour: widget.estimatedQuantityOfLabour,
                  measurementDetails: widget.measurementDetails,
                  taskId: widget.taskId,
                  structureId: widget.structureId,
                  mst_scheme_id: widget.mst_scheme_id,
                ),
                // Button to add new row for labour entry
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      labourEntries.add(
                        LabourEntry(
                          tasks: widget.tasks,
                          reflectQuantityDetails: widget.reflectQuantityDetails,
                          estimatedQuantityOfLabour:
                              widget.estimatedQuantityOfLabour,
                          measurementDetails: widget.measurementDetails,
                          taskId: widget.taskId,
                          structureId: widget.structureId,
                          mst_scheme_id: widget.mst_scheme_id,
                        ),
                      );
                    });
                  },
                  child: Text('Add New Row'),
                ),
                // Display the dynamically added labour entries
                ...labourEntries,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
