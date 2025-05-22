import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/ib_booking/complaint_details.dart';
import 'package:samagra/local_url.dart';

const apiBase = localUrl ;

class ComplaintListScreen extends StatefulWidget {
  final int currentUserId; // pass your user’s ID here

  const ComplaintListScreen({super.key, required this.currentUserId});

  @override
  _ComplaintListScreenState createState() => _ComplaintListScreenState();
}

class _ComplaintListScreenState extends State<ComplaintListScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: apiBase));
  List<dynamic> _all = [], _mine = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final resp = await _dio.get('/api/ibbooking/ib-complaints');
    final list = resp.data as List;
    setState(() {
      _all = list;
      _mine = list.where((c) => c['user_id'] == widget.currentUserId).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complaints'),
          bottom: const TabBar(tabs: [
            Tab(text: 'All'),
            Tab(text: 'Mine'),
          ]),
        ),
        body: TabBarView(children: [
          _buildList(_all),
          _buildList(_mine),
        ]),
      ),
    );
  }

  Widget _buildList(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No complaints found.'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final c = items[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text('${c['ib']['name']} — Room ${c['room']['room_number']}'),
            subtitle: Text('Status: ${c['status']}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) => ComplaintDetailScreen(
        complaint: c,  // pass the map in directly
      ),
    ),
  );
},
          ),
        );
      },
    );
  }
}
