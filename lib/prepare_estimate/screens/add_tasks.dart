import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:samagra/common.dart';
import 'package:samagra/prepare_estimate/getMainTaskMaster.dart';
import 'package:samagra/prepare_estimate/screens/getStructureMasterForTasks.dart';
import 'package:samagra/prepare_estimate/screens/main_task_master_widget.dart';
import 'package:samagra/prepare_estimate/screens/main_tasks_filter_master_widget.dart';

class AddTasksWidget extends StatefulWidget {
  final String categoryId;

  const AddTasksWidget({Key? key, required this.categoryId}) : super(key: key);

  @override
  _AddTasksWidgetState createState() => _AddTasksWidgetState();
}

class _AddTasksWidgetState extends State<AddTasksWidget> {
  String? _selectedTaskFilter = '-2';
  bool _showMainTaskWidget = true;
  Map<dynamic, dynamic>? user;
  int sbuId = 4;
  String errorMessage = '';
  List<dynamic> _taskList = [];
  List<String> selectedTaskIds = [];
  
  bool _showMainTasksSpinner=false;
  
  var selectedTasks=[];

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

  Future<void> _updateSelectedTaskFilter(String? taskFilter) async {
    try {
      user = await getUser();

      if (user == null) {
        throw Exception('Failed to fetch user data.');
      }

      sbuId = user?['user']?['seats']?.firstWhere(
              (seat) =>
                  seat['mst_seat_id'] == user?['user']?['current_seat_id'],
              orElse: () => null)?['office']?['office_detail']?['mst_sbu_id'] ??
          4;

      if (!mounted) return;

      setState(() {
        _selectedTaskFilter = taskFilter;
        _showMainTaskWidget = taskFilter != null && taskFilter.isNotEmpty;

        _showMainTasksSpinner=true;
      });

      // Call API to fetch tasks

      
      var response = await getMainTaskMaster(sbuId, 3, 2);

      setState(() {
        _taskList = response['result_data']['list'];
         _showMainTasksSpinner=false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error in _updateSelectedTaskFilter: $e');
      debugPrintStack(stackTrace: stackTrace);

      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void _onTasksSelected(List<String> value) async {
    try {

     

     
      for (var taskId in value) {

    var a = _taskList.firstWhere(
  (t) => t['id'].toString() == taskId,
  orElse: () => {}, // Provide a default value or null if not found
);


selectedTasks.add(a);

        var response = await getStructureMasterForTask(int.parse(taskId));


        log('Task ID: $taskId, Structure: $response');
      }
    } catch (e) {
      debugPrint('Error fetching structure for tasks: $e');
    }
  }


 Widget _viewSelectedTasks() {
    if (selectedTasks.isEmpty) {
      return const Text(
        'No tasks selected.',
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      );
    }

    return ListView.builder(
      itemCount: selectedTasks.length,
      itemBuilder: (context, index) {
        final task = selectedTasks[index];
        // final task = _taskList.firstWhere(
        //   (task) => task['id'].toString() == taskId,
        //   orElse: () => null,
        // );

        if (task == null) {
          return const SizedBox.shrink();
        }

        return ListTile(
          title: Text(task['main_task_name']),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                selectedTaskIds.remove(task);
              });
            },
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Tasks'),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: MainTaskFilterMasterWidget(
                  onTaskFilterSelected: _updateSelectedTaskFilter,
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      if (_selectedTaskFilter != null && _selectedTaskFilter!='-2')
                        Text(
                          'Selected Task Filter: $_selectedTaskFilter',
                          style: const TextStyle(fontSize: 16),
                        ),
                      if (errorMessage.isNotEmpty)
                        Text(
                          'Error: $errorMessage',
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                    
                    
                      if (_showMainTaskWidget && _selectedTaskFilter != null && _selectedTaskFilter!='-2')
                       
                       
           
                       _showMainTasksSpinner?CircularProgressIndicator(color: Colors.orange): Expanded(
                          child: MainTaskMasterWidget(
                            taskList: _taskList,
                            onTasksSelected: _onTasksSelected,
                            selectedTaskIds: selectedTaskIds,
                          ),
                        )
                      else
                        const Text(
                          'No tasks to display. Please select a valid task filter.',
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
              ),
          
              Flexible(
                flex:4,
                
                child:_viewSelectedTasks() )
            ],
          ),
        ),
      ),
    );
  }
}
