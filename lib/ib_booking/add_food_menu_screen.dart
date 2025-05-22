// lib/ib_booking/add_food_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/local_url.dart';

class AddFoodMenuScreen extends StatefulWidget {
  const AddFoodMenuScreen({Key? key}) : super(key: key);

  @override
  State<AddFoodMenuScreen> createState() => _AddFoodMenuScreenState();
}

class _AddFoodMenuScreenState extends State<AddFoodMenuScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: localUrl));
  bool _loadingIbs = true, _submitting = false;
  List<Map<String, dynamic>> _ibs = [];
  Map<String, dynamic>? _selectedIb;
  DateTime _selectedDate = DateTime.now();
  String? _mealType;
  final TextEditingController _itemsCtrl = TextEditingController();

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

  Future<void> _submit() async {
    if (_selectedIb == null || _mealType == null || _itemsCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick IB, date, meal & items')),
      );
      return;
    }
    setState(() => _submitting = true);

    final payload = {
      'ib_id': _selectedIb!['id'],
      'date': _selectedDate.toIso8601String().split('T').first,
      'meal_type': _mealType,
      'items': _itemsCtrl.text.split(',').map((s) => s.trim()).toList(),
    };

    try {
      await _dio.post('/api/ibbooking/food-menu', data: payload);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu added')),
      );
      _itemsCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add menu: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Food Menu')),
      body: _loadingIbs
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  DropdownButton<Map<String, dynamic>>(
                    value: _selectedIb,
                    hint: const Text('Select IB'),
                    items: _ibs
                        .map((ib) => DropdownMenuItem(
                              value: ib,
                              child: Text(ib['name']),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedIb = v),
                  ),

                  const SizedBox(height: 12),
                  ListTile(
                    title: Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final dt = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (dt != null) setState(() => _selectedDate = dt);
                    },
                  ),

                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: _mealType,
                    hint: const Text('Meal Type'),
                    items: ['Breakfast','Lunch','Dinner']
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _mealType = v),
                  ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: _itemsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Items (comma-separated)',
                    ),
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const CircularProgressIndicator()
                        : const Text('Submit Menu'),
                  ),
                ],
              ),
            ),
    );
  }
}
