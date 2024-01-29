import 'package:flutter/material.dart';

class ViewTabbedViewOfComponentsInLocation extends StatelessWidget {
  final Map<dynamic, dynamic> componentsMap;

  ViewTabbedViewOfComponentsInLocation({required this.componentsMap});

  @override
  Widget build(BuildContext context) {
    debugPrint(this.componentsMap.keys);
    return ElevatedButton(
      onPressed: () {
        _showComponentPopup(context, componentsMap);
      },
      child: Text('Show Components'),
    );
  }

  void _showComponentPopup(
      BuildContext context, Map<dynamic, dynamic> componentsMap) {
    // debugPrint("this is componenet map $componentsMap");
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
                        _buildListComponent(componentsMap, 'materials'),
                        _buildListComponent(componentsMap, 'labour'),
                        _buildListComponent(componentsMap, 'takenBacks'),
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

  _getFullListOfComponsnts(components, type) {
    List<dynamic> items = [];

    List<dynamic> tasks = components["tasks"];
    tasks.forEach((task) {
      // debugPrint("T $task ");
      if (task != null && task["structures"] != null) {
        List<dynamic> structures = task["structures"];
        structures.forEach((structure) {
          // debugPrint("s $structure ");

          // debugPrint("type $type");
          // debugPrint("structure $structure");
          if (structure != null && structure[type] != null) {
            // debugPrint("type ${structure[type]} ");

            List<dynamic> typeList = structure[type];
            // items.addAll(typeList as Iterable<String>);

            // debugPrint("TYPE $type STRUCTURE $structure");
            debugPrint("TYPE $type typeListx $typeList");
            debugPrint("typeListxrun  ${typeList.runtimeType}");

            items.addAll(typeList);
            debugPrint("items $items");
          }
        });
      }
    });

    debugPrint("ITEMS $items");
    return items;
  }

  Widget _buildListComponent(Map<dynamic, dynamic>? components1, type) {
    List components = _getFullListOfComponsnts(components1, type);

    debugPrint("components $components");

    return ListView.builder(
      itemCount: components.length ?? 0,
      itemBuilder: (context, index) {
        // debugPrint("CONTEXT $context");

        if (components[index] != null)
          return ListTile(
            trailing: Text(double.parse(
                    components[index]?['quantity'].toString() as String)
                .toStringAsFixed(2)),
            contentPadding: EdgeInsets.only(left: 0.0),
            leading: CircleAvatar(
              maxRadius: 10,
              child: Text(index.toString()),
            ),
            title: Text(components[index]['material_name'].toString() ?? ''),
          );
        return null;
      },
    );
  }

  // Public method to trigger the pop-up dialog
  void showComponentsPopUp(
      BuildContext context, Map<dynamic, dynamic> componentsMap) {
    _showComponentPopup(context, componentsMap);
  }
}
