import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:samagra/common.dart';
import 'package:samagra/prepare_estimate/getMainTaskMaster.dart';
import 'package:samagra/prepare_estimate/screens/create_location_screen.dart';
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
  
  var _updatingStructureDetails=false;

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
      // Check if the task already exists in selectedTasks
      bool alreadyExists = selectedTasks.any((task) => task['id'].toString() == taskId);

      if (!alreadyExists) {
        // Fetch task details
        var task = _taskList.firstWhere(
          (t) => t['id'].toString() == taskId,
          orElse: () => {}, // Default to empty map if not found
        );

        if (task.isNotEmpty) {
          // Add task to selectedTasks
          

          // Optional: Fetch additional structure details if needed

          setState(() {
  _updatingStructureDetails=true;
});
          var response = await getStructureMasterForTask(int.parse(taskId));

                    setState(() {
  _updatingStructureDetails=false;
});
   


          if (response['result_data'] != null &&
      response['result_data']['structureMaster'] != null) {
    List<dynamic> structureMaster = response['result_data']['structureMaster'];

    // Ensure task has a 'structures' key as a list
    task['structures'] ??= []; // Initialize if null

    for (var structure in structureMaster) {
      // Extract details into a structure object
      Map<String, dynamic> structureObject = {
        'id': structure['id'],
        'structure_code': structure['structure_code'].toString(),
        'structure_name': structure['structure_name'],
        'mst_uom_id': structure['mst_uom_id'],
        'start_date': structure['start_date'],
        'updated_at': structure['updated_at'],
        'uom_code': structure['mst_uom']?['uom_code'] ?? 'N/A',
        'uom_descr': structure['mst_uom']?['uom_descr'] ?? 'N/A',
      };

      // Push structureObject to task's structures
      task['structures'].add(structureObject);

      
    }

    print('Updated Task with Structures: $task');
  } else {
    print('No structureMaster data found.');
  }

                  setState(() {
  _updatingStructureDetails=false;
});


selectedTasks.add(task);
          log('Task ID: $taskId, Structure: $response');
        }
      }
    }

    // Update UI after tasks are added
    setState(() {});

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
                selectedTasks.remove(task);
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
                flex: 2,
                child: MainTaskFilterMasterWidget(
                  onTaskFilterSelected: _updateSelectedTaskFilter,
                ),
              ),
              Flexible(
                flex: 3,
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
          Flexible(child:      Text(
  _updatingStructureDetails? '...Updating Structure Details':''),),
              Flexible(
                flex:4,
                
                child:_viewSelectedTasks() ),

                Flexible(
                flex:1,
                
                child:ElevatedButton(onPressed: captureLocations, child: Text('Capture Locations')) )
            ],
          ),
        ),
      ),
    );
  }

  void captureLocations() {

    Navigator.push(context, MaterialPageRoute(
                                builder: (context) =>
                                    
                                    CreateLocation(tasks: [],)
                                    // ReviewDetailsPage(workDetails: workDetails),
                              )
    

    
    
    );
  }
}
