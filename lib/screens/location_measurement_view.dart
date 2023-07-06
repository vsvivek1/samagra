import 'package:flutter/material.dart';
import 'package:samagra/screens/whatsapp_button.dart';

class LocationMeasurementView extends StatefulWidget {
  final List<Map<dynamic, dynamic>> tasks;

  LocationMeasurementView({required this.tasks});

  @override
  _LocationMeasurementViewState createState() =>
      _LocationMeasurementViewState();
}

class _LocationMeasurementViewState extends State<LocationMeasurementView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(
          'Location Measurement View',
          // style: TextStyle(backgroundColor: Colors.yellowAccent)
        ),
      ),
      body: ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) {
          final task = widget.tasks[index];

          final structureList = task["structures"].toList();

          // print(task["structures"]);
          print('structes above');

          return Column(
            children: [
              Center(
                child: WhatsAppButton(
                  phoneNumber:
                      '+919847599946', // Enter the phone number you want to send the message to
                  message:
                      'Hello from my app!', // Enter the message you want to pre-fill
                ),
              ),
              ListTile(
                title: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Task: ${task['task_name']}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // subtitle:
                //     Text("Task ID: ${task['id']}  ${structureList.length}, "),
              ),
              //  print();

              // if (false)
              ListView.builder(
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
                        title: structure['structure_name'] != null
                            ? Text(
                                'Structure Name: ${structure['structure_name']}')
                            : Text('Structure No: ${structureIndex + 1}'),
                      ),
                      Column(
                        children: [
                          MaterialsView(structure, structureIndex, index),
                          Divider(color: Colors.grey[100]),
                          LabourView(structure, structureIndex, index),
                          Divider(color: Colors.grey[100]),
                          TakenBackView(structure, structureIndex, index),
                          Divider(color: Colors.grey[100])
                        ],
                      ),
                    ],
                  );
                },
              ),

              Divider(
                color:
                    Colors.black, // Customize the color of the line if needed
                thickness: 1, // Adjust the thickness of the line if needed
                height:
                    0, // Set the height to 0 to make it invisible (only the line will be shown)
              ),
            ],
          );
        },
      ),
    );
  }

  Builder MaterialsView(structure, int structureIndex, int index) {
    int matLen = structure['materials'].length;

    return Builder(builder: (context) {
      return Column(
        children: [
          Text(structure.containsKey('materials') == false
              ? "No Material"
              : "structure['structure_name']"),
          if (structure.containsKey('materials'))
            if (structure != null && structure.containsKey('materials'))
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
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
    return Builder(builder: (context) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Labour',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (structure.containsKey('labour'))
            if (structure != null && structure.containsKey('labour'))
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: structure['labour'].length,
                itemBuilder: (context, labourIndex) {
                  // final material = structure['materials'][labourIndex];

                  final labour = structure['labour'][labourIndex];

                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                            '${labourIndex + 1}: ${labour['labour_name']}'),
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
              ),
        ],
      );
    });
  }

  Builder TakenBackView(structure, int structureIndex, int index) {
    return Builder(builder: (context) {
      return Column(
        children: [
          Text(
              structure.containsKey('takenbacks') == false
                  ? "No Taken backs"
                  : "structure['structure_name']",
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              )),
          if (structure.containsKey('takenbacks'))
            if (structure != null && structure.containsKey('materials'))
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: structure['materials'].length,
                itemBuilder: (context, takenBackIndex) {
                  final material = structure['takenbacks'][takenBackIndex];

                  // final labour = structure['labour'][materialIndex];

                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Materials',
                          style: TextStyle(
                            color: Colors.grey[750],
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                            '${takenBackIndex + 1} : ${material['material_name']}'),
                        subtitle: Text('Quantity: ${material['quantity']}'),
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
            [structureIndex]['takenBack'][takenBackIndex]['quantity'];

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
                      ['materials'][takenBackIndex]['quantity'] = newQuantity;
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
