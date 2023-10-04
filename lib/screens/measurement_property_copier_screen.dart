import 'package:flutter/material.dart';

class MeasurementPropertyCopierScreen extends StatefulWidget {
  List<Map> measurementDetails;
  final int noOfLocations;
  final Function(String locationNo, Map<dynamic, dynamic> newObject)
      updateMeasurementDetails; // Callback function

  MeasurementPropertyCopierScreen({
    required this.measurementDetails,
    required this.noOfLocations,
    required this.updateMeasurementDetails, // Callback function parameter
  });

  @override
  _MeasurementPropertyCopierScreenState createState() =>
      _MeasurementPropertyCopierScreenState();

  // void updateMeasurementDetails({required Map targetDetails, required String locationNo}) {}
}

class _MeasurementPropertyCopierScreenState
    extends State<MeasurementPropertyCopierScreen> {
  late String selectedSourceLocation = "1";
  List<String> selectedTargetLocations = [];
  List<String> propertiesToCopy = [];
  List<String> selectedProperties = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Source Location:'),
          DropdownButton<String>(
            value: selectedSourceLocation,
            items: List.from(widget.measurementDetails).map((details) {
              return DropdownMenuItem<String>(
                value: details["locationNo"].toString(),
                child: Text(details["locationNo"].toString()),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedSourceLocation = newValue!;
                propertiesToCopy = [];
              });
            },
          ),
          SizedBox(height: 10),
          Text('Target Locations:'),
          MultiSelect(
            value: selectedTargetLocations,
            items: _getTargetLocationsList(),
            onChanged: (List<String> newValues) {
              setState(() {
                selectedTargetLocations = newValues;
              });
            },
            isExpanded: true,
            selectAllLabel: 'Select All',
          ),
          SizedBox(height: 10),
          // SizedBox(height: 16),
          Text('Properties to Copy:'),
          MultiSelect(
            value: selectedProperties,
            items: _getPropertiesList(selectedSourceLocation),
            onChanged: (List<String> newValues) {
              setState(() {
                selectedProperties = newValues;
              });
            },
            isExpanded: true,
          ),
          // ElevatedButton(onPressed: onPressedTest, child: Text('test1')),
          ElevatedButton(
            onPressed: copyProperties,
            child: Text('Copy Properties'),
          ),
        ],
      ),
    );
  }

  List<MultiSelectItem> _getTargetLocationsList() {
    return List.generate(widget.noOfLocations, (index) {
      final value = (index + 1).toString();

      if (value != selectedSourceLocation) {
        return MultiSelectItem(
          value: value,
          label: value,
        );
      } else {
        return null;
      }
    }).whereType<MultiSelectItem>().toList();
  }

  List<MultiSelectItem> _getPropertiesList(String sourceLocation) {
    Map sourceDetails = widget.measurementDetails.firstWhere(
      (details) => details['locationNo'].toString() == sourceLocation,
      orElse: () {
        return {};
      },
    );

    var p = '';

    List s = [
      'latitude',
      'longitude',
      'locationName',
      'geoCordinates',
      'tasks'
    ];
    // return sourceDetails.keys.map((property) {
    return s.map((property) {
      // p = p + "${property},";
      // print(p);
      return MultiSelectItem(
        value: property,
        label: property,
      );
    }).toList();
  }

  void copyProperties() {
    // Find the selected source MeasurementDetails
    Map sourceDetails = widget.measurementDetails.firstWhere(
      (details) => details["locationNo"].toString() == selectedSourceLocation,
      orElse: () {
        return {};
      },
    );

    // print("SOURCE DETAILS $sourceDetails");
    // Copy properties to selected target MeasurementDetails
    for (String targetLocation in selectedTargetLocations) {
      // Find the target MeasurementDetails

      Map targetDetails = widget.measurementDetails.firstWhere(
        (details) =>
            details["locationNo"].toString() == targetLocation.toString(),
        orElse: () {
          print("NO LOCation $targetLocation");
          return {'locationNo': targetLocation};
        },
      );

      // Update targetDetails properties with sourceDetails properties
      for (String property in selectedProperties) {
        targetDetails[property] = sourceDetails[property];
        var tp = targetDetails[property];
      }

      // widget.measurementDetails.forEach((element) {
      //   print(element['locationNo']);
      // });

      print("M details $targetDetails");

      print("TARGET LOC  ${targetLocation.toString()}");

      widget.updateMeasurementDetails(targetLocation, targetDetails);
    }

    // setState(() {
    //   propertiesToCopy = [];
    // });
  }

  void onPressedTest() {
    print(widget.measurementDetails.length);

    int ln = widget.measurementDetails.length;

    widget.measurementDetails.map((details) {
      print("details $details");
    });

    print("end");
  }
}

// Custom MultiSelect widget for better user experience
class MultiSelect extends StatefulWidget {
  final List<String> value;
  final List<MultiSelectItem> items;
  final ValueChanged<List<String>> onChanged;
  final bool isExpanded;
  final String? selectAllLabel;

  MultiSelect({
    required this.value,
    required this.items,
    required this.onChanged,
    this.isExpanded = false,
    this.selectAllLabel,
  });

  @override
  _MultiSelectState createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  bool _isAllSelected = false;

  @override
  void initState() {
    super.initState();
    _isAllSelected =
        widget.items.every((item) => widget.value.contains(item.value));
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        _isAllSelected
            ? widget.selectAllLabel ?? 'Select All'
            : widget.value.isNotEmpty
                ? widget.value.join(', ')
                : 'Select target locations',
      ),
      children: widget.items.map(buildCheckBox).toList(),
      initiallyExpanded: widget.isExpanded,
    );
  }

  Widget buildCheckBox(MultiSelectItem item) {
    final checked = widget.value.contains(item.value);
    return CheckboxListTile(
      shape: OvalBorder(),
      title: Text(item.label),
      value: checked,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            widget.value.add(item.value);
          } else {
            widget.value.remove(item.value);
          }

          _isAllSelected =
              widget.items.every((item) => widget.value.contains(item.value));
        });
        widget.onChanged(widget.value);
      },
    );
  }
}

class MultiSelectItem {
  final String value;
  final String label;

  MultiSelectItem({required this.value, required this.label});
}
