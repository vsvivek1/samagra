import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/spares_management/spare_details.dart';

class InventoryAvailableTab extends StatefulWidget {
  @override
  _InventoryAvailableTabState createState() => _InventoryAvailableTabState();
}

class _InventoryAvailableTabState extends State<InventoryAvailableTab> {
  Dio dio = Dio();
  List<dynamic> spares = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchSpares();
  }

  Future<void> fetchSpares() async {
    try {
      String apiUrl3 = 'http://192.168.100.109:8000/api/spares';
      // Replace with your actual API URL
      final response = await dio.get(apiUrl3);

      if (response.statusCode == 200) {
        setState(() {
          spares = response.data; // Assuming the response is a list of spares
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load spares');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(child: Text('Failed to load spares'));
    }

    return ListView.builder(
      itemCount: spares.length,
      itemBuilder: (context, index) {
        final spare = spares[index];

        // Extracting spare details
        final spareName = spare['spare_name'] ?? 'Unknown Spare';
        final location = spare['location'] ?? 'Unknown Location';
        final spareImageUrl =
            spare['image_url']; // Assuming the image is available here

        return Card(
          margin: EdgeInsets.all(10),
          elevation: 5,
          child: ListTile(
            leading: spareImageUrl != null
                ? Image.network(spareImageUrl,
                    width: 50, height: 50, fit: BoxFit.cover)
                : Icon(Icons.image, size: 50),
            title: Text(spareName),
            subtitle: Text('Location: $location'),
            onTap: () {
              // Navigate to the details page and pass the spare data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpareDetailsPage(spare: spare),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
