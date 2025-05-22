import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/local_url.dart';

class IbRoomManagementScreen extends StatefulWidget {
  const IbRoomManagementScreen({Key? key}) : super(key: key);

  @override
  _IbRoomManagementScreenState createState() => _IbRoomManagementScreenState();
}

class _IbRoomManagementScreenState extends State<IbRoomManagementScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: '$localUrl/api'));
  bool _loading = true;
  List<Map<String, dynamic>> _ibs = [];

  @override
  void initState() {
    super.initState();
    _fetchIbsWithRooms();
  }

  Future<void> _fetchIbsWithRooms() async {
    setState(() => _loading = true);
    try {
      final res = await _dio.get('/ibbooking/ibs-with-rooms');
      _ibs = List<Map<String, dynamic>>.from(res.data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load IBs: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _showRoomForm({required int ibId, Map<String, dynamic>? room}) async {
    final isNew = room == null;
    final formKey = GlobalKey<FormState>();
    String number = room?['room_number'] ?? '';
    String type = room?['room_type'] ?? 'AC';
    String beds = (room?['beds'] ?? 1).toString();
    bool hasTv = room?['has_tv'] ?? false;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isNew ? 'Add Room' : 'Edit Room'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: number,
                decoration: const InputDecoration(labelText: 'Room Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => number = v!.trim(),
              ),
              DropdownButtonFormField<String>(
                value: type,
                items: ['AC', 'NonAC', 'Dormitory']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Room Type'),
                onChanged: (v) => type = v!,
              ),
              TextFormField(
                initialValue: beds,
                decoration: const InputDecoration(labelText: 'Beds'),
                keyboardType: TextInputType.number,
                validator: (v) => int.tryParse(v!) == null ? 'Enter number' : null,
                onSaved: (v) => beds = v!,
              ),
              SwitchListTile(
                value: hasTv,
                title: const Text('Has TV'),
                onChanged: (v) => setState(() => hasTv = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              formKey.currentState!.save();
              Navigator.pop(context);

              final payload = {
                'ib_id': ibId,
                'room_number': number,
                'room_type': type,
                'beds': int.parse(beds),
                'has_tv': hasTv,
              };

              try {
                if (isNew) {
                  await _dio.post('/ibbooking/rooms', data: payload);
                } else {
                  await _dio.put('/ibbooking/rooms/${room!['id']}', data: payload);
                }
                await _fetchIbsWithRooms();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Save failed: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRoom(int roomId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Room?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _dio.delete('/ibbooking/rooms/$roomId');
      await _fetchIbsWithRooms();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IB & Room Management')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _ibs.length,
              itemBuilder: (_, i) {
                final ib = _ibs[i];
                final rooms = List<Map<String, dynamic>>.from(ib['rooms'] ?? []);
                return ExpansionTile(
                  title: Text(ib['name'] ?? 'IB #${ib['id']}'),
                  subtitle: Text('ID: ${ib['id']}'),
                  children: [
                    if (rooms.isEmpty)
                      const ListTile(title: Text('No rooms yet.')),
                    ...rooms.map((r) => ListTile(
                          title: Text(r['room_number'] ?? '—'),
                          subtitle: Text(
                              '${r['room_type']} · Beds: ${r['beds']} · TV: ${r['has_tv'] ? 'Yes' : 'No'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showRoomForm(ibId: ib['id'], room: r),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteRoom(r['id']),
                              ),
                            ],
                          ),
                        )),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _showRoomForm(ibId: ib['id']),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Room'),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
