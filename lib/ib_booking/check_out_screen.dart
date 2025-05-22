// lib/ib_booking/check_out_screen.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/local_url.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({Key? key}) : super(key: key);

  @override
  _CheckOutScreenState createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: localUrl));

  bool _loadingIbs   = true;
  bool _loadingStays = false;
  bool _submitting   = false;

  List<Map<String, dynamic>> _ibs   = [];
  int? _selectedIb;

  List<Map<String, dynamic>> _stays  = [];
  Map<String, dynamic>? _stay;  // chosen stay

  // checkout form fields
  DateTime _checkoutTime    = DateTime.now();
  final _amountCalcCtrl    = TextEditingController();
  final _amountPaidCtrl    = TextEditingController();
  String _paymentStatus     = 'pending';
  final _defectsCtrl        = TextEditingController();
  final _lossesCtrl         = TextEditingController();
  final _complaintCtrl      = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCaretakerIbs();
  }

  Future<void> _loadCaretakerIbs() async {
    try {
      //final res = await _dio.get('/api/ibbooking/ibs-for-caretaker');

      final res = await _dio.get('/api/ibbooking/ibs');
      _ibs = List<Map<String, dynamic>>.from(res.data);
      if (_ibs.isEmpty) {
        throw 'No IBs assigned';
      }
      _selectedIb = _ibs.first['id'] as int;
      await _fetchActiveStays();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading IBs: $e')),
      );
      Navigator.of(context).pop();
    } finally {
      setState(() => _loadingIbs = false);
    }
  }

  Future<void> _fetchActiveStays() async {
    if (_selectedIb == null) return;
    setState(() {
      _loadingStays = true;
      _stays = [];
      _stay  = null;
    });
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final res = await _dio.get(
        '/api/ibbooking/stays',
        // queryParameters: {
        //   'ib_id':   _selectedIb,
        //   'status': 'checked_in',
        //   'date':   today,
        // },
      );
      _stays = List<Map<String, dynamic>>.from(res.data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading stays: $e')),
      );
    } finally {
      setState(() => _loadingStays = false);
    }
  }

  Future<void> _submitCheckout() async {
    if (_stay == null) return;
    setState(() => _submitting = true);

    final payload = {
      'checkout_time':           _checkoutTime.toIso8601String(),
      'amount_calculated':       _amountCalcCtrl.text,
      'amount_prepaid':          _amountPaidCtrl.text,
      'payment_status':          _paymentStatus,
      'defects_made':            _defectsCtrl.text,
      'losses_made':             _lossesCtrl.text,
      'complaint_against_guest': _complaintCtrl.text,
    };

    try {
      final stayId = _stay!['id'];
      await _dio.put('/api/ibbooking/stays/$stayId/checkout', data: payload);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checked out successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-out failed: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingIbs) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Check-Out')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loadingStays
            ? const Center(child: CircularProgressIndicator())
            : _stay == null
                // Stage 1: Choose which stay
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IB header: either the selected IB or list all
                      Builder(builder: (_) {
                        final match = _ibs.where((i) => i['id'] == _selectedIb);
                        if (match.isNotEmpty) {
                          return Text(
                            'IB: ${match.first['name']}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assigned IBs:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ..._ibs.map((i) => Text(
                                  '• ${i['name']}',
                                  style: const TextStyle(fontSize: 14),
                                )),
                          ],
                        );
                      }),
                      const SizedBox(height: 12),
                      const Text('Select Stay to Check-Out',
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _stay,
                        hint: const Text('Pick a Stay'),
                        items: _stays.map((s) {
                          final roomNum = s['room']['room_number'];
                          final ciTime = (s['checkin_time'] as String)
                              .split('T')
                              .join(' ');
                          return DropdownMenuItem(
                            value: s,
                            child: Text('Room $roomNum @ $ciTime'),
                          );
                        }).toList(),
                        onChanged: (s) => setState(() => _stay = s),
                      ),
                    ],
                  )

                // Stage 2: Checkout form
                : ListView(
                    children: [
                      ListTile(
                        title: Text(
                            'Room: ${_stay!['room']['room_number']}'),
                        subtitle:
                            Text('Checked in at: ${_stay!['checkin_time']}'),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: const Text('Check-Out Time'),
                        subtitle: Text(_checkoutTime.toLocal().toString()),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _checkoutTime,
                            firstDate:
                                DateTime.now().subtract(const Duration(days: 7)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime:
                                  TimeOfDay.fromDateTime(_checkoutTime),
                            );
                            if (time != null) {
                              setState(() {
                                _checkoutTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountCalcCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Amount Calculated'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountPaidCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Amount Prepaid'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _paymentStatus,
                        decoration:
                            const InputDecoration(labelText: 'Payment Status'),
                        items: const [
                          DropdownMenuItem(
                              value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(
                              value: 'prepaid', child: Text('Prepaid')),
                          DropdownMenuItem(value: 'paid', child: Text('Paid')),
                        ],
                        onChanged: (v) => setState(() => _paymentStatus = v!),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _defectsCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Defects Made'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _lossesCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Losses Made'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _complaintCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Complaint Against Guest'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submitCheckout,
                        child: _submitting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Confirm Check-Out'),
                      ),
                    ],
                  ),
      ),
    );
  }
}
