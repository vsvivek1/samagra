import 'package:flutter/material.dart';

class EstimateRevisionTabs extends StatefulWidget {
  final List<TabData> tabs;

  const EstimateRevisionTabs({required Key key, required this.tabs})
      : super(key: key);

  @override
  _EstimateRevisionTabsState createState() => _EstimateRevisionTabsState();
}

class _EstimateRevisionTabsState extends State<EstimateRevisionTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estimate Revision Tabs'),
        bottom: TabBar(
          controller: _tabController,
          tabs: widget.tabs.map((tab) => Tab(text: tab.title)).toList(),
        ),
      ),
      body: SingleChildScrollView(
        child: TabBarView(
          controller: _tabController,
          children: widget.tabs.map((tab) => tab.content).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class TabData {
  final String title;
  final Widget content;

  TabData({required this.title, required this.content});
}
