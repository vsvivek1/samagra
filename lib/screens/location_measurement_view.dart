import 'dart:developer';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:samagra/kseb_color.dart';
import 'package:samagra/screens/add_labour_not_in_estimate.dart';
import 'package:samagra/screens/add_new_material.dart';
import 'package:samagra/screens/add_new_labour.dart';

class LocationMeasurementView extends StatefulWidget {
  List<Map<dynamic, dynamic>> tasks;
  final Function reflectQuantityDetails;
  final Function onNewMaterialAdditionFinished;
  final Function onNewLabourAdditionFinished;

  final estimatedQuantityOfmaterials;

  int selectedLocationIndex;

  final measurementDetails;

  var locationNo;

  var mst_scheme_id;

  var estimatedQuantityOfLabour;

  LocationMeasurementView(
      {required this.tasks,
      required this.reflectQuantityDetails,
      required this.estimatedQuantityOfmaterials,
      required this.measurementDetails,
      required this.selectedLocationIndex,
      required this.onNewMaterialAdditionFinished,
      required this.onNewLabourAdditionFinished,
      required this.mst_scheme_id});

  @override
  _LocationMeasurementViewState createState() =>
      _LocationMeasurementViewState();
}

class _LocationMeasurementViewState extends State<LocationMeasurementView> {
  @override
  Widget build(BuildContext context) {
    // print("${widget.tasks} is tasks");

    // print('selected index ${widget.selectedLocationIndex}');

    //debugger(when: true);
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) {
          final task = widget.tasks[index];

          final structureList = (task["structures"] ?? []).toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  margin: EdgeInsets.only(top: 50),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                  decoration: BoxDecoration(
                    color:
                        Color.fromARGB(255, 212, 211, 216), // Background color
                    borderRadius:
                        BorderRadius.circular(16.0), // Optional: Border radius
                  ),
                  child: Text("Selected Task view of this Location",
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ))),
              // Center(
              //   child: WhatsAppButton(
              //     phoneNumber:
              //         '+919847599946', // Enter the phone number you want to send the message to
              //     message:
              //         'Hello from my app!', // Enter the message you want to pre-fill
              //   ),
              // ),
              ListTile(
                //leading:
                contentPadding: EdgeInsets.only(right: 1.0),
                title: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[400], // Background color
                    borderRadius:
                        BorderRadius.circular(8.0), // Optional: Border radius
                  ),
                  padding: EdgeInsets.all(1.0),
                  child: Column(
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        'Task Id: ${task['id']}  \n' +
                            'Task Name : ${task['task_name']}',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 177, 74, 74),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'T' + (index + 1).toString(),
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      structureWidget(structureList, index, task['id']),
                    ],
                  ),
                ),
                // subtitle:
                //     Text("Task ID: ${task['id']}  ${structureList.length}, "),

                // subtitle:
                //  structureWidget(structureList, index),
              ),

              // if (false)

              Divider(
                color:
                    Colors.black, // Customize the color of the line if needed
                thickness: 2, // Adjust the thickness of the line if needed
                height:
                    0, // Set the height to 0 to make it invisible (only the line will be shown)
              ),
            ],
          );
        },
      ),
    );
  }

  ListView structureWidget(structureList, int index, taskId) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: structureList.length,
      itemBuilder: (context, structureIndex) {
        final structure = structureList[structureIndex];

        return Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          decoration: BoxDecoration(
            color: Colors.grey[300], // Background color
            borderRadius:
                BorderRadius.circular(16.0), // Optional: Border radius
          ),
          child: Column(
            children: [
              ListTile(
                tileColor: Colors.grey[200],
                contentPadding: EdgeInsets.only(left: 1.0),
                leading: CircleAvatar(
                    maxRadius: 40,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        'T' +
                            (index + 1).toString() +
                            '/S' +
                            (structureIndex + 1).toString())),
                title: structure['structure_name'] != null
                    ? Text(
                        'Str Id : ${structure['id']}\n Structure Name:\n${structure['structure_name']}',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ))
                    : Text('Structure No: ${structureIndex + 1}'),
              ),
              Column(
                children: [
                  MaterialsView(structure, structureIndex, index, taskId,
                      structure['id']),
                  //  Divider({Key? key, double? height, double? thickness, double? indent, double? endIndent, Color? color}))
                  Divider(
                    color: ksebMaterialColor,
                    height: 30,
                    indent: 0,
                    endIndent: BorderSide.strokeAlignOutside,
                    thickness: 7,
                  ),
                  LabourView(structure, structureIndex, index, taskId,
                      structure['id']),
                  Divider(
                    color: ksebMaterialColor,
                    height: 30,
                    indent: 0,
                    endIndent: BorderSide.strokeAlignOutside,
                    thickness: 7,
                  ),
                  TakenBackView(structure, structureIndex, index),
                  Divider(
                    color: ksebMaterialColor,
                    height: 30,
                    indent: 0,
                    endIndent: BorderSide.strokeAlignOutside,
                    thickness: 7,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Builder MaterialsView(
      structure, int structureIndex, int index, taskId, strutctureId) {
    // int matLen = structure['materials'].length;

    int matLen = structure['materials'].length;
    int labLen = structure['labour'].length;
    int takenLen = structure['takenBacks']?.length ?? 0;

    String name = structure['structure_name'];

    return Builder(builder: (context) {
      return Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Background color
          borderRadius: BorderRadius.circular(16.0), // Optional: Border radius
        ),
        child: Column(
          children: [
            if (structure.containsKey('materials'))
              if (structure != null && structure.containsKey('materials'))
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        'Materials',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    matLen == 0
                        ? Column(children: [
                            Text(
                              'No materials for this Task or Not Issued',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ])
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: structure['materials'].length,
                            itemBuilder: (context, materialIndex) {
                              final material =
                                  structure['materials'][materialIndex];

                              // final labour = structure['labour'][materialIndex];

                              return Column(
                                children: [
                                  ListTile(
                                      contentPadding:
                                          EdgeInsets.only(left: 1.0),
                                      title: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .9,
                                        child: Wrap(
                                          children: [
                                            Text(
                                                style: GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                maxLines: 2,
                                                '${materialIndex + 1} : ${material['material_name']}'),
                                          ],
                                        ),
                                      ),
                                      subtitle: itemEditingBox(material)

                                      // trailing: ,
                                      // trailing: TextFormField(
                                      //         keyboardType:
                                      //             TextInputType.numberWithOptions(
                                      //                 decimal: true),

                                      // trailing: TextField(),
                                      // trailing: IconButton(
                                      //   icon: Icon(Icons.edit),
                                      //   onPressed: () {
                                      //     _editMaterialQuantity(
                                      //         materialIndex, structureIndex, index);
                                      //   },
                                      // ),
                                      ),
                                  Divider(color: Colors.grey)
                                ],
                              );
                            },
                          ),
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 132, 184, 134)),
                        ),
                        onPressed: (() {
                          print(widget.mst_scheme_id);

                          addMaterialsNotInEstimate(taskId, strutctureId);
                        }),
                        child: Text(
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            'Add Materials Not in Estimate')),
                  ],
                ),
          ],
        ),
      );
    });
  }

  Wrap itemEditingBox(item) {
    double estimateQuantity = 0;

    if (item['material_code'] != null) {
      int id = item['mst_material_id'];
      var foundObject = widget.estimatedQuantityOfmaterials[id];
      if (foundObject != null) {
        estimateQuantity = foundObject['quantity'];
      }

      print("$foundObject is found");
    }

    TextEditingController itemController = TextEditingController();
    itemController.text = item['quantity'].toString();

    bool editingMode = item['editingMode'] ?? false;

    if (double.parse(item['quantity'].toString()) > 0) {
      item['editingMode'] = false;
    }

    return Wrap(
      children: [
        Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Divider(),
              Text(
                  'Measured Quantity Here: ${double.parse(item['quantity'].toString()).toStringAsFixed(2)}'),
              Divider(),
              Text('Total Issued Quantity: '),
              Divider(),
              if (item['material_code'] != null)
                Text('Total Estimate Quantity: ${estimateQuantity} '),
              Divider()
            ],
          ),
        ),
        SizedBox(width: 50),
        if (editingMode)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                height: 25,
                child: TextField(
                  controller: itemController,
                  onChanged: (value) {
                    item['quantity'] = value;
                  },
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      gapPadding: 10,
                      borderSide: BorderSide(
                        width: 2.0,
                        color: Colors.blue, // Border color
                      ),
                    ),
                  ),
                  cursorColor: Colors.red,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    item['editingMode'] = !editingMode;
                  });
                },
                icon: Icon(
                  editingMode ? Icons.save : Icons.edit,
                  color: editingMode ? Colors.green : Colors.red,
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Text(
                  "Qty: ${double.parse(item['quantity'].toString()).toStringAsFixed(2)}"),
              SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  setState(() {
                    item['editingMode'] = !editingMode;
                  });
                },
                icon: Icon(
                  editingMode ? Icons.save : Icons.edit,
                  color: editingMode ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Builder LabourView(
      structure, int structureIndex, int index, taskId, strutctureId) {
    if (structure != null && structure.containsKey('labour')) {
// structure.

      final labour1 = structure['labour'];

      return Builder(builder: (context) {
        return Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          decoration: BoxDecoration(
            color: Colors.grey[200], // Background color
            borderRadius:
                BorderRadius.circular(16.0), // Optional: Border radius
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  'Labour',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: labour1.length,
                itemBuilder: (context, labourIndex) {
                  // final material = structure['materials'][labourIndex];

                  final labour = labour1[labourIndex];

                  return Builder(builder: (context) {
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.only(left: 1.0),
                          title: Text(
                              '${labourIndex + 1}: ${labour['labour_name']}'),
                          // subtitle: Text('Quantity: ${labour['quantity']}'),
                          subtitle: itemEditingBox(labour),

                          /* trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editLabourQuantity(
                                  labourIndex, structureIndex, index);
                            },
                          ), */
                        ),
                      ],
                    );
                  });
                },
              ),
               ElevatedButton(
  onPressed: () {
    addLabourNotInEstimate(context, taskId, strutctureId.toString(),widget.measurementDetails,widget.selectedLocationIndex

 ,() => setState(() {}), // parent refresh
);
  },
  child: Text('Add Labour'),
),

                
            ],
          ),
        );
      });
    } else {
      return Builder(builder: (context) {
        return Column(children: [
          Container(child: Text('No labour')),
          
         ElevatedButton(
  onPressed: () {
       addLabourNotInEstimate(context, taskId, strutctureId,widget.measurementDetails,widget.selectedLocationIndex,
        () => setState(() {}), // parent refresh
       );
  },
  child: Text('Add Labour'),
),
        ]);
      });
    }
  }

  Builder TakenBackView(structure, int structureIndex, int index) {
    return Builder(builder: (context) {
      var tb = structure['takenBacks'];

      return Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Background color
          borderRadius: BorderRadius.circular(16.0), // Optional: Border radius
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'Taken Backs',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
                structure.containsKey('takenBacks') == false
                    ? "No Taken backs"
                    : "${structure['structure_name']}",
                style: TextStyle(
                  color: ksebColor,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                )),
            if (structure.containsKey('takenBacks'))
              if (structure != null && structure.containsKey('takenBacks'))
                ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: structure['takenBacks'].length,
                  itemBuilder: (context, takenBackIndex) {
                    final takenBacks = structure['takenBacks'][takenBackIndex];

                    // final labour = structure['labour'][materialIndex];

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.only(left: 1.0),
                          title: Text(
                              '${takenBackIndex + 1} : ${takenBacks['material_name']}'),
                          // subtitle: Text('Quantity: ${takenBacks['quantity']}'),
                          subtitle: itemEditingBox(takenBacks),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editTakenBackQuantity(
                                  takenBackIndex, structureIndex, index);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
            /*  ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 132, 184, 134)),
                ),
                onPressed: addtakenbacksNotInEstimate(),
                child: Text(
                    textAlign: TextAlign.center,
                    'Add Takenbacks Not in Estimate')), */
          ],
        ),
      );
    });
  }

  void _editMaterialQuantity(
      int materialIndex, int structureIndex, int taskIndex) {
    showDialog(
      context: context,
      builder: (context) {
        String newQuantity = widget.tasks[taskIndex]['structures']
            [structureIndex]['materials'][materialIndex]['quantity'];

        return AlertDialog(
          insetPadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(0),
          title: Text('Edit Quantity'),
          content: TextField(
            onChanged: (value) {
              // newQuantity = double.tryParse(value) ?? newQuantity;
              newQuantity = value ?? newQuantity;
            },
            decoration: InputDecoration(
              labelText: 'New Quantity',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  widget.tasks[taskIndex]['structures'][structureIndex]
                      ['materials'][materialIndex]['quantity'] = newQuantity;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editTakenBackQuantity(
      int takenBackIndex, int structureIndex, int taskIndex) {
    showDialog(
      context: context,
      builder: (context) {
        String newQuantity = widget.tasks[taskIndex]['structures']
            [structureIndex]['takenBacks'][takenBackIndex]['quantity'];

        return AlertDialog(
          title: Text('Edit Quantity'),
          content: TextField(
            onChanged: (value) {
              // newQuantity = double.tryParse(value) ?? newQuantity;
              newQuantity = value ?? newQuantity;
            },
            decoration: InputDecoration(
              labelText: 'New Quantity',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  widget.tasks[taskIndex]['structures'][structureIndex]
                      ['takenBacks'][takenBackIndex]['quantity'] = newQuantity;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editLabourQuantity(int labourIndex, int structureIndex, int taskIndex) {
    showDialog(
      context: context,
      builder: (context) {
        var newQuantity = widget.tasks[taskIndex]['structures'][structureIndex]
            ['labour'][labourIndex]['quantity'];

        return AlertDialog(
          title: Text('Edit Quantity'),
          content: TextField(
            onChanged: (value) {
              // newQuantity = double.tryParse(value) ?? newQuantity;
              newQuantity = int.parse(value); //?? newQuantity;
            },
            decoration: InputDecoration(
              labelText: 'New Quantity',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  widget.tasks[taskIndex]['structures'][structureIndex]
                      ['labour'][labourIndex]['quantity'] = newQuantity;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  addMaterialsNotInEstimate(taskId, structureId) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AddNewMaterial(
            seletedLocationIndex: widget.selectedLocationIndex,
            taskId: taskId,
            structureId: structureId,
            tasks: widget.tasks,
            reflectQuantityDetails: (object) {},
            estimatedQuantityOfmaterials: widget.estimatedQuantityOfmaterials,
            measurementDetails: widget.measurementDetails,
            mst_scheme_id: widget.mst_scheme_id),
      ),
    )
        .then((result) {
      if (result == null || !(result is Map)) {
        return;
      }

      print(result);
      //debugger(when: true);
      // print('poped $result');

      if (result['selectedMaterials'] == null ||
          result['selectedMaterials'].length == 0) {
        print('hi return');
        return;
      }

      var taskId = result['taskId'];
      var structureId = result['strutctureId'];
      var selectedMaterials = result['selectedMaterials'];

      selectedMaterials.forEach((element) {
        element['mst_material_id'] = element['id'];
      });

      var a = widget.measurementDetails;

      Map loc = widget.measurementDetails.firstWhere(
          (l) => l['locationNo'] == widget.selectedLocationIndex + 1);

      List tasks = loc['tasks'];

      Map task = tasks.firstWhere((lc) => lc['id'] == taskId);

      //  debugger(when: true);
      List structures = task['structures'];
      // debugger(when: true);
      Map structure = structures
          .firstWhere((s) => s['id'].toString() == structureId.toString());
      //debugger(when: true);
      List materials = structure['materials'];

      //debugger(when: true);
      materials.addAll(selectedMaterials);

      widget.onNewMaterialAdditionFinished();
      //onMaterialFinished();
/* 
      print(materials);
      debugger(when: true);
      debugger(when: true);
      print('$loc is loc'); */
    });
  }

  addLabourNotInEstimatex(taskId, structureId) {

    print('pressed');

    return;
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AddNewLabour(
            selectedLocationIndex: widget.selectedLocationIndex,
            taskId: taskId,
            structureId: structureId,
            tasks: widget.tasks,
            reflectQuantityDetails: (object) {},
            estimatedQuantityOfLabour: widget.estimatedQuantityOfLabour,
            measurementDetails: widget.measurementDetails,
            mst_scheme_id: widget.mst_scheme_id),
      ),
    )
        .then((result) {
      if (result == null || !(result is Map)) {
        return;
      }

      print(result);

      if (result['selectedLabour'] == null ||
          result['selectedLabour'].isEmpty) {
        print('No labor selected');
        return;
      }

      var taskId = result['taskId'];
      var structureId = result['structureId'];
      var selectedLabour = result['selectedLabour'];

      selectedLabour.forEach((element) {
        element['mst_labour_id'] = element['id'];
      });

      Map loc = widget.measurementDetails.firstWhere(
          (l) => l['locationNo'] == widget.selectedLocationIndex + 1);

      List tasks = loc['tasks'];

      Map task = tasks.firstWhere((lc) => lc['id'] == taskId);

      List structures = task['structures'];
      Map structure = structures
          .firstWhere((s) => s['id'].toString() == structureId.toString());

      List labour = structure['labour'];

      labour.addAll(selectedLabour);

      widget.onNewLabourAdditionFinished();
    });
  }

  addtakenbacksNotInEstimate() {}

  void onMaterialFinished() {}
}
