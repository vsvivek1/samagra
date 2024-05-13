import 'package:flutter/material.dart';
import 'package:samagra/screens/material_list_widget.dart';

class SearchMaterial extends StatefulWidget {
  Function onNewMaterialAdded;

  SearchMaterial({
    super.key,
    required this.materialMaster,
    required this.selectedMaterials,
    required this.onNewMaterialAdded,
  });

  final List materialMaster;
  List selectedMaterials;

  @override
  State<SearchMaterial> createState() => _SearchMaterialState();
}

class _SearchMaterialState extends State<SearchMaterial> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFDDE1), // rgb(255, 221, 225)
              Color(0xFFFFFFFF), // rgb(255, 255, 255)
            ],
            stops: [0.112, 0.922], // Stop percentages from CSS gradient
            transform: GradientRotation(
                109.6 * 3.14 / 180), // Convert degrees to radians
          )),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * .9,
        height: MediaQuery.sizeOf(context).height * .3,
        child: MaterialListWidget(
          updateMaterialStatus: updateMaterialStatus,
          materialMaster: widget.materialMaster,
          key: UniqueKey(),
          selectedMaterials: widget.selectedMaterials,
        ),
      ),
    );
  }

  updateMaterialStatus(item) {
    print('update material');
    widget.onNewMaterialAdded(item);
  }
}
