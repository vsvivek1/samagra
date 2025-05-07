import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:samagra/prepare_estimate/add_new_work_form.dart';
import 'package:samagra/prepare_estimate/screens/capture_photos_widget.dart';
import 'package:samagra/prepare_estimate/screens/create_location_screen.dart';
import 'package:samagra/prepare_estimate/screens/database_file_explorer.dart';
import 'package:samagra/prepare_estimate/screens/saved_estimate_details_screen.dart';

import 'package:uuid/uuid.dart';
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
  String _selectedStatus = 'inProgress';
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _fetchEstimates();
  }

  Future<void> _fetchEstimates() async {
    setState(() {
      _isLoading = true;
    });

    final storedData = await secureStorage.read(key: 'estimates');
    if (storedData != null && storedData.isNotEmpty) {
      final decodedData = jsonDecode(storedData);
      if (decodedData is Map<String, dynamic>) {
        final secureEstimates = decodedData.map(
          (key, value) => MapEntry(
            key,
            EstimateDetails.fromJson(value as Map<String, dynamic>),
          ),
        );
        setState(() {
          _estimatesMap.clear();
          _estimatesMap.addAll(secureEstimates);
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveToSecureStorage(String id, EstimateDetails workDetails) async {
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
    }
  }

  List<MapEntry<String, EstimateDetails>> get _filteredEstimates {
    return _estimatesMap.entries
        .where((entry) => entry.value.status == _selectedStatus)
        .toList();
  }

  Future<void> _navigateToLastScreen(String estimateId, EstimateDetails estimate) async {
    Widget screenToNavigate;

    switch (estimate.lastVisitedScreen) {
      case 'SavedEstimateDetailsScreen':
        screenToNavigate = SavedEstimateDetailsScreen(uuid: estimateId);
        break;
      case 'AddNewWorkForm':
        screenToNavigate = AddNewWorkForm(uuid: estimateId);
        break;
      case 'CreateLocation':
        screenToNavigate = CreateLocation(uuId: estimateId);
        break;
      case 'CapturePhotosWidget':
        screenToNavigate = CapturePhotosWidget(uuid: estimateId);
        break;
      default:
        screenToNavigate = SavedEstimateDetailsScreen(uuid: estimateId);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screenToNavigate),
    );

    if (result is EstimateDetails) {
      setState(() {
        _estimatesMap[estimateId] = result;
      });
      await _saveToSecureStorage(estimateId, result);
    }
  }
Future<void> downloadDatabase() async {
  final dio = Dio();
  final dir = await getApplicationDocumentsDirectory();

  try {
    final response = await dio.get(
      'http://192.168.100.100:8000/api/download-sqlite-zip',
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception("Failed to download ZIP file");
    }

    // Check header
    final contentType = response.headers.map['content-type']?.first ?? '';
    if (!contentType.contains('application/zip')) {
      throw Exception("Expected ZIP file, got: $contentType");
    }

    // Decode ZIP
    final archive = ZipDecoder().decodeBytes(response.data);

    for (final file in archive) {
      if (file.isFile && file.name.endsWith('.sqlite')) {
        final output = File(p.join(dir.path, file.name));
        await output.writeAsBytes(file.content as List<int>);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Database saved to ${output.path}")),
        );
        return; // exit after successful save
      }
    }

    throw Exception("No .sqlite file found in the ZIP");

  } catch (e) {
    print("Download/unzip error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
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
                              '${index + 1}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            estimate.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Status: ${estimate.status}'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () async {
                            if (_isNavigating) return;
                            _isNavigating = true;

                            try {
                              await _navigateToLastScreen(estimateId, estimate);
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
          if (_isNavigating) return;
          _isNavigating = true;

          try {
            final newId = uuid.v4();
            final newEstimate = EstimateDetails(
              name: 'New Estimate',
              status: 'inProgress',
              details: {'date': DateTime.now().toString()},
              lastVisitedScreen: 'AddNewWorkForm',
            );

            setState(() {
              _estimatesMap[newId] = newEstimate;
            });

            await _saveToSecureStorage(newId, newEstimate);
            await _navigateToLastScreen(newId, newEstimate);
          } finally {
            _isNavigating = false;
          }
        },
        label: Text('New Estimate'),
        icon: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) async {
          final dir = await getApplicationDocumentsDirectory();
          final dbPath = p.join(dir.path, 'mst.sqlite');

          if (index == 0) {
            await downloadDatabase();
          } else if (index == 1) {
            if (await File(dbPath).exists()) {
              Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DatabaseExplorerScreen(dbPath: dbPath),
  ),
);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Database not found. Please download first.")),
              );
            }
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Download DB',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'View DB',
          ),
        ],
      ),
    );
  }
}
