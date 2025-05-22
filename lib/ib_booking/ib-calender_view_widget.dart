import 'package:flutter/material.dart';
import 'package:samagra/booking_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';
import 'package:samagra/local_url.dart';

class IbCalendarView extends StatefulWidget {
  final int ibId;
  const IbCalendarView({Key? key, required this.ibId}) : super(key: key);

  @override
  State<IbCalendarView> createState() => _IbCalendarViewState();
}

class _IbCalendarViewState extends State<IbCalendarView> {
  final Dio dio = Dio(BaseOptions(baseUrl: '$localUrl/api'));
  bool _loading = true;
  String? _error;

  // roomId → set of booked dates
  final Map<int, Set<DateTime>> _bookedByRoom = {};
  List<Map<String, dynamic>> _rooms = [];
  int? _selectedRoomId;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  


  @override
  void initState() {
    super.initState();
    _loadBookedDays();
  }

  Future<void> _loadBookedDays() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final resp = await dio.get('/ibbooking/${widget.ibId}/booked-days');
      final data = List<Map<String, dynamic>>.from(resp.data);

      final rooms = <Map<String, dynamic>>[];
      final bookedMap = <int, Set<DateTime>>{};

      for (final entry in data) {
        final roomId = entry['room_id'] as int;
        final roomNumber = entry['room_number'] as String;
        rooms.add({'id': roomId, 'number': roomNumber});

        final ranges = (entry['booked'] as List).cast<Map<String, dynamic>>();
        final dates = <DateTime>{};
        for (final r in ranges) {
          var from = DateTime.parse(r['from']);
          var to = DateTime.parse(r['to']);
          for (var d = from; !d.isAfter(to); d = d.add(const Duration(days: 1))) {
            dates.add(DateTime(d.year, d.month, d.day));
          }
        }
        bookedMap[roomId] = dates;
      }

      setState(() {
        _rooms = rooms;
        _bookedByRoom
          ..clear()
          ..addAll(bookedMap);
        _selectedRoomId = rooms.isNotEmpty ? rooms.first['id'] as int : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _dot(Color c) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot(Colors.blue), const Text(' AC  '),
          _dot(Colors.amber), const Text(' Non-AC  '),
          _dot(Colors.brown), const Text(' Dorm'),
        ],
      ),
    );
  }

  void _showBookingDialog(DateTime day,ibId) {
    showDialog(
      context: context,
      builder: (_) =>  BookingDialog(selectedDay:day,ibId:widget.ibId),
    );
  }

  Widget _dayBuilder(BuildContext ctx, DateTime day, DateTime _) {
    final d = DateTime(day.year, day.month, day.day);
    final bookedDates = _selectedRoomId != null
        ? _bookedByRoom[_selectedRoomId] ?? {}
        : <DateTime>{};
    final isBooked = bookedDates.contains(d);

    final dots = !isBooked
        ? <Widget>[
            _dot(Colors.blue),
            _dot(Colors.amber),
            _dot(Colors.brown),
          ]
        : <Widget>[];

    return Container(
      decoration: BoxDecoration(
        color: isBooked ? Colors.red.shade200 : Colors.green.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${day.day}', style: const TextStyle(fontSize: 12)),
          if (dots.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: dots,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error loading data:\n$_error'));
    }

    return Column(
      children: [
        // Room selector
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<int>(
            value: _selectedRoomId,
            isExpanded: true,
            hint: const Text('Select a room'),
            items: _rooms.map((r) {
              return DropdownMenuItem<int>(
                value: r['id'] as int,
                child: Text('Room ${r['number']}'),
              );
            }).toList(),
            onChanged: (rid) => setState(() {
              _selectedRoomId = rid;
            }),
          ),
        ),

        // Legend
        _buildLegend(),

        // Calendar
        Expanded(
          child: TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 5)),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            onDaySelected: (sel, focus) {
              setState(() {
                _selectedDay = sel;
                _focusedDay = focus;
              });
              _showBookingDialog(sel,widget.ibId);
            },
            onPageChanged: (newFocused) {
              setState(() {
                _focusedDay = newFocused;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: const CalendarStyle(
              cellMargin: EdgeInsets.zero,
              isTodayHighlighted: true,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: _dayBuilder,
            ),
          ),
        ),
      ],
    );
  }
}
