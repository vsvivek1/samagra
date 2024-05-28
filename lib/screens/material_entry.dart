import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:samagra/common.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/screens/search_material.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';

class MaterialEntry extends StatefulWidget {
  List<Map<dynamic, dynamic>> tasks;
  Function reflectQuantityDetails;
  Map<int, Map<dynamic, dynamic>> estimatedQuantityOfmaterials;
  var measurementDetails;

  var taskId;

  var structureId;

  var mst_scheme_id;

  MaterialEntry(
      {required this.tasks,
      required this.reflectQuantityDetails,
      required this.estimatedQuantityOfmaterials,
      required this.measurementDetails,
      required this.taskId,
      required this.structureId,
      required this.mst_scheme_id});

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
                  onNewMaterialAdded: (item) => {onNewMaterialAdded(item)},
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
    final url2 = '${config.liveServiceUrl}wrk/getMaterialMaster/3/0';

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

    Navigator.pop(context, result);
    /* Future.microtask(() {
     
    }) */
    ;
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
      trailing: Column(
        children: [
          Text('UOM :' +
              selectedMaterials[index]['mst_stock_uom']['uom_descr']
                  .toString()
                  .toUpperCase()),
          Text(
              style: TextStyle(
                color: selectedMaterials[index]['stock'] > 0
                    ? Colors.green
                    : Colors.red,
                fontSize: 13,
              ),
              'Stock Qty:\n${selectedMaterials[index]['stock']}'),
          
          
          IconButton(onPressed: (() {
            _removeSelectedItem(index);
          }), icon: Icon(Icons.delete())
          // Text("${selectedMaterials[index]['stock']} x")
        ],
      ),
    );

    /*   trailing: Text(
          'UOM :' + selectedMaterials[index]['mst_stock_uom_id'].toString()),
    ); */
    selectedMaterials.map((e) => {print(e)});
  }

  Future getStockPosition(mstMaterialId) async {
    // try {
    Map userDetails = await getUserLoginDetailsMap();

    var officeId = userDetails['seat_details']['office_id'] ?? -1;

    EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
    final dio = Dio();
    // mstMaterialId = 2659;
    final url2 =
        '${config.liveServiceUrl}wrk/getStockPosition/${officeId}/${widget.mst_scheme_id}/${mstMaterialId}';

    final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};

    String accessToken = await getAccessToken();
    setDioAccessokenAndApiKey(dio, accessToken, config);
    Response response = await dio.get(url2);

    if (response.statusCode == 200 && response.data['result_flag'] == 1) {
      var responseDataResultData = response.data['result_data'];

      //debugger(when: true);
      List<dynamic> materialsData = responseDataResultData['materials'];
      List<dynamic> alternateMaterialsData =
          responseDataResultData['alternate_materials'];

      var materials = materialsData
          .where(
              (material) => [1, 2, 4, 5].contains(material['materialStatusId']))
          .toList()
          .map((m) => m['qty'] ?? 0 - m['allocated_qty'] ?? 0);

      var alternateMaterials = alternateMaterialsData
          .where(
              (material) => [1, 2, 4, 5].contains(material['materialStatusId']))
          .toList()
          .map((m) => m['qty'] ?? 0 - m['allocated_qty'] ?? 0);

      List combinedList = [...materials, ...alternateMaterials];

      if (combinedList.isEmpty) {
        return 0;
      }
      //debugger(when: true);
      return combinedList.reduce((value, element) => value + element);
    } else {
      return 0;
    }
  }

  onNewMaterialAdded(data) async {
    var a = await getStockPosition(data['id']);

    var mat = selectedMaterials.firstWhere(
      (element) {
        return element['id'] == data['id'];
      },
      orElse: () {
        return {};
      },
    );
    if (mat.isEmpty || a == 0) {
      mat['stock'] = 0;
    } else {
      mat['stock'] = a;
    }

    // return;
    //debugger(when: true);

    /*
    print(
        'on neew material aded selectedMaterials.length ${selectedMaterials.length}');

    print(selectedMaterials[0].keys.toList());
 */
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
  
  void _removeSelectedItem(int index) {

    
  }
}
