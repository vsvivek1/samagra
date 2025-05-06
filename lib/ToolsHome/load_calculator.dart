import 'package:flutter/material.dart';


class LoadCalculatorApp extends StatefulWidget {
  @override
  _LoadCalculatorAppState createState() => _LoadCalculatorAppState();
}

class _LoadCalculatorAppState extends State<LoadCalculatorApp> {
  List<LoadItem> loads = [LoadItem()];

  double get totalLoad {
    return loads.fold(0, (sum, item) => sum + (item.watts * item.quantity));
  }

  void addLoad() {
    setState(() {
      loads.add(LoadItem());
    });
  }

  void removeLoad(int index) {
    setState(() {
      loads.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Load Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: loads.length,
                itemBuilder: (context, index) {
                  final load = loads[index];
                  return Card(
                    color:Colors.grey,

                    borderOnForeground: true,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: load.type,
                                  onChanged: (val) {
                                    setState(() {
                                      load.type = val!;
                                      final preset = appliancePresets.firstWhere(
                                          (e) => e['type'] == val,
                                          orElse: () => {'watts': 0});
                                      load.watts =
                                          (preset['watts'] as num).toDouble();
                                    });
                                  },
                                  decoration:
                                      InputDecoration(labelText: 'Appliance'),
                                  items: appliancePresets
                                      .map((e) => DropdownMenuItem<String>(
                                            value: e['type'] as String,
                                            child: Text(e['type'] as String),
                                          ))
                                      .toList(),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: loads.length > 1
                                    ? () => removeLoad(index)
                                    : null,
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: load.watts.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: 'Watts'),
                                  onChanged: (val) {
                                    setState(() =>
                                        load.watts = double.tryParse(val) ?? 0);
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: load.quantity.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      InputDecoration(labelText: 'Quantity'),
                                  onChanged: (val) {
                                    setState(() =>
                                        load.quantity = int.tryParse(val) ?? 0);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: addLoad,
              icon: Icon(Icons.add),
              label: Text('Add Load'),
            ),
            SizedBox(height: 16),
            Text(
              'Total Load: ${totalLoad.toStringAsFixed(2)} W',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}

class LoadItem {
  String type;
  double watts;
  int quantity;

  LoadItem({this.type = 'LED Bulb', this.watts = 10, this.quantity = 1});
}

final List<Map<String, dynamic>> appliancePresets = [
  {"type": "LED Bulb", "watts": 10},
  {"type": "Tube Light (LED)", "watts": 20},
  {"type": "Ceiling Fan", "watts": 75},
  {"type": "Table Fan", "watts": 55},
  {"type": "Pedestal Fan", "watts": 65},
  {"type": "Wall Fan", "watts": 50},
  {"type": "Exhaust Fan", "watts": 45},
  {"type": "Refrigerator (Single Door)", "watts": 180},
  {"type": "Refrigerator (Double Door)", "watts": 250},
  {"type": "Mini Fridge", "watts": 90},
  {"type": "Deep Freezer", "watts": 280},
  {"type": "Television (LED)", "watts": 120},
  {"type": "CRT TV", "watts": 150},
  {"type": "Set-Top Box", "watts": 15},
  {"type": "DVD Player", "watts": 25},
  {"type": "Mobile Charger", "watts": 10},
  {"type": "Laptop Charger", "watts": 65},
  {"type": "WiFi Router", "watts": 15},
  {"type": "Modem", "watts": 10},
  {"type": "Desktop Computer", "watts": 150},
  {"type": "Monitor (LCD)", "watts": 40},
  {"type": "Printer (Inkjet)", "watts": 30},
  {"type": "Printer (Laser)", "watts": 300},
  {"type": "Scanner", "watts": 25},
  {"type": "Electric Kettle", "watts": 1800},
  {"type": "Toaster", "watts": 1000},
  {"type": "Microwave Oven", "watts": 1100},
  {"type": "Mixer Grinder", "watts": 500},
  {"type": "Juicer", "watts": 300},
  {"type": "Blender", "watts": 350},
  {"type": "Coffee Maker", "watts": 900},
  {"type": "Induction Cooktop", "watts": 1800},
  {"type": "Electric Stove", "watts": 2000},
  {"type": "Gas Stove Ignition", "watts": 5},
  {"type": "Rice Cooker", "watts": 700},
  {"type": "Electric Pressure Cooker", "watts": 1000},
  {"type": "Water Heater (Geyser)", "watts": 2000},
  {"type": "Instant Water Heater", "watts": 3000},
  {"type": "Immersion Rod", "watts": 1500},
  {"type": "Washing Machine (Top Load)", "watts": 500},
  {"type": "Washing Machine (Front Load)", "watts": 450},
  {"type": "Clothes Dryer", "watts": 1500},
  {"type": "Hair Dryer", "watts": 1200},
  {"type": "Hair Straightener", "watts": 60},
  {"type": "Hair Curler", "watts": 80},
  {"type": "Electric Iron", "watts": 1200},
  {"type": "Steam Iron", "watts": 1500},
  {"type": "Vacuum Cleaner", "watts": 1400},
  {"type": "Sewing Machine", "watts": 75},
  {"type": "Air Conditioner (1T)", "watts": 1500},
  {"type": "Air Conditioner (1.5T)", "watts": 2000},
  {"type": "Air Conditioner (2T)", "watts": 2500},
  {"type": "Cooler", "watts": 180},
  {"type": "Dehumidifier", "watts": 350},
  {"type": "Room Heater", "watts": 1500},
  {"type": "Oil Heater", "watts": 2000},
  {"type": "Electric Blanket", "watts": 200},
  {"type": "Inverter/UPS", "watts": 150},
  {"type": "Battery Charger", "watts": 100},
  {"type": "CCTV Camera", "watts": 15},
  {"type": "DVR/NVR", "watts": 30},
  {"type": "LED Strip Light", "watts": 12},
  {"type": "Chandelier", "watts": 150},
  {"type": "Smart Light", "watts": 10},
  {"type": "Smart Plug", "watts": 5},
  {"type": "Smart Speaker", "watts": 10},
  {"type": "Bluetooth Speaker", "watts": 20},
  {"type": "Soundbar", "watts": 100},
  {"type": "Home Theatre", "watts": 250},
  {"type": "Alexa/Google Home", "watts": 7},
  {"type": "Projector", "watts": 300},
  {"type": "Game Console", "watts": 150},
  {"type": "Treadmill", "watts": 2500},
  {"type": "Air Purifier", "watts": 60},
  {"type": "Water Purifier", "watts": 35},
  {"type": "Ceiling Lamp", "watts": 25},
  {"type": "Floor Lamp", "watts": 40},
  {"type": "Wall Sconce", "watts": 20},
  {"type": "Mosquito Repellent", "watts": 5},
  {"type": "Night Light", "watts": 1},
  {"type": "Table Lamp", "watts": 10},
  {"type": "Foot Massager", "watts": 100},
  {"type": "Body Massager", "watts": 120},
  {"type": "Electric Toothbrush", "watts": 3},
  {"type": "Shaver", "watts": 10},
  {"type": "Trimmer", "watts": 8},
  {"type": "Clothes Steamer", "watts": 1000},
  {"type": "Car Vacuum Cleaner", "watts": 120},
  {"type": "Aquarium Pump", "watts": 15},
  {"type": "Fountain Pump", "watts": 50},
  {"type": "Guitar Amplifier", "watts": 30},
  {"type": "Electric Drill", "watts": 500},
  {"type": "Soldering Iron", "watts": 60},
  {"type": "Glue Gun", "watts": 40},
  {"type": "Battery Light", "watts": 25},
  {"type": "Emergency Lamp", "watts": 20},
  {"type": "Recliner Motor", "watts": 150},
  {"type": "Massage Chair", "watts": 250},
  {"type": "Custom", "watts": 0},
];
