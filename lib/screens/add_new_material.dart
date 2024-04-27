import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:samagra/common.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/kseb_color.dart';
import 'package:samagra/screens/material_list_widget.dart';
import 'package:samagra/screens/searchable_dropdown.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:samagra/secure_storage/secure_storage.dart';
import 'package:gap/gap.dart';

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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Add New Material')),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
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
                  child: Placeholder(),
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

  Widget materialList(List materialList) {
    String userText = '';
    List filteredMaterialMaster = materialMaster;

    print(filteredMaterialMaster);
    print('filteredMaterialMaster');

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 300,
              height: 100,
              child: TextField(
                onChanged: (value) {
                  userText = value;
                  print('hi');
                },
                decoration: InputDecoration(
                  hintText: 'Search Material',
                  suffixIcon: IconButton(
                    onPressed: () {
                      // searchMaterial(filteredMaterialMaster, userText);
                    },
                    icon: Icon(Icons.search),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width * .8,
          height: 300,
          child: ListView.builder(
            itemCount: filteredMaterialMaster.length,
            itemBuilder: (BuildContext context, int index) {
              var item = filteredMaterialMaster[index];
              return ListTile(
                selected: item['selected'] == true,
                selectedTileColor: Colors.red,
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.select_all_sharp),
                ),
                title: Text(item['material_name'].toString()),
                onTap: () {
                  // selectMaterial(item, index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<dynamic> searchMaterial(
      List<dynamic> filteredMaterialMaster, String value) {
    setState(() {
      filteredMaterialMaster = materialMaster
          .where((material) => material['material_name']
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
    return filteredMaterialMaster;
  }

  void selectMaterial(item, int index) {
    setState(() {
      item['selected'] = item['selected'] ?? false;
      item['selected'] = !item['selected'];
      selectedMaterial = (index + 1).toString();
    });
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

class SearchMaterial extends StatelessWidget {
  const SearchMaterial({
    super.key,
    required this.materialMaster,
    required this.selectedMaterials,
  });

  final List materialMaster;
  final List selectedMaterials;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
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
          )),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * .9,
        height: MediaQuery.sizeOf(context).height * .3,
        child: MaterialListWidget(
          materialMaster: materialMaster,
          key: UniqueKey(),
          selectedMaterials: selectedMaterials,
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