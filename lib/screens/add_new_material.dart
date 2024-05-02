import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:samagra/common.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/kseb_color.dart';
import 'package:samagra/screens/material_list_widget.dart';
import 'package:samagra/screens/on_will_pop.dart';
import 'package:samagra/screens/search_material.dart';
import 'package:samagra/screens/searchable_dropdown.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:samagra/secure_storage/secure_storage.dart';
import 'package:gap/gap.dart';

class AddNewMaterial extends StatefulWidget {
  final List<Map<dynamic, dynamic>> tasks;
  final Function reflectQuantityDetails;
  final Map<int, Map<dynamic, dynamic>> estimatedQuantityOfmaterials;
  var measurementDetails;
  var taskId;
  var structureId;

  var locationNo;

  int seletedLocationIndex;

  AddNewMaterial({
    required this.tasks,
    required this.reflectQuantityDetails,
    required this.estimatedQuantityOfmaterials,
    required this.measurementDetails,
    required this.taskId,
    required this.structureId,
    required int this.seletedLocationIndex,
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
          canPop: false,
          onPopInvoked: (didPop) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text('Please use Save Button to go back'),
                  );
                });
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Displaying existing rows

                MaterialEntry(
                  tasks: widget.tasks,
                  reflectQuantityDetails: widget.reflectQuantityDetails,
                  estimatedQuantityOfmaterials:
                      widget.estimatedQuantityOfmaterials,
                  measurementDetails: widget.measurementDetails,
                  taskId: widget.taskId, structureId: widget.structureId,

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

class MaterialEntry extends StatefulWidget {
  List<Map<dynamic, dynamic>> tasks;
  final Function reflectQuantityDetails;
  final Map<int, Map<dynamic, dynamic>> estimatedQuantityOfmaterials;
  var measurementDetails;

  var taskId;

  var structureId;

  MaterialEntry(
      {required this.tasks,
      required this.reflectQuantityDetails,
      required this.estimatedQuantityOfmaterials,
      required this.measurementDetails,
      required this.taskId,
      required this.structureId});

  @override
  _MaterialEntryState createState() => _MaterialEntryState();
}

class _MaterialEntryState extends State<MaterialEntry> {
  var materials = [];
  String selectedMaterial = '1'; // Set a valid initial value
  String quantity = '';
  List materialMaster = [];
  String userText = '';

  List selectedMaterials = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getMaterialmasterData(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!(snapshot.hasData)) {
          return Center(
            widthFactor: 1,
            heightFactor: 1,
            child: SpinKitFadingCube(color: Colors.blue), // Use your color here
          );
        }
        //print(snapshot);
        materialMaster = snapshot.data;
        return Container(
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(spreadRadius: 2, blurRadius: 2)],
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                  colors: [Colors.grey, Colors.white70, Colors.grey])),
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            //height*.3,
            children: [
              /* SizedBox(
                width: ,
              ) */
              // Gap(),

              SearchMaterial(
                  onNewMaterialAdded: onNewMaterialAdded,
                  materialMaster: materialMaster,
                  selectedMaterials: selectedMaterials),

              Divider(
                color: Colors.red,
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFDDE1), // rgb(255, 221, 225)
                      Color(0xFFFFFFFF), // rgb(255, 255, 255)
                    ],
                    stops: [0.112, 0.922], // Stop percentages from CSS gradient
                    transform: GradientRotation(
                        109.6 * 3.14 / 180), // Convert degrees to radians
                  ),
                ),
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * .9,
                  height: MediaQuery.sizeOf(context).height * .4,
                  child: Container(
                    child: Column(
                      children: [
                        Expanded(
                            child: ListView.separated(
                                scrollDirection: Axis.vertical,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemBuilder: itemBuilder,
                                separatorBuilder: separatorBuilder,
                                itemCount: selectedMaterials.length)),
                        ElevatedButton(
                            onPressed: (() {
                              addExtraMaterialsToMeasurements();
                            }),
                            child: Text('Save'))
                      ],
                    ),
                  ),
                  /*  child: ListWheelScrollView(itemExtent: 5, children: [
                    Text('1hhhhdhdhdhdhdhh'),
                    Text('1'),
                    Text('1'),
                    Text('1'),
                  ]), */
                ),
              )

              // materialList(materialMaster),
              // List of ListTile for materials
              /*  SizedBox(
                  width: 250, height: 1000, child: materialList(materialMaster)), */
              // SizedBox(width: 10),
              // Field to enter quantity
              /*   Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      quantity = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Quantity',
                  ),
                ),
              ),
              // Edit, Delete, and Save buttons
              IconButton(
                onPressed: () {
                  // Implement edit functionality
                },
                icon: Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    // Implement delete functionality
                  });
                },
                icon: Icon(Icons.delete),
              ),
              IconButton(
                onPressed: () {
                  // Implement save functionality
                },
                icon: Icon(Icons.save),
              ),
          
              */
            ],
          ),
        );
      },
    );
  }

  Future<List<dynamic>> getMaterialmasterData() async {
    if (materialMaster.isNotEmpty) {
      return materialMaster;
    }

    EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
    final dio = Dio();
    final url = '${config.liveServiceUrl}wrk/getLabourMaster/0';
    final url2 = '${config.liveServiceUrl}wrk/getMaterialMaster/2/0';

    final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};

    String accessToken = await getAccessToken();
    setDioAccessokenAndApiKey(dio, accessToken, config);

    final response = await dio.get(url2, options: Options(headers: headers));

    //debugger(when: true);
    return response.data['result_data']['materialMaster'];
  }

  @override
  void initState() {
    super.initState();
    // Call your initialization method here
  }

  @override
  void dispose() {
    // Dispose any resources here
    super.dispose();
  }

  addExtraMaterialsToMeasurements() {
    Map result = {};

    result['selectedMaterials'] = selectedMaterials;
    result['taskId'] = widget.taskId;
    result['strutctureId'] = widget.structureId;
    Future.microtask(() {
      Navigator.pop(context, result);
    });
  }

  Widget separatorBuilder(BuildContext context, int index) {
    return Divider(color: Colors.red);
  }
// Import for TextInputFormatter

  Widget buildIntegerInputField({
    String labelText = '',
    required Function(String) onChanged,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      keyboardType: TextInputType.number, // Set keyboard type to number
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly // Allow only digits
      ],
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget? itemBuilder(BuildContext context, int index) {
    //print(index);

    return ListTile(
      title: Text(selectedMaterials[index]['material_name']),
      subtitle: buildIntegerInputField(
        labelText: 'Enter quantity',
        onChanged: (value) {
          selectedMaterials[index]['quantity'] = value;

          // Handle input value change
        },
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter some text';
          }
          // You can add more validation logic here if needed
          return null;
        },
      ),
      trailing: Text('UOM :' +
          selectedMaterials[index]['mst_stock_uom']['uom_descr']
              .toString()
              .toUpperCase()),
    );

    /*   trailing: Text(
          'UOM :' + selectedMaterials[index]['mst_stock_uom_id'].toString()),
    ); */
    selectedMaterials.map((e) => {print(e)});
  }

  onNewMaterialAdded() {
    print(
        'on neew material aded selectedMaterials.length ${selectedMaterials.length}');

    print(selectedMaterials[0].keys.toList());
    if (selectedMaterials.length > 0) {
      Future.microtask(() {
        setState(
          () {},
        );
      });
    }
    /*   setState(
      () {},
    ); */
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