import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:samagra/common.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/screens/estimate_revision_tabs.dart';
import 'package:samagra/screens/get_login_details.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';

class TSRevision {
  final int userId;
  final int seatId;
  final int roleId;
  final int officeId;
  final int plgWorkId;
  final String estimateReport;
  final String note;
  final List<Map<String, dynamic>> estimateData;

  TSRevision({
    required this.userId,
    required this.seatId,
    required this.roleId,
    required this.officeId,
    required this.plgWorkId,
    required this.estimateReport,
    required this.note,
    required this.estimateData,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'seat_id': seatId,
      'role_id': roleId,
      'office_id': officeId,
      'plg_work_id': plgWorkId,
      'estimate_report': estimateReport,
      'note': note,
      'estimate_data': estimateData,
    };
  }
}

class TSRevisonForm extends StatefulWidget {
  int workId;

  List<Map<dynamic, dynamic>> measurementDetails;

  TSRevisonForm(
      {required this.workId,
      required List<Map<dynamic, dynamic>> this.measurementDetails});
  @override
  _TSRevisonFormState createState() => _TSRevisonFormState();
}

class _TSRevisonFormState extends State<TSRevisonForm> {
//TSRevisonForm({required workId:this.workId});

  var userId;

  var seatId;

  late var userDetails;

  var roleId;

  var seatDetails;

  var officeId;

  var estimateReport = 'Estimate Report';

  var note = 'Note..';

  late Map<String, dynamic> consolidatedData;

  Map<dynamic, Map> materialQuantities = {};

  // Map to store labour quantities for each task, structure, and labour
  Map<dynamic, Map> labourQuantities = {};

  var plgWorkId;

  @override
  void initState() {
    // TODO: implement initState
    setUserData();
    super.initState();
  }

  Future<void> sendDataToServer(BuildContext context) async {
    EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
    // String seatId = await getSeatId();
    Dio dio = Dio();
    var accessToken = await getAccessToken();
    final headers = {'Authorization': 'Bearer $accessToken'};

    dio = setDioAccessokenAndApiKey(dio, await getAccessToken(), config);

    // final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};
    String url = "${config.liveServiceUrl}wrk/saveTSRevisionEstimate";

    var estimate_data = consolidatedData['estimate_data'];
    Map<String, dynamic> userData = {
      'user_id': userId,
      'seat_id': seatId,
      'role_id': roleId,
      'office_id': officeId,
      'plg_work_id': plgWorkId,
      'estimate_report': estimateReport,
      'note': note,
      "estimate_data": estimate_data
    };

    //debugger(when: true);

    dio = await setDioAccessokenAndApiKey(dio, await getAccessToken(), config);

    final body = jsonEncode(userData); //.toJson();

    //try {
    var response = await dio.post(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
      data: body,
    );
    //debugger(when: true);
    //debugger(when: true);
    if (response.statusCode == 200) {
      if (response.data['result_flag'] == -1) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 5),
            backgroundColor: Colors.red,
            content: Text(response.data['result_message'])));
      } else
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Data sent successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Failed to send data. Error: ${response.statusMessage}')));
    }
    /*   } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error sending data: $error')));
    }
 */
    Navigator.of(context).pop();
  }

  setUserData() async {
    userId = int.parse(await getUserId());
    plgWorkId = widget.workId;
    seatId = int.parse(await getSeatId());
    userDetails = await getUserLoginDetails();
    seatDetails = userDetails['seat_details'];
    roleId = seatDetails['role_id'];
    officeId = seatDetails['office_id'];

    consolidatedData = buildEstimateData(widget.measurementDetails);

    /* print(materialQuantities);
    print(labourQuantities); */

    setState(() {});

    //debugger(when: true);

    //debugger(when: true);

    /*  print(userDetails);
    debugger(); */
  }

