import 'package:dio/dio.dart';

class TaskService {
  final Dio _dio = Dio();
  final String url = "http://192.168.100.101:8000/api"; // kfon"; // Change this to your actual API URL

  /// Fetch all tasks for a given SBU ID
  Future<Map<String, dynamic>> getTasksBySbu(int sbuId) async {
    try {
      Response response = await _dio.get("$url/tasks/sbu/$sbuId");



      return response.data;
    } catch (e) {
      print("Error fetching tasks by SBU: $e");
      return {"error": "Failed to fetch tasks"};
    }
  }

  /// Fetch a specific task and its details
  Future<Map<String, dynamic>> getTaskTree(int taskId) async {
    try {
      Response response = await _dio.get("$url/task/$taskId");
      return response.data;
    } catch (e) {
      print("Error fetching task tree: $e");
      return {"error": "Failed to fetch task"};
    }
  }

  /// Fetch all tasks with full details (structures, materials, labours)
  Future<Map<String, dynamic>> getAllTaskTrees() async {
    try {
      Response response = await _dio.get("$url/tasks/all");
      return response.data;
    } catch (e) {
      print("Error fetching all tasks: $e");
      return {"error": "Failed to fetch all tasks"};
    }
  }

  /// Fetch all tasks for a specific SBU with full details
  Future<Map<String, dynamic>> getAllTaskTreesBySbu(int sbuId) async {
    //try {

    String base="$url/tasks/sbu/$sbuId/all";

    
      Response response = await _dio.get(base);


      return response.data;
    // } catch (e) {
    //   print("Error fetching task trees by SBU: $e");
    //   return {"error": "Failed to fetch tasks for SBU"};
    // }
  }
}
