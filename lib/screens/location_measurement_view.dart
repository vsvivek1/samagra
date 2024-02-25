import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) {
          final task = widget.tasks[index];

          final structureList = (task["structures"] ?? []).toList();

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
                        'Task Id: ${task['id']}  \n' +
                            'Task Name : ${task['task_name']}',
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
                      'Str Id : ${structure['id']}, ${structure['structure_name']}',
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

    int matLen = structure['labour'].length;
    int labLen = structure['materials'].length;
    int takenLen = structure['takenBacks']?.length ?? 0;

    String name = structure['structure_name'];

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
                                title: SizedBox(
                                  width: MediaQuery.of(context).size.width * .5,
                                  child: Wrap(
                                    children: [
                                      Text(
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
                                );
                          },
                        ),
                ],
              ),
        ],
      );
    });
  }

  Wrap itemEditingBox(item) {
    return Wrap(
      children: [
        Text('Quantity: ${item['quantity']}'),
        SizedBox(width: 50),
        if (item['editing'] == null || item['editing'] == true)
          SizedBox(
            width: 100.0,
            height: 25,
            child: TextField(
              onChanged: (value) {
                print(item);
                setState(() {
                  item['quantity'] = value;
                });

                // print('hi');
                // _edititemQuantity(itemIndex,
                //     structureIndex, index);
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  gapPadding: 10,
                  borderSide: BorderSide(
                      strokeAlign: BorderSide.strokeAlignInside,
                      width: 2.0,
                      color: Colors.blue), // Border color
                ),
              ),
              onEditingComplete: () {},
              // focusNode: FocusScope.of(context).parent,
              cursorColor: Colors.red,
              // maxLines: 2,
              // maxLength: 2,
            ),
          ),
        SizedBox(width: 10),
        if (item['editing'] == null || item['editing'] == true)
          IconButton(
              onPressed: (() {
                setState(() {
                  item['editing'] = false;
                });
              }),
              icon: Icon(color: Colors.green, Icons.save)),
        if (item['editing'] != null && item['editing'] == false)
          IconButton(
              onPressed: (() {
                setState(() {
                  item['editing'] = true;
                });
              }),
              icon: Icon(color: Colors.red, Icons.edit))
      ],
    );
  }

  Builder LabourView(structure, int structureIndex, int index) {
    if (structure != null && structure.containsKey('labour')) {
// structure.

      final labour1 = structure['labour'];

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

                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.only(left: 1.0),
                      title:
                          Text('${labourIndex + 1}: ${labour['labour_name']}'),
                      // subtitle: Text('Quantity: ${labour['quantity']}'),
                      subtitle: itemEditingBox(labour),

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
