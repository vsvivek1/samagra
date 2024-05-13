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
        forceMaterialTransparency: true,
        primary: false,
        title: Text('Estimate Revision Tabs'),
        bottom: TabBar(
          indicatorColor: Colors.orange,
          tabAlignment: TabAlignment.center,
          dividerColor: Color.fromARGB(255, 6, 20, 153),
          isScrollable: true,
          indicatorWeight: 2,
          physics: ScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          controller: _tabController,
          tabs: widget.tabs
              .map((tab) =>
                  SizedBox(width: 200, height: 50, child: Tab(text: tab.title)))
              .toList(),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          height: 500,
          child: Container(
            padding: EdgeInsets.all(20),
            child: TabBarView(
              controller: _tabController,
              children: widget.tabs.map((tab) => tab.content).toList(),
            ),
          ),
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
