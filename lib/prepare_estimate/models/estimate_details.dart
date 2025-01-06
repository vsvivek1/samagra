class EstimateDetails {
  final String name;
  final String status;
  final Map<String, dynamic> details;

  EstimateDetails({
    required this.name,
    required this.status,
    required this.details,
  });

  // Convert JSON to EstimateDetails object
  factory EstimateDetails.fromJson(Map<String, dynamic> json) {
    return EstimateDetails(
      name: json['name'] as String,
      status: json['status'] as String,
      details: json as Map<String, dynamic>,
    );
  }

  // Convert EstimateDetails object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'details': details,
    };
  }
}
