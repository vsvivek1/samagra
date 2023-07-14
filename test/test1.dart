import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:samagra/screens/measurement_display_widget.dart';

void main() {
  testWidgets('Measurement Display Widget Test', (WidgetTester tester) async {
    final measurementDetails = [
      {
        'locationName': 'Location 1',
        'tasks': [
          {
            'task_name': 'Task 1',
            'structures': [
              {
                'structure_name': 'Structure 1',
                'materials': [
                  {'material_name': 'Material 1'},
                  {'material_name': 'Material 2'},
                ],
                'labour': [
                  {'labour_name': 'Labour 1'},
                  {'labour_name': 'Labour 2'},
                ],
              },
              {
                'structure_name': 'Structure 2',
                'materials': [
                  {'material_name': 'Material 3'},
                  {'material_name': 'Material 4'},
                ],
                'labour': null,
              },
            ],
          },
          {
            'task_name': 'Task 2',
            'structures': null,
          },
        ],
      },
      {
        'locationName': 'Location 2',
        'tasks': null,
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MeasurementDisplayWidget(measurementDetails),
        ),
      ),
    );

    expect(find.text('1. Location 1'), findsOneWidget);
    expect(find.text('Task 1'), findsOneWidget);
    expect(find.text('Structure 1'), findsOneWidget);
    expect(find.text('Material 1'), findsOneWidget);
    expect(find.text('Material 2'), findsOneWidget);
    expect(find.text('Labour 1'), findsOneWidget);
    expect(find.text('Labour 2'), findsOneWidget);

    expect(find.text('Structure 2'), findsOneWidget);
    expect(find.text('Material 3'), findsOneWidget);
    expect(find.text('Material 4'), findsOneWidget);
    expect(find.text('No Labour'), findsNothing);

    expect(find.text('2. Location 2'), findsOneWidget);
    expect(find.text('No tasks'), findsOneWidget);
  });
}
