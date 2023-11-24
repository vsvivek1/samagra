import 'dart:convert';
import 'package:samagra/kseb_color.dart';
import 'package:samagra/screens/save_to_work_module.dart';
import 'package:samagra/screens/set_access_token_to_dio.dart';

import 'get_work_details.dart';
import 'log_functions.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/screens/arrow_with_text_painter.dart';
import 'package:samagra/screens/editable_table.dart';
import 'package:samagra/screens/location_details_widget.dart';
import 'package:samagra/screens/location_measurement_progress.dart';
import 'package:samagra/screens/location_measurement_view.dart';
import 'package:samagra/screens/view_tabbed_view_of_components_in_location.dart';
import 'package:samagra/screens/work_name_widget.dart';

import '../app_theme.dart';
import '../secure_storage/secure_storage.dart';

import 'measurement_display_widget.dart';

import 'package:geolocator/geolocator.dart';

import 'dart:core';
import 'dart:developer';

import 'measurement_property_copier_screen.dart';

class PolVarScreen extends StatefulWidget {
  @override
  final int workId;
  final String workName;
  final String workCode;
  final String measurementSetId;
  final String workScheduleGroupId;

  PolVarScreen({
    Key? key,
    required this.workId,
    required this.workName,
    required this.workCode,
    required this.measurementSetId,
    required this.workScheduleGroupId,
    required isMuted,
  }) : super(key: key);

  _PolVarScreenState createState() => _PolVarScreenState();
}

class _PolVarScreenState extends State<PolVarScreen> {
  final storage = SecureStorage();
  int _numberOfLocations = 0;
  int _selectedLocationIndex = -1;
  int _previoslySelectedIndex = -1;
  late AudioCache audioCache = AudioCache(prefix: 'assets/audio/');

  bool viewStructures = false;

  String userDirections = 'Watch here to Know what to do next';

  bool _enableEntryOfLocationDetails = true;

  bool _hasLocationDetailsInStorage = false;
  bool _hasMeasurementDetailsInStorage = false;

  bool _showSaveMeasurementDetailsButton = false;

  String _fromLocation = '';
  String _toLocation = '';
  int _tappedIndex = -1;

  int steps = 0;

  Map<String, dynamic> _selectedLocationDetails = {};

  List _selectedMeasurements = [];
  List<Map<String, dynamic>> _masterMaterialEstimate = [];
  List<Map<String, dynamic>> _masterLabEstimateItems = [];

  List _tasks = [];

  List _taskList = [];

  List allTasks = [];

  List _taskByName = [];

  List _fetchingWorkResData = [];

  bool isPlaying = false;
  bool isMuted = false;

  var _wrk_schedule_group_id;

  late bool _fetchingMasterEstimate = false;

  bool _showAnotherLocationButton = false;

  var _showSubmitToSamagraButton = false;

  int noOFLocationsMeasured = 0;

  var _selectedLocationTasks = [];

  var _viewFullLocationList = false;

  bool _showSpinnerForAsync = false;

  var _selectedLocationHasGeoLocations = false;

  var _selectedLocationHasMeasurements = false;

  var apiDataForSamagra = {};

  bool _openedMeasurementCopier = false;

  List wrk_schedule_group_structures = [];

  var _savedToSamagra = false;

  bool isAudioMuted = true;

  void togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void stop() {
    setState(() {
      isPlaying = false;
    });
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
  }

  Future<Map<String, dynamic>> getMeasurementDetails(

      // print()
      String workId,
      int locationNumber) async {
    logCurrentFunction();
    final storage = new FlutterSecureStorage();
    String? jsonDetails = await storage.read(key: 'measurementDetails');

    if (jsonDetails != null) {
      List<dynamic> details = jsonDecode(jsonDetails);
      Map<dynamic, dynamic> matchingDetail = details.firstWhere(
          (detail) =>
              detail['workId'] == workId &&
              detail['locationNumber'] == locationNumber,
          orElse: () => {});
      return {'matchingDetail': matchingDetail, 'detailsList': details};
    }
    return {'matchingDetail': {}, 'detailsList': []};
  }

  Future<void> storeMeasurementDetails(
      List<Map<dynamic, dynamic>> measurementDetails) async {
    logCurrentFunction();
    final storage = new FlutterSecureStorage();
    String jsonDetails = jsonEncode(measurementDetails);
    await storage.write(key: 'measurementDetails', value: jsonDetails);
  }

  bool loadingLocationDetails = false;
  List<Map<dynamic, dynamic>> measurementDetails = [];

  Map<dynamic, dynamic>? _workDetails;

  /// save this if this is present
  // List<String> _templates = [

  List<String> _selectedTemplates = [];

  // get workName => this.workName;

  List getTasksByName(wrkScheduleGroupStructures) {
    if (this.allTasks.length > 0) {
      return this.allTasks;
    }

    print('getTasksByName CALLED');
    // print(wrk_schedule_group_structures);

    // print('dabove 144');
    // return;
    List<dynamic> tasks = wrkScheduleGroupStructures;

    List res = [];

    var allTasks =
        tasks.map((t) => t['mst_task']['task_name']).toSet().toList();

    var allTasksIds = tasks.map((t) => t['mst_task']['id']).toSet().toList();

    // print(allTasksIds);

    // print('all task id above @157n pol var');

    for (int z = 0; z < allTasks.length; z++) {
      var ta = allTasks[z];

      var taskId = allTasksIds[z];

      // print('tasks above');

      var t2 = tasks
          .where((t) => t['mst_task']['task_name'] == ta)
          .map((t3) => t3['mst_structure']);

      var mstTaskId =
          tasks.where((t) => t['mst_task_id'] == taskId).map((t3) => t3['id']);

// var wrkScheduleGroupStructureId= tasks.where((t) => t['id'] == taskId).map((t3) => t3['id']);
      // print('mst_structure_id avbvove');

      var ob = {};
      // ob['wrkScheduleGroupStructureId'] = wrkScheduleGroupStructureId;
      ob['id'] = taskId;
      ob['task_name'] = ta;
      ob['isExpanded'] = false;
      ob['structures'] = t2;

      print('$ta  $taskId is task id');
      res.add(ob);
    }

    allTasks = res;

    return res;
  }

  Future<void> saveWorkDetails({
    required String workId,
    String? longitude,
    String? latitude,
    String? locationName,
    String? fromLocation,
    String? toLocation,
    String? measurementDetails,
    String? noOfLocations,
  }) async {
    logCurrentFunction();
    // Get existing work details from secure storage, if any

    final storage = FlutterSecureStorage();
    final existingDetails = await storage.read(key: 'workDetails') ?? '{}';
    final workDetails = Map<String, dynamic>.from(json.decode(existingDetails));

    // Update work details with new data, if any
    final workData = <String, dynamic>{
      if (longitude != null) 'longitude': longitude,
      if (latitude != null) 'latitude': latitude,
      if (locationName != null) 'locationName': locationName,
      if (measurementDetails != null) 'measurementDetails': measurementDetails,
      if (fromLocation != null) 'fromLocation': fromLocation,
      if (toLocation != null) 'toLocation': toLocation,
      if (noOfLocations != null) 'noOfLocations': noOfLocations,
    };
    workDetails[workId] = workData;

    // Store updated work details securely
    await storage.write(key: 'workDetails', value: json.encode(workDetails));
  }

  Future _sheduleBuilder() async {
    // logCurrentFunction();
    logCurrentFunction();
    if (_taskByName.length > 0) {
      return _taskByName;
    }

    print(_taskByName);
    print('sheduleBuilder CALLED');
    var workDetails = await _fetchWorkDetails(); //.then((workDetails) {

    if (workDetails.length == 1 && workDetails[0] == -1) {
      return Future.value(-1);
    }
    List wrkScheduleGroupStructures =
        workDetails[0]['wrk_schedule_group_structures'];

    // print(workDetails);
    // print('workDetails above');

    _taskByName = getTasksByName(wrkScheduleGroupStructures).toList();

    // var c = getTasksByName(workDetails).toList();

    _tasks = _taskByName;
    // print(c);

    var taskln = _taskByName.length;

    // print(' $taskln TASK LENGTH task list structure s see abobe 215');

    return Future.value(_taskByName.toList());
  }

