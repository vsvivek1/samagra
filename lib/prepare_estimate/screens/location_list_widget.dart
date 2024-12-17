import 'package:flutter/material.dart';
import 'package:samagra/prepare_estimate/screens/add_tasks.dart';
import 'package:samagra/prepare_estimate/screens/create_location_screen.dart';


class LocationListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> locations;

  const LocationListWidget({Key? key, required this.locations})
      : super(key: key);

  @override
  _LocationListWidgetState createState() => _LocationListWidgetState();
}

class _LocationListWidgetState extends State<LocationListWidget> {
  Map<String, dynamic>? selectedLocation;

  // Show details of the selected location
  Widget _buildLocationDetails() {
    if (selectedLocation == null) {
      return const Center(
        child: Text(
          'Select a location to view details',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Number: ${selectedLocation!['locationNumber']}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'Geo-coordinates:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
            'Latitude: ${selectedLocation!['geoCoordinates']['latitude']}, Longitude: ${selectedLocation!['geoCoordinates']['longitude']}'),
        const SizedBox(height: 10),
        Text(
          'Tasks:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (selectedLocation!['tasks'] != null &&
            selectedLocation!['tasks'].isNotEmpty)
          Column(
            children: (selectedLocation!['tasks'] as List<Map<String, dynamic>>)
                .map((task) => ListTile(
                      leading: const Icon(Icons.task_alt),
                      title: Text(task['name']),
                      subtitle: Text('Task ID: ${task['id']}'),
                    ))
                .toList(),
          )
        else
          const Text('No tasks available for this location.'),
        const SizedBox(height: 10),
        Text(
          'Photos:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        // Dummy photos section
        const Text('Photos section here (implementation required).'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location List'),
      ),
      body: Row(
        children: [
          // List of locations
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: widget.locations.length,
              itemBuilder: (context, index) {
                final location = widget.locations[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text('Location ${index + 1}'),
                  onTap: () {
                    setState(() {
                      selectedLocation = location;
                    });
                  },
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          // Details of selected location
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildLocationDetails(),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add_tasks',
            onPressed: () async {
              final tasks = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTasksWidget(categoryId: '1'),
                ),
              );

              if (tasks != null && selectedLocation != null) {
                setState(() {
                  selectedLocation!['tasks'] = tasks;
                });
              }
            },
            icon: const Icon(Icons.add_task),
            label: const Text('Capture New Tasks'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'add_location',
            onPressed: () async {
              final newLocation = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateLocation(
                    tasks: [],
                  ),
                ),
              );

              if (newLocation != null) {
                setState(() {
                  widget.locations.add(newLocation);
                });
              }
            },
            icon: const Icon(Icons.add_location),
            label: const Text('Capture New Location'),
          ),
        ],
      ),
    );
  }
}
