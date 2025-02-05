import 'package:flutter/material.dart';

class TaskHierarchyOfLocation extends StatefulWidget {
  @override
  _TaskHierarchyOfLocationState createState() =>
      _TaskHierarchyOfLocationState();
}

class _TaskHierarchyOfLocationState extends State<TaskHierarchyOfLocation> {
  String? selectedStructure;

  final List<Map<String, dynamic>> tasks = [
    {
      'taskName': 'Foundation',
      'structures': [
        {
          'structureName': 'Base Concrete',
          'qty': 10,
          'labours': [
            {'type': 'Masons', 'quantity': 5},
            {'type': 'Helpers', 'quantity': 8},
          ],
          'materials': [
            {'type': 'Cement', 'quantity': 20},
            {'type': 'Sand', 'quantity': 15},
          ],
          'takenBacks': [
            {'type': 'Cement Bags', 'quantity': 2},
          ],
        },
        {
          'structureName': 'Pillars',
          'qty': 5,
          'labours': [
            {'type': 'Welders', 'quantity': 3},
            {'type': 'Helpers', 'quantity': 6},
          ],
          'materials': [
            {'type': 'Steel Rods', 'quantity': 30},
            {'type': 'Concrete Mix', 'quantity': 40},
          ],
          'takenBacks': [
            {'type': 'Steel Scraps', 'quantity': 5},
          ],
        },
      ],
    },
    {
      'taskName': 'Walls',
      'structures': [
        {
          'structureName': 'Brickwork',
          'qty': 15,
          'labours': [
            {'type': 'Bricklayers', 'quantity': 4},
            {'type': 'Helpers', 'quantity': 5},
          ],
          'materials': [
            {'type': 'Bricks', 'quantity': 200},
            {'type': 'Cement', 'quantity': 10},
          ],
          'takenBacks': [
            {'type': 'Broken Bricks', 'quantity': 10},
          ],
        },
      ],
    },
  ];

  Map<String, dynamic>? getSelectedStructureDetails() {
    for (var task in tasks) {
      for (var structure in task['structures']) {
        if (structure['structureName'] == selectedStructure) {
          return structure;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isShrinking = selectedStructure != null;
    final selectedDetails = getSelectedStructureDetails();

    return Scaffold(
   
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Legend: Lab (Labours), MAT (Materials), TknBack (Taken Backs)',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Task Pane
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedStructure = null; // Reset to initial layout
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: isShrinking
                        ? MediaQuery.of(context).size.width * 0.25
                        : MediaQuery.of(context).size.width * 0.75,
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, taskIndex) {
                        final task = tasks[taskIndex];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          color: Colors.green.shade100,
                          child: isShrinking
                              ? Center(
                                  child: Text(
                                    'T${taskIndex + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                )
                              : ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 14.0),
                                  title: Text(
                                    'T${taskIndex + 1}: ${task['taskName']}',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: List.generate(
                                      task['structures'].length,
                                      (structureIndex) {
                                    final structure = task['structures']
                                        [structureIndex];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 4.0,
                                      ),
                                      color: Colors.blue.shade100,
                                      child: ListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'S${structureIndex + 1}: ${structure['structureName']}',
                                              style: TextStyle(
                                                color: Colors.blue.shade800,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 50,
                                              child: TextFormField(
                                                initialValue: structure['qty']
                                                    .toString(),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 6),
                                                  border:
                                                      OutlineInputBorder(),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  setState(() {
                                                    structure['qty'] =
                                                        int.tryParse(value) ??
                                                            structure['qty'];
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          setState(() {
                                            selectedStructure =
                                                structure['structureName'];
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                ),
                        );
                      },
                    ),
                  ),
                ),
                // Details Pane
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isShrinking
                      ? MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width * 0.10,
                  child: selectedStructure == null
                      ? Text('Select a structure \nto view details')
                      : DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              TabBar(
                                labelColor: Colors.blue,
                                unselectedLabelColor: Colors.grey,
                                tabs: [
                                  Tab(text: 'Lab'),
                                  Tab(text: 'MAT'),
                                  Tab(text: 'TknBack'),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    // Labours Tab
                                    ListView.builder(
                                      itemCount:
                                          selectedDetails!['labours'].length+1,
                                      itemBuilder: (context, index) {


                                          if(index==selectedDetails!['labours'].length){

                                              return ElevatedButton(onPressed: saveLabour, child: Text('Save labour'));
                                            }
                                        final labour =
                                            selectedDetails['labours'][index];



                                          
                                        return ListTile(
                                          title: Text(labour['type']+selectedDetails!['labours'].length.toString()+index.toString()),
                                          trailing: SizedBox(
                                            width: 50,
                                            child: TextFormField(
                                              initialValue: labour['quantity']
                                                  .toString(),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                setState(() {
                                                  labour['quantity'] =
                                                      int.tryParse(value) ??
                                                          labour['quantity'];
                                                });
                                                
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Materials Tab
                                    ListView.builder(
                                      itemCount:
                                          selectedDetails['materials'].length+1,
                                      itemBuilder: (context, index) {

if(index==selectedDetails!['materials'].length){

                                              return ElevatedButton(onPressed: saveMaterials, child: Text('Save Materials'));
                                            }

                                        final material =
                                            selectedDetails['materials'][index];
                                        return ListTile(
                                          title: Text(material['type']),
                                          trailing: SizedBox(
                                            width: 50,
                                            child: TextFormField(
                                              initialValue:
                                                  material['quantity']
                                                      .toString(),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                setState(() {
                                                  material['quantity'] =
                                                      int.tryParse(value) ??
                                                          material['quantity'];
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Taken Backs Tab
                                    ListView.builder(
                                      itemCount:
                                          selectedDetails['takenBacks'].length + 1,
                                      itemBuilder: (context, index) {


if(index==selectedDetails!['takenBacks'].length){

                                              return ElevatedButton(onPressed: saveMaterials,
                                               child: Text('Save Takenbacks'));
                                            }
                                        final takenBack =
                                            selectedDetails['takenBacks']
                                                [index];


                                        return ListTile(
                                          title: Text(takenBack['type']),
                                          trailing: SizedBox(
                                            width: 50,
                                            child: TextFormField(
                                              initialValue:
                                                  takenBack['quantity']
                                                      .toString(),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                setState(() {
                                                  takenBack['quantity'] =
                                                      int.tryParse(value) ??
                                                          takenBack['quantity'];
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void saveLabour() {
  }

  void saveMaterials() {
  }
}