  Future<void> initialSetup() async {
    logCurrentFunction();
    await _updateWorkDetailsOnLoading();
    audioCache = AudioCache(prefix: 'assets/audio/');

    print('$_numberOfLocations is numberof locations at 230');

    if (_enableEntryOfLocationDetails) {
      setState(() {
        this.steps = this.steps++;
        if (_numberOfLocations == 0) {
          this.userDirections = 'Enter Number of Locations';
          if (!isAudioMuted) {
            audioCache.play('no_of_loc.mp3');
          }
        } else if (!(_numberOfLocations > 0) && _fromLocation == '' ||
            _toLocation == '') {
          this.userDirections = 'Please Enter From and To Locations';
          if (!isAudioMuted) {
            audioCache.play('enter_from_to_location_name.wav');
          }
        } else if (_fromLocation != '' &&
            _toLocation != '' &&
            _numberOfLocations != 0) {
          this.userDirections = 'Select a Location';
          if (!isAudioMuted) {
            audioCache.play('select_location.wav');
          }
        }

// else {
//   this.userDirections = 'Invalid Number of Locations';
//   audioCache.play('invalid_loc.mp3');
// }
      });
    } else {
      setState(() {
        if (_numberOfLocations > 0 &&
            _fromLocation != '' &&
            _toLocation != '') {
          this.userDirections =
              'Now Select any Location to Starting with  L, Ensure correct location ';
          if (!isAudioMuted) {
            audioCache.play('select_location.wav');
          }
        }

        this.steps = 0;
        this.userDirections = 'Enter location details';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initialSetup();
    // ignore: todo
    // TODO: implement initState
  }

  Future<void> _updateWorkDetailsOnLoading() async {
    logCurrentFunction();

    final data = await getWorkDetails(widget.workId.toString(),
        measurementsetListId: widget.measurementSetId.toString());

    // print(data);

    print('data above 277');

    // return;

    setState(() {
      if (data != null &&
          data['fromLocation'] != null &&
          data['toLocation'] != null &&
          data['noOfLocations'] != null) {
        _workDetails = {};

        data.forEach((key, value) {
          _workDetails![key] =
              value ?? ''; // set the value to an empty string if it's null
        });

        _fromLocation = data['fromLocation']!;
        _toLocation = data['toLocation']!;
        _numberOfLocations = int.parse(data['noOfLocations']!) > 1000
            ? 999
            : int.parse(data['noOfLocations']!);

        // print(data['measurementDetails']);
        // print('measurementDetails above 111111');

        if (data['measurementDetails'] != null &&
                data['measurementDetails']?.length != 0

            // &&
            // jsonDecode(data['measurementDetails']!) != null

            ) {
          if (widget.measurementSetId.toString() == '-1') {
            measurementDetails = List<Map<dynamic, dynamic>>.from(
                jsonDecode(data['measurementDetails']));
          } else {
            var mout = jsonDecode(data['measurementDetails']);
            measurementDetails = List<Map<dynamic, dynamic>>.from(mout);

            debugger(when: true);
          }

          ///during normal fetching from storage its a striong

          getTasksofSelectedLocation();
        }

        if (_workDetails!['locations'] == null) {
          // _workDetails!['locations'] = 'hi';
          _workDetails!['locations'] ??= <dynamic, dynamic>{
            'key1': 'value1',
            'key2': 123,
            'key3': true
          };
        }

        // }

        // print(_workDetails);

        print('work details abobve $_numberOfLocations');

        _enableEntryOfLocationDetails = false;
      }
    });
  }

  String getUnitQuantity(
    Map<String, dynamic> jsonData,
    String type,
    int mstId,
    int mstStructureId,
  ) {
    final resultData = jsonData;

    // print(jsonData['unit_master']);

    // print('printing unit master abovbe $jsonData["unit_master"]');

    print('getting into unit qty function');

    print("type is $type unit master $resultData['unit_master']");

    if (resultData.containsKey('unit_master')) {
      final unitMaster = resultData['unit_master'];

      if (unitMaster.containsKey(type)) {
        final laboursOrMaterials = unitMaster[type];

        print(laboursOrMaterials);

        print('laboursOrMaterials above');

        if (laboursOrMaterials is List) {
          final matchingItem = laboursOrMaterials.firstWhere(
            (item) =>
                item['mst_${type}_id'] == mstId &&
                item['mst_structure_id'] == mstStructureId,
            orElse: () => null,
          );

          if (matchingItem != null && matchingItem.containsKey('quantity')) {
            return matchingItem['quantity'].toString();
          }
        }
      }
    }
    return 0.toString();
  }

  void sendObjectToSamagra(obj) async {
    setState(() {
      _savedToSamagra = true;
    });
    // var url =
    //     'http://192.168.1.215/api/send-object'; // Replace with your server endpoint

    // print(obj);

    // print(obj.runtimeType);

    var o = List.from(obj);

    var ts = [];

    // print("TASk measurements $taskMeasurements");

    Map<dynamic, dynamic> a =
        Map<String, dynamic>.from(await getMeasurementObjForApi(obj));

    print("A is $a");

    // var strcutreMeasurements =
    //     (await getMeasurementObjForApi(obj)) as Future<Map<dynamic, dynamic>>;

    return;

    // print(strcutreMeasurements);

    // var tasks = obj.forEach((o) => {
    //       o['tasks'].forEach((t) => {ts.add(t['task_name'])})
    //     });

    // print(ts.length);

    // sendObjectViaEmail(obj);

    return;

    // final myObject = obj; // Replace with your own object
    // final fileHelper = FileHelper();
    // await fileHelper.saveObjectAsFile(myObject, 'myObject.json');

    // return;
    // try {
    //   var response = await Dio().post(url, data: obj);

    //   if (response.statusCode == 200) {
    //     print('Object sent successfully!');
    //   } else {
    //     print('Request failed with status: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   print('Error: $e');
    // }
  }

  // Map getTaskMeasurementList(obj) {
  List getTaskMeasurementList(obj) {
    List taskMeasurements = [];
    Map tm = {};
    List tm1 = [];

    Map<String, int> taskCounts = {};

    for (var location in obj) {
      List<Map<dynamic, dynamic>> tasks =
          List<Map<dynamic, dynamic>>.from(location['tasks'] ?? []);
      for (var task in tasks) {
        String taskId = task['id'] ?? 'Unknown Task';
        if (taskCounts.containsKey(taskId)) {
          if (taskCounts[taskId] == null) {
            taskCounts[taskId] = 0;
            taskCounts[taskId] = (taskCounts[taskId]! + 1);
          }
        } else {
          taskCounts[taskId] = 1;
        }
      }
    }

    // print('Task Counts:');

    taskCounts.forEach((taskId, count) {
      // print("TASK NAME FROm $taskId");
      Map taskMeasurement = {};
      Map<String, dynamic> taskMeasurementDetails = {};

      taskMeasurementDetails["quantity"] = count;
      taskMeasurementDetails["mst_task_id"] = taskId;
      taskMeasurementDetails["plg_work_id"] = widget.workId;

      print('this is tm $taskMeasurementDetails');

      // taskMeasurement[taskId] = taskMeasurementDetails;

      // tm[taskId] = taskMeasurement;
      tm[taskId] = taskMeasurementDetails;
      tm1.add(taskMeasurementDetails);
    });
    // return tm;
    return tm1;
  }

  void updateStructureMeasurements(
      // List<Map<String, dynamic>> structureMeasurements, int targetId) {
      Map<dynamic, dynamic> structureMeasurements,
      int tgt,
      Map structure,
      taskId,
      wrkScheduleGroupStructureId) {
    String targetId = tgt.toString();
    bool structureExists = structureMeasurements.containsKey(targetId);

    if (structureExists) {
      // Increment the quantity if the structure exists

      structureMeasurements[targetId]['quantity'] =
          structureMeasurements[targetId]['quantity'] + 1;

      // structureMeasurements
      //     .firstWhere((structure) => structure['id'] == targetId)
      //     .update('quantity', (value) => value + 1);
    } else {
      Map<String, dynamic> result = {};
      Map<String, dynamic> str = Map<String, dynamic>.from(structure);

      structure['quantity'] = 1;

      result['quantity'] = 1;
      result['mst_structure_id'] = targetId;
      result['mst_task_id'] = taskId;
      result['wrk_schedule_group_structure_id'] = wrkScheduleGroupStructureId;

      print("wrkScheduleGroupStructureId $wrkScheduleGroupStructureId");

      structureMeasurements[targetId.toString()] = result;

      // Map<String, dynamic>.from(structure);
      // If the structure does not exist, add it with quantity 1
      // structureMeasurements.add({'id': targetId, 'quantity': 1});
    }
  }

  Future<List> getScheduleDetailsForMeasurement(String workId) async {
    // bool retVal = false;
    try {
      String baseUrlOld =
          "http://erpuat.kseb.in/api/wrk/getScheduleDetailsForMeasurement/NORMAL/$workId/0";

      String baseUrl =
          "http://erpuat.kseb.in/api/wrk/getScheduleDetailsForMeasurement/NORMAL/$workId/0";

      print("BASE UR mdtwm 136L $baseUrl");

      Dio dio = new Dio();

      dio = await setAccessTockenToDio(dio);

      Response response = await dio.get(baseUrl);
      if (response.statusCode == 200) {
        Map<dynamic, dynamic> apiData = response.data['result_data']['data'];

        print("api @693 $apiData");

        return apiData['wrk_schedule_group_structures'];
        // print("apidata at mdtwm $apiData");
      } else {
        return Future.value([]);
      }
    } catch (e) {
      print('error at 672 polvar screen $e');

      return Future.value([]);
    }
  }

  getMeasurementObjForApi(obj) async {
    // getScheduleDetailsForMeasurement(
    Map retObj = {};

    apiDataForSamagra['polevar_data'] = obj;

    await getWorkSheduleGroupStructuresfromSamgra();

    print("wrk_schedule_group_structures 693 $wrk_schedule_group_structures");

    // Map taskMeasurements = getTaskMeasurementList(obj);
    List taskMeasurements = getTaskMeasurementList(obj);

    apiDataForSamagra['taskMeasurements'] = taskMeasurements;
    // apiDataForSamagra['taskMeasurements'] = taskMeasurements;

    // apiDataForSamagra['taskMeasurements'] = taskMeasurements;

    // List<Map<String, dynamic>> structureMeasurements = [];
    // List taskMeasurements = [];
    Map<String, int> taskCounts = {};
    Map<String, dynamic> structureCounts = {};

    // print(obj);

    // List structureMeasurements = [];
    Map<String, Map<String, dynamic>> structureMeasurements = {};
    Map materialMeasurements = {};
    Map labourMeasurements = {};
    Map materialTakenBackMeasurements = {};

    // Map locationAndMaterialsView = {};
    // List locationList = [];
    // List<Map<String, dynamic>> totalMaterialList = [];
    Set<Map<String, dynamic>> totalMaterialList = {};

    for (var location in obj) {
      print('location $location');

      List<Map<dynamic, dynamic>> tasks =
          List<Map<dynamic, dynamic>>.from(location['tasks'] ?? []);

      if (tasks.isEmpty) {
        continue;
      }

      for (var task in tasks) {
        String taskId = (task["id"] ?? -1).toString();
        print("this is task $task");

        List<Map<dynamic, dynamic>> structures =
            List<Map<dynamic, dynamic>>.from(task['structures'] ?? []);

        if (structures.isEmpty) {
          continue;
        }

        for (var structure in structures) {
          // gmailMe(structure);
          // print("STRCUTRE ID $structure is str id");

          var mstStructureId = structure['id'];

          var wrkScheduleGroupStructure =
              wrk_schedule_group_structures.firstWhere(
            (item) =>
                item['mst_task_id'].toString() == taskId.toString() &&
                item['mst_structure_id'].toString() ==
                    mstStructureId.toString(),
            orElse: () => null,
          );
          var wrkScheduleGroupStructureId =
              wrkScheduleGroupStructure?['id'] ?? -1;

          // workScheduleGroupId
          debugger(when: true);

          updateStructureMeasurements(structureMeasurements, structure['id'],
              structure, taskId, wrkScheduleGroupStructureId.toString());

          List<Map<dynamic, dynamic>> materials =
              List<Map<dynamic, dynamic>>.from(structure['materials'] ?? []);

          List<Map<dynamic, dynamic>> labours =
              List<Map<dynamic, dynamic>>.from(structure['labour'] ?? []);
          // print(structure['labour']);

          // debugger;

          List<Map<dynamic, dynamic>> takenBacks =
              List<Map<dynamic, dynamic>>.from(structure['takenBacks'] ?? []);

          int labourLen = labours.length;
          int takenbackLen = takenBacks.length;

          if (materials.length > 0) {
            Map<String, dynamic> mat = {};

            print('materialx $materials');

            materials.forEach((mat1) {
              mat['material_name'] = mat1['material_name'];
              mat['mst_material_id'] = mat1['mst_material_id'];
              mat['material_code'] = mat1['material_code'];
            });

            totalMaterialList.add(mat);
            // debugger(when: true);

            // // mat['material_name'] = materials['material_name'];
            // mat['material_code'] = materialMeasurements['material_code'];
            // mat['mst_material_status'] =
            //     materialMeasurements['mst_material_status'];

            // totalMaterialList.add(mat);

            updateMaterialmeasurements(materialMeasurements, materials);
          }

          if (labours.length > 0) {
            // print("LABOURS IS $labours");

            updateLabourmeasurements(labourMeasurements, labours);
          }

          if (takenBacks.length > 0) {
            updateMaterialTakenBackMeasurements(
                materialTakenBackMeasurements, takenBacks);
          }

          // print("LABOURr  $labours");
          // debugger;
        }

        // List<Map<dynamic, dynamic>>.from(task['structures'] ?? []);

        // print("this is tasks $tasks");

        print('totalmaterial list  $totalMaterialList');

        // debugger(when: true);
      }

      setState(() {
        _savedToSamagra = false;
      });
    }

    apiDataForSamagra['structreMeasurements'] = structureMeasurements;
    apiDataForSamagra['labourMeasurements'] = labourMeasurements;
    apiDataForSamagra['materialMeasurements'] = materialMeasurements;
    apiDataForSamagra['materialTakenBackMeasurements'] =
        materialTakenBackMeasurements;

    // print("qqqmaterialTakenBackMeasurements $materialTakenBackMeasurements");
    // print("qqqSTR  MEASUREMENT $structureMeasurements");
    // print("qqqLABOUR MEASUREMENT $labourMeasurements");
    // print("qqqmaterial  MEASUREMENT $materialMeasurements");
    // print("qqqtasks  MEASUREMENT $taskMeasurements");

    // debugger;

    //       Map materialMeasurements = {};
    // Map labourMeasurements = {};
    // Map materialTakenBackMeasurements

    print('all materials $totalMaterialList');
    // debugger(when: true);

    apiDataForSamagra['workId'] = widget.workId;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaveToWorkModule(
            dataFromPreviousScreen: apiDataForSamagra,
            workId: widget.workId,
            workScheduleGroupId: widget.workScheduleGroupId),
      ),
    );

    print('test');
    // debugger;
    return Future.value({});

    // print("Strcutre measurement  is this $structureMeasurements");

    // speakText('നമസ്കാരം, ഇത് മലയാളം ആവാസം ആണ്‌.');

    // await flutterTts.speak('നമസ്കാരം, ഇത് മലയാളം ആവാസം ആണ്‌.');

    // print(obj.length);
  }

  Future<void> getWorkSheduleGroupStructuresfromSamgra() async {
    wrk_schedule_group_structures =
        await getScheduleDetailsForMeasurement(widget.workId.toString());
  }

  dynamic updateMeasurementDetails(
      String locationNo, Map<dynamic, dynamic> newObject) {
    print("from parent function $newObject");
    setState(() {
      // Find the index of the locationNo in measurementDetails
      int index = measurementDetails.indexWhere((details) =>
          details['locationNo'].toString() == locationNo.toString());

      if (index != -1) {
        // Update the object at the specified location

        print('updating');
        measurementDetails[index] = newObject;
      } else {
        print('ading');
        measurementDetails.add(newObject);
      }
    });

    measurementDetails.forEach((element) {
      print("LOCS NEW ${element['locationNo']} $element");
    });
    _saveMeasurementDetails();
    setState(() {
      _openedMeasurementCopier = true;
      _openedMeasurementCopier = false;
    });

    // setState(() {
    //   _openedMeasurementCopier = false;
    // });
  }

  void _showMeasurementCopierDialog(BuildContext context) {
    setState(() {
      _openedMeasurementCopier = !_openedMeasurementCopier;
    });
    measurementDetails.forEach((element) {
      print("current m dstails $element");
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Measurement Property Copier'),
          content: AspectRatio(
            aspectRatio: .1,
            child: MeasurementPropertyCopierScreen(
                measurementDetails: measurementDetails,
                noOfLocations: _numberOfLocations,
                updateMeasurementDetails: updateMeasurementDetails),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _openedMeasurementCopier = false;
                });
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                measurementDetails.forEach(
                  (element) {
                    print("MEASURESMENT LIST loc ${element["locationNo"]}");
                  },
                );

                setState(() {});
                Navigator.of(context).pop();

                setState(() {
                  _openedMeasurementCopier = false;
                });
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  _handleEmitLocDetailsToPolVarWidget(Map locDetails) async {
    logCurrentFunction();
    setState(() {
      _showSpinnerForAsync = true;
      int locationNumber = _selectedLocationIndex + 1;

      Map existingMeasurementDetails = measurementDetails.firstWhere(
          (element) => element['locationNo'] == locationNumber,
          orElse: () => Map<String, dynamic>());

      debugger(when: true);
      if (existingMeasurementDetails.isEmpty) {
        print(existingMeasurementDetails);
        print('existng param above');

        print(locDetails);

        print('locDetais new above');

        if (locDetails.isNotEmpty) {
          existingMeasurementDetails = {
            ...existingMeasurementDetails,
            ...locDetails
          };

          print(existingMeasurementDetails);
        }

        print('new exiasting details above');
        int locationNumber = _selectedLocationIndex + 1;
        int indexToUpdate = measurementDetails
            .indexWhere((details) => details['locationNo'] == locationNumber);

        if (indexToUpdate != -1) {
          setState(() {
            measurementDetails[indexToUpdate] =
                Map<String, dynamic>.from(existingMeasurementDetails);
          });
        } else {
          print('adding new');

          setState(() {
            measurementDetails
                .add(Map<String, dynamic>.from(existingMeasurementDetails));
          });

          int ln = measurementDetails.length;

          print('measurement details length $ln');
        }
      }

      print(existingMeasurementDetails);
      print('existing mesr detaiks above');

      print('from parent location details just above as map');

      // widget.latitude = p1;
      // widget.longitude = p2;
      // widget.locationName = name;

      // widget.locationDetails['lattitude'] = p1.toString();
      // widget.locationDetails['longitude'] = p2.toString();
      // widget.locationDetails['name'] = name.toString();
      // // widget.locationDetails['name'] = name.toString();
    });

    // print(measurementDetails[2]);
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _showSpinnerForAsync = false;
      viewStructures = true;
    });

    this.userDirections =
        'NOW Select Task and then correct structure inside it ';
    if (!isAudioMuted) {
      audioCache.play('select_structure.wav');
    }
    // print(this._workDetails);

    // print(' measurementDetails above');
  }

  //

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _sheduleBuilder(),
        builder: (context, AsyncSnapshot snapshot) {
          if ((!snapshot.hasData &&
              snapshot.data == -1 &&
              snapshot.data == null)) {
            return Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }

          var tasklist1 = snapshot.data;

          // ignore: unrelated_type_equality_checks
          if (tasklist1 == null || tasklist1 == -1) {
            return Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }

          int ln = tasklist1.length;

          _taskList = tasklist1;

          return
              //
              // _showSpinnerForAsync
              //     ? Center(
              //         child: SizedBox(
              //           width: 50,
              //           height: 50,
              //           child: CircularProgressIndicator(
              //             color: Colors.amberAccent,
              //             strokeWidth: 20,
              //           ),
              //         ),
              //       )
              //     :

              SafeArea(
            child: Container(
              padding: EdgeInsets.all(1),
              child: Scaffold(
                bottomNavigationBar: BottomAppBar(
                  shape: CircularNotchedRectangle(),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _savedToSamagra
                            ? CircularProgressIndicator()
                            : IconButton(
                                color: Colors.green,
                                icon: Icon(Icons.send_sharp),
                                onPressed: () =>
                                    {sendObjectToSamagra(measurementDetails)},
                                tooltip: 'Save to samagra'),
                        IconButton(
                          icon: Icon(
                            Icons.copy,
                            color: Color.fromARGB(255, 3, 64, 246),
                          ),
                          onPressed: () =>
                              _showMeasurementCopierDialog(context),
                          tooltip: 'M- Copier',
                        ),
                        IconButton(
                            icon: Icon(Icons.remove_red_eye),
                            onPressed: () => {
                                  setState(
                                    () {
                                      _viewFullLocationList =
                                          !_viewFullLocationList;
                                    },
                                  )
                                },
                            tooltip: _viewFullLocationList
                                ? 'Hide Detailed View of Locations'
                                : "View Detailed View of Locations")
                      ]),
                ),
                floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.place),
                  onPressed: () {
                    _gotToAnotherLocation();
                    // Add functionality for when the button is pressed
                    // print('Button pressed!');
                  },
                ),
                appBar: AppBar(
                  backgroundColor: AppTheme.grey.withOpacity(0.7),
                  title: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          userDirections,
                          key: ValueKey<String>(userDirections),
                          style: TextStyle(fontSize: 11, color: Colors.red),
                        ),
                        // VoiceControl(),
                      ],
                    ),
                  ),
                ),
                body: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 10,
                  child: SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 2,
                      margin: EdgeInsets.all(16.0),
                      child: Column(
                        // mainAxisSize: MainAxisSize.min,
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          WorkNameWidget(
                            workName: widget.workName +
                                '\n\nWork Code : ${widget.workCode}',
                            color: Colors.blue,
                            workId: widget.workId.toString(),
                          ),
                          enterLocationDetails(),
                          locationNumberAndLocationPointsEntryScreen(),
                          if (_selectedLocationIndex == -1 &&
                              !_enableEntryOfLocationDetails) ...[
                            Visibility(
                                visible: !_openedMeasurementCopier,
                                child: showLocationButtons())

                            // for showing loading issued material
                          ],
                          if ((!_enableEntryOfLocationDetails &&
                              _numberOfLocations > 0 &&
                              _numberOfLocations < 999 &&
                              _fromLocation != '' &&
                              _toLocation != '')) ...[
                            Divider(
                              height: 5,
                              thickness: 2,
                              color: Colors.blueAccent,
                            ),

                            // Visibility(
                            //   // visible: _showAnotherLocationButton

                            //   visible: _selectedLocationIndex != -1

                            //   //  &&
                            //   //     !_showSaveMeasurementDetailsButton
                            //   ,
                            //   child: Row(
                            //     children: [
                            //       Spacer(),
                            //       ElevatedButton(
                            //           onPressed: () =>
                            //               {_gotToAnotherLocation()},
                            //           child: Text('Go to  Another Location')),
                            //       Spacer(),
                            //     ],
                            //   ),
                            // ),
                            Visibility(
                              visible: (_showSaveMeasurementDetailsButton ||
                                  (_showAnotherLocationButton &&
                                      !_showSaveMeasurementDetailsButton) ||
                                  _showSubmitToSamagraButton),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 1.5,
                                child: Row(
                                  children: [
                                    Visibility(
                                      visible:
                                          _showSaveMeasurementDetailsButton &&
                                              false,
                                      child: ElevatedButton(
                                          onPressed: () =>
                                              {_saveMeasurementDetails()},
                                          child: Text('Save')),
                                    ),
                                    Visibility(
                                      visible: _showSubmitToSamagraButton,
                                      child: ElevatedButton(
                                          onPressed: () => {},
                                          child: Text('Submit to Samagara')),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Visibility(
                              visible: _selectedLocationIndex != -1,
                              child: IntrinsicHeight(
                                child: SizedBox(
                                  // height: 200,
                                  width: 500,
                                  child: Row(children: [
                                    Column(
                                      children: [
                                        // _selectedLocationHasGeoLocations
                                        if (!_selectedLocationHasGeoLocations)
                                          LocationDetailsWidget(
                                              hasLocationDetailsInStorage:
                                                  _hasLocationDetailsInStorage,
                                              locationDetails: {},
                                              updateLocationDetailsArray:
                                                  _updateLocationDetailsArray,
                                              locationNo: _selectedLocationIndex
                                                  .toString(),
                                              measurements: List<String>.from(
                                                _selectedMeasurements,
                                              ),
                                              emitLocDetailsToPolVarWidget:
                                                  _handleEmitLocDetailsToPolVarWidget)
                                        // ,

                                        ,
                                        // SizedBox(
                                        //   height:
                                        //       MediaQuery.of(context).size.height *
                                        //           8,
                                        //   width:
                                        //       MediaQuery.of(context).size.width * 8,
                                        //   child: MeasurementDisplayWidget(
                                        //       measurementDetails),
                                        // )

                                        // // viewAllLocationDetails(context),
                                        // ,
                                      ],
                                    )
                                  ]),
                                ),
                              ),
                            ),
                            // Divider(color: Colors.white10, thickness: 10),
                            // SizedBox(height: 50),

                            viewLocationList(tasklist1),

                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Spacer(),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Visibility(
                                visible: _selectedLocationTasks.length > 0,
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 1),
                                        color: ksebColor),
                                    child: Text(
                                        "Task view of This Location\n Enter Mesasured Quantity",
                                        style: TextStyle(
                                          shadows: [
                                            Shadow(
                                              blurRadius: 1.0,
                                              color: const Color.fromARGB(
                                                  255, 158, 158, 158),
                                              offset: Offset(1.0, 1.0),
                                            ),
                                          ],
                                          fontSize: 18,
                                          color: Colors.amber,
                                        )))),

                            Visibility(
                              visible: _selectedLocationTasks.length > 0,
                              // visible: true,
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    border: Border.all(width: 1),
                                    color: ksebColor),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: LocationMeasurementView(
                                      tasks: List<Map<dynamic, dynamic>>.from(
                                          _selectedLocationTasks),
                                      reflectQuantityDetails:
                                          reflectQuantityDetails),
                                ),
                              ),
                            ),

                            Visibility(
                              visible: _viewFullLocationList,
                              child: SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: MeasurementDisplayWidget(
                                      measurementDetails)),
                            ),

                            Spacer(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Row VoiceControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: 50,
          ),
          onPressed: togglePlay,
        ),
        IconButton(
          icon: Icon(
            isMuted ? Icons.volume_off : Icons.volume_up,
            size: 50,
          ),
          onPressed: toggleMute,
        ),
        ElevatedButton(
          child: Text('Play Again'),
          onPressed: () {
            setState(() {
              isPlaying = true;
            });
          },
        ),
        ElevatedButton(
          child: Text('Stop'),
          onPressed: stop,
        ),
      ],
    );
  }

  SizedBox viewAllLocationDetails(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .4,
      child: ListView.builder(
          // itemCount: _numberOfLocations,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                LocationDetailsWidget(
                    hasLocationDetailsInStorage: _hasLocationDetailsInStorage,
                    locationDetails: {},
                    updateLocationDetailsArray: _updateLocationDetailsArray,
                    locationNo: _selectedLocationIndex.toString(),
                    measurements: List<String>.from(
                      _selectedMeasurements,
                    ),
                    emitLocDetailsToPolVarWidget:
                        _handleEmitLocDetailsToPolVarWidget),
                SizedBox(
                  height: 300,
                  // child: Text('hi'),

                  child: MeasurementDisplayWidget(measurementDetails),
                )
              ],
            );
          }),
    );
  }

  // ignore: non_constant_identifier_names

  _updateLocationDetailsArray(arr) async {
    logCurrentFunction();
    print('$arr @ 556');

    if (arr != null && this._workDetails != null) {
      if (this._workDetails!['locations'] == null) {
        this._workDetails!['locations'] = {};
      }
      this._workDetails!['locations'][this._selectedLocationIndex.toString()] =
          arr;

      // await Future.delayed(Duration(seconds: 10));

      // setState(() {
      //   viewStructures = true;
      // });

      // this.userDirections =
      //     'NOW Select Task and then correct structure inside it ';
      // audioCache.play('select_structure.wav');

      // print(this._workDetails);
    }

// this.
  }

  AnimatedOpacity enterLocationDetails() {
    return AnimatedOpacity(
        opacity: _enableEntryOfLocationDetails ? 1.0 : 0.0,
        duration: Duration(milliseconds: 3000),
        child: Visibility(
            visible: _enableEntryOfLocationDetails,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 80,
                    child: TextFormField(
                      maxLength: 3,
                      initialValue: _numberOfLocations.toString(),
                      // controller: TextEditingController(
                      //     text: _numberOfLocations.toString()),
                      decoration: InputDecoration(
                        labelText: 'Number of Locations',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30))),
                      ),
                      keyboardType: TextInputType.number,

                      onEditingComplete: () {},
                      onChanged: (value) {
                        setState(() {
                          _numberOfLocations = int.tryParse(value) ?? 0;

                          if (_numberOfLocations > 0) {
                            this.userDirections =
                                'NOW ENTER FROM AND TO LOCATIONS';
                            if (!isAudioMuted) {
                              audioCache
                                  .play('enter_from_to_location_name.wav');
                            }
                          }
                          this.steps = this.steps++;
                        });
                      },
                    ),
                  ),
                ),
                Divider(
                  height: 20,
                  thickness: 2,
                  color: Colors.blueAccent,
                ),
                Visibility(
                  visible: _numberOfLocations > 0 && _numberOfLocations < 999,
                  child: Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'From Location',
                            border: OutlineInputBorder(),
                          ),
                          child: TextFormField(
                            initialValue: _toLocation,
                            onChanged: (value) async {
                              String from = ' _fromLocation';
                              String to = '_toLocation';

                              if (_fromLocation != '' && _toLocation != '') {
                                await Future.delayed(Duration(seconds: 3));

                                if (from == _fromLocation &&
                                    to == _toLocation) {
                                  this.userDirections = 'Now Press save ';

                                  if (!isAudioMuted) {
                                    audioCache.play('press_save_button.mp3');
                                  }
                                } else {
                                  from = _fromLocation;
                                  to = _toLocation;
                                }
                              }

                              setState(() {
                                _fromLocation = value;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'To Location',
                            border: OutlineInputBorder(),
                          ),
                          child: TextFormField(
                            initialValue: _toLocation.toString(),
                            onChanged: (value) {
                              setState(() {
                                _toLocation = value;

                                if (_fromLocation != '' && _toLocation != '') {
                                  this.userDirections = 'Now Press save ';
                                  if (!isAudioMuted) {
                                    audioCache.play('press_save_button.mp3');
                                  }
                                  this.steps = this.steps++; //3
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: (_numberOfLocations > 0 &&
                      _numberOfLocations < 999 &&
                      _fromLocation != '' &&
                      _toLocation != ''),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: saveFromAndTwoLocation,
                        icon: Icon(Icons.save),
                        color: Color.fromARGB(255, 33, 33, 33),
                        tooltip: 'Save Location Details',
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }

  AnimatedOpacity locationNumberAndLocationPointsEntryScreen() {
    return AnimatedOpacity(
      opacity: !_enableEntryOfLocationDetails ? 1.0 : 0.0,
      duration: Duration(milliseconds: 3000),
      child: Visibility(
        visible: !_enableEntryOfLocationDetails,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(.0),
              child: WorkNameWidget(
                workName:
                    ' Number  of location Measured : $noOFLocationsMeasured    \n Total  Locations : ' +
                        _numberOfLocations.toString(),
                workId: widget.workId.toString(),
              ),
            ),
            Divider(
              height: 5,
              thickness: 2,
              color: Colors.blueAccent,
            ),
            Row(
              children: [
                Expanded(
                  child: WorkNameWidget(
                    workName: 'From :  $_fromLocation',
                    color: Color(0xFF000080),
                    workId: '',
                  ),

                  // Text('From : ' + _fromLocation),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: WorkNameWidget(
                    workName: 'To  : ' + _toLocation,
                    color: Color(0xFF0080800),
                    workId: '',
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: saveFromAndTwoLocation,
                  icon: Icon(Icons.edit),
                  color: Color.fromARGB(255, 4, 181, 235),
                  tooltip: 'Edit ',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Visibility viewLocationList(tasklist1) {
    // return Visibility(child: Text('hi'));

    return Visibility(
      visible: !_enableEntryOfLocationDetails,
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fetchingMasterEstimate
              ? Center(
                  child: SizedBox(
                  width: MediaQuery.of(context).size.width * .5,
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    semanticsValue: AutofillHints.photo,
                    semanticsLabel: 'Please wait',
                  ),
                ))
              : viewTasksAndStructures(tasklist1),
          // Text(_selectedLocationIndex.toString()),
        ],
      ),
    );
  }

// ...

  SizedBox showLocationButtons() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .3,
      // width: MediaQuery.of(context).size.height * 1.4,
      child: ListView.builder(
        itemCount: _numberOfLocations,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          var status = _getLocationMeasuredStatus(index);

          // print("STATUS OF LOC $index $status");

          bool hasGeoLocations = status['hasGeoLocations'] as bool;
          bool hasMeasurements = status['hasMeasurements'] as bool;

          // bool completed = hasGeoLocations && hasMeasurements;

          // print(status);
          // print('status above at 1076');

          var geoCordinates;

          if (status['geoCordinates'] != null) {
            geoCordinates = status['geoCordinates'] as Map<dynamic, dynamic>;
          }

          var geoCordinatesEnd;
          if (status['geoCordinatesEnd'] != null) {
            geoCordinatesEnd =
                status['geoCordinatesEnd'] as Map<dynamic, dynamic>;
          }

          // print("viii this is status $status");
          // print(
          //     'geocordinates above @1095 is location ${index + 1} $geoCordinatesEnd and $geoCordinates');

          String distanceText = '0 Meters';

          if (geoCordinates != null) {
            double startLatitude =
                (geoCordinates['latitude'] ?? 0.0).toDouble();
            double startLongitude =
                (geoCordinates['longitude'] ?? 0.0).toDouble();

            // Replace `endLatitude` and `endLongitude` with the coordinates of the other location
            if (geoCordinatesEnd != null) {
              double endLatitude = geoCordinatesEnd['latitude'] ?? 0.0;
              double endLongitude = geoCordinatesEnd['longitude'] ?? 0.0;

              double distance = Geolocator.distanceBetween(
                startLatitude,
                startLongitude,
                endLatitude,
                endLongitude,
              );

              // print(geoCordinates.runtimeType);
              // print(geoCordinatesEnd.runtimeType);
              // print('geocordinates above @1081 is location ${index + 1}');

              distanceText = ' ${distance.toStringAsFixed(2)} mtrs';
            }
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => _viewLocationDetail(index, status),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: (index == _tappedIndex)
                        ? Color.fromARGB(255, 56, 96, 58)
                        : (hasGeoLocations && hasMeasurements)
                            ? Color.fromARGB(74, 10, 54, 229)
                            : Color.fromRGBO(241, 78, 3, 0.6),
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        CircleAvatar(child: Text('L  ${(index + 1)}')),

                        SizedBox(
                          height: 5,
                        ),
                        Visibility(
                          visible: hasMeasurements,
                          child: ElevatedButton(
                            onPressed: () {
                              Map obj = measurementDetails.firstWhere(
                                (element) => element['locationNo'] == index + 1,
                                orElse: () => {},
                              );
                              viewMeasurementExtract(context, obj);
                            },
                            child: Text('Details'),
                          ),
                        ),

                        // CustomButtonRow(
                        //     locationNumber: (index + 1), workId: widget.workId),

                        SizedBox(
                          height: 5,
                        ),

                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                // Get the location number from the index.
                                // int locationNo = measurementDetails[index];

                                var locationNo = index + 1;

                                // Show a confirmation dialog.
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Delete Location?'),
                                      content: Text(
                                          'Are you sure you want to delete location number $locationNo?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            // Remove the location from the list.
                                            measurementDetails.removeWhere(
                                                (element) =>
                                                    element['locationNo']
                                                        .toString() ==
                                                    locationNo.toString());

                                            setState(() {});
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Delete'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Dismiss the dialog.
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              color: Colors.amber,
                              icon: Icon(Icons.view_agenda),
                              onPressed: () {
                                _viewLocationDetail(index, status);
                                // Handle the button press
                                // You can add the logic to navigate to the location detail
                              },
                              tooltip: 'GO',
                            ),
                          ],
                        ),

                        Container(
                            alignment: AlignmentDirectional.bottomStart,
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: LocationMeasurementProgress(
                                    hasGeoLocations: hasGeoLocations,
                                    hasMeasurements: hasMeasurements)

                                //  Text(
                                //   status['text'].toString(),
                                //   style: TextStyle(
                                //     color: status['color'] as Color,
                                //   ),
                                // )
                                //
                                )),

                        // Container(
                        //   width: MediaQuery.of(context).size.width / 3,
                        //   child: Flexible(
                        //     child: Text(
                        //       distanceText,
                        //       style: TextStyle(
                        //         color: status['color'] as Color,
                        //       ),
                        //       maxLines: null, // Allow unlimited lines
                        //       overflow: TextOverflow.visible,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              if (geoCordinatesEnd != null) ...[
                Container(
                    margin: EdgeInsets.all(1.0), child: Text(distanceText))
              ]
            ],
          );
        },
      ),
    );
  }

  void viewMeasurementExtract(BuildContext context, Map<dynamic, dynamic> obj) {
    ViewTabbedViewOfComponentsInLocation _ViewTabbedViewOfComponentsInLocation =
        ViewTabbedViewOfComponentsInLocation(
      componentsMap: obj,
    );

    _ViewTabbedViewOfComponentsInLocation.showComponentsPopUp(context, obj);
  }

  Widget arrowWithText(String text) {
    return CustomPaint(
      painter: ArrowWithTextPainter(text),
    );
  }

  t(String text) {
    return CustomPaint(
      painter: ArrowWithTextPainter(text),
    );
  }

  Visibility viewTasksAndStructures(tasklist1) {
    // print(tasklist1);
    // print('taskList abobve  polvar911');
    return Visibility(
      visible: viewStructures,
      child: Expanded(flex: 4, child: expansionPanelOfTask(tasklist1)),
    );
  }

  Visibility viewLocationDetailsX() {
    return Visibility(
        visible: _enableEntryOfLocationDetails,
        child: Text('View111111111111111111111111111111'));

    return Visibility(
      visible: _enableEntryOfLocationDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: Colors.blue,
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter Text Here',
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.red,
                    child: Center(
                      child: Text('Bottom Text Box 1'),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.green,
                    child: Center(
                      child: Text('Bottom Text Box 2'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.yellow,
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // do something
              },
            ),
          ),
        ],
      ),
    );
  }

  Column expansionPanelOfTask(tasklist1, {int index = 0}) {
//  var structures = tasklist1[index]['tasks'].toList();

    int counter = 0;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Select details fom Task List',
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.pink[10]),
          ),
        ),
        ExpansionPanelList(
            key: GlobalKey(),
            expansionCallback: (int panelIndex, bool isExpanded) {
              setState(() {
                for (int i = 0; i < tasklist1.length; i++) {
                  tasklist1[i]['isExpanded'] = false;
                  // tasklist1[i]['isExpanded'] = !tasklist1[i]['isExpanded'];
                }

                tasklist1[panelIndex]['isExpanded'] = isExpanded;
                print(
                    'expansion panel index $panelIndex  and isExpanded is $isExpanded && ${tasklist1[panelIndex]['isExpanded']}');

                //
              });
            },
            children: tasklist1.map<ExpansionPanel>((t) {
              // print('$ind is ind');

              var structures = t['structures'];
              // print(t);
              // print('tabove');

              print('is  yyy  expanded ${t['isExpanded']}');

              counter++;
              return ExpansionPanel(
                // canTapOnHeader: true,
                // isExpanded: true,

                isExpanded: t['isExpanded'] ?? false,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(
                      t['task_name'].toString(),
                    ),
                  );
                },
                body: Column(
                    children: structures.map<Widget>((st) {
                  return GestureDetector(
                    onDoubleTap: () => _showBottomSheet(context),
                    child: Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                children: [
                                  Text(
                                    st["structure_name"] ?? 'ERROR',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent),
                                  ),
                                ],
                              )),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  // Decrement task quantity
                                },
                              ),
                              Text((st['quantity'] ?? 0)
                                  .toString()), // Display task quantity
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () async {
                                  await this.getMasterEstimateForStructureItem(
                                      widget.workId, t, st);

                                  // st["id"], st['qty'] ?? 0, st);

                                  // _showBottomSheet(context);

                                  // Increment task quantity
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );

                  // Text(st["structure_name"]);
                }).toList()

                    //  [Text(counter.toString(), Text('2')]

                    //  tasklist1[ind]['tasks']
                    //     .map((structure) => {Text(structure['structure_name'])})
                    //     .toList()

                    // children: getStructuresOfTask(tasklist1[ind]['tasks']),
                    ),
              );
            }).toList()),
      ],
    );
  }

  List<Widget> getStructuresOfTask(List tasks) {
    if (tasks.isEmpty) {
      return [Text('No tasks found.')];
    }

    print(tasks);

    print('tasks above from panel  childern inside');

    return [Text('t1'), Text('t2')];

    return tasks.map<Widget>((struct) {
      // print(t);

      var currentItem = measurementDetails.firstWhere(
        (element) => element['locationNo'] == _selectedLocationIndex + 1,
        orElse: () => {},
      );

      /// find structure using structure code for currentItem
      /// find structure using structure code for currentItem

      var str = struct['structure_name'] as String;

      // int taskCount=

      var mstStructureId = struct['structure_code'];

      // print(mstStructureId);

      if (str == null) {
        return Text('Invalid task.');
      }

      return GestureDetector(
        onDoubleTap: () => _showBottomSheet(context),
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Wrap(
                    children: [
                      Text(
                        str,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      ),
                    ],
                  )),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      // Decrement task quantity
                    },
                  ),
                  Text('2'), // Display task quantity
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      await this.getMasterEstimateForStructureItem(
                          mstStructureId, 2, struct);
                      // _showBottomSheet(context);

                      // Increment task quantity
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> getStructuresOfTask1(tasks) {
    if (tasks == null || tasks.isEmpty) {
      return [Text('error')];
    }

    var a = tasks.map((t) {
      var str = t['structure_name'] as String; // cast to String

      if (str == null) {
        return Text('hi');
      }

      // ignore: unnecessary_cast
      return Card(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(str),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    // item.quantity--;
                  });
                },
              ),
              // Text(item.quantity.toString()),
              Text('2'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    // item.quantity++;
                  });
                },
              ),
            ],
          ),
        ],
      )) as Widget;

      // return Container(child: Text(str));
    }).toList();

    return a;
    // return [Text('1'), Text('2')];
  }

  Future<String> getAccessToken() async {
    logCurrentFunction();
    final secureStorage = FlutterSecureStorage();
    final accessToken = await secureStorage.read(key: 'access_token');
    return Future.value(accessToken);
  }

  Future<void> getMasterEstimateForStructureItem(
    workId,
    task,
    strcuture,
  ) async {
    logCurrentFunction();
    try {
      setState(() {
        _fetchingMasterEstimate = true;
      });

      final dio = Dio();

      int mstStructureId = strcuture['id'];
      String structureName = strcuture['structure_name'] ?? 'BUG in struc name';

      String taskId = task['id'].toString();

      final url =
          "http://erpuat.kseb.in/api/wrk/getScheduleForMobilePolevar/$_wrk_schedule_group_id/$taskId/$mstStructureId";

      final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};

      Response<dynamic> response;
      try {
        final response1 = await dio
            .get(
          url,
          options: Options(headers: headers),
        )
            .catchError((er) {
          throw Exception('Intert error');
        });

        response = response1;

        // debugger(when: true);
      } catch (e) {
        final snackBar = SnackBar(
          content: Text('Internet error $e'),
          duration:
              Duration(seconds: 3), // How long the snackBar will be displayed
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              // Code to execute when 'Close' is pressed
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        setState(() {
          _fetchingMasterEstimate = false;
        });

        return;
      }

      print("LOCATION NUMBER $_selectedLocationIndex $response.data");

      if (response.data != null && response.data['result_data'] != null) {
        var re = response.data['result_data'];

        var issuedMaterialsForSelectedStructure = re['issues'];

        var totalLabourDetails =
            response.data['result_data']['labour_schedule'];

        var resultData = response.data['result_data'];
        var takenBacksOfSelectedStructure = resultData['takenbacks'];

        var responseDataForStructureDetails = response.data['result_data'];
        var master = response.data['result_data']['unit_master'];

        var out = measurementDetails.firstWhere(
          (element) => element['locationNo'] == _selectedLocationIndex + 1,
          orElse: () => {},
        );

        if (out.length > 0) {
          setState(() {
            _selectedLocationDetails = Map<String, dynamic>.from(out);

            _selectedLocationTasks = out['tasks'] ?? [];
          });
        }

        print("SELCTD LOCATION TAKS $_selectedLocationDetails");
        measurementDetails.forEach((location) {
          int locationNumber = _selectedLocationIndex + 1;

          if (location['locationNo'] != locationNumber) {
            return;
          }

          if (location['locationNo'] == locationNumber) {
            if (location['tasks'] == null) {
              location['tasks'] = [];
            }

            bool isTaskPresent =
                location['tasks'].any((task) => task['id'] == taskId);

            var task;
            if (isTaskPresent) {
              task =
                  location['tasks'].firstWhere((task) => task['id'] == taskId);
            } else {
              task = {};
              initiateTaskDetails(task, taskId, mstStructureId, structureName);
              location['tasks'].add(task);
            }

// print(tasks)
            if (task['structures'] == null) {
              task['structures'] = [];
            }

            if (task['structures'].any((s) => s['id'] == mstStructureId)) {
              var structure = task['structures'].firstWhere(
                  (s) => s['id'] == mstStructureId,
                  orElse: () => {});
              structure['quantity'] = structure['quantity'] + 1;
            } else {
              var selectedStructure = {};
              selectedStructure['materials'] = [];
              selectedStructure['labour'] = [];
              selectedStructure['takenBack'] = [];

              selectedStructure['quantity'] = 1;
              selectedStructure['structure_name'] =
                  structureName ?? 'str Name Not Found';
              selectedStructure['id'] = mstStructureId;

              if (issuedMaterialsForSelectedStructure != null &&
                  responseDataForStructureDetails != null) {
                setIssuedmaterials(
                    issuedMaterialsForSelectedStructure,
                    responseDataForStructureDetails,
                    mstStructureId,
                    selectedStructure);
              }

              if (totalLabourDetails != null &&
                  responseDataForStructureDetails != null) {
                setLabourDetails(
                    totalLabourDetails,
                    responseDataForStructureDetails,
                    mstStructureId,
                    selectedStructure);
              }

              if (takenBacksOfSelectedStructure != null) {
                setTakenBacks(takenBacksOfSelectedStructure, selectedStructure);
              }

              task['structures'].add(selectedStructure);
            }

            updateQuantityOfStructureInStrucureList(taskId, mstStructureId);
            _showSaveMeasurementDetailsButton = true;

            print("BEFORE CALLING SAVE MEASUREMENT DETAILS");
            _saveMeasurementDetails();
            return;
          }

          return;
        });
      }
    } catch (e) {
      print("$e is the try cathc error at 1975 of polvar");
    }

    setState(() {
      _fetchingMasterEstimate = false;
    });

    // getTasksofSelectedLocation();
  }

  initiateTaskDetails(Map<dynamic, dynamic> task, String taskId,
      int mstStructureId, String structureName) {
    task['id'] = taskId;

    var selectedTask = _tasks.firstWhere(
      (element) => element['id'].toString() == taskId.toString(),
      orElse: () {},
    );

    if (selectedTask != null && selectedTask['task_name'] != null) {
      task['task_name'] = selectedTask['task_name'];

      // var str1 = selectedTask['structures'].firstWhere(
      //   (element) => element['id'].toString() == mstStructureId.toString(),
      //   orElse: () {},
      // );

      // print(str1);
      // print('str1 above @1488');
      // structureName = str1['structure_name'];

      print('---------------------------$structureName');
    } else {
      print('some issue with selectedTask name $selectedTask');
      task['task_name'] = 'Issue with task name';
    }
    // return structureName;
  }

  void updateQuantityOfStructureInStrucureList(
      String taskId, int mstStructureId) {
    setState(() {
      // this is for updating the quantity feild
      var t = _taskList.firstWhere(
          (element) => element['id'].toString() == taskId.toString());

      var s = t['structures'].firstWhere(
          (ele) => ele['id'].toString() == mstStructureId.toString());

      print(s);
      print('s above 2068');

      // s['quantity'] = s['quantity'] + 1;

      _showSaveMeasurementDetailsButton = true;
    });
  }

  void setIssuedmaterials(totalIssuedMaterialDetails, jsonData,
      int mstStructureId, Map<dynamic, dynamic> structure) {
    print("this is issued materials $totalIssuedMaterialDetails");
    if (totalIssuedMaterialDetails.length != 0) {
      totalIssuedMaterialDetails.forEach((item) {
        int mstMaterialId = item['mst_labour_id'] ?? 0;
        // int mstStructureId = item['mst_labour_id'];

        String quantity = getUnitQuantity(
            jsonData, 'material', mstMaterialId, mstStructureId);
        item['quantity'] = quantity;

        print("this is unit of labour quantity $quantity");
      });

      structure['materials'].addAll(totalIssuedMaterialDetails);
    }

    if (totalIssuedMaterialDetails.length != 0) {
      structure['materials'].addAll(totalIssuedMaterialDetails);

      /// neede looping here for unit qty
    }
  }

  void setLabourDetails(
      totalLabourDetails,
      jsonData,
      int mstStructureId,

      //function to add new labour to existing labour in the structure
      Map<dynamic, dynamic> structure) {
    if (totalLabourDetails != null && totalLabourDetails.length != 0) {
      print("TOITAL LABOUR DETAILS ${totalLabourDetails.length}");

      // print()

      // totalLabourDetails.forEach((Map<dynamic, dynamic> item) {

      //   if (item.containsKey('wrk_execution_labour_schedule_id')) {
      //     return;

      //   }

      // });

      if (structure['labour'] == null) {
        structure['labour'] = [];
      }

      structure['labour'].addAll(totalLabourDetails);
    }
  }

  void setTakenBacks(takenBacks, Map<dynamic, dynamic> structure) {
    // funcgtion to append taken backs of a strcuture to a strcutre

    print("this is from taken backs 1991 $takenBacks");
    if (takenBacks.length != 0) {
      if (structure['takenBacks'] == null) {
        structure['takenBacks'] = [];
      }
      structure['takenBacks'].addAll(takenBacks);

      // takenBacks.forEach((item) {
      //   // int mstLabourId = item['mst_labour_id'] ?? 0;
      //   // int mstStructureId = item['mst_labour_id'];

      //   //   String quantity = getUnitQuantity(
      //   //       jsonData, 'labour', mstLabourId, mstStructureId);
      //   //   item['quantity'] = quantity;

      //   //   print("this is unit of labour quantity $quantity");
      //   // });

      //   if (structure['takenBacks'] == null) {
      //     structure['takenBacks'] = [];
      //   }
      // });
    }
  }

  // measurementDetails[_selectedLocationIndex][]

  // print(response.data['result_data']);

  // print(response.runtimeType);

  // var tmp = Map.from(response);

  // _measurementsObject = tmp['result_data'];

  // final secureStorage = FlutterSecureStorage();
  // await secureStorage.write(key: 'response_data', value: response.data);

  final employees = [
    {'id': 1, 'name': 'John Doe', 'position': 'Manager'},
    {'id': 2, 'name': 'Jane Smith', 'position': 'Developer'},
    {'id': 3, 'name': 'Bob Johnson', 'position': 'Designer'},
  ];
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              children: [
                EditableTable<Map<String, dynamic>>(
                  data: _masterLabEstimateItems,
                  headers: ['material_name', 'quantity', 'material_code'],
                ),
                ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                  onTap: () {
                    // do something when Share is tapped
                  },
                ),
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                  onTap: () {
                    // do something when Edit is tapped
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                  onTap: () {
                    // do something when Delete is tapped
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<dynamic>> _fetchWorkDetails() async {
    try {
      logCurrentFunction();
      print('FETCHING WORK DETAILS CALLED');
      final accessToken1 =
          await storage.getSecureAllStorageDataByKey("access_token");

      final accessToken = accessToken1['access_token'];
      final loginDetails1 =
          await storage.getSecureAllStorageDataByKey('loginDetails');
      final loginDetails = loginDetails1['loginDetails'];

      // final currentSeatDetails = getCurrentSeatDetails(loginDetails);

      // final officeCode = currentSeatDetails['office']['office_code'];
      // final officeId = currentSeatDetails['office_id'];

// http://erpuat.kseb.in/api/wrk/getScheduleForMobilePolevar/8147/1474/4010  taken back example
      final url =
          'http://erpuat.kseb.in/api/wrk/getScheduleDetailsForMeasurement/NORMAL/${widget.workScheduleGroupId}/0';

      print("url called $url");
      final headers = {'Authorization': 'Bearer $accessToken'};
      Response response =
          await Dio().get(url, options: Options(headers: headers));

      if (response.statusCode != 200) {
        return Future.value([-1]);
      }

      if (response.data != null && response.data['result_data'] != null) {
        var res = response.data['result_data'];

        print("response polvar 2504 $res");

        _wrk_schedule_group_id = res['data']['id'];

        return Future.value([res['data']]);
      } else {
        return Future.value([-1]);
      }
    } on Exception catch (e) {
      print("$e  is the error in _fetchWorkDetails()");

      return Future.value([-1]);

      // TODO
    }
  }

  _viewLocationDetail(int index, status) async {
    logCurrentFunction();
    print("this is new index of locations $index");

    if (index != -1) {
      _previoslySelectedIndex = _selectedLocationIndex;
      _selectedLocationIndex = index;

      _tappedIndex = index;

      /// if a user selectts a location after selecting any other location saving the current datat to storage

      storeMeasurementDetails(measurementDetails);

      getTasksofSelectedLocation();

      print('storeing location details');
    }

    if (_workDetails != null &&
        _workDetails!['locations'] != null &&
        _workDetails!['locations'] != null) {
      // _selectedLocationDetails =
      //     _workDetails!['locations']![_selectedLocationIndex]
      //         as Map<dynamic, dynamic>;

      // _selectedMeasurements = _selectedLocationDetails['measurements'];
    } else {
      _selectedLocationDetails = {};

      // _selectedMeasurements = ['test1 ', 'Item2 Qty: 30', 'Item3 Qty: 30'];
      _selectedMeasurements = [];
    }

//add the code afger location is selected
    // if (measurementDetails?.length != 0) {
    //   measurementDetails['geoCordinates'] != null
    //       ? _hasLocationDetailsInStorage = true
    //       : _hasLocationDetailsInStorage = false;

    //   measurementDetails['measurementDetails']?.length != 0
    //       ? _hasMeasurementDetailsInStorage = true
    //       : _hasMeasurementDetailsInStorage = false;
    // }

    var s = await getMeasurementDetails(
        widget.workId.toString(), _selectedLocationIndex);

    setState(() {
      _selectedLocationHasGeoLocations = status['hasGeoLocations'];
      _selectedLocationHasMeasurements = status['hasMeasurements'];

      if (_selectedLocationHasGeoLocations) {
        _handleEmitLocDetailsToPolVarWidget({});

        print("HAS GEO LOCATIONS $_selectedLocationHasMeasurements ");
        // _showAnotherLocationButton = true;
        // _showSaveMeasurementDetailsButton = true;
        // viewStructures = true;
        // _enableEntryOfLocationDetails = false;

        // _selectedLocationTasks = [];
        // _selectedLocationDetails['tasks'] = [];
        // _selectedLocationDetails = {};

        // // _gotToAnotherLocation();
        // // viewStructures = true;
        // _enableEntryOfLocationDetails = false;
        // // _fetchingMasterEstimate = false;
      }

      _previoslySelectedIndex = _selectedLocationIndex;
      _selectedLocationIndex = index;

      _tappedIndex = index;

      // print(s);
      // print('s aprinted above');
    });
  }

  void getTasksofSelectedLocation() {
    String locationNo = (_selectedLocationIndex + 1).toString();

    print("MEASUREMENT DETAILS $measurementDetails");
    print("LOCATION NO $locationNo");

    setState(() {
      _selectedLocationDetails =
          Map<String, dynamic>.from(measurementDetails.firstWhere(
        (element) => element['locationNo'].toString() == locationNo,
        orElse: () =>
            Map<String, dynamic>(), // Return an empty map of the correct type
      ));

      print("_selectedLocationDetails $_selectedLocationDetails");

      if (_selectedLocationDetails.isNotEmpty) {
        if (_selectedLocationDetails['tasks'] == null) {
          _selectedLocationTasks = [];
        } else {
          _selectedLocationTasks = _selectedLocationDetails['tasks'];
        }
      }
    });

    print("SELECTED LOCATION DR $_selectedLocationDetails");
  }

  void saveFromAndTwoLocation() {
    setState(() {
      _enableEntryOfLocationDetails = !_enableEntryOfLocationDetails;

      this.userDirections =
          'Now Select any Location to Starting with  L, Ensure correct location ';
      if (!isAudioMuted) {
        audioCache.play('select_location.wav');
      }

      this.saveWorkDetails(
          workId: widget.workId.toString(),
          fromLocation: _fromLocation,
          toLocation: _toLocation,
          noOfLocations: _numberOfLocations.toString());
    });
  }

  _saveMeasurementDetails() async {
    logCurrentFunction();
    this.saveWorkDetails(
        workId: widget.workId.toString(),
        fromLocation: _fromLocation,
        toLocation: _toLocation,
        noOfLocations: _numberOfLocations.toString(),
        measurementDetails: jsonEncode(measurementDetails));

    noOFLocationsMeasured = measurementDetails.length;

    // print('Number of locations now is noOFLocationsMeasured');
    var a = await getWorkDetails(widget.workId.toString(),
        measurementsetListId: widget.measurementSetId.toString());

    setState(() {
      this._showSaveMeasurementDetailsButton = false;
      this._showAnotherLocationButton = true;

      getTasksofSelectedLocation();
    });

    // print(a);

    // print('work details as retrived');
    return;

    final storage = SecureStorage();

    var jsonDetails =
        await storage.getSecureStorageDataByKey('measurementDetails');

    if (jsonDetails != null) {
      List<dynamic> details = jsonDecode(jsonDetails);

      Map<dynamic, dynamic> matchingDetail =
          details.firstWhere((detail) => detail['workId'] == widget.workId,

              // &&
              // detail['locationNumber'] == locationNumber,
              orElse: () => {});

      print(matchingDetail);

      print('matching details above');

      print(measurementDetails);

      print('measurementDetailsdetails above');

      // matchingDetail = measurementDetails;

      // return {'matchingDetail': matchingDetail, 'detailsList': details};
    }
  }

  Map<String, Object> _getLocationMeasuredStatus(int index) {
    var retObj = {'text': '', 'color': Colors.white};
    int locationNo = index + 1;

    Color? color;

    var location = measurementDetails.firstWhere(
      (element) => element['locationNo'].toString() == locationNo.toString(),
      orElse: () => Map<String, dynamic>(),
    );

    var measured = measurementDetails.length;

    // print("location no is ${locationNo} &&  measured is  ${measured}");

    if (locationNo <= measured) {
      var locationEnd = measurementDetails.firstWhere(
        (element) =>
            element['locationNo'].toString() == (locationNo + 1).toString(),
        orElse: () => Map<String, dynamic>(),
      );

      // print("$locationEnd is location ebnd");
      if (locationEnd['geoCordinates'] != null) {
        retObj['geoCordinatesEnd'] = locationEnd['geoCordinates'];
      }
    } else {
      print('masured is $measured');
    }

    // print(location['geoCordinates']);
    // print(location['geoCordinates']);
    // print('location above at 1942');

    if (location.isEmpty) {
      retObj['hasGeoLocations'] = false;
      retObj['hasMeasurements'] = false;
      retObj['text'] = ' \n Not Started1';
      color = Color.fromARGB(255, 255, 82, 151);
      retObj['color'] = color;
      return retObj;
    }

    if (location['tasks'] == null || location['tasks'].length == 0) {
      if (location['geoCordinates'] == null ||
          location['geoCordinates'].isEmpty) {
        print(
            '@2150 ${location['geoCordinates']} ${location['geoCordinates'].isBlank}');

        retObj['text'] = ' \n Not started2';
        color = Color.fromARGB(255, 82, 111, 255);
        retObj['color'] = color;
        return retObj;
      } else {
        retObj['geoCordinates'] = location['geoCordinates'];

        // print(
        //     '@2158 ${location['geoCordinates']} ${location['geoCordinates'].isEmpty}');

        retObj['text'] = ' \n No measurements';

        retObj['hasGeoLocations'] = true;
        retObj['hasMeasurements'] = false;
        color = Color.fromARGB(255, 255, 82, 229);
        retObj['color'] = color;
        return retObj;
      }
    }

    retObj['text'] = ' \n Has measurements and Geo';

    retObj['hasGeoLocations'] = true;
    retObj['hasMeasurements'] = true;

    retObj['geoCordinates'] = location['geoCordinates'];

    if (locationNo <= measured) {
      var locationEnd = measurementDetails.firstWhere(
        (element) =>
            element['locationNo'].toString() == (locationNo + 1).toString(),
        orElse: () => Map<String, dynamic>(),
      );

      if (locationEnd['geoCordinatesEnd'] != null) {
        retObj['geoCordinatesEnd'] = locationEnd['geoCordinatesEnd'];
      }
    }
    color = Color.fromARGB(255, 22, 29, 230);
    retObj['color'] = color;
    return retObj;
  }

  _gotToAnotherLocation() {
    // _show

    setState(() {
      _selectedLocationIndex = -1;
      _showAnotherLocationButton = true;
      _showSaveMeasurementDetailsButton = true;
      viewStructures = false;

      _selectedLocationTasks = [];
      _selectedLocationDetails['tasks'] = [];
      _selectedLocationDetails = {};
    });
  }

  _enterLocationDetails(int index) {
    var _selectedLocationIndex = index;
  }

  _viewMeasurementDetilsOfLocation(context) {
    // ViewTabbedViewOfComponentsInLocation._showComponentPopup( context);
  }

  void updateMaterialmeasurements(
      Map materialMeasurements, List<Map> materials) {
    int materialLen = materials.length;

    for (Map material in materials) {
      // print("Material $material");

      Map<dynamic, dynamic> result = createMaterialMeasurementObject(material);

      // speakText('result oflogin request below');

      // print("RESULT $result");

//aug 23  22 heado oof  aadhar pan card mcc road jayalakshmi
      // debugger;

      Map<String, dynamic> materialMeasurement = result["materialMeasurement"];
      appendToMaterialMeasurements(materialMeasurements, result);

      // Destructuring the 'result' map
      String key = result["key"];

      // print("KEY $key");

      // String materialId = material['mst_material_id'].toString();
      // if (materialMeasurements.containsKey(materialId)) {
      //   materialMeasurements[materialId]['quantity'] =
      //       materialMeasurements[materialId]['quantity'] + 1;
      // } else {
      //   Map mat = {};
      //   materialMeasurements[materialId] = mat;
      //   mat['material_name'] = material['material_name'];
      //   mat['quantity'] = 1;
      // }
    }

    // print('NOW FROM HERE ${materialMeasurements.length}');
    // print("MATERIAL MEASUREMENTS $materialMeasurements");
    // debugger;

    // print("MATERIALmeasurements only $materialMeasurements");

    // print("This is materials $materials");
  }

  Map<dynamic, dynamic> createMaterialMeasurementObject(
      Map<dynamic, dynamic> materialObject) {
    String key =
        "${materialObject["wrk_execution_material_schedule_id"]}_${materialObject["mst_material_id"]}_${materialObject["mst_uom_id"]}";

// print()
    Map<String, dynamic> materialMeasurement = {
      "wrk_execution_schedule_id": materialObject["wrk_execution_schedule_id"],
      "wrk_execution_material_schedule_id":
          materialObject["wrk_execution_material_schedule_id"],
      "wrk_material_allocation_item_id":
          materialObject["wrk_material_allocation_item_id"],
      "mst_material_id": materialObject["mst_material_id"],
      "material_name": materialObject["material_name"],
      "material_code": materialObject["material_code"],
      "mst_material_status_id": materialObject["mst_material_status_id"],
      "mst_material_status": materialObject["mst_material_status"],
      "mst_uom_id": materialObject["mst_uom_id"],
      "uom_code": materialObject["uom_code"],
      "supply_mode": materialObject["supply_mode"],
      "batch_id": materialObject["batch_id"],
      "rate": materialObject["rate"],
      "quantity": materialObject["quantity"],
    };

    return {
      "key": key,
      "materialMeasurement": materialMeasurement,
    };
  }

  void appendToMaterialMeasurements(Map materialMeasurements, Map result) {
    String key = result["key"].toString();

    // print("result key $result");
    Map<String, dynamic> materialMeasurement = result["materialMeasurement"];

    if (materialMeasurements.containsKey(key)) {
      int currentQuantity = int.parse(materialMeasurements[key]['quantity']);
      int additionalQuantity = int.parse(materialMeasurement['quantity']);
      int updatedQuantity = currentQuantity + additionalQuantity;
      materialMeasurements[key]['quantity'] = updatedQuantity.toString();

      print("new quantity ${materialMeasurements[key]['quantity']}");
    } else {
      materialMeasurements[key] = materialMeasurement;
    }

    // print("Materrial measuremetn from $materialMeasurements");
  }

  void updateLabourmeasurements(Map labourMeasurements, List<Map> labours) {
    labours.forEach((element) {
      // print('qqq1 labour ${element}');
      var key = element['wrk_execution_labour_schedule_id'].toString();

      if (labourMeasurements.containsKey(element[key])) {
        labourMeasurements[key]['quantity'] =
            labourMeasurements[key]['quantity'] + element['quantity'];
      } else {
        labourMeasurements[key] = element;
      }
    });
  }

  void updateMaterialTakenBackMeasurements(
      Map materialTakenBackMeasurements, List<Map> takenBacks) {
    takenBacks.forEach((element) {
      // print('qqq1 taken back ${element}');
      // var key = element['wrk_execution_schedule_id'];
      var key = element['wrk_material_field_return_item_id'].toString();

      if (materialTakenBackMeasurements.containsKey(element[key])) {
        materialTakenBackMeasurements[key]['quantity'] =
            double.parse(materialTakenBackMeasurements[key]['quantity']) +
                double.parse(element['quantity']);
      } else {
        materialTakenBackMeasurements[key] = element;
      }
    });
  }

  reflectQuantityDetails() {}
}
