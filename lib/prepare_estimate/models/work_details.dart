import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkDetails {
  String? scheme;
  String? subGroup;
  String? priority;
  List<Map<String, dynamic>> selectedAssemblies;
  List<Map<String, dynamic>> selectedVillages;
  List<Map<String, dynamic>> selectedLocalBodies;
  String? workName;
  String? workRemarks;
  List<LocationDetails> locations; // List of locations with tasks

  WorkDetails({
    this.scheme,
    this.subGroup,
    this.priority,
    required this.selectedAssemblies,
    required this.selectedVillages,
    required this.selectedLocalBodies,
    this.workName,
    this.workRemarks,
    List<LocationDetails>? locations,
  }) : locations = locations ?? [];

  // Add a location dynamically
  void addLocation(LocationDetails location) {
    locations.add(location);
  }
}

class LocationDetails {
  int locationNumber; // Unique location number
  String? name; // Name of the location
  Map<String, double>? geoCoordinates; // { "latitude": x, "longitude": y }
  List<TaskDetails> tasks; // List of tasks for this location

  LocationDetails({
    required this.locationNumber,
    this.name,
    this.geoCoordinates,
    List<TaskDetails>? tasks,
  }) : tasks = tasks ?? [];

  // Add a task dynamically
  void addTask(TaskDetails task) {
    tasks.add(task);
  }
}

class TaskDetails {
  String? name; // Task name
  List<StructureDetails> structures; // Structures related to the task

  TaskDetails({
    this.name,
    List<StructureDetails>? structures,
  }) : structures = structures ?? [];

  // Add a structure dynamically
  void addStructure(StructureDetails structure) {
    structures.add(structure);
  }
}

class StructureDetails {
  String? name; // Structure name
  List<MaterialDetails> materials; // Materials used in the structure
  List<LabourDetails> labours; // Labour details for the structure
  List<TakenBackDetails> takenBacks; // Items taken back from the site

  StructureDetails({
    this.name,
    List<MaterialDetails>? materials,
    List<LabourDetails>? labours,
    List<TakenBackDetails>? takenBacks,
  })  : materials = materials ?? [],
        labours = labours ?? [],
        takenBacks = takenBacks ?? [];

  // Add material dynamically
  void addMaterial(MaterialDetails material) {
    materials.add(material);
  }

  // Add labour dynamically
  void addLabour(LabourDetails labour) {
    labours.add(labour);
  }

  // Add taken back dynamically
  void addTakenBack(TakenBackDetails takenBack) {
    takenBacks.add(takenBack);
  }
}

class MaterialDetails {
  String name;
  double quantity;

  MaterialDetails({
    required this.name,
    required this.quantity,
  });
}

class LabourDetails {
  String name;
  double hoursWorked;

  LabourDetails({
    required this.name,
    required this.hoursWorked,
  });
}

class TakenBackDetails {
  String name;
  double quantity;

  TakenBackDetails({
    required this.name,
    required this.quantity,
  });
}

// StateNotifier for WorkDetails
class WorkDetailsNotifier extends StateNotifier<WorkDetails> {
  WorkDetailsNotifier()
      : super(
          WorkDetails(
            selectedAssemblies: [],
            selectedVillages: [],
            selectedLocalBodies: [],
          ),
        );

  void updateScheme(String? scheme) {
    state = WorkDetails(
      scheme: scheme,
      subGroup: state.subGroup,
      priority: state.priority,
      selectedAssemblies: state.selectedAssemblies,
      selectedVillages: state.selectedVillages,
      selectedLocalBodies: state.selectedLocalBodies,
      workName: state.workName,
      workRemarks: state.workRemarks,
      locations: state.locations,
    );
  }

  void updateWorkName(String? workName) {
    state = WorkDetails(
      scheme: state.scheme,
      subGroup: state.subGroup,
      priority: state.priority,
      selectedAssemblies: state.selectedAssemblies,
      selectedVillages: state.selectedVillages,
      selectedLocalBodies: state.selectedLocalBodies,
      workName: workName,
      workRemarks: state.workRemarks,
      locations: state.locations,
    );
  }

  void updatePriority(String? priority) {
    state = WorkDetails(
      scheme: state.scheme,
      subGroup: state.subGroup,
      priority: priority,
      selectedAssemblies: state.selectedAssemblies,
      selectedVillages: state.selectedVillages,
      selectedLocalBodies: state.selectedLocalBodies,
      workName: state.workName,
      workRemarks: state.workRemarks,
      locations: state.locations,
    );
  }
}

// Define the Riverpod provider
final workDetailsProvider =
    StateNotifierProvider<WorkDetailsNotifier, WorkDetails>(
  (ref) => WorkDetailsNotifier(),
);
