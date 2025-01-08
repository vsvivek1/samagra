import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:samagra/prepare_estimate/data_fetch_service.dart';

// Function to fetch structure master for a specific task
Future getStructureMasterForTask(int taskId) async {

  final DataFetchService _dataFetchService = DataFetchService();
  // Construct the full URL by affixing taskId to the base URL



  taskId=1403;

  

  
  try {
    // Send the GET request to the server
 final fetchedStructureMasterForTask =
          await _dataFetchService.fetchData('getStructureMasterForTask', taskId);

          return fetchedStructureMasterForTask ;

      print(fetchedStructureMasterForTask );

           debugger(when:true);

    print(fetchedStructureMasterForTask );

    print('hi');
    
   
  } catch (e) {
    // Handle any errors during the HTTP request
    print('Error occurred: $e');
  }
}
