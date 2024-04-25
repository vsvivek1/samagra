import 'package:flutter/material.dart';

class MaterialListWidget extends StatefulWidget {
  final List<dynamic> materialMaster;

  const MaterialListWidget({required Key key, required this.materialMaster})
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
    setState(() {
      filteredMaterialMaster = widget.materialMaster
          .where((material) => material['material_name']
              .toString()
              .toLowerCase()
              .contains(userText.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 300,
              height: 100,
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
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 300,
          child: ListView.builder(
            itemCount: filteredMaterialMaster.length,
            itemBuilder: (BuildContext context, int index) {
              var item = filteredMaterialMaster[index];
              return ListTile(
                selected: item['selected'] == true,
                selectedTileColor: Colors.red,
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.select_all_sharp),
                ),
                title: Text(item['material_name'].toString()),
                onTap: () {
                  // selectMaterial(item, index);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
