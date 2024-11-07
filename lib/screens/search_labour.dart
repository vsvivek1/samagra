import 'package:flutter/material.dart';
import 'package:samagra/screens/labour_list_widget.dart';

class SearchLabour extends StatefulWidget {
  final Function onNewLabourAdded;
  final List labourMaster;
  final List selectedLabour;

  SearchLabour({
    Key? key,
    required this.labourMaster,
    required this.selectedLabour,
    required this.onNewLabourAdded,
  }) : super(key: key);

  @override
  State<SearchLabour> createState() => _SearchLabourState();
}

class _SearchLabourState extends State<SearchLabour> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
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
        ),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.3,
        child: LabourListWidget(
          updateLabourStatus: updateLabourStatus,
          labourMaster: widget.labourMaster,
          key: UniqueKey(),
          selectedLabour: widget.selectedLabour,
        ),
      ),
    );
  }

  void updateLabourStatus(item) {
    print('Updating labour status...');
    widget.onNewLabourAdded(item);
  }
}
