import 'package:flutter/material.dart';

Widget buildTrailing(
    bool editMode,
    int index,
    List<String> items,
    List<String> itemValues,
    Function(int) onEdit,
    Function(int) onSave,
    Function(int) onCancel) {
  if (editMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: () {
            onSave(index);
          },
        ),
        IconButton(
          icon: Icon(Icons.cancel),
          onPressed: () {
            onCancel(index);
          },
        ),
      ],
    );
  } else {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        onEdit(index);
      },
    );
  }
}
