import 'package:flutter/material.dart';

class MaterialListWidget extends StatefulWidget {
  final List<dynamic> materialMaster;

  List selectedMaterials = [];

  Function updateMaterialStatus;

  MaterialListWidget(
      {required Key key,
      required this.materialMaster,
      required this.selectedMaterials,
      required this.updateMaterialStatus})
      : super(key: key);

  @override
  _MaterialListWidgetState createState() => _MaterialListWidgetState();
}

class _MaterialListWidgetState extends State<MaterialListWidget> {
  String userText = '';
  late List<dynamic> filteredMaterialMaster;

  @override
  void initState() {
    super.initState();
    filteredMaterialMaster = widget.materialMaster;
  }

  void searchMaterial() {
    filteredMaterialMaster = widget.materialMaster
        .where((material) => material['material_name']
            .toString()
            .toLowerCase()
            .contains(userText.toLowerCase()))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.05,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    userText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search Material',
                  suffixIcon: IconButton(
                    onPressed: searchMaterial,
                    icon: Icon(Icons.search),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(
          color: Colors.grey[900],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.2,
          child: ListView.builder(
            itemCount: filteredMaterialMaster.length,
            itemBuilder: (BuildContext context, int index) {
              var item = filteredMaterialMaster[index];
              return ListTile(
                selected: item['selected'] == true,
                selectedTileColor: Colors.red,
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      item['selected'] = item['selected'] ?? false;
                      item['selected'] = !item['selected'];

                      if (item['selected']) {
                        widget.selectedMaterials.add(item);
                      } else {
                        widget.selectedMaterials.remove(item);
                      }
                    });

                    widget.updateMaterialStatus();
                    //print(widget.selectedMaterials);
                  },
                  icon: Icon(Icons.select_all_sharp),
                ),
                title: Text(item['material_name'].toString()),
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}
