import 'package:flutter/material.dart';

class ViewTabbedViewOfComponentsInLocation extends StatelessWidget {
  final Map<dynamic, dynamic> componentsMap;

  ViewTabbedViewOfComponentsInLocation({required this.componentsMap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _showComponentPopup(context, componentsMap);
      },
      child: Text('Show Components'),
    );
  }

  static void _showComponentPopup(
      BuildContext context, Map<dynamic, dynamic> componentsMap) {
    print("this is componenet map $componentsMap");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Components in Locations'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: DefaultTabController(
              length: 3,
              child: Column(
                // mainAxisSize: MediaQuery.of(context).size.width,
                children: [
                  TabBar(
                    tabs: [
                      Tab(child: Text('Materials', softWrap: true)),
                      Tab(child: Text('Labour', softWrap: true)),
                      Tab(child: Text('Taken Backs', softWrap: true)),
                      // Tab(child: Text('Task/Structure View', softWrap: true)),
                    ],
                  ),
                  SizedBox(
                    height: 300, // Adjust the height as needed
                    child: TabBarView(
                      children: [
                        _buildListComponent(componentsMap['materials']),
                        _buildListComponent(componentsMap['labour']),
                        _buildListComponent(componentsMap['takenBacks']),
                        // _buildListComponent(componentsMap['takenBacks']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildListComponent(List<dynamic>? components) {
    print(components);
    print('components');
    return ListView.builder(
      itemCount: components?.length ?? 0,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(components?[index].toString() ?? ''),
        );
      },
    );
  }

  // Public method to trigger the pop-up dialog
  static void showComponentsPopUp(
      BuildContext context, Map<dynamic, dynamic> componentsMap) {
    _showComponentPopup(context, componentsMap);
  }
}
