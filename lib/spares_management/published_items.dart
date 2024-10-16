import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/spares_management/published_item_details.dart';

class PublishedItems extends StatefulWidget {
  final String officeId;
  final String employeeId;

  PublishedItems({required this.officeId, required this.employeeId});

  @override
  _PublishedItemsState createState() => _PublishedItemsState();
}

class _PublishedItemsState extends State<PublishedItems> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchPublishedItems();
  }

  // Fetch published items based on office ID or employee ID
  Future<void> _fetchPublishedItems() async {
    setState(() {
      _loading = true;
    });

    final Dio dio = Dio();
    final String url = "https://your-api-endpoint.com/items";

    try {
      final response = await dio.get(
        url,
        queryParameters: {
          'office_id': widget.officeId,
          'employee_id': widget.employeeId,
        },
      );

      setState(() {
        _items = List<Map<String, dynamic>>.from(response.data);
        _loading = false;
      });
    } catch (e) {
      print('Failed to load items: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  // Navigate to details page
  void _navigateToDetails(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PublishedItemDetail(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Published Items")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return GestureDetector(
                  onTap: () => _navigateToDetails(item),
                  child: Card(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display image(s) of the spare
                        if (item['images'] != null && item['images'].isNotEmpty)
                          Container(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: item['images'].length,
                              itemBuilder: (context, imageIndex) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(
                                    item['images'][imageIndex],
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                        ListTile(
                          title: Text(
                            item['spare_name'] ?? "No Name",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(
                                item['description'] ?? "No Description",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5),
                              Text("Make: ${item['make'] ?? 'Unknown'}"),
                              SizedBox(height: 5),
                              Text(
                                  "KVA Rating: ${item['kva_rating'] ?? 'N/A'} KVA"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
