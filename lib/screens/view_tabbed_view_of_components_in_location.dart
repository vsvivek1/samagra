import 'dart:developer';

import 'package:flutter/material.dart';

class ViewTabbedViewOfComponentsInLocation extends StatelessWidget {
  final Map<dynamic, dynamic> componentsMap;

  ViewTabbedViewOfComponentsInLocation({required this.componentsMap});

  @override
  Widget build(BuildContext context) {
    print(this.componentsMap.keys);
    return ElevatedButton(
      onPressed: () {
        _showComponentPopup(context, componentsMap);
      },
      child: Text('Show Components'),
    );
  }

  void _showComponentPopup(
      BuildContext context, Map<dynamic, dynamic> componentsMap) {
    // print("this is componenet map $componentsMap");
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
                    height: MediaQuery.of(context).size.height *
                        .5, // Adjust the height as needed
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
      // print("T $task ");
      if (task != null && task["structures"] != null) {
        List<dynamic> structures = task["structures"];
        structures.forEach((structure) {
          // print("s $structure ");

          // print("type $type");
          // print("structure $structure");
          if (structure != null && structure[type] != null) {
            // print("type ${structure[type]} ");

            List<dynamic> typeList = structure[type];
            // items.addAll(typeList as Iterable<String>);

            // print("TYPE $type STRUCTURE $structure");
            // print("TYPE $type typeListx $typeList");
            // print("typeListxrun  ${typeList.runtimeType}");

            items.addAll(typeList);
            // print("items $items");
          }
        });
      }
    });

    // print("ITEMS $items");
    return items;
  }

  Widget _buildListComponent(Map<dynamic, dynamic>? components1, expenseType) {
    String type = expenseType;

    // print("$type is type");

    String typeName = '';
    switch (expenseType) {
      case 'labour':
        typeName = 'labour_name';
        break;
      case 'materials':
        typeName = 'material_name';
        break;
      case 'takenBacks':
        typeName = 'taken_back_name';
        break;
    }

    List components = _getFullListOfComponsnts(components1, type);

    // print("components $components");

    return ListView.builder(
      itemCount: components.length ?? 0,
      itemBuilder: (context, index) {
        // print("CONTEXT $context");

        var type1 = type;

        var name = components[index][type];
        print("name $name");
        // debugger(when: true);
        print("$components[index] comp $name");

        if (components[index] != null)
          return ListTile(
            trailing: Text(double.parse(
                    components[index]?['quantity'].toString() as String)
                .toStringAsFixed(2)),
            contentPadding: EdgeInsets.only(left: 0.0),
            leading: CircleAvatar(
              maxRadius: 10,
              child: Text((index + 1).toString()),
            ),
            title: Text(components[index][typeName].toString() ?? ''),
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
