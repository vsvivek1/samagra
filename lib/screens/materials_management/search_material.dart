import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SearchMaterial extends StatefulWidget {
  const SearchMaterial({Key? key}) : super(key: key);

  @override
  State<SearchMaterial> createState() => _SearchMaterialState();
}

class _SearchMaterialState extends State<SearchMaterial> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://192.168.1.17:8000/api'));

  List<dynamic> _materialGroups = [];
  List<dynamic> _materialSubGroups = [];
  List<dynamic> _materialItems = [];

  String? _selectedGroup='';
  String? _selectedSubGroup='';
  String? _selectedItem='';

  bool _isLoadingGroups = true;
  bool _isLoadingSubGroups = false;
  bool _isLoadingItems = false;

  @override
  void initState() {
    super.initState();
    _fetchMaterialGroups();
  }

  Future<void> _fetchMaterialGroups() async {
    setState(() {
      _isLoadingGroups = true;
    });
    final response = await _dio.get('/getMaterialGroups/');
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      setState(() {
        _materialGroups = [
          {'id': 0, 'material_group_name': '-- Select a Group --'},
          ...data
        ];
        _isLoadingGroups = false;
      });
    }
  }

  Future<void> _fetchMaterialSubGroups(String groupId) async {
    setState(() {
      _isLoadingSubGroups = true;
    });
    final response = await _dio.get('/getMaterialSubGroups/groupId/'+ _selectedGroup.toString());
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      setState(() {
        _materialSubGroups = [
          {'id': 0, 'value': '-- Select a Subgroup --'},
          ...data
        ];
        _isLoadingSubGroups = false;
      });
    }
  }

  Future<void> _fetchMaterialItems(String subGroupId) async {
    setState(() {
      _isLoadingItems = true;
    });
    final response = await _dio.get('/getMaterialsBySubGroupId/subGroupId/$_selectedSubGroup');
    
  
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      setState(() {
        _materialItems = [
          {'id': 0, 'value': '-- Select an Item --'},
          ...data
        ];
        _isLoadingItems = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Material'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingGroups
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Material Group', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value:  _materialGroups.any((g) => g['id'].toString() == _selectedGroup) ? _selectedGroup : null,

                    items: _materialGroups.map((group) {
                      return DropdownMenuItem<String>(
                        value: group['id'].toString(),
                        child: Text(group['material_group_name']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGroup = newValue;
                        _selectedSubGroup = null;
                        _selectedItem = null;
                        _materialSubGroups = [];
                        _materialItems = [];
                      });
                      if (newValue != null && newValue != '0') {
                        _fetchMaterialSubGroups(newValue);
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Material Sub Group', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                   value: _materialSubGroups.any((g) => g['id'].toString() == _selectedSubGroup) ? _selectedSubGroup : null,


                    items: _materialSubGroups.map((subgroup) {
                      return DropdownMenuItem<String>(
                        value: subgroup['id'].toString(),
                        child: Text(subgroup["value"]),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSubGroup = newValue!;
                        _selectedItem = '';
                        _materialItems = [];
                      });
                      if (newValue != null && newValue != '0') {
                        _fetchMaterialItems(newValue);
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Material Item', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _materialItems.any((g) => g['id'].toString() == _selectedItem) ? _selectedItem : null,
                    items: _materialItems.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['value'],

                        child: Text(item['value']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedItem = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
