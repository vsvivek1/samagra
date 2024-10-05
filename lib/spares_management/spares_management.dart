import 'package:flutter/material.dart';
import 'inventory_requests_tab.dart';
import 'inventory_available_tab.dart';
import 'publish_inventory_item_tab.dart';

class SparesManagement extends StatefulWidget {
  @override
  _SparesManagementState createState() => _SparesManagementState();
}

class _SparesManagementState extends State<SparesManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Inventory Requests'),
            Tab(text: 'Inventory Available'),
            Tab(text: 'Publish an Inventory Item'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InventoryRequestsTab(),
          InventoryAvailableTab(),
          PublishInventoryItemTab(),
        ],
      ),
    );
  }
}
