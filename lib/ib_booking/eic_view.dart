// ─── Screen 2: EIC View & Status Update ───────────────────────────────────────
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:samagra/ib_booking/complaint_list_screen.dart';

class EicScreen extends StatefulWidget {
  const EicScreen({super.key});
  @override
  _EicScreenState createState() => _EicScreenState();
}

class _EicScreenState extends State<EicScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: apiBase));
  List<dynamic> _complaints = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _dio.get('/complaints');
    setState(() {
      _complaints = res.data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('EIC Complaints')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _complaints.length,
              itemBuilder: (c, i) {
                final cData = _complaints[i] as Map<String, dynamic>;
                return ListTile(
                  title: Text(
                      '${cData['ib']['name']} — Room ${cData['room']['room_number']}'),
                  subtitle: Text('Status: ${cData['status']}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDetail(ctx, cData),
                );
              },
            ),
    );
  }

  void _showDetail(BuildContext ctx, Map<String, dynamic> c) {
    String status = c['status'];
    final notes = TextEditingController();

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButton<String>(
            value: status,
            items: [
              'submitted',
              'fixed',
              'estimate_prepared',
              'not_found',
              'resolved'
            ]
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              if (v != null) status = v;
            },
          ),
          TextField(
            controller: notes,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _dio.patch('/complaints/${c['id']}/status',
                  data: {'status': status, 'notes': notes.text});
              Navigator.pop(ctx);
              _load();
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}