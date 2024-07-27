import 'package:flutter/material.dart';

class UtilitiesScreen extends StatelessWidget {
  final List<Utility> utilities = [
    Utility(icon: Icons.work, label: 'TA', route: '/ta'),
    Utility(
        icon: Icons.calculate,
        label: 'Power Calc',
        route: '/power_calculations'),
    Utility(
        icon: Icons.electric_meter_sharp,
        label: 'Circuit Design',
        route: '/circuit_design'),
    Utility(icon: Icons.inventory, label: 'Inventory', route: '/inventory'),
    Utility(icon: Icons.file_copy, label: 'Docs', route: '/documentation'),
    Utility(icon: Icons.build, label: 'Maintenance', route: '/maintenance'),
    Utility(icon: Icons.security, label: 'Safety', route: '/safety_guidelines'),
    Utility(icon: Icons.book, label: 'Regulations', route: '/regulations'),
    Utility(icon: Icons.contacts, label: 'Contacts', route: '/contacts'),
    Utility(icon: Icons.settings, label: 'Settings', route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Electrical Engineer Dashboard'),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
        ),
        itemCount: utilities.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (index == 0) {
                Navigator.pushNamed(context, utilities[index].route);
              }
              //Navigator.pushNamed(context, utilities[index].route);
            },
            child: Card(
              elevation: 4.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(utilities[index].icon, size: 50.0, color: Colors.blue),
                  SizedBox(height: 10),
                  Text(utilities[index].label,
                      style: TextStyle(fontSize: 16.0)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Utility {
  final IconData icon;
  final String label;
  final String route;

  Utility({required this.icon, required this.label, required this.route});
}
