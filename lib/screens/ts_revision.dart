import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/common.dart';
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

  TSRevisonForm({required this.workId});
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

  var plgWorkId;

  var note;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('User ID: ${userId}'),
            Text('Seat ID: ${seatId}'),
            Text('Role ID: ${roleId}'),
            Text('Office ID: ${officeId}'),
            Text('PLG Work ID: ${plgWorkId}'),
            Text('Estimate Report: ${estimateReport}'),
            Text('Note: ${note}'),
            SizedBox(height: 20.0),
            Divider(),
            EstimateReport(),
            Divider(),
            Note(),
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
}

class Note extends StatelessWidget {
  const Note({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(100.0),
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
    );
  }
}

class EstimateReport extends StatelessWidget {
  const EstimateReport({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(100.0),
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
    );
    ;
  }
}
