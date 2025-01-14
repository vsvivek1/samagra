import 'package:http/http.dart' as http;
import 'dart:convert';

Future getMainTaskMaster( int sbuId, int mainTaskFilterId, int categoryId) async {
  // Construct the URL by affixing the parameters to the baseUrl
 
 String baseUrl = "http://192.168.29.92:8000/api";
  final String url = '$baseUrl/getMainTaskMaster/$sbuId/$mainTaskFilterId/$categoryId';
 
  try {
    // Make the GET request
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      // If the server returns a successful response
      var data = jsonDecode(response.body);

      return data;
      print('Response data: $data');
      
      // Do something with the data, such as returning it or processing further
    } else {

      return [];
      // If the server returns an error
      print('Failed to load data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any error that occurs during the request
    print('Error occurred: $e');
  }
}
