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

          MaterialEntry(
              tasks: widget.tasks,
              reflectQuantityDetails: widget.reflectQuantityDetails,
              estimatedQuantityOfmaterials: widget.estimatedQuantityOfmaterials,
              measurementDetails: widget.measurementDetails)
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
            child: SpinKitFadingCube(color: Colors.blue), // Use your color here
          );
        }
        print(snapshot);
        materialMaster = snapshot.data;
        return Row(
          children: [
            // List of ListTile for materials
            SizedBox(height: 200, child: materialList(materialMaster)),
            SizedBox(width: 10),
            // Field to enter quantity
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
      },
    );
  }

  Widget materialList(List materialList) {
    List filteredMaterialMaster = [];
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 100,
          child: TextField(
            onChanged: (value) {
              setState(() {
                filteredMaterialMaster = materialMaster
                    .where((material) => material['material_name']
                        .toString()
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              });
            },
            /*  decoration: InputDecoration(
              hintText: 'Search Material',
            ), */
          ),
        ),
        SizedBox(
          width: 100,
          height: 200,
          child: ListView.builder(
            itemCount: filteredMaterialMaster.length,
            itemBuilder: (BuildContext context, int index) {
              var item = filteredMaterialMaster[index];
              return ListTile(
                title: Text(item['material_name'].toString()),
                onTap: () {
                  setState(() {
                    selectedMaterial = (index + 1).toString();
                  });
                },
              );
            },
          ),
        ),
      ],
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