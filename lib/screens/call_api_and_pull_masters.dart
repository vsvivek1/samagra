import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:samagra/common.dart';
import 'dart:convert';

import 'package:samagra/environmental_config.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';

Future<void> callApiAndSaveLabourGroupMasterInSecureStorage() async {
  try {
    EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();
    final dio = Dio();
    final secureStorage = FlutterSecureStorage();

    final accessToken = await getAccessToken();
    setDioAccessokenAndApiKey(dio, accessToken, config);

    final headers = {'Authorization': 'Bearer $accessToken'};

    final labourUrl = '${config.liveServiceUrl}wrk/getLabourMaster/0';
    final materialUrl = '${config.liveServiceUrl}wrk/getMaterialMaster/2/0';

    // Call Labour API
    final labourResponse = await dio.get(labourUrl, options: Options(headers: headers));
    final labourData = labourResponse.data['result_data']['labourMaster'] ?? [];

    // Call Material API
    setDioAccessokenAndApiKey(dio, await getAccessToken(), config); // Refresh access token if needed
    final materialResponse = await dio.get(materialUrl, options: Options(headers: headers));
    final materialData = materialResponse.data['result_data']['materialMaster'] ?? [];

    // Prepare Labour Data
    final List<Map<String, dynamic>> labourList = labourData.map<Map<String, dynamic>>((a) => {
      'id': a['id'],
      'key': a['code'],
      'code': a['code'],
      'uom': a['mst_uom']['uom_code'],
      'rate': a['rate'],
      'name': a['name'],
      'mst_uom_id': a['mst_uom_id'],
    }).toList();

    // Prepare Material Data
    final List<Map<String, dynamic>> materialList = materialData.map<Map<String, dynamic>>((a) => {
      'id': a['id'],
      'key': a['material_code'],
      'code': a['material_code'],
      'uom': a['mst_stock_uom']['uom_code'],
      'rate': (a['mst_material_rates'] != null && a['mst_material_rates'].isNotEmpty) 
              ? a['mst_material_rates'][0]['rate'] 
              : 0.0,
      'name': a['name'],
      'mst_uom_id': a['mst_uom_id'],
    }).toList();

    // Save Labour Master
    await secureStorage.write(
      key: 'getLabourGroupMaster',
      value: json.encode({'labours': labourList}),
    );
    await secureStorage.write(
      key: 'getLabourGroupMasterUpdatedAt',
      value: DateTime.now().toIso8601String(),
    );

    // Save Material Master
    await secureStorage.write(
      key: 'getMaterialGroupMaster',
      value: json.encode({'materials': materialList}),
    );
    await secureStorage.write(
      key: 'getMaterialGroupMasterUpdatedAt',
      value: DateTime.now().toIso8601String(),
    );

    print('Labour and Material Master saved successfully.');

  } catch (e) {
    print('Error in saving master data: $e');
  }
}
