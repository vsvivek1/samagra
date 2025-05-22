import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/ib_booking/view_ib.dart';
import 'package:samagra/local_url.dart';
import 'add_ib_screen.dart';

class IbListScreen extends StatefulWidget {
  final List<String> userRoles;

  const IbListScreen({super.key, required this.userRoles});

  @override
  State<IbListScreen> createState() => _IbListScreenState();
}

class _IbListScreenState extends State<IbListScreen> {
  final Dio dio = Dio(BaseOptions(baseUrl: '$localUrl/api'));

  List<Map<String, dynamic>> ibList = [];
  bool loading = true;

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
      print("Failed to load IBs: $e");
      setState(() {
        ibList = [];
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchIbs();
  }

  void navigateToAddIb({Map<String, dynamic>? existingIb}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddIbScreen(ibData: existingIb),
      ),
    );
    fetchIbs(); // refresh list after return
  }

  void navigateToViewIb(Map<String, dynamic> ib) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewIbScreen(ibData: ib),
      ),
    );
  }

  bool canAddIb() {
    return widget.userRoles.contains('admin') || widget.userRoles.contains('ritu_user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Bungalows'),
        actions: [
          if (canAddIb())
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add IB',
              onPressed: () => navigateToAddIb(),
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ibList.isEmpty
              ? const Center(child: Text("No IBs found"))
              : ListView.builder(
                  itemCount: ibList.length,
                  itemBuilder: (context, index) {
                    final ib = ibList[index];
                    return Card(
                      child: ListTile(
                        title: Text(ib['name'] ?? 'Unnamed'),
                        subtitle: Text("${ib['location'] ?? ''} • ${ib['district'] ?? ''}"),
                        trailing: Text(ib['phone'] ?? ''),
                        onTap: () => navigateToViewIb(ib),
                      ),
                    );
                  },
                ),
    );
  }
}
