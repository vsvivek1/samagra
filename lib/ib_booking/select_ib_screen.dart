import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/local_url.dart';

class SelectIbScreen extends StatefulWidget {
  const SelectIbScreen({super.key});

  @override
  State<SelectIbScreen> createState() => _SelectIbScreenState();
}

class _SelectIbScreenState extends State<SelectIbScreen> {
  final Dio dio = Dio(BaseOptions(baseUrl: "$localUrl/api"));

  List<Map<String, dynamic>> ibList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchIbs();
  }

  Future<void> fetchIbs() async {
    try {
      final res = await dio.get('/ibbooking/ibs');
      if (res.statusCode == 200) {
        setState(() {
          ibList = List<Map<String, dynamic>>.from(res.data);
          loading = false;
        });
      }
    } catch (e) {
      print("Error fetching IBs: $e");
      setState(() {
        ibList = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Inspection Bungalow")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ibList.isEmpty
              ? const Center(child: Text("No IBs found"))
              : ListView.builder(
                  itemCount: ibList.length,
                  itemBuilder: (context, index) {
                    final ib = ibList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(ib['name'] ?? 'Unnamed IB'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (ib['location'] != null) Text("📍 ${ib['location']}"),
                            if (ib['district'] != null) Text("🌍 ${ib['district']}"),
                            if (ib['pincode'] != null) Text("📫 Pincode: ${ib['pincode']}"),
                            if (ib['phone'] != null) Text("📞 ${ib['phone']}"),
                          ],
                        ),
                        onTap: () => Navigator.pop(context, ib),
                      ),
                    );
                  },
                ),
    );
  }
}
