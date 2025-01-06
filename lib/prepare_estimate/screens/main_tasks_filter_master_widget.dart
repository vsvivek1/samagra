import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:samagra/prepare_estimate/data_fetch_service.dart';

class MainTaskFilterMasterWidget extends StatefulWidget {
  final ValueChanged<String?> onTaskFilterSelected;

  const MainTaskFilterMasterWidget({
    Key? key,
    required this.onTaskFilterSelected,
  }) : super(key: key);

  @override
  _MainTaskFilterMasterWidgetState createState() =>
      _MainTaskFilterMasterWidgetState();
}

class _MainTaskFilterMasterWidgetState
    extends State<MainTaskFilterMasterWidget> {
  final DataFetchService _dataFetchService = DataFetchService();
  List<Map<String, dynamic>> _taskFilters = [];
  String? _selectedTaskFilter;
  bool _isLoading = true; // Loading state
  String? _error; // Error message

  @override
  void initState() {
    super.initState();
    _fetchMainTaskFilterMaster();
  }

  Future<void> _fetchMainTaskFilterMaster() async {
    setState(() {
      _isLoading = true; // Start loading
      _error = null; // Clear any previous error
    });

    try {
      final data =
          await _dataFetchService.fetchData('mainTaskFilterMaster', null);

      setState(() {
        _taskFilters = data;
        _isLoading = false; // Data fetched successfully
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch MainTaskFilterMaster: $e';
        _isLoading = false; // Stop loading on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Main Task Filter Master',
        ), // Display loader
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchMainTaskFilterMaster, // Retry on error
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_taskFilters.isEmpty) {
      return const Center(
        child: Text(
          'No task filters available.',
          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a Task Filter:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Select Task Filter'),
          value: _selectedTaskFilter,
          items: _taskFilters.map<DropdownMenuItem<String>>((taskFilter) {
            return DropdownMenuItem<String>(
              value: taskFilter['id'].toString(), // Adjust based on API data
              child:
                  Text(taskFilter['description']), // Adjust based on API data
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTaskFilter = value;
            });
            widget.onTaskFilterSelected(value);
          },
        ),
      ],
    );
  }
}
