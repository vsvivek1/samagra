import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:samagra/common.dart';
import 'package:samagra/configProviderSingleton.dart';
import 'package:samagra/environmental_config.dart';
import 'package:samagra/expired_token_notifier_and_updater.dart';
import 'package:samagra/lobal_loader.dart';
import 'package:samagra/main.dart';
import 'package:samagra/model/http_helper.dart';
import 'package:samagra/screens/set_access_toke_and_api_key.dart';
import 'package:samagra/screens/set_access_token_to_dio.dart';

class DataFetchService {
  String baseUrl = ConfigProviderSingleton.instance.liveAccessUrl;
  // Dio _dio = Dio();

  Future<String> getCurrentIp() async {
    try {
      List<NetworkInterface> interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Failed to get IP address: $e');
    }
    return '127.0.0.1';
  }

  /// Builds API URL based on the type using a switch case
  Future<List<Map<String, dynamic>>> fetchData(String type, dynamic id) async {
    String url;
    baseUrl = "http://192.168.1.102:8000/api"; // kfon
    print("Base URL: $baseUrl");

    switch (type) {
      case 'localBodies':
        url = "$baseUrl/office-local-body/get-map/$id";
        break;
      case 'villages':
        url = "$baseUrl/office-village/get-map/$id";
        break;
      case 'assemblies':
        url = "$baseUrl/office-assembly/get-map/$id";
        break;
      case 'mainTaskFilterMaster':
        url = "$baseUrl/getMainTaskFilterMaster";
        break;

        case 'getStructureMasterForTask':
        url = "$baseUrl/getStructureMasterForTask/$id";
        break;



      default:
        throw Exception("Invalid type: $type");
    }

   try {
    //  Show loader
      // GlobalLoader().show(navigatorKey.currentState!.overlay!.context);
      Fluttertoast.showToast(
        msg: "Fetching data, please wait...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
      );

      final headers = {'Authorization': 'Bearer ${await getAccessToken()}'};
      EnvironmentConfig config = await EnvironmentConfig.fromEnvFile();

      Dio dio = Dio();
      dio = await setAccessTockenToDio(dio);
      setDioAccessokenAndApiKey(dio, await getAccessToken(), config);

      print(url);

      final response = await dio.get(
        url,
        options: Options(headers: headers),
      );



//debugger(when:true);
//print(response);
      if (response.data != null &&
          response.data is Map<String, dynamic> &&
          response.data.containsKey('result_flag') &&
          response.data['result_flag'] == -9) {
        await expiredTokenNotifierAndUpdater();
      }

      if (response.statusCode == 200 && response.data != null) {
        if (type == 'mainTaskFilterMaster') {
          print(response.data['result_data']['list']);
          return List<Map<String, dynamic>>.from(
              response.data['result_data']['list']);
        } 

        else if (type == 'getStructureMasterForTask') {
        //  print(response.data['result_data']['structureMaster']);
          return List<Map<String, dynamic>>.from(
              response.data['result_data']['structureMaster']);
        } 
        
        
        
        else {
          print(response.data);
          return List<Map<String, dynamic>>.from(response.data);
        }
      }
    } catch (e) {
      throw Exception("Error fetching $type data: ${e.toString()}");
    } finally {
      Fluttertoast.cancel();
      // Hide loader
      // GlobalLoader().hide();
    }

    return [];
  }
}
