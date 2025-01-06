import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:samagra/prepare_estimate/add_new_work_form.dart';
import '../models/estimate_details.dart';

final FlutterSecureStorage secureStorage = FlutterSecureStorage();
final Uuid uuid = Uuid();

class NewEstimateCreationLandingPage extends StatefulWidget {
  @override
  _NewEstimateCreationLandingPageState createState() =>
      _NewEstimateCreationLandingPageState();
}

class _NewEstimateCreationLandingPageState
    extends State<NewEstimateCreationLandingPage> {
  final Map<String, EstimateDetails> _estimatesMap = {};
  bool _isLoading = true;
  String _selectedStatus = 'inProgress'; // Default filter status
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _fetchEstimates();
  }

  /// Fetch estimates from secure storage
  Future<void> _fetchEstimates() async {
    setState(() {
      _isLoading = true;
    });

   //try {
      final storedData = await secureStorage.read(key: 'estimates');



      if (storedData != null && storedData.isNotEmpty) {
        final decodedData = jsonDecode(storedData);


        if (decodedData is Map<String, dynamic>) {





          final secureEstimates = decodedData.map(
            (key, value) => MapEntry(
              key, EstimateDetails.fromJson(value as Map<String, dynamic>),
            ),
          );


print( secureEstimates);
          setState(() {
            _estimatesMap.clear();
            _estimatesMap.addAll(secureEstimates);
          });
        } else {
          // Log and handle if the stored data is not a valid map
          print("Fetched data is not a valid Map<String, dynamic>: $decodedData");
        }
      } else {
        // Log if stored data is null or empty
        print("No estimates found in secure storage.");
      }
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Error fetching estimates: ${e.toString()}")),
    //   );
    //   print("Error decoding estimates: $e");
    // } finally {
       setState(() {
        _isLoading = false;
       });
    // }
  }

  /// Save a new estimate to secure storage
  Future<void> _saveToSecureStorage(
      String id, EstimateDetails workDetails) async {
    try {
      final storedData = await secureStorage.read(key: 'estimates');
      final Map<String, dynamic> storedMap =
          storedData != null ? jsonDecode(storedData) : {};
      storedMap[id] = workDetails.toJson();
      await secureStorage.write(key: 'estimates', value: jsonEncode(storedMap));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving estimate: $e")),
      );
      print("Error saving estimate: $e");
    }
  }

  /// Filter estimates based on the selected status
  List<MapEntry<String, EstimateDetails>> get _filteredEstimates {
    return _estimatesMap.entries
        .where((entry) => entry.value.status == _selectedStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estimate List'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatus,
              icon: Icon(Icons.filter_list, color: Colors.white),
              dropdownColor: Colors.blueAccent,
              items: ['inProgress', 'completed', 'savedInServer']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(
                          status,
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/lineman.webp'),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _filteredEstimates.isEmpty
                ? Center(
                    child: Text(
                      'No estimates found for $_selectedStatus.',
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredEstimates.length,
                    itemBuilder: (context, index) {
                      final estimateEntry = _filteredEstimates[index];
                      final estimateId = estimateEntry.key;
                      final estimate = estimateEntry.value;

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              '${index + 1}', // Serial number
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            estimate.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              'Status: ${estimate.status}\nDate: ${estimate.details['date']}'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () async {
                            if (_isNavigating) return; // Prevent duplicate navigation
                            _isNavigating = true;

                            try {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddNewWorkForm(
                                    uuid: estimateId,
                                  ),
                                ),
                              );

                              if (result is EstimateDetails) {
                                setState(() {
                                  _estimatesMap[estimateId] = result;
                                });
                                await _saveToSecureStorage(estimateId, result);
                              }
                            } finally {
                              _isNavigating = false;
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          if (_isNavigating) return; // Prevent duplicate navigation
          _isNavigating = true;

          try {
            final newId = uuid.v4();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewWorkForm(uuid: newId),
              ),
            );

            if (result is EstimateDetails) {
              setState(() {
                _estimatesMap[newId] = result;
              });
              await _saveToSecureStorage(newId, result);
            }
          } finally {
            _isNavigating = false;
          }
        },
        label: Text('New Estimate'),
        icon: Icon(Icons.add),
      ),
    );
  }
}
