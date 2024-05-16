import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/common.dart';
import 'package:samagra/screens/estimate_revision_tabs.dart';
import 'package:samagra/screens/get_login_details.dart';

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

  var estimateReport;

  var note;

  late Map<String, dynamic> consolidatedData;

  Map<String, double> materialQuantities = {};

  // Map to store labour quantities for each task, structure, and labour
  Map<String, double> labourQuantities = {};

  @override
  void initState() {
    // TODO: implement initState
    setUserData();
    super.initState();
  }

  Future<void> sendDataToServer(BuildContext context) async {
    final url = 'your_server_endpoint_here';
    final headers = {'Content-Type': 'application/json'};
    final body = 'k'; //.toJson();

    try {
      final response =
          await Dio().post(url, data: body, options: Options(headers: headers));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Data sent successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Failed to send data. Error: ${response.statusMessage}')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error sending data: $error')));
    }
  }

  setUserData() async {
    userId = await getUserId();
    seatId = await getSeatId();
    userDetails = await getUserLoginDetails();
    seatDetails = userDetails['seat_details'];
    roleId = seatDetails['role_id'];
    officeId = seatDetails['office_id'];

    consolidatedData = buildEstimateData(widget.measurementDetails);

    debugger(when: true);

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
      (location['tasks'] as List<dynamic>).forEach((task) {
        (task['structures'] as List<dynamic>).forEach((structure) {
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
            consolidatedData['estimate_data']['structures'].add(structureData);
          }

          // Materials
          (structure['materials'] as List<dynamic>).forEach((material) {
            String materialKey =
                '${task['id']}_${structure['id']}_${material['mst_material_id']}';
            if (materialQuantities.containsKey(materialKey)) {
              materialQuantities[materialKey] =
                  double.parse(material['quantity']);
            } else {
              materialQuantities[materialKey] =
                  double.parse(material['quantity']);
              Map<String, dynamic> parsedMaterial = Map.from(material);
              parsedMaterial['quantity'] = double.parse(material['quantity']);
              consolidatedData['estimate_data']['materials']
                  .add(parsedMaterial);
            }
          });

          // Labours

          if (task['labours'] != null)
            (task['labours'] as List<dynamic>).forEach((labour) {
              String labourKey =
                  '${task['id']}_${structure['id']}_${labour['mst_labour_id']}';
              Map<String, dynamic> labourData = {
                'mst_task_id': task['id'],
                'mst_structure_id': structure['id'],
                'mst_labour_id': labour['mst_labour_id'],
                'mst_uom_id': labour['mst_uom_id'],
                'labour_code': labour['labour_code'],
                'uom_code': labour['uom_code'],
                'quantity': double.parse(labour['quantity']),
                'rate': double.parse(labour['rate']),
                'supply_mode': labour['supply_mode'],
              };
              consolidatedData['estimate_data']['labours'].add(labourData);
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
              height: 2000,
              child: EstimateRevisionTabs(
                key: UniqueKey(),
                tabs: [
                  TabData(title: "Materials", content: RevisedMaterialList()),
                  TabData(title: "Labour", content: RevisedMaterialList()),
                  TabData(title: "Taken backs", content: RevisedMaterialList()),
                  TabData(
                      title: "Estimate Report",
                      content: EstimateReport(
                        onSaved: (data) {
                          return {};
                        },
                      )),
                  TabData(
                      title: "Note",
                      content: Note(onSaved: (data) => {saveNote(data)}))
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
                            Navigator.of(context).pop();
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
  }

  SaveEstimateReport(data) {}
}

class RevisedMaterialList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('hi');
    // TODO: implement build
    throw UnimplementedError();
  }
}

class Note extends StatelessWidget {
  const Note({
    super.key,
    required Set<dynamic> Function(dynamic data) onSaved,
  });

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
          ),
        ),
        Divider(),
        ElevatedButton(
          child: Text('Save Note'),
          onPressed: () {},
        )
      ],
    );
  }
}

class EstimateReport extends StatelessWidget {
  const EstimateReport({
    super.key,
    required Map Function(dynamic data) onSaved,
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
              // saveEstimateReport(data);
            })
      ],
    );
    ;
  }

  void saveEstimateReport(data) {}
}
