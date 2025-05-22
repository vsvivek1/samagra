import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:samagra/local_url.dart';

class ViewMyBookingsScreen extends StatefulWidget {
  final String employeeCode;
  const ViewMyBookingsScreen({Key? key, required this.employeeCode})
      : super(key: key);

  @override
  State<ViewMyBookingsScreen> createState() => _ViewMyBookingsScreenState();
}

class _ViewMyBookingsScreenState extends State<ViewMyBookingsScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: '${localUrl}/api'));
  bool _loading = true;
  String? _error;
  Map<String, List<Map<String, dynamic>>> _grouped = {};
  final _fmt = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _fetchMyBookings();
  }

  Future<void> _fetchMyBookings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await _dio.get(
        '/ibbooking/bookings/employee/${widget.employeeCode}',
      );
      final raw = List<Map<String, dynamic>>.from(resp.data);
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (var b in raw) {
        final d = b['from_date'] as String;
        grouped.putIfAbsent(d, () => []).add(b);
      }
      setState(() {
        _grouped = grouped;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load your bookings: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _grouped.isEmpty
                  ? const Center(child: Text('You have no future bookings'))
                  : ListView(
                      children: _grouped.entries.map((entry) {
                        final header =
                            _fmt.format(DateTime.parse(entry.key));
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              color: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Text(header,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                            ...entry.value.map((b) {
                              final from = _fmt.format(
                                  DateTime.parse(b['from_date']));
                              final to = _fmt.format(
                                  DateTime.parse(b['to_date']));
                              return ListTile(
                                title: Text(
                                  'Room ${b['ib_room_id']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'From $from to $to\n'
                                  'Arr: ${b['arrival_time']}  Dep: ${b['departure_time']}\n'
                                  'Persons: ${b['num_persons']}',
                                ),
                                trailing: Text(
                                  b['status'] as String,
                                  style: TextStyle(
                                    color: b['status'] == 'cancelled'
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              );
                            }).toList(),
                            const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                    ),
    );
  }
}
