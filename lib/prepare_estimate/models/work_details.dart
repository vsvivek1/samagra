class WorkDetails {
  String? scheme;
  String? subGroup;
  String? priority;
  List<Map<String, dynamic>> selectedAssemblies;
  List<Map<String, dynamic>> selectedVillages;
  List<Map<String, dynamic>> selectedLocalBodies;
  String? workName;
  String? workRemarks;

  WorkDetails({
    this.scheme,
    this.subGroup,
    this.priority,
    required this.selectedAssemblies,
    required this.selectedVillages,
    required this.selectedLocalBodies,
    this.workName,
    this.workRemarks,
  });
}
