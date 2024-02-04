bool checkAnyStructureHasQuantity(Map<dynamic, dynamic> data) {
  List<dynamic>? structures = List<dynamic>.from(data['structures']);

  // Check if any structure has a 'quantity' field set
  return structures.any((structure) => structure['quantity'] != null);

  return false; // If 'structures' is null or not a List
}
