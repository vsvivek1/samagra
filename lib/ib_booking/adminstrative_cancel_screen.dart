import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:samagra/local_url.dart';

class AdministrativeCancelScreen extends StatefulWidget {
  final List<int> caretakerIbIds;
  const AdministrativeCancelScreen({Key? key, this.caretakerIbIds = const []})
      : super(key: key);

  @override
  _AdministrativeCancelScreenState createState() =>
      _AdministrativeCancelScreenState();
}

class _AdministrativeCancelScreenState
    extends State<AdministrativeCancelScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: '${localUrl}/api'));
  bool _loadingIbs = true, _loadingBookings = false;
  String? _error;
  List<Map<String, dynamic>> _ibs = [];
  int? _selectedIbId;
  Map<String, List<Map<String, dynamic>>> _groupedBookings = {};
  final _fmt = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _fetchIbs();
  }

  Future<void> _fetchIbs() async {
    setState(() {
      _loadingIbs = true;
      _error = null;
    });
    try {
      final resp = await _dio.get('/ibbooking/ibs');
      var ibs = List<Map<String, dynamic>>.from(resp.data);
      if (widget.caretakerIbIds.isNotEmpty) {
        ibs = ibs
            .where((ib) => widget.caretakerIbIds.contains(ib['id'] as int))
            .toList();
      }
      setState(() {
        _ibs = ibs;
        if (ibs.length == 1) _selectedIbId = ibs.first['id'] as int;
        _loadingIbs = false;
      });
      if (_selectedIbId != null) _fetchBookings();
    } catch (e) {
      setState(() {
        _error = 'Failed to load IBs: $e';
        _loadingIbs = false;
      });
    }
  }

  Future<void> _fetchBookings() async {
    if (_selectedIbId == null) return;
    setState(() {
      _loadingBookings = true;
      _error = null;
    });
    try {
      final resp =
          await _dio.get('/ibbooking/bookings/future/$_selectedIbId');
      final raw = List<Map<String, dynamic>>.from(resp.data);
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (var b in raw) {
        final d = b['from_date'] as String;
        grouped.putIfAbsent(d, () => []).add(b);
      }
      setState(() {
        _groupedBookings = grouped;
        _loadingBookings = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load bookings: $e';
        _loadingBookings = false;
      });
    }
  }

  Future<void> _cancelBooking(int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Cancellation'),
        content:
            const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _dio.delete('/ibbooking/bookings/$bookingId');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Booking cancelled')));
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingIbs) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Administrative Cancelling')),
        body: Center(child: Text(_error!)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Administrative Cancelling')),
      body: Column(
        children: [
          if (_ibs.length > 1)
            Padding(
              padding: const EdgeInsets.all(8),
              child: DropdownButton<int>(
                value: _selectedIbId,
                hint: const Text('Select IB'),
                isExpanded: true,
                items: _ibs.map((ib) {
                  return DropdownMenuItem<int>(
                    value: ib['id'] as int,
                    child: Text(ib['name'] as String),
                  );
                }).toList(),
                onChanged: (id) {
                  setState(() => _selectedIbId = id);
                  _fetchBookings();
                },
              ),
            ),
          Expanded(
            child: _loadingBookings
                ? const Center(child: CircularProgressIndicator())
                : _groupedBookings.isEmpty
                    ? const Center(child: Text('No future bookings'))
                    : ListView(
                        children:
                            _groupedBookings.entries.map((entry) {
                          final header =
                              _fmt.format(DateTime.parse(entry.key));
                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                child: Text(header,
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold)),
                              ),
                              ...entry.value.map((b) {
                                final from = _fmt.format(
                                    DateTime.parse(
                                        b['from_date']));
                                final to = _fmt.format(
                                    DateTime.parse(b['to_date']));
                                return ListTile(
                                  title:
                                      Text(b['employee_name'] ?? 'KSEB EMPLOYEE'
                                          as String),
                                  subtitle: Text(
                                    'Room ${b['ib_room_id']}\n'
                                    'From $from to $to\n'
                                    'Arr: ${b['arrival_time']}  Dep: ${b['departure_time']}\n'
                                    'Persons: ${b['num_persons']}',
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(b['status']
                                          as String),
                                      TextButton(
                                        onPressed: () =>
                                            _cancelBooking(
                                                b['id']
                                                    as int),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color:
                                                  Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const Divider(height: 1),
                            ],
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }
}
