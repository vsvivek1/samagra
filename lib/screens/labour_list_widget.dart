import 'package:flutter/material.dart';

class LabourListWidget extends StatefulWidget {
  final List<dynamic> labourMaster;
  List selectedLabour = [];
  final Function updateLabourStatus;

  LabourListWidget({
    required Key key,
    required this.labourMaster,
    required this.selectedLabour,
    required this.updateLabourStatus,
  }) : super(key: key);

  @override
  _LabourListWidgetState createState() => _LabourListWidgetState();
}

class _LabourListWidgetState extends State<LabourListWidget> {
  String userText = '';
  late List<dynamic> filteredLabourMaster;

  @override
  void initState() {
    super.initState();
    filteredLabourMaster = widget.labourMaster;
  }

  void searchLabour() {
    filteredLabourMaster = widget.labourMaster
        .where((labour) => labour['labour_name']
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
                  hintText: 'Search Labour',
                  suffixIcon: IconButton(
                    onPressed: searchLabour,
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
            itemCount: filteredLabourMaster.length,
            itemBuilder: (BuildContext context, int index) {
              var item = filteredLabourMaster[index];
              return GestureDetector(
                onDoubleTap: () {
                  chooseTheItem(item);
                },
                onTap: () {
                  chooseTheItem(item);
                },
                child: ListTile(
                  selected: item['selected'] == true,
                  selectedTileColor: Colors.blue[100],
                  trailing: IconButton(
                    onPressed: () {
                      chooseTheItem(item);
                    },
                    icon: Icon(Icons.check),
                  ),
                  title: Text(item['labour_name'].toString()),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void chooseTheItem(item) {
    setState(() {
      item['selected'] = item['selected'] ?? false;
      item['selected'] = !item['selected'];

      if (item['selected']) {
        widget.selectedLabour.add(item);
      } else {
        widget.selectedLabour.remove(item);
      }
    });

    widget.updateLabourStatus(item);
  }
}
