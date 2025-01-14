class EstimateDetails {
  final String name;
  final String status;
  final Map<String, dynamic> details;
  final String lastVisitedScreen;

  EstimateDetails({
    required this.name,
    required this.status,
    required this.details,
    this.lastVisitedScreen = 'SavedEstimateDetailsScreen',
  });

  /// Factory constructor to safely handle null values from JSON
  factory EstimateDetails.fromJson(Map<String, dynamic> json) {
    return EstimateDetails(
      name: json['name'] ?? 'Untitled Estimate',       // Default value if null
      status: json['status'] ?? 'inProgress',          // Default value if null
      details: json['details'] ?? {},                 // Default empty map if null
      lastVisitedScreen: json['lastVisitedScreen'] ?? 'SavedEstimateDetailsScreen',
    );
  }

  /// Convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'details': details,
      'lastVisitedScreen': lastVisitedScreen,
    };
  }

  /// Allows selective updates while keeping immutability
  EstimateDetails copyWith({
    String? name,
    String? status,
    Map<String, dynamic>? details,
    String? lastVisitedScreen,
  }) {
    return EstimateDetails(
      name: name ?? this.name,
      status: status ?? this.status,
      details: details ?? this.details,
      lastVisitedScreen: lastVisitedScreen ?? this.lastVisitedScreen,
    );
  }
}
