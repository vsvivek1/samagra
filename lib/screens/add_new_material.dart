import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:samagra/common.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/kseb_color.dart';
import 'package:samagra/screens/searchable_dropdown.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:samagra/secure_storage/secure_storage.dart';

class AddNewMaterial extends StatefulWidget {
  final List<Map<dynamic, dynamic>> tasks;
  final Function reflectQuantityDetails;
  final Map<int, Map<dynamic, dynamic>> estimatedQuantityOfmaterials;
  var measurementDetails;

  AddNewMaterial({
    required this.tasks,
    required this.reflectQuantityDetails,
    required this.estimatedQuantityOfmaterials,
    required this.measurementDetails,
  });

  @override
  _AddNewMaterialState createState() => _AddNewMaterialState();
}

class _AddNewMaterialState extends State<AddNewMaterial> {
  List<MaterialEntry> materialEntries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Material')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Displaying existing rows
          for (var entry in materialEntries) entry,
          // Button to add new row
          ElevatedButton(
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
          ),
        ],
      ),
    );
  }
}

class MaterialEntry extends StatefulWidget {
  List<Map<dynamic, dynamic>> tasks;
  final Function reflectQuantityDetails;
  final Map<int, Map<dynamic, dynamic>> estimatedQuantityOfmaterials;
  var measurementDetails;

  MaterialEntry({
    required this.tasks,
    required this.reflectQuantityDetails,
    required this.estimatedQuantityOfmaterials,
    required this.measurementDetails,
  });

  @override
  _MaterialEntryState createState() => _MaterialEntryState();
}

class _MaterialEntryState extends State<MaterialEntry> {
  var materials = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /*   var a = getMaterialmasterDataFromSecureStorage(); */
  }

  String selectedMaterial = '1'; // Set a valid initial value
  String quantity = '';

  List materialMaster = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getMaterialmasterData(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!(snapshot.hasData)) {
            return Center(
              child: SpinKitFadingCube(color: ksebColor),
              // child: CircularProgressIndicator(
              //   backgroundColor: Colors.grey,
              //   strokeWidth: 5.0,
              //   valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              // ),
            );
          }
          print(snapshot);

          materialMaster = snapshot.data;
          //  debugger(when: true);
          return Row(
            children: [
              // Selectable field for materials
              Expanded(
                child: dropDownButton(),
              ),
              // Field to enter quantity
              SizedBox(width: 10),
              // Field to enter quantity
              SizedBox(width: 10),
              Expanded(
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
            ],
          );
        });
  }

  SizedBox dropDownButton() {
    return SizedBox(
                height: 10,
                child: DropdownButton<String>(
                  value: selectedMaterial,
                  items: convertToDropdownItems(materialMaster),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMaterial = newValue!;
                    });
                  },
                ),

                /* child: SearchableDropdown(
                  items: materials,
                  onChanged: (newValue) {
                    setState(() {
                      selectedMaterial = newValue;
                    });
                  },
                ) */
              );
  }

  List<DropdownMenuItem<String>> convertToDropdownItems(List<dynamic> items) {
    int c = 1;
    return items.skipWhile(
      (value) {
        return (value == null || value['material_name'] == null);
      },
    ).map((
      item,
    ) {
      c++;
      return DropdownMenuItem<String>(
        // value: item['material_name']

        value: c.toString(), // Assuming each item can be converted to a string
        child:
            Text(item['material_name'].toString()), // Display the item as text
      );
    }).toList();
  }

  getMaterialmasterData() async {
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

    // print(url);

    // debugger(when: true);
    final response = await dio.get(url2, options: Options(headers: headers));

    return response.data['result_data']['materialMaster'];
    debugger(when: true);
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