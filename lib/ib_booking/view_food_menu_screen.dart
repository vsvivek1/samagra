// lib/ib_booking/view_food_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/local_url.dart';

class ViewFoodMenuScreen extends StatefulWidget {
  const ViewFoodMenuScreen({Key? key}) : super(key: key);

  @override
  State<ViewFoodMenuScreen> createState() => _ViewFoodMenuScreenState();
}

class _ViewFoodMenuScreenState extends State<ViewFoodMenuScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: localUrl));
  bool _loadingIbs = true, _loadingMenu = false;
  List<Map<String, dynamic>> _ibs = [];
  Map<String, dynamic>? _selectedIb;
  List<dynamic> _menus = [];

  @override
  void initState() {
    super.initState();
    _loadIbs();
  }

  Future<void> _loadIbs() async {
    final res = await _dio.get('/api/ibbooking/ibs');
    setState(() {
      _ibs = List<Map<String, dynamic>>.from(res.data);
      _loadingIbs = false;
    });
  }

  Future<void> _loadMenu() async {
    if (_selectedIb == null) return;
    setState(() {
      _loadingMenu = true;
      _menus = [];
    });
    final res = await _dio.get('/api/ibbooking/food-menu/${_selectedIb!['id']}');
    setState(() {
      _menus = res.data;
      _loadingMenu = false;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Food Menu')),
      body: _loadingIbs
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButton<Map<String, dynamic>>(
                    value: _selectedIb,
                    hint: const Text('Select IB'),
                    items: _ibs
                        .map((ib) => DropdownMenuItem(
                              value: ib,
                              child: Text(ib['name']),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedIb = v);
                      _loadMenu();
                    },
                  ),
                ),

                Expanded(
                  child: _loadingMenu
                      ? const Center(child: CircularProgressIndicator())
                      : _menus.isEmpty
                          ? const Center(child: Text('No menu found'))
                          : ListView.builder(
                              itemCount: _menus.length,
                              itemBuilder: (_, i) {
                                final m = _menus[i];
                                return ListTile(
                                  title: Text(
                                      '${m['meal_type']} (${m['date']})'),
                                  subtitle: Text(
                                      (m['items'] as List).join(', ')),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}
