import 'package:flutter/material.dart';
import 'package:samagra/kseb_color.dart';

class LocationMeasurementView extends StatefulWidget {
  final List<Map<dynamic, dynamic>> tasks;
  final Function reflectQuantityDetails;

  LocationMeasurementView(
      {required this.tasks, required this.reflectQuantityDetails});

  @override
  _LocationMeasurementViewState createState() =>
      _LocationMeasurementViewState();
}

class _LocationMeasurementViewState extends State<LocationMeasurementView> {
  @override
  Widget build(BuildContext context) {
    // print("TAKS from hloca measurement widget ${widget.tasks}");
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) {
          final task = widget.tasks[index];

          final structureList = (task["structures"] ?? []).toList();

          // print(task["structures"]);

          return Column(
            children: [
              Text("Selected Task view of this Location"),
              // Center(
              //   child: WhatsAppButton(
              //     phoneNumber:
              //         '+919847599946', // Enter the phone number you want to send the message to
              //     message:
              //         'Hello from my app!', // Enter the message you want to pre-fill
              //   ),
              // ),
              ListTile(
                leading: CircleAvatar(
                  maxRadius: 14,
                  child: Text(
                    'T' + (index + 1).toString(),
                    textScaleFactor: .5,
                  ),
                ),

                contentPadding: EdgeInsets.only(right: 1.0),
                title: Container(
                  padding: EdgeInsets.all(1.0),
                  child: Column(
                    children: [
                      Text(
                        ' ${task['task_name']}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      structureWidget(structureList, index),
                    ],
                  ),
                ),
                // subtitle:
                //     Text("Task ID: ${task['id']}  ${structureList.length}, "),

                // subtitle:
                //  structureWidget(structureList, index),
              ),
              //  print();

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

  ListView structureWidget(structureList, int index) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: structureList.length,
      itemBuilder: (context, structureIndex) {
        final structure = structureList[structureIndex];

        // print(structure);

        print('structure above at 53');
        return Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.only(left: 1.0),
              leading: CircleAvatar(
                  maxRadius: 13,
                  backgroundColor: Colors.blue[100],
                  child: Text('S' + (structureIndex + 1).toString())),
              title: structure['structure_name'] != null
                  ? Text(
                      '${structure['structure_name']}',
                      style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    )
                  : Text('Structure No: ${structureIndex + 1}'),
            ),
            Column(
              children: [
                MaterialsView(structure, structureIndex, index),
                //  Divider({Key? key, double? height, double? thickness, double? indent, double? endIndent, Color? color}))
                Divider(
                  color: ksebMaterialColor,
                  height: 30,
                  indent: 0,
                  endIndent: BorderSide.strokeAlignOutside,
                  thickness: 7,
                ),
                LabourView(structure, structureIndex, index),
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
        );
      },
    );
  }

  Builder MaterialsView(structure, int structureIndex, int index) {
    // int matLen = structure['materials'].length;

    print('structes above');

    int matLen = structure['labour'].length;
    int labLen = structure['materials'].length;
    int takenLen = structure['takenBacks']?.length ?? 0;

    String name = structure['structure_name'];

    print(
        "$name material no $matLen and labour len $labLen and taen len $takenLen at 130 ");

    return Builder(builder: (context) {
      return Column(
        children: [
          if (structure.containsKey('materials'))
            if (structure != null && structure.containsKey('materials'))
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      'Materials',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  matLen == 0
                      ? Column(children: [
                          Text(
                            'Nil',
                            style: TextStyle(
                              color: Color.fromARGB(255, 234, 12, 12),
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
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

                            return ListTile(
                              contentPadding: EdgeInsets.only(left: 1.0),
                              title: Text(
                                  '${materialIndex + 1} : ${material['material_name']}'),
                              subtitle:
                                  Text('Quantity: ${material['quantity']}'),
                              trailing: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _editMaterialQuantity(
                                      materialIndex, structureIndex, index);
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),
        ],
      );
    });
  }

  Builder LabourView(structure, int structureIndex, int index) {
    if (structure != null && structure.containsKey('labour')) {
// structure.

      print("this is structreue 190 $structure");
      final labour1 = structure['labour'];

      // labour1.keys.forEach((key) {
      //   print("this is key from 190 $key");
      // });

      print('from view this is labour $labour1');
      print('LABOUR LENGTH ${labour1.length}');
      return Builder(builder: (context) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(5.0),
              child: Text(
                'Labour',
                style: TextStyle(
                  color: Colors.grey[700],
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

                print("LABVOURNAME $labourIndex $labour");

                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 1.0),
                      title:
                          Text('${labourIndex + 1}: ${labour['labour_name']}'),
                      subtitle: Text('Quantity: ${labour['quantity']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editLabourQuantity(
                              labourIndex, structureIndex, index);
                        },
                      ),
                    ),
                  ],
                );
              },
            )
          ],
        );
      });
    } else {
      return Builder(builder: (context) {
        return Column(children: [Container(child: Text('No labour'))]);
      });
    }
  }

  Builder TakenBackView(structure, int structureIndex, int index) {
    return Builder(builder: (context) {
      var tb = structure['takenBacks'];

      print('from view this is TAKEN BACKS $tb');
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(5.0),
            child: Text(
              'Taken Backs',
              style: TextStyle(
                color: Colors.grey[750],
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
                        subtitle: Text('Quantity: ${takenBacks['quantity']}'),
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
        ],
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
                  // print(widget.tasks[taskIndex]['structures'][structureIndex]
                  //         ['labour'][labourIndex]['quantity']
                  //     .toString());

                  // print('task above');
                  // // [taskIndex]

                  // // ['structures'][structureIndex]
                  // return;
                  // print(widget.tasks[taskIndex]['structures'][structureIndex]
                  //     ['labour']);
                  // print(widget.tasks[taskIndex]['structures'][structureIndex]
                  //     ['labour'][labourIndex]);
                  // print(widget.tasks[taskIndex]['structures'][structureIndex]
                  //     ['labour'][labourIndex]['quantity']);

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
}
