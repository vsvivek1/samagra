import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:samagra/common.dart';
import 'package:samagra/prepare_estimate/getMainTaskMaster.dart';
import 'package:samagra/prepare_estimate/getTasksBySbu.dart';
import 'package:samagra/prepare_estimate/screens/check_and_refresh_data.dart';
import 'package:samagra/prepare_estimate/screens/create_location_screen.dart';
import 'package:samagra/prepare_estimate/screens/getStructureMasterForTasks.dart';
import 'package:samagra/prepare_estimate/screens/main_task_master_widget.dart';
import 'package:samagra/prepare_estimate/screens/main_tasks_filter_master_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/prepare_estimate/data_fetch_service.dart';
import 'package:samagra/prepare_estimate/screens/tasks_mult_select.dart';

class AddTasksWidget extends StatefulWidget {
  final String uuId;

  const AddTasksWidget({Key? key, required this.uuId}) : super(key: key);

  @override
  _AddTasksWidgetState createState() => _AddTasksWidgetState();
}

class _AddTasksWidgetState extends State<AddTasksWidget> {
  final DataFetchService _dataFetchService = DataFetchService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String? _selectedTaskFilter = '-2';
  bool _showMainTaskWidget = true;
  Map<dynamic, dynamic>? user;
  int sbuId = 4;
  String errorMessage = '';
  List<dynamic> _taskList = [];
  List<String> selectedTaskIds = [];
  bool _showMainTasksSpinner = false;
  var selectedTasks = [];
  var _updatingStructureDetails = false;
  bool _savedToStorage = false;
  bool _fetchingTasks = false;

  final GlobalKey<MainTaskMasterWidgetState> taskMasterKey = GlobalKey();
  
 List<Map<String, dynamic>> allTasks=[];

  @override
  void initState() {
    super.initState();
    debugPrint('AddTasksWidget initialized');
  }

  @override
  void dispose() {
    debugPrint('AddTasksWidget disposed');
    super.dispose();
  }

  /// Fetch and store all tasks in local storage
  Future<void> fetchAndStoreTasks() async {
    setState(() {
      _fetchingTasks = true;
    });

    try {
      user = await getUser();
      if (user == null) throw Exception('Failed to fetch user data.');

      sbuId = user?['user']?['seats']?.firstWhere(
              (seat) => seat['mst_seat_id'] == user?['user']?['current_seat_id'],
              orElse: () => null)?['office']?['office_detail']?['mst_sbu_id'] ??
          4;

      // Fetch tasks from API
      var response = await getMainTaskMaster(sbuId, 3, 2);
      List<dynamic> tasks = response['result_data']['list'];

      // Save tasks to local storage under key 'mst_tasks'
      await _secureStorage.write(key: 'mst_tasks', value: jsonEncode(tasks));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tasks successfully saved to storage as mst_tasks')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _fetchingTasks = false;
      });
    }
  }

  /// Fetch and update selected tasks
  Future<void> _updateSelectedTaskFilter(String? taskFilter) async {
    try {
      user = await getUser();
      if (user == null) throw Exception('Failed to fetch user data.');

      sbuId = user?['user']?['seats']?.firstWhere(
              (seat) => seat['mst_seat_id'] == user?['user']?['current_seat_id'],
              orElse: () => null)?['office']?['office_detail']?['mst_sbu_id'] ??
          4;

      setState(() {
        _selectedTaskFilter = taskFilter;
        _showMainTaskWidget = taskFilter != null && taskFilter.isNotEmpty;
        _showMainTasksSpinner = true;
      });

      var response = await getMainTaskMaster(sbuId, 3, 2);
      setState(() {
        _taskList = response['result_data']['list'];
        _showMainTasksSpinner = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error in _updateSelectedTaskFilter: $e');
      debugPrintStack(stackTrace: stackTrace);
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  /// Build the selected tasks list
  Widget _viewSelectedTasks() {
    if (selectedTasks.isEmpty) {
      return const Text(
        'No tasks selected.',
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      );
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black45),
          color: Colors.white,
        ),
        child: ListView.builder(
          itemCount: selectedTasks.length,
          itemBuilder: (context, index) {
            final task = selectedTasks[index];
            if (task == null) return const SizedBox.shrink();

            return ListTile(
              title: Text(task['main_task_name']),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  taskMasterKey.currentState?.refreshState();
                  setState(() {
                    selectedTasks.remove(task);
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build the widget UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Tasks')),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fetch and Save Tasks Button
              ElevatedButton(
                onPressed: _fetchingTasks ? null :()=> fetchTasksIfNeeded(4),
                child: _fetchingTasks
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Fetch and Save Tasks'),
              ),


              Expanded(
            child: TaskMultiSelect(
              tasks: allTasks,
              onSelectionChanged: _onTasksSelected,
            ),
          ),
              SizedBox(height: 10),

              // Show Task List
              if (_selectedTaskFilter != null && _selectedTaskFilter != '-2')
                Text('Selected Task Filter: $_selectedTaskFilter',
                    style: const TextStyle(fontSize: 16)),

              if (errorMessage.isNotEmpty)
                Text('Error: $errorMessage',
                    style: const TextStyle(color: Colors.red, fontSize: 14)),

              if (_showMainTaskWidget &&
                  _selectedTaskFilter != null &&
                  _selectedTaskFilter != '-2')
                _showMainTasksSpinner
                    ? CircularProgressIndicator(color: Colors.orange)
                    : SizedBox(
                        height: 200,
                        // child: 
                        
                        // MainTaskMasterWidget(
                        //   key: taskMasterKey,
                        //   taskList: _taskList,
                        //   onTasksSelected: _onTasksSelected,
                        //   selectedTaskIds: selectedTaskIds,
                        // ),
                      )
              else
                const Text('No tasks to display. Please select a valid task filter.',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),

              // Show Selected Tasks
              Text('Selected Tasks', style: TextStyle(fontSize: 20)),
              _viewSelectedTasks(),

              !_savedToStorage
                  ? ElevatedButton(
                      onPressed: saveToStorage,
                      child: Text('Save'),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _savedToStorage = false;
                        });
                      },
                      child: Text('Edit'),
                    ),

              if (_savedToStorage)
                ElevatedButton(
                  onPressed: () => captureLocations(widget.uuId),
                  child: Text('Capture Locations'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to Create Location Screen
  void captureLocations(String uuid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateLocation(uuId: uuid)),
    );
  }

Future<void> fetchTasksIfNeeded(int sbuId) async {
  String result1 = await checkAndRefreshData(
    storageKey: 'mst_tasks_sbu',
    timestampKey: 'mst_tasks_sbu_timestamp',
    refreshFunction: () => getTasksBySbu(sbuId),
  );



 var result =jsonDecode(result1);
setState(() {
  allTasks=List<Map<String, dynamic>>.from(result['result_data']);
});
  print('Final Retrieved Data: $allTasks');
}

 void _onTasksSelected(List<Map<String, dynamic>> selected) {
    setState(() {
      selectedTasks = selected;
    });

    print('Selected Tasks: $selectedTasks'); // Handle the selection change
  }

  // void _onTasksSelected(List<String> value) {
  // }

  void saveToStorage() {
  }
}
