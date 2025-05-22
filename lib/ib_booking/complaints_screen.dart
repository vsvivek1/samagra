import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samagra/ib_booking/complaint_list_screen.dart';
import 'package:samagra/local_url.dart';

// ─── Screen 1: File a Complaint ───────────────────────────────────────────────
class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});
  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: localUrl));

  // ── state for IB & Room dropdowns ─────────────────────────────
  List<Map<String, dynamic>> _ibs = [];
  Map<String, dynamic>? _selectedIb;
  Map<String, dynamic>? _selectedRoom;

  // ── other form state ────────────────────────────────────────────
  final TextEditingController _causeCtrl = TextEditingController();
  int _satisfaction = 3;
  final Set<String> _defects = {};
  List<File> _photos = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadIbs();
  }

  Future<void> _loadIbs() async {
    final res = await _dio.get('/api/ibbooking/ibs-with-rooms');
    // Expect each ib entry to include a `rooms` list
    setState(() => _ibs = List<Map<String, dynamic>>.from(res.data));
  }

  Future<void> _pickPhotos() async {
    final imgs = await ImagePicker().pickMultiImage();
    if (imgs != null) {
      setState(() => _photos = imgs.map((i) => File(i.path)).toList());
    }
  }

  Future<void> _submit() async {
    if (_selectedIb == null ||
        _selectedRoom == null ||
        _causeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill IB, room & cause')),
      );
      return;
    }
    setState(() => _busy = true);

    final form = FormData.fromMap({
      'ib_id': _selectedIb!['id'],
      'room_id': _selectedRoom!['id'],
      'cause': _causeCtrl.text,
      'satisfaction': _satisfaction,
      'defects': _defects.join(','),
    });
    for (var f in _photos) {
      form.files.add(
        MapEntry('photos[]',
            await MultipartFile.fromFile(f.path, filename: f.path.split('/').last)),
      );
    }

    try {
      await _dio.post('/api/ibbooking/ib-complaints', data: form);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted')),
      );
      // Optionally clear form or navigate away
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submit failed: $e')),
      );
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Complaint'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(ctx, '/eic'),
            child: const Text('EIC View', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: _ibs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // IB dropdown
                  DropdownButton<Map<String, dynamic>>(
                    value: _selectedIb,
                    hint: const Text('Select IB'),
                    items: _ibs
                        .map((ib) => DropdownMenuItem(
                              value: ib,
                              child: Text(ib['name'].toString()),
                            ))
                        .toList(),
                    onChanged: (ib) => setState(() {
                      _selectedIb = ib;
                      _selectedRoom = null;
                    }),
                  ),

                  // Room dropdown (once IB is chosen)
                  if (_selectedIb != null)
                    DropdownButton<Map<String, dynamic>>(
                      value: _selectedRoom,
                      hint: const Text('Select Room'),
                      items: List<Map<String, dynamic>>.from(_selectedIb!['rooms'])
                          .map((room) => DropdownMenuItem(
                                value: room,
                                child: Text(room['room_number'].toString()),
                              ))
                          .toList(),
                      onChanged: (r) => setState(() => _selectedRoom = r),
                    ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: _causeCtrl,
                    decoration: const InputDecoration(labelText: 'Cause of Issue'),
                  ),

                  const SizedBox(height: 12),
                  Text('Satisfaction: $_satisfaction'),
                  Slider(
                    value: _satisfaction.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (v) => setState(() => _satisfaction = v.toInt()),
                  ),

                  const SizedBox(height: 12),
                  const Text('Defects'),
                  ...['Lights', 'Plumbing', 'AC', 'Furniture', 'Socket']
                      .map((d) => CheckboxListTile(
                            title: Text(d),
                            value: _defects.contains(d),
                            onChanged: (b) => setState(() {
                              if (b == true) _defects.add(d);
                              else _defects.remove(d);
                            }),
                          )),

                  ElevatedButton(
                    onPressed: _pickPhotos,
                    child: const Text('Add Photos'),
                  ),
                  Wrap(
                    spacing: 8,
                    children: _photos
                        .map((f) => Image.file(f, width: 60, height: 60))
                        .toList(),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const CircularProgressIndicator()
                        : const Text('Submit'),
                  ),
                ],
              ),
            ),
    );
  }
}
