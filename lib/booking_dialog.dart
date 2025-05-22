import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:samagra/common.dart';
import 'package:samagra/local_url.dart';

class BookingDialog extends StatefulWidget {
  final DateTime selectedDay;
  final int ibId;

  const BookingDialog({
    Key? key,
    required this.selectedDay,
    required this.ibId,
  }) : super(key: key);

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  // form fields
  late DateTime fromDate, toDate;
  TimeOfDay? fromTime, toTime;
  final personsController = TextEditingController();
  final remarksController = TextEditingController();
  bool additionalBed = false;
  bool allEmployees = false;
  bool boardAccompanying = false;
  

  // meals map
  Map<DateTime, Map<String, bool>> mealsPerDay = {};

  // rooms fetched from server
  List<Map<String, dynamic>> _rooms = [];
  int? _selectedRoomId;
  bool _roomsLoading = true;
  String? _roomsError;

  final Dio _dio = Dio(BaseOptions(baseUrl: '$localUrl/api'));

  @override
  void initState() {
    super.initState();
    fromDate = widget.selectedDay;
    toDate = widget.selectedDay;
    fromTime = const TimeOfDay(hour: 14, minute: 0);
    toTime   = const TimeOfDay(hour: 10, minute: 0);
    _initializeMeals();
    _loadRooms();
  }





//int employe_code=await getUser();
  void _initializeMeals() {
    mealsPerDay.clear();
    final days = toDate.difference(fromDate).inDays;
    for (var i = 0; i <= days; i++) {
      final d = fromDate.add(Duration(days: i));
      mealsPerDay[d] = {
        'breakfast': false,
        'lunch': false,
        'dinner': false,
      };
    }
  }

  Future<void> _loadRooms() async {
    try {
      final res = await _dio.get('/ibbooking/${widget.ibId}/booked-days');
      final data = List<Map<String, dynamic>>.from(res.data);
      final rooms = data.map((e) => {
            'id': e['room_id'] as int,
            'name': e['room_number'] as String,
          }).toList();

      setState(() {
        _rooms = rooms;
        if (_rooms.isNotEmpty) _selectedRoomId = _rooms.first['id'] as int;
        _roomsLoading = false;
      });
    } catch (e) {
      // fallback dummy data
      setState(() {
        _rooms = [
          {'id': 1, 'name': 'Room 1'},
          {'id': 2, 'name': 'Room 2'},
          {'id': 3, 'name': 'Room 3'},
          {'id': 4, 'name': 'Dormitory'},
        ];
        _selectedRoomId = 1;
        _roomsError = e.toString();
        _roomsLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext ctx, bool isFrom) async {
    final initial = isFrom ? fromDate : toDate;
    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          if (fromDate.isAfter(toDate)) toDate = fromDate;
        } else {
          toDate = picked;
          if (toDate.isBefore(fromDate)) fromDate = toDate;
        }
        _initializeMeals();
      });
    }
  }

  Future<void> _selectTime(BuildContext ctx, bool isFrom) async {
    final initial = isFrom ? fromTime : toTime;
    final picked = await showTimePicker(
      context: ctx,
      initialTime: initial ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) fromTime = picked;
        else toTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedRoomId == null || personsController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    final payload = {
      'ib_id': widget.ibId,
      'ib_room_id': _selectedRoomId,
      'employee_code': 'E0123', // replace with real code from your auth
      'from_date': DateFormat('yyyy-MM-dd').format(fromDate),
      'to_date': DateFormat('yyyy-MM-dd').format(toDate),
      'arrival_time': fromTime!.format(context),
      'departure_time': toTime!.format(context),
      'num_persons': int.parse(personsController.text),
      'breakfast_needed': mealsPerDay[fromDate]!['breakfast'],
      'lunch_needed':     mealsPerDay[fromDate]!['lunch'],
      'dinner_needed':    mealsPerDay[fromDate]!['dinner'],
      'additional_bed_required': additionalBed,
      'all_employees': allEmployees,
      'board_employee_accompanying': boardAccompanying,
      'remarks': remarksController.text,
    };

    try {
      await _dio.post('/ibbooking/bookings', data: payload);
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Booking submitted')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to book: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_roomsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AlertDialog(
      title: const Text("Book Inspection Bungalow"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Date & Time pickers
            Row(children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "From Date"),
                  controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(fromDate),
                  ),
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "From Time"),
                  controller: TextEditingController(
                    text: fromTime?.format(context) ?? '',
                  ),
                  onTap: () => _selectTime(context, true),
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "To Date"),
                  controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(toDate),
                  ),
                  onTap: () => _selectDate(context, false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "To Time"),
                  controller: TextEditingController(
                    text: toTime?.format(context) ?? '',
                  ),
                  onTap: () => _selectTime(context, false),
                ),
              ),
            ]),

            // Room selector
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Select Room'),
              value: _selectedRoomId,
              items: _rooms.map((r) {
                return DropdownMenuItem<int>(
                  value: r['id'] as int,
                  child: Text(r['name'] as String),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedRoomId = v),
            ),

            // Persons
            TextField(
              controller: personsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'No. of Persons'),
            ),

            // Toggles
            SwitchListTile(
              title: const Text("Additional Bed Required"),
              value: additionalBed,
              onChanged: (v) => setState(() => additionalBed = v),
            ),
            SwitchListTile(
              title: const Text("All are KSEB Employees"),
              value: allEmployees,
              onChanged: (v) => setState(() => allEmployees = v),
            ),
            SwitchListTile(
              title: const Text("Board Employee Accompanying?"),
              value: boardAccompanying,
              onChanged: (v) => setState(() => boardAccompanying = v),
            ),

            const Divider(),
            const Text("Meals per Day", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...mealsPerDay.entries.map((e) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('EEE, dd MMM').format(e.key),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  CheckboxListTile(
                    title: const Text("Breakfast"),
                    value: e.value['breakfast'],
                    onChanged: (v) => setState(() => e.value['breakfast'] = v!),
                  ),
                  CheckboxListTile(
                    title: const Text("Lunch"),
                    value: e.value['lunch'],
                    onChanged: (v) => setState(() => e.value['lunch'] = v!),
                  ),
                  CheckboxListTile(
                    title: const Text("Dinner"),
                    value: e.value['dinner'],
                    onChanged: (v) => setState(() => e.value['dinner'] = v!),
                  ),
                  const Divider(),
                ],
              );
            }).toList(),

            // Remarks
            TextField(
              controller: remarksController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Other Requests / Remarks'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: _submitBooking, child: const Text("Submit")),
      ],
    );
  }
}
