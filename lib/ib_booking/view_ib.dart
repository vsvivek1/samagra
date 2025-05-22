import 'dart:math';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:samagra/ib_booking/add_ib_screen.dart';
import 'package:samagra/ib_booking/ib-calender_view_widget.dart';

class ViewIbScreen extends StatefulWidget {
  final Map<String, dynamic> ibData;

  const ViewIbScreen({super.key, required this.ibData});

  @override
  State<ViewIbScreen> createState() => _ViewIbScreenState();
}

class _ViewIbScreenState extends State<ViewIbScreen> {
  late Map<String, dynamic> ib;
  late List<Map<String, dynamic>> rooms;
  late Map<String, Map<String, int>> availabilityByDate;

  final List<String> dummyImages = [
    'https://cdn.pixabay.com/photo/2016/11/29/10/07/hotel-1867768_960_720.jpg',
    'https://cdn.pixabay.com/photo/2016/11/22/07/09/hotel-room-1841297_960_720.jpg',
    'https://cdn.pixabay.com/photo/2017/08/06/09/56/hotel-2592177_960_720.jpg',
    'https://cdn.pixabay.com/photo/2020/01/17/17/53/bedroom-4774532_960_720.jpg',
    'https://cdn.pixabay.com/photo/2017/09/01/08/52/hotel-2707564_960_720.jpg',
  ];

  @override
  void initState() {
    super.initState();
    ib = widget.ibData;
    rooms = getDummyRooms();
    availabilityByDate = getDummyAvailability();
  }

  List<Map<String, dynamic>> getDummyRooms() {
    return [
      {'type': 'AC', 'beds': 2, 'facilities': ['TV', 'Wi-Fi', 'Hot Water']},
      {'type': 'Non-AC', 'beds': 3, 'facilities': ['Fan', 'Table']},
      {'type': 'Dormitory', 'beds': 10, 'facilities': ['Shared Toilet']},
    ];
  }

  Map<String, Map<String, int>> getDummyAvailability() {
    final today = DateTime.now();
    final map = <String, Map<String, int>>{};
    for (int i = 0; i < 15; i++) {
      final date = today.add(Duration(days: i));
      final key = "${date.year}-${_pad(date.month)}-${_pad(date.day)}";
      map[key] = {
        'AC': Random().nextInt(4),
        'NonAC': Random().nextInt(5),
        'Dorm': Random().nextInt(3),
      };
    }
    return map;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Widget buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View IB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddIbScreen(ibData: ib)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IB Info
            Text(ib['name'] ?? 'No Name', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("📍 ${ib['location'] ?? 'Unknown'}"),
            Text("🏠 ${ib['address'] ?? ''}"),
            Text("📞 ${ib['phone'] ?? ''}"),
            Text("📫 ${ib['pincode'] ?? ''}"),
            Text("🌍 ${ib['district'] ?? ''}"),

            const Divider(height: 32),

            /// Availability Legends
            const Text("📅 Availability Legend", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 20,
              runSpacing: 6,
              children: [
                buildLegend('🟥 Fully Booked', Colors.red.shade300),
                buildLegend('🟨 Partially Booked', Colors.yellow.shade300),
                buildLegend('🟩 Mostly Available', Colors.green.shade300),
                buildLegend('🔵 AC Available', Colors.blue),
                buildLegend('🟠 Non-AC Available', Colors.amber),
                buildLegend('🟤 Dorm Available', Colors.brown),
              ],
            ),

            const SizedBox(height: 20),
            const Text("📅 Room Availability Calendar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 600,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: IbCalendarView(ibId: 1),
            ),

            const Divider(height: 32),

            /// Image Carousel
            const Text("🏞 IB Images", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
          SizedBox(
  height: 400,
  child: CarouselSlider(
    options: CarouselOptions(
      height: 300,
      autoPlay: true,
      enlargeCenterPage: true,
    ),
    items: List.generate(13, (index) => 'assets/ib/${index + 1}.jpeg')
        .map((assetPath) {
      return Builder(
        builder: (BuildContext context) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image)),
            ),
          );
        },
      );
    }).toList(),
  ),
),

            const Divider(height: 32),

            /// Room Details
            const Text("🛏 Room Types", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...rooms.map((room) => Card(
                  child: ListTile(
                    leading: Icon(
                      room['type'] == 'AC'
                          ? Icons.ac_unit
                          : room['type'] == 'Dormitory'
                              ? Icons.groups
                              : Icons.bed,
                    ),
                    title: Text("${room['type']} Room - ${room['beds']} bed(s)"),
                    subtitle: Text("Facilities: ${room['facilities'].join(', ')}"),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