/*   TSRevision tsRevision = TSRevision(
    userId:widget.workId,
    seatId:seatId,
    roleId: 1,
    officeId: 1,
    plgWorkId: 1,
    estimateReport: '',
    note: '',
    estimateData: [
      {
        'materials': [
          {
            'mst_task_id': 1,
            'mst_structure_id': 1,
            'mst_material_id': 1,
            'mst_material_status_id': 1,
            'is_return': '0',
            'mst_uom_id': 1,
            'material_code': '',
            'uom_code': '',
            'quantity': 1,
            'rate': 1,
            'supply_mode': 'KSEB',
          },
        ],
        'labours': [
          {
            'mst_task_id': 1,
            'mst_structure_id': 1,
            'mst_labour_id': 1,
            'mst_uom_id': 1,
            'labour_code': '',
            'uom_code': '',
            'quantity': [1],
            'rate': 1,
            'supply_mode': 'CONTRACTOR',
          },
        ],
        'structures': [
          {
            'mst_task_id': 1,
            'mst_structure_id': 1,
            'mst_uom_id': 1,
            'structure_code': '',
            'uom_code': '',
            'quantity': 1,
          },
        ],
        'otherCharges': [
          {
            'mst_other_charge_id': 1,
            'quantity_or_rate': 16,
          },
        ],
      },
    ],
  );
 */

  Map<String, dynamic> buildEstimateData(
      List<Map<dynamic, dynamic>> locations) {
    Map<String, dynamic> consolidatedData = {
      'estimate_data': {
        'materials': [],
        'labours': [],
        'structures': [],
        'otherCharges': [],
      }
    };

    // Map to store material quantities for each task, structure, and material

    // Iterate through locations
    locations.forEach((location) {
      if (location['tasks'] != null)
        (location['tasks'] as List<dynamic>).forEach((task) {
          var mst_task_id = task['id'];
          (task['structures'] as List<dynamic>).forEach((structure) {
            int mst_structure_id = structure['id'];
            // Check if structure is already present
            String structureKey = '${task['id']}_${structure['id']}';
            bool isStructurePresent =
                consolidatedData['estimate_data']['structures'].any((entry) =>
                    entry['mst_task_id'] == task['id'] &&
                    entry['mst_structure_id'] == structure['id']);

            if (isStructurePresent) {
              // If structure is present, increment the quantity
              consolidatedData['estimate_data']['structures']
                  .where((entry) =>
                      entry['mst_task_id'] == task['id'] &&
                      entry['mst_structure_id'] == structure['id'])
                  .forEach((existingStructure) {
                existingStructure['quantity'] += structure['quantity'];
              });
            } else {
              // If structure is not present, add it as a new entry
              Map<String, dynamic> structureData = {
                'mst_task_id': task['id'],
                'mst_structure_id': structure['id'],
                'mst_uom_id': structure['mst_uom_id'],
                'structure_code': structure['structure_code'],
                'uom_code': structure['uom_code'],
                'quantity': structure['quantity'],
              };
              consolidatedData['estimate_data']['structures']
                  .add(structureData);
            }

            // Materials
            (structure['materials'] as List<dynamic>).forEach((material) {
              String materialKey =
                  '${task['id']}_${structure['id']}_${material['mst_material_id']}';

              if (materialQuantities.containsKey(materialKey)) {
                Map<dynamic, dynamic> mat =
                    materialQuantities[materialKey] ?? {};
                mat['quantity'] =
                    mat['quantity'] + double.parse(material['quantity']);

                mat['mst_task_id'] = mst_task_id;
                mat['mst_structure_id'] = mst_structure_id;

                materialQuantities[materialKey] = mat;
                /*  materialQuantities[materialKey] =
                  double.parse(material['quantity']); */
              } else {
                Map mat = {};

                mat['material_name'] = material['material_name'];
                mat['quantity'] = double.parse(material['quantity']);
                mat['mst_task_id'] = mst_task_id;
                mat['mst_structure_id'] = mst_structure_id;

                materialQuantities[materialKey] = mat;

                Map<String, dynamic> parsedMaterial = Map.from(material);
                parsedMaterial['quantity'] = double.parse(material['quantity']);
                consolidatedData['estimate_data']['materials']
                    .add(parsedMaterial);
              }
            });

            // Labours

            (structure['labour'] as List<dynamic>).forEach((labour) {
              String labourKey =
                  '${task['id']}_${structure['id']}_${labour['id']}'; // Using 'id'

              if (labourQuantities.containsKey(labourKey)) {
                Map<dynamic, dynamic> lab = labourQuantities[labourKey] ?? {};
                lab['quantity'] = lab['quantity'] +
                    double.parse(labour['quantity'].toString());
                lab['mst_task_id'] = mst_task_id;
                lab['mst_structure_id'] = mst_structure_id;
                labourQuantities[labourKey] = lab;
                /*  labourQuantities[labourKey] =
            double.parse(labour['quantity']); */
              } else {
                Map lab = {};
                lab['mst_task_id'] = mst_task_id;
                lab['mst_structure_id'] = mst_structure_id;
                lab['labour_name'] = labour['labour_name'];
                lab['quantity'] = double.parse(labour['quantity'].toString());

                labourQuantities[labourKey] = lab;

                Map<String, dynamic> parsedLabour = Map.from(labour);
                parsedLabour['quantity'] =
                    double.parse(labour['quantity'].toString());
                //debugger(when: true);
                consolidatedData['estimate_data']['labours'].add(parsedLabour);
              }
            });

            // Other Charges

            if (task['otherCharges'] != null)
              (location['otherCharges'] as List<Map<String, dynamic>>)
                  .forEach((charge) {
                Map<String, dynamic> parsedCharge = Map.from(charge);
                parsedCharge['quantity_or_rate'] =
                    double.parse(charge['quantity_or_rate']);
                consolidatedData['estimate_data']['otherCharges']
                    .add(parsedCharge);
              });
          });
        });
    });

    // Update material quantities in the consolidated data
    consolidatedData['estimate_data']['materials'].forEach((material) {
      String materialKey =
          '${material['mst_task_id']}_${material['mst_structure_id']}_${material['mst_material_id']}';
      if (materialQuantities.containsKey(materialKey)) {
        material['quantity'] = materialQuantities[materialKey];
      }
    });

    return consolidatedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(25, 100, 50, 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('User ID: ${userId}'),
            Text('Seat ID: ${seatId}'),
            Text('Role ID: ${roleId}'),
            Text('Office ID: ${officeId}'),
            Text('PLG Work ID: ${widget.workId}'),
            Text('Estimate Report: ${estimateReport}'),
            Text('Note: ${note}'),
            SizedBox(height: 20.0),
            Divider(),
            SizedBox(
              width: 500,
              height: 400,
              child: EstimateRevisionTabs(
                key: UniqueKey(),
                tabs: [
                  TabData(
                      title: "Materials",
                      content: Builder(builder: (context) {
                        if (materialQuantities != null) {
                          return RevisedMaterialList(
                              materialQuantities: materialQuantities);
                        } else {
                          return Text('No materials');
                        }
                      })),
                  // TabData(title: "Labour", content: RevisedLabourList()),
                  TabData(
                      title: "Labour",
                      content: Builder(builder: (context) {
                        if (materialQuantities != null) {
                          return RevisedLabourList(
                              labourQuantities: labourQuantities);
                        } else {
                          return Text('No materials');
                        }
                      })),

                  /*  TabData(
                      title: "Taken backs",
                      content: Builder(builder: (context) {
                        if (materialQuantities != null) {
                          return RevisedMaterialList();
                        } else {
                          return Text('No Takenbacks');
                        }
                      })), */

                  TabData(
                      title: "Estimate Report",
                      content: EstimateReport(
                        onSaved: (data) {
                          this.estimateReport = data;

                          setState(() {});
                          return data;
                        },
                      )),
                  TabData(
                      title: "Note",
                      content: Note(
                          onSaved: (data) => {
                                debugger(when: true)
                                // saveNote(data)
                              }))
                ],
              ),
            ),
            // HeadingContainer(key: UniqueKey(), text: 'Estimate Report'),
            // Divider(),
            // HeadingContainer(key: UniqueKey(), text: 'Note'),
            Divider(),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content:
                          Text('Do you want to send this data to the server?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            sendDataToServer(context);
                            // Navigator.of(context).pop();
                          },
                          child: Text('Send'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Send Data to Server'),
            ),
          ],
        ),
      ),
    );
  }

  saveNote(data) {
    this.note = data;

    debugger(when: true);

    setState(() {});
  }

  SaveEstimateReport(data) {}
}

