import 'package:flutter/material.dart';
import 'package:samagra/screens/materials_management/search_material.dart';

class MaterialManagement extends StatelessWidget {
  const MaterialManagement({Key? key}) : super(key: key);

  void _onSearchMaterialPressed(BuildContext context) {
    // Navigate or show a message when the button is pressed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search Material button pressed')),
    );


     Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SearchMaterial()),
  );

//     void _onSearchMaterialPressed(BuildContext context) {
 
// }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => _onSearchMaterialPressed(context),
              icon: const Icon(Icons.search),
              label: const Text('Search Material'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            // You can add more buttons here later
          ],
        ),
      ),
    );
  }
}
