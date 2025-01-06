// prepare_estimate/models/work_details_preview.dart
class WorkDetailsPreview {
  final String name;
  final String status;
  final Map<String, dynamic> details;

  WorkDetailsPreview({
    required this.name,
    required this.status,
    required this.details,
  });

  // Convert WorkDetailsPreview to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'details': details,
    };
  }

  // Create WorkDetailsPreview from JSON
  factory WorkDetailsPreview.fromJson(Map<String, dynamic> json) {
    return WorkDetailsPreview(
      name: json['name'],
      status: json['status'],
      details: json['details'],
    );
  }

  // Check for equality based on the name and status
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkDetailsPreview) return false;
    return name == other.name && status == other.status;
  }

  @override
  int get hashCode => name.hashCode ^ status.hashCode;

  // Copy WorkDetailsPreview with updated fields
  WorkDetailsPreview copyWith({
    String? name,
    String? status,
    Map<String, dynamic>? details,
  }) {
    return WorkDetailsPreview(
      name: name ?? this.name,
      status: status ?? this.status,
      details: details ?? this.details,
    );
  }
}