class RevisedLabourList extends StatelessWidget {
  final Map labourQuantities;

  RevisedLabourList({required Map this.labourQuantities});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: labourQuantities.length,
      itemBuilder: (BuildContext context, int index) {
        String labourId = labourQuantities.keys.elementAt(index);
        String labourName = labourQuantities[labourId]!['labour_name'];
        double quantity = labourQuantities[labourId]!['quantity'];

        return ListTile(
          title: Text(labourName),
          subtitle: Text('Quantity: $quantity'),
        );
      },
    );
  }
}

class RevisedMaterialList extends StatelessWidget {
  var materialQuantities;

  RevisedMaterialList({this.materialQuantities});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: materialQuantities.length,
      itemBuilder: (BuildContext context, int index) {
        String materialId = materialQuantities.keys.elementAt(index);
        String materialName = materialQuantities[materialId]['material_name'];
        double quantity = materialQuantities[materialId]['quantity'];

        return ListTile(
          title: Text(materialName),
          subtitle: Text('Quantity: $quantity'),
        );
      },
    );
  }
}

class Note extends StatelessWidget {
  Function(dynamic data) onSaved;

  Note({
    super.key,
    required Function(dynamic data) this.onSaved,
  });
  TextEditingController no = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextFormField(
            maxLines: null, // Allow unlimited lines
            keyboardType: TextInputType.multiline, // Enable multiline input
            decoration: InputDecoration(
              hintText: 'Note ...',
              border: InputBorder.none, // Hide the default border
            ),
            style: TextStyle(fontSize: 16.0),
            controller: no,
          ),
        ),
        Divider(),
        ElevatedButton(
          child: Text('Save Note'),
          onPressed: () {
            print(no.text);

            debugger(when: true);
            //onSaved(no.text);

            debugger(when: true);
          },
        )
      ],
    );
  }
}

class EstimateReport extends StatelessWidget {
  TextEditingController er = new TextEditingController();

  String Function(dynamic data) onSaved;

  EstimateReport({
    super.key,
    required String Function(dynamic data) this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(75.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextFormField(
            controller: er,
            maxLines: null, // Allow unlimited lines
            keyboardType: TextInputType.multiline, // Enable multiline input
            decoration: InputDecoration(
              hintText: 'Estimate report ...',
              border: InputBorder.none, // Hide the default border
            ),
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        Divider(),
        ElevatedButton(
            child: Text('Save Estimate report'),
            onPressed: () {
              //print(er.text);
              onSaved(er.text);
            })
      ],
    );
    ;
  }
}
