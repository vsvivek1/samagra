class LocationProcessor {
  Map<String, int> getTotalMaterialQuantities(List<Location> locations) {
    Map<String, int> materialTotals = {};

    for (var location in locations) {
      for (var material in location.materials) {
        materialTotals.update(
            material.materialName, (value) => value + material.quantity,
            ifAbsent: () => material.quantity);
      }
    }

    return materialTotals;
  }

  Map<String, int> getTotalTakenBackQuantities(List<Location> locations) {
    Map<String, int> takenBackTotals = {};

    for (var location in locations) {
      for (var takenback in location.takenbacks) {
        takenBackTotals.update(
            takenback.takenBackName, (value) => value + takenback.quantity,
            ifAbsent: () => takenback.quantity);
      }
    }

    return takenBackTotals;
  }

  Map<String, int> getTotalLaborQuantities(List<Location> locations) {
    Map<String, int> laborTotals = {};

    for (var location in locations) {
      for (var labor in location.labors) {
        laborTotals.update(labor.laborName, (value) => value + labor.quantity,
            ifAbsent: () => labor.quantity);
      }
    }

    return laborTotals;
  }

  Map<int, Map<String, int>> getLocationWiseMaterialTotals(
      List<Location> locations) {
    Map<int, Map<String, int>> locationWiseMaterialTotals = {};

    for (var location in locations) {
      Map<String, int> materialTotals = {};

      for (var material in location.materials) {
        materialTotals.update(
            material.materialName, (value) => value + material.quantity,
            ifAbsent: () => material.quantity);
      }

      locationWiseMaterialTotals[location.locationNo] = materialTotals;
    }

    return locationWiseMaterialTotals;
  }

  Map<int, Map<String, int>> getLocationWiseTakenBackTotals(
      List<Location> locations) {
    Map<int, Map<String, int>> locationWiseTakenBackTotals = {};

    for (var location in locations) {
      Map<String, int> takenBackTotals = {};

      for (var takenback in location.takenbacks) {
        takenBackTotals.update(
            takenback.takenBackName, (value) => value + takenback.quantity,
            ifAbsent: () => takenback.quantity);
      }

      locationWiseTakenBackTotals[location.locationNo] = takenBackTotals;
    }

    return locationWiseTakenBackTotals;
  }

  Map<int, Map<String, int>> getLocationWiseLaborTotals(
      List<Location> locations) {
    Map<int, Map<String, int>> locationWiseLaborTotals = {};

    for (var location in locations) {
      Map<String, int> laborTotals = {};

      for (var labor in location.labors) {
        laborTotals.update(labor.laborName, (value) => value + labor.quantity,
            ifAbsent: () => labor.quantity);
      }

      locationWiseLaborTotals[location.locationNo] = laborTotals;
    }

    return locationWiseLaborTotals;
  }
}

void main() {
  List<Location> locations = [
    Location(
      locationNo: 1,
      coordinates: [12.345, 67.890],
      materials: [Material(materialName: 'Material1', quantity: 10)],
      takenbacks: [TakenBack(takenBackName: 'TakenBack1', quantity: 5)],
      labors: [Labor(laborName: 'Labor1', quantity: 3)],
    ),

    Location(
      locationNo: 2,
      coordinates: [12.345, 67.890],
      materials: [
        Material(materialName: 'Material2', quantity: 12),
        Material(materialName: 'Material3', quantity: 12)
      ],
      takenbacks: [TakenBack(takenBackName: 'TakenBack21', quantity: 5)],
      labors: [Labor(laborName: 'Labor12', quantity: 3)],
    ),

    // Add more locations as needed
  ];

  LocationProcessor locationProcessor = LocationProcessor();

  Map<String, int> totalMaterialQuantities =
      locationProcessor.getTotalMaterialQuantities(locations);
  Map<String, int> totalTakenBackQuantities =
      locationProcessor.getTotalTakenBackQuantities(locations);
  Map<String, int> totalLaborQuantities =
      locationProcessor.getTotalLaborQuantities(locations);

  print('Total Material Quantities:');
  totalMaterialQuantities.forEach((name, quantity) {
    print('$name: $quantity');
  });

  print('\nTotal TakenBack Quantities:');
  totalTakenBackQuantities.forEach((name, quantity) {
    print('$name: $quantity');
  });

  print('\nTotal Labor Quantities:');
  totalLaborQuantities.forEach((name, quantity) {
    print('$name: $quantity');
  });

  Map<int, Map<String, int>> locationWiseMaterialTotals =
      locationProcessor.getLocationWiseMaterialTotals(locations);
  Map<int, Map<String, int>> locationWiseTakenBackTotals =
      locationProcessor.getLocationWiseTakenBackTotals(locations);
  Map<int, Map<String, int>> locationWiseLaborTotals =
      locationProcessor.getLocationWiseLaborTotals(locations);

  print('\nLocation-wise Material Totals:');
  locationWiseMaterialTotals.forEach((locationNo, materialTotals) {
    print('Location $locationNo:');
    materialTotals.forEach((name, quantity) {
      print('$name: $quantity');
    });
  });

  print('\nLocation-wise TakenBack Totals:');
  locationWiseTakenBackTotals.forEach((locationNo, takenBackTotals) {
    print('Location $locationNo:');
    takenBackTotals.forEach((name, quantity) {
      print('$name: $quantity');
    });
  });

  print('\nLocation-wise Labor Totals:');
  locationWiseLaborTotals.forEach((locationNo, laborTotals) {
    print('Location $locationNo:');
    laborTotals.forEach((name, quantity) {
      print('$name: $quantity');
    });
  });
}

class Location {
  int locationNo;
  List<double> coordinates;
  List<Material> materials;
  List<TakenBack> takenbacks;
  List<Labor> labors;

  Location({
    required this.locationNo,
    required this.coordinates,
    required this.materials,
    required this.takenbacks,
    required this.labors,
  });
}

class Material {
  String materialName;
  int quantity;

  Material({required this.materialName, required this.quantity});
}

class TakenBack {
  String takenBackName;
  int quantity;

  TakenBack({required this.takenBackName, required this.quantity});
}

class Labor {
  String laborName;
  int quantity;

  Labor({required this.laborName, required this.quantity});
}
