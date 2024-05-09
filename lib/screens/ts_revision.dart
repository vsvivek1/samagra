import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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

  Future<void> sendDataToServer(BuildContext context) async {
    final url = 'your_server_endpoint_here';
    final headers = {'Content-Type': 'application/json'};
    final body = toJson();

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
}

class TSRevisonForm extends StatefulWidget {
  @override
  _TSRevisonFormState createState() => _TSRevisonFormState();
}

class _TSRevisonFormState extends State<TSRevisonForm> {
  TSRevision tsRevision = TSRevision(
    userId: 1,
    seatId: 1,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('User ID: ${tsRevision.userId}'),
            Text('Seat ID: ${tsRevision.seatId}'),
            Text('Role ID: ${tsRevision.roleId}'),
            Text('Office ID: ${tsRevision.officeId}'),
            Text('PLG Work ID: ${tsRevision.plgWorkId}'),
            Text('Estimate Report: ${tsRevision.estimateReport}'),
            Text('Note: ${tsRevision.note}'),
            SizedBox(height: 20.0),
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
                            tsRevision.sendDataToServer(context);
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
