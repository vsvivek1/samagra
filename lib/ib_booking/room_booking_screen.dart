import 'package:flutter/material.dart';

class RoomBookingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> rooms;
  final Map<String, Map<String, int>> availability;

  const RoomBookingScreen({
    super.key,
    required this.rooms,
    required this.availability,
  });

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  String? selectedRoom;
  DateTime? fromDate;
  DateTime? toDate;

  Map<String, bool> foodNeeds = {
    'Breakfast': false,
    'Lunch': false,
    'Dinner': false,
  };

  final personsController = TextEditingController();
  final remarksController = TextEditingController();

  bool allAreEmployees = false;
  bool boardEmployeeAccompanying = false;
  bool additionalBedRequired = false;

  Future<void> pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          if (toDate != null && toDate!.isBefore(fromDate!)) {
            toDate = null;
          }
        } else {
          toDate = picked;
        }
      });
    }
  }

  void submitBooking() {
    if (selectedRoom == null || fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final booking = {
      'room': selectedRoom,
      'from_date': fromDate.toString(),
      'to_date': toDate.toString(),
      'food': foodNeeds.entries.where((e) => e.value).map((e) => e.key).toList(),
      'persons': personsController.text,
      'all_employees': allAreEmployees,
      'board_accompany': boardEmployeeAccompanying,
      'extra_bed': additionalBedRequired,
      'remarks': remarksController.text,
    };

    print(booking); // replace with API call later

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Booking submitted!")),
    );
  }

  @override
  void dispose() {
    personsController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Room")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Room", style: TextStyle(fontWeight: FontWeight.bold)),
            ...widget.rooms.map((room) {
              final name = room['type'] + " - ${room['beds']} beds";
              return RadioListTile<String>(
                title: Text(name),
                value: name,
                groupValue: selectedRoom,
                onChanged: (val) => setState(() => selectedRoom = val),
              );
            }),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text("From: ${fromDate != null ? "${fromDate!.day}/${fromDate!.month}" : "--"}"),
                    trailing: const Icon(Icons.date_range),
                    onTap: () => pickDate(isFrom: true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text("To: ${toDate != null ? "${toDate!.day}/${toDate!.month}" : "--"}"),
                    trailing: const Icon(Icons.date_range),
                    onTap: () => pickDate(isFrom: false),
                  ),
                ),
              ],
            ),

            const Divider(),
            const Text("Food Requirement", style: TextStyle(fontWeight: FontWeight.bold)),
            ...foodNeeds.keys.map((item) => CheckboxListTile(
                  title: Text(item),
                  value: foodNeeds[item],
                  onChanged: (val) => setState(() => foodNeeds[item] = val ?? false),
                )),

            TextField(
              controller: personsController,
              decoration: const InputDecoration(labelText: "Number of persons"),
              keyboardType: TextInputType.number,
            ),

            CheckboxListTile(
              title: const Text("All are employees"),
              value: allAreEmployees,
              onChanged: (val) => setState(() => allAreEmployees = val ?? false),
            ),
            CheckboxListTile(
              title: const Text("Board employee accompanying"),
              value: boardEmployeeAccompanying,
              onChanged: (val) => setState(() => boardEmployeeAccompanying = val ?? false),
            ),
            CheckboxListTile(
              title: const Text("Extra bed required"),
              value: additionalBedRequired,
              onChanged: (val) => setState(() => additionalBedRequired = val ?? false),
            ),

            TextField(
              controller: remarksController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Other Requests / Remarks"),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: submitBooking,
              icon: const Icon(Icons.send),
              label: const Text("Submit Booking"),
            ),
          ],
        ),
      ),
    );
  }
}
