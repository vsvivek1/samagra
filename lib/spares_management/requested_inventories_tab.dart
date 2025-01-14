import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/spares_management/requested_inventory_details.dart';

class RequestedInventoriesTab extends StatefulWidget {
  @override
  _RequestedInventoriesTabState createState() =>
      _RequestedInventoriesTabState();
}

class _RequestedInventoriesTabState extends State<RequestedInventoriesTab> {
  Dio dio = Dio();
  List<dynamic> requestedInventories = [];
  List<dynamic> filteredRequestedInventories = [];
  bool isLoading = true;
  bool hasError = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRequestedInventories();
  }

  Future<void> fetchRequestedInventories() async {
    try {
      String apiUrl =
          'http://192.168.29.92:8000/api/requested_inventories'; // Replace with your actual API URL
      final response = await dio.get(apiUrl);

      if (response.statusCode == 200) {
        setState(() {
          requestedInventories = response.data;
          filteredRequestedInventories = requestedInventories;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load requested inventories');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void filterRequestedInventories(String query) {
    setState(() {
      filteredRequestedInventories = requestedInventories
          .where((inventory) => (inventory['inventory_name'] ?? '')
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
      return Center(child: Text('Failed to load requested inventories'));
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              filterRequestedInventories(value);
            },
            decoration: InputDecoration(
              labelText: 'Search by Inventory Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredRequestedInventories.length,
            itemBuilder: (context, index) {
              final inventory = filteredRequestedInventories[index];

              // Extracting inventory details
              final inventoryName =
                  inventory['inventory_name'] ?? 'Unknown Inventory';
              final location = inventory['location'] ?? 'Unknown Location';
              final images = inventory['images'] as List<dynamic>?;

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
                  title: Text(inventoryName),
                  subtitle: Text('Location: $location'),
                  onTap: () {
                    // Navigate to the details page and pass the inventory data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RequestedInventoryDetailsPage(inventory: inventory),
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
