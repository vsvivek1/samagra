// lib/ib_booking/complaint_detail_screen.dart

import 'package:flutter/material.dart';

class ComplaintDetailScreen extends StatelessWidget {
  static const routeName = '/complaintDetail';
    final Map<String, dynamic> complaint;

  const ComplaintDetailScreen({Key? key, required this.complaint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // grab the complaint map passed in
    // final complaint =widget.com
    //     ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final ib   = complaint['ib']   as Map<String, dynamic>;
    final room = complaint['room'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('IB: ${ib['name']}', style: Theme.of(context).textTheme.titleLarge),
            Text('Location: ${ib['location']}'),
            const SizedBox(height: 12),

            Text('Room #: ${room['room_number']}  (${room['room_type']})',
                style: Theme.of(context).textTheme.titleMedium),
            Text('Beds: ${room['beds']}'),
            const Divider(),

            Text('Cause of Issue', style: Theme.of(context).textTheme.titleSmall),
            Text(complaint['cause'] as String),
            const SizedBox(height: 12),

            Text('Satisfaction', style: Theme.of(context).textTheme.titleSmall),
            Text('${complaint['satisfaction']}/5'),
            const SizedBox(height: 12),

            if ((complaint['defects'] as String).isNotEmpty) ...[
              Text('Defects', style: Theme.of(context).textTheme.titleSmall),
              Text(complaint['defects'] as String),
              const SizedBox(height: 12),
            ],

            Text('Submitted on',
                style: Theme.of(context).textTheme.titleSmall),
            Text(complaint['created_at'] as String),
          ],
        ),
      ),
    );
  }
}
