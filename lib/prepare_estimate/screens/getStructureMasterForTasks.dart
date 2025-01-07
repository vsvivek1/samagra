import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';

// Function to fetch structure master for a specific task
Future getStructureMasterForTask(int taskId) async {
  // Construct the full URL by affixing taskId to the base URL



  taskId=1403;

   String baseUrl = "http://192.168.100.100:8000/api";
  final String url = '$baseUrl/getStructureMasterForTask/$taskId';
  
  try {
    // Send the GET request to the server
    final response = await http.get(Uri.parse(url));

      print(response);

           debugger(when:true);

    print(response);

    print('hi');
    
    // Check if the server response is successful (status code 200)
    if (response.statusCode == 200) {
      // If successful, decode the JSON response body
      var data = jsonDecode(response.body);
      print('Response data: $data');
      
      // You can return or use the data here for your app logic
    } else {
      // Handle non-successful status codes
      print('Failed to load data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any errors during the HTTP request
    print('Error occurred: $e');
  }
}
