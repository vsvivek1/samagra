import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/local_url.dart';

class CheckInScreen extends StatefulWidget {
  /// If coming from a booking, pass its ID, IB and room here.
  final int? bookingId;
  final int? ibId;
  final int? roomId;

  const CheckInScreen({
    Key? key,
    this.bookingId,
    this.ibId,
    this.roomId,
  }) : super(key: key);

  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: localUrl));

  bool _loading = true;
  bool _submitting = false;

  // dropdown data
  List<Map<String, dynamic>> _ibs = [];
  List<Map<String, dynamic>> _rooms = [];

  // selected values
  int? _selectedIb;
  int? _selectedRoom;

  // form controllers
  final TextEditingController _bookingCtrl    = TextEditingController();
  final TextEditingController _guestIdCtrl    = TextEditingController();
  final TextEditingController _empNumCtrl     = TextEditingController();
  bool _isFreshUp = false;

  @override
  void initState() {
    super.initState();
    // prefill booking ID
    _bookingCtrl.text = widget.bookingId?.toString() ?? 'Auto';
    _loadIbs();
  }

  Future<void> _loadIbs() async {
    final res = await _dio.get('/api/ibbooking/ibs');
    _ibs = List<Map<String, dynamic>>.from(res.data);
    _selectedIb = widget.ibId ?? _ibs.first['id'];
    setState(() => _loading = false);
    if (_selectedIb != null) _loadRooms(_selectedIb!);
  }

  Future<void> _loadRooms(int ibId) async {
    final res = await _dio.get('/api/ibbooking/ibs-with-rooms');
    final ib = (res.data as List).cast<Map<String, dynamic>>()
      .firstWhere((e) => e['id'] == ibId);
    _rooms = List<Map<String, dynamic>>.from(ib['rooms']);
    _selectedRoom = widget.roomId ?? (_rooms.isNotEmpty ? _rooms.first['id'] : null);
    setState(() {});
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final payload = {
      'booking_id':   widget.bookingId,
      'ib_id':        _selectedIb,
      'room_id':      _selectedRoom,
      'guest_id':     _guestIdCtrl.text,
      'employee_no':  _empNumCtrl.text,
      'is_freshup':   _isFreshUp ? 1 : 0,
    };
    try {
      await _dio.post('/api/ibbooking/stays', data: payload);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checked in successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-in failed: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _bookingCtrl,
              decoration: const InputDecoration(labelText: 'Booking ID'),
              enabled: false,
            ),

            const SizedBox(height: 12),
         DropdownButtonFormField<int>(
  value: _selectedIb,
  decoration: const InputDecoration(labelText: 'Select IB'),
  items: _ibs.map((ib) {
    return DropdownMenuItem<int>(
      value: ib['id'] as int,
      child: Text(ib['name'] as String),
    );
  }).toList(),
  onChanged: (v) {
    if (v == null) return;
    setState(() {
      _selectedIb = v;
      _selectedRoom = null;   // clear the previously selected room
    });
    _loadRooms(v);
  },
),

            const SizedBox(height: 12),
         DropdownButtonFormField<int>(
  value: _rooms.any((r) => r['id'] == _selectedRoom)
      ? _selectedRoom
      : null,
  hint: const Text('Select Room'),
  decoration: const InputDecoration(labelText: 'Room'),
  items: _rooms.map((r) {
    final roomId = r['id'] as int;                      // cast to int
    final number = r['room_number'].toString();
    final type   = r['room_type'].toString();
    return DropdownMenuItem<int>(
      value: roomId,
      child: Text('$number ($type)'),
    );
  }).toList(),
  onChanged: (newId) {
    setState(() {
      _selectedRoom = newId;
    });
  },
),

            const SizedBox(height: 12),
            TextField(
              controller: _guestIdCtrl,
              decoration: const InputDecoration(labelText: 'Guest ID Card No.'),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _empNumCtrl,
              decoration: const InputDecoration(labelText: 'Employee Number'),
            ),

            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Fresh-Up Service?'),
              value: _isFreshUp,
              onChanged: (v) => setState(() => _isFreshUp = v),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm Check-In'),
            ),
          ],
        ),
      ),
    );
  }
}
