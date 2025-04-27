import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/common.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';



class SearchMaterial extends StatefulWidget {
  const SearchMaterial({Key? key}) : super(key: key);

  @override
  State<SearchMaterial> createState() => _SearchMaterialState();
}

class _SearchMaterialState extends State<SearchMaterial> {


  List<dynamic> _materialGroups = [];
  List<dynamic> _materialSubGroups = [];
  List<dynamic> _materialItems = [];
  List<dynamic> _searchResult = [];

  String? _selectedGroup;
  String? _selectedSubGroup;
  String? _selectedItem;

  bool _isLoadingGroups = false;
  bool _isLoadingSubGroups = false;
  bool _isLoadingItems = false;
  bool _isSearchingStock = false;

  late EnvironmentConfig config;
late String url;

late  Dio _dio=Dio();


Future<void> _loadConfig() async {
  config = await EnvironmentConfig.fromEnvFile();
  url = '${config.liveServiceUrlLogin}';

    _dio.options.baseUrl='${config.liveServiceUrlLogin}';


 // setState(() {}); // To reflect changes if UI depends on it
}

  @override
  void initState()  {
   
    
     _loadConfig();
     _fetchMaterialGroups();

      super.initState();
  }

  Future<void> _fetchMaterialGroups() async {
    setState(() => _isLoadingGroups = true);

    print(_dio.options);

    config = await EnvironmentConfig.fromEnvFile();
   

    setDioAccessokenAndApiKey(_dio, await getAccessToken(), config);

 url=config.liveServiceUrl;

 

    final response = await _dio.get('/getMaterialGroups/');
    if (response.statusCode == 200) {
      setState(() {
        _materialGroups = [{'id': 0, 'material_group_name': '-- Select Group --'}, ...response.data];
        _isLoadingGroups = false;
      });
    }
  }

  Future<void> _fetchMaterialSubGroups(String groupId) async {
    setState(() => _isLoadingSubGroups = true);
    final response = await _dio.get('getMaterialSubGroups/groupId/$groupId');
    if (response.statusCode == 200) {
      setState(() {
        _materialSubGroups = [{'id': 0, 'value': '-- Select Subgroup --'}, ...response.data];
        _isLoadingSubGroups = false;
      });
    }
  }

  Future<void> _fetchMaterialItems(String subGroupId) async {
    setState(() => _isLoadingItems = true);
    final response = await _dio.get('getMaterialsBySubGroupId/subGroupId/$subGroupId');
    if (response.statusCode == 200) {
      setState(() {
        _materialItems = [{'id': 0, 'value': '-- Select Item --'}, ...response.data];
        _isLoadingItems = false;
      });
    }
  }

  Future<void> _searchMaterial() async {
    if (_selectedItem == null || _selectedItem == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid Item')),
      );
      return;
    }

    setState(() {
      _isSearchingStock = true;
      _searchResult = [];
    });

    try {
      final response = await _dio.get('stockReport_search_results_dash/item/$_selectedItem');


      if (response.statusCode == 200) {
        setState(() {
          _searchResult = response.data['result_data'] ?? [];
          _isSearchingStock = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _isSearchingStock = false);
    }
  }

Future<void> _showOfficeDetails(Map<String, dynamic> item) async {
  String? officeId = item['circle_office_id']?.toString();
  String? matId = _selectedItem;

  if (officeId == null || matId == null) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  //try {
    final response = await _dio.get('stocksubdet/$officeId/$matId');

    Navigator.pop(context); // Close the loading dialog

    final List<dynamic> details = response.data;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['office_name'] ?? 'Sub-stock Details'),
        content: details.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: details.map((d) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(d['office_name'] ?? 'Sub Office'),
                      subtitle: Text(
                          'New: ${d['new_stock']} ${d['uom_descr']}, Used: ${d['used_stock']}, Allocated: ${d['new_allocated']} / ${d['used_allocated']}'),
                    );
                  }).toList(),
                ),
              )
            : const Text("No sub-office stock details available."),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  // } 
  
  // catch (e) {
  //   Navigator.pop(context);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Error fetching sub-office stock details")),
  //   );
  // }


}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Material')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Material Group Dropdown
            _isLoadingGroups
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: _selectedGroup,
                    decoration: const InputDecoration(labelText: 'Select Group'),
                    items: _materialGroups.map((group) {
                      return DropdownMenuItem<String>(
                        value: group['id'].toString(),
                        child: Text(group['material_group_name']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedGroup = val;
                        _selectedSubGroup = null;
                        _selectedItem = null;
                        _materialSubGroups = [];
                        _materialItems = [];
                      });
                      if (val != null && val != '0') _fetchMaterialSubGroups(val);
                    },
                  ),

            const SizedBox(height: 10),

            // Subgroup Dropdown
            _isLoadingSubGroups
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: _selectedSubGroup,
                    decoration: const InputDecoration(labelText: 'Select Subgroup'),
                    items: _materialSubGroups.map((sub) {
                      return DropdownMenuItem<String>(
                        value: sub['id'].toString(),
                        child: Text(sub['value']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSubGroup = val;
                        _selectedItem = null;
                        _materialItems = [];
                      });
                      if (val != null && val != '0') _fetchMaterialItems(val);
                    },
                  ),

            const SizedBox(height: 10),

            // Item Dropdown
            _isLoadingItems
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: _selectedItem,
                    decoration: const InputDecoration(labelText: 'Select Item'),
                    items: _materialItems.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['id'].toString(),
                        child: Text(item['value']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedItem = val),
                  ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _searchMaterial,
              child: const Text("Search Stock"),
            ),

            const SizedBox(height: 20),

            _isSearchingStock
                ? const CircularProgressIndicator()
                : _searchResult.isEmpty
                    ? const Text("No results yet.")
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _searchResult.length,
                          itemBuilder: (context, index) {
                            final item = _searchResult[index];
                            return Card(
                              child: ListTile(
                                title: Text(item['office_name'] ?? ''),
                                subtitle: Text("Stock: ${item['new_stock']} ${item['uom_descr']}"),
                                onTap: () => _showOfficeDetails(item),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
