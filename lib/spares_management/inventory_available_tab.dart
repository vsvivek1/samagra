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
  List<dynamic> filteredSpares = [];
  bool isLoading = true;
  bool hasError = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSpares();
  }

  Future<void> fetchSpares() async {
    try {
/*       String apiUrl3 =
          'localUrl/api/spares'; */

      //String apiUrl3 =
      String apiUrl = 'localUrl/api/spares';

      // Replace with your actual API URL
      final response = await dio.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          spares = response.data;
          filteredSpares =
              spares; // Initialize the filtered list with all spares
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

  void filterSpares(String query) {
    setState(() {
      filteredSpares = spares
          .where((spare) => (spare['spare_name'] ?? '')
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(child: Text('Failed to load spares'));
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              filterSpares(value);
            },
            decoration: InputDecoration(
              labelText: 'Search by Spare Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredSpares.length,
            itemBuilder: (context, index) {
              final spare = filteredSpares[index];

              // Extracting spare details
              final spareName = spare['spare_name'] ?? 'Unknown Spare';
              final location = spare['location'] ?? 'Unknown Location';
              final images = spare['images'] as List<dynamic>?;

              // Get the first image URL, if available
              final imageUrl = (images != null && images.isNotEmpty)
                  ? images[0]['asset_url']
                  : null;

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 5,
                child: ListTile(
                  leading: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
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
          ),
        ),
      ],
    );
  }
}
