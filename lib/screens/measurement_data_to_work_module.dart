import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/screens/get_login_details.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:samagra/screens/set_access_token_to_dio.dart';

import '../common.dart';

class MeasurementDataToWorkModule {
  String? wrk_measurement_set_id;
  String? user_id;
  String? seat_id;
  String? plg_work_id;
  String? wrk_schedule_group_id;
  bool? is_premeasurement;
  bool? part_or_final;
  var measurement_set_date;
  var commencement_date;
  var completion_date;
  // Map<dynamic, dynamic>? polevar_data;
  String? polevar_data;
  Map<dynamic, dynamic>? structureMeasurements;
  // Map<dynamic, dynamic>? taskMeasurements;
  List taskMeasurements = [];
  Map<dynamic, dynamic>? materialMeasurements;
  Map<dynamic, dynamic>? labourMeasurements;
  Map<dynamic, dynamic>? materialTakenBackMeasurements;

  Map<dynamic, dynamic>? wrk_schedule_group_structures;

  MeasurementDataToWorkModule({
    this.wrk_measurement_set_id,
    required String workId, // Pass the workId to the constructor
    this.user_id,
    this.seat_id,
    required plg_work_id,
    this.wrk_schedule_group_id,
    this.is_premeasurement,
    this.part_or_final,
    this.measurement_set_date,
    this.commencement_date,
    this.completion_date,
    this.polevar_data,
    required this.taskMeasurements,
    this.structureMeasurements,
    this.materialMeasurements,
    this.labourMeasurements,
    this.materialTakenBackMeasurements,
    required String workScheduleGroupId,
    // this.polevar_data,
  }) {
    // Fetch the API data using Dio and set parameters from the response
    // _fetchScheduleDetailsAndSetParams(workId);
  }
  bool areAllVariablesSet() {
    return (user_id != null &&
        seat_id != null &&
        plg_work_id != null &&
        wrk_schedule_group_id != null &&
        is_premeasurement != null &&
        part_or_final != null &&
        measurement_set_date != null &&
        commencement_date != null &&
        completion_date != null &&
        polevar_data != null &&
        structureMeasurements != null &&
        materialMeasurements != null &&
        labourMeasurements != null &&
        materialTakenBackMeasurements != null);
  }

  List<String> getUnsetVariables() {
    List<String> unsetVariables = [];
    if (user_id == null) unsetVariables.add('user_id');
    if (seat_id == null) unsetVariables.add('seat_id');
    if (plg_work_id == null) unsetVariables.add('plg_work_id');
    if (wrk_schedule_group_id == null)
      unsetVariables.add('wrk_schedule_group_id');
    if (is_premeasurement == null) unsetVariables.add('is_premeasurement');
    if (part_or_final == null) unsetVariables.add('part_or_final');
    if (measurement_set_date == null)
      unsetVariables.add('measurement_set_date');
    if (commencement_date == null) unsetVariables.add('commencement_date');
    if (completion_date == null) unsetVariables.add('completion_date');
    if (polevar_data == null) unsetVariables.add('polevar_data');
    if (structureMeasurements == null)
      unsetVariables.add('structureMeasurements');
    if (materialMeasurements == null)
      unsetVariables.add('materialMeasurements');
    if (labourMeasurements == null) unsetVariables.add('labourMeasurements');
    if (materialTakenBackMeasurements == null)
      unsetVariables.add('materialTakenBackMeasurements');
    return unsetVariables;
  }

  Map<String, dynamic> convertMapKeysToString(Map<dynamic, dynamic>? map) {
    if (map == null) return {};
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = value.toString(); // Convert the value to String
    });
    return newMap;
  }

  Map<String, dynamic> toMap() {
    return {
      // 'wrk_measurement_set_id': wrk_measurement_set_id,
      'user_id': user_id,
      'seat_id': seat_id,
      'plg_work_id': plg_work_id,
      'wrk_schedule_group_id': wrk_schedule_group_id,
      'is_premeasurement': is_premeasurement,
      'part_or_final': part_or_final,
      'measurement_set_date': measurement_set_date,
      'commencement_date': commencement_date,
      'completion_date': completion_date,

      'taskMeasurements': jsonEncode(taskMeasurements),
      'structureMeasurements': jsonEncode(structureMeasurements),
      'materialMeasurements': jsonEncode(materialMeasurements),
      'labourMeasurements': jsonEncode(labourMeasurements),
      'materialTakenBackMeasurements':
          jsonEncode(materialTakenBackMeasurements),

      // 9231004321

      'polevar_data': jsonEncode(polevar_data),

      // 'polevar_data': convertMapKeysToString(polevar_data),
      // 'taskMeasurements': convertMapKeysToString(taskMeasurements),
      // 'structureMeasurements': convertMapKeysToString(structureMeasurements),
      // 'materialMeasurements': convertMapKeysToString(materialMeasurements),
      // 'labourMeasurements': convertMapKeysToString(labourMeasurements),
      // 'materialTakenBackMeasurements':
      //     convertMapKeysToString(materialTakenBackMeasurements),
      // 'wrk_schedule_group_structures': convertMapToDynamicKeys(wrk_schedule_group_structures),
      // Add other attributes here...
    };
  }

  // Private method to fetch the API data using Dio and set parameters from the response
  Future<bool> fetchScheduleDetailsAndSetParams(
      String workId, dataFromPolvarScreen) async {
    EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
    bool retVal = false;
    try {
      String baseUrl =
          "${config.liveServiceUrl}wrk/getScheduleDetailsForMeasurement/NORMAL/$workId/0";

      Dio dio = new Dio();

      dio = await setAccessTockenToDio(dio);
      setDioAccessokenAndApiKey(dio, await getAccessToken(), config);

      Response response = await dio.get(baseUrl);
      if (response.statusCode == 200) {
        Map<dynamic, dynamic> apiData = response.data;

        Map wrkScheduleGroupStructures =
            apiData['wrk_schedule_group_structures'] ?? {};

        var resultdata = apiData['result_data'];

        plg_work_id = workId;
        user_id = await getUserId();

        Map<dynamic, dynamic> ob = {};
        ob['measurements'] = dataFromPolvarScreen['polevar_data'];

        polevar_data = jsonEncode(ob);

        dataFromPolvarScreen.keys.forEach((key) {
          print("keyfrom 182 of mdtw $key");
        });

        taskMeasurements =
            // dataFromPolvarScreen['taskMeasurements'] as Map<dynamic, dynamic>;
            dataFromPolvarScreen['taskMeasurements'];

        structureMeasurements =
            dataFromPolvarScreen['structreMeasurements'] ?? {};

        materialMeasurements = dataFromPolvarScreen['materialMeasurements']
            as Map<dynamic, dynamic>;

        labourMeasurements =
            dataFromPolvarScreen['labourMeasurements'] as Map<dynamic, dynamic>;

        materialTakenBackMeasurements =
            dataFromPolvarScreen['materialTakenBackMeasurements']
                as Map<dynamic, dynamic>;

        retVal = true;
        return retVal;

        // Set other attributes as needed from the fetched data
        // For example:
        // user_id = apiData['user_id'];
        // seat_id = apiData['seat_id'];
        // measurement_set_date = apiData['measurement_set_date'];
        // ...
      } else {
        throw Exception('Failed to load schedule details');
      }
    } catch (e) {
      throw Exception('Failed to load schedule details: $e');
    }

    //  retVal = true;
    return retVal;
  }
}
