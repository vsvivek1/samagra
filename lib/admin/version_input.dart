import 'package:flutter/material.dart';

class VersionInput extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const VersionInput({Key? key, required this.onChanged}) : super(key: key);

  @override
  _VersionInputState createState() => _VersionInputState();
}

class _VersionInputState extends State<VersionInput> {
  TextEditingController _majorController = TextEditingController();
  TextEditingController _minorController = TextEditingController();
  TextEditingController _patchController = TextEditingController();

  @override
  void dispose() {
    _majorController.dispose();
    _minorController.dispose();
    _patchController.dispose();
    super.dispose();
  }

  void _updateVersionNumber() {
    final versionNumber =
        '${_majorController.text}.${_minorController.text}.${_patchController.text}';
    widget.onChanged(versionNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _majorController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Major Version'),
            onChanged: (_) => _updateVersionNumber(),
          ),
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: TextFormField(
            controller: _minorController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Minor Version'),
            onChanged: (_) => _updateVersionNumber(),
          ),
        ),
        SizedBox(width: 10.0),
        Expanded(
          child: TextFormField(
            controller: _patchController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Patch Version'),
            onChanged: (_) => _updateVersionNumber(),
          ),
        ),
      ],
    );
  }
}
