import 'dart:developer';

class LocationProcessor {
  Map<String, double> getTotalMaterialQuantities(
      List<Map<String, dynamic>> locations) {
    Map<String, double> materialTotals = {};

    for (var location in locations) {
      var tasks = location['tasks'];

      if (tasks != null) {
        for (var task in tasks) {
          var structures = task['structures'];

          if (structures != null) {
            for (var structure in structures) {
              var materials = structure['materials'];

              if (materials is List && materials.isNotEmpty) {
                for (var material in materials) {
                  if (material != null &&
                      material['material_name'] != null &&
                      material['quantity'] != null) {
                    materialTotals.update(
                      material['material_name'],
                      (value) => (value + material['quantity']).toDouble(),
                      ifAbsent: () => material['quantity'].toDouble(),
                    );
                  }
                }
              }
            }
          }
        }
      }
    }

    return materialTotals;
  }

  Map<String, double> getTotalTakenBackQuantities(
      List<Map<String, dynamic>> locations) {
    Map<String, double> takenBackTotals = {};

    for (var location in locations) {
      var tasks = location['tasks'];

      if (tasks != null) {
        for (var task in tasks) {
          var structures = task['structures'];

          if (structures != null) {
            for (var structure in structures) {
              var takenBack = structure['takenBack'];

              if (takenBack is List && takenBack.isNotEmpty) {
                for (var takenback in takenBack) {
                  if (takenback != null &&
                      takenback['taken_back_name'] != null &&
                      takenback['quantity'] != null) {
                    takenBackTotals.update(
                      takenback['taken_back_name'],
                      (value) => (value + takenback['quantity']).toDouble(),
                      ifAbsent: () => takenback['quantity'].toDouble(),
                    );
                  }
                }
              }
            }
          }
        }
      }
    }

    return takenBackTotals;
  }

  Map<String, double> getTotalLaborQuantities(
      List<Map<String, dynamic>> locations) {
    Map<String, double> laborTotals = {};

    for (var location in locations) {
      var tasks = location['tasks'];

      if (tasks != null) {
        for (var task in tasks) {
          var structures = task['structures'];

          if (structures != null) {
            for (var structure in structures) {
              var labour = structure['labour'];

              if (labour is List && labour.isNotEmpty) {
                for (var labor in labour) {
                  if (labor != null &&
                      labor['labour_name'] != null &&
                      labor['quantity'] != null) {
                    laborTotals.update(
                      labor['labour_name'],
                      (value) => (value + labor['quantity']).toDouble(),
                      ifAbsent: () => labor['quantity'].toDouble(),
                    );

                    print(laborTotals);
                    // debugger(when: true);
                  }
                }
              }
            }
          }
        }
      }
    }

    return laborTotals;
  }

  Map<double, Map<String, double>> getLocationWiseMaterialTotals(
      List<Map<String, dynamic>> locations) {
    Map<double, Map<String, double>> locationWiseMaterialTotals = {};

    for (var location in locations) {
      var tasks = location['tasks'];

      if (tasks != null) {
        for (var task in tasks) {
          var structures = task['structures'];

          Map<String, double> materialTotals = {};

          if (structures != null) {
            for (var structure in structures) {
              var materials = structure['materials'];

              if (materials is List && materials.isNotEmpty) {
                for (var material in materials) {
                  if (material != null &&
                      material['material_name'] != null &&
                      material['quantity'] != null) {
                    materialTotals.update(
                      material['material_name'],
                      (value) => (value + material['quantity']).toDouble(),
                      ifAbsent: () => material['quantity'].toDouble(),
                    );
                  }
                }
              }
            }
          }

          // Convert location['locationNo'] to double before using it as the key
          locationWiseMaterialTotals[location['locationNo'].toDouble()] =
              materialTotals;
        }
      }
    }

    return locationWiseMaterialTotals;
  }

  Map<double, Map<String, double>> getLocationWiseTakenBackTotals(
      List<Map<String, dynamic>> locations) {
    Map<double, Map<String, double>> locationWiseTakenBackTotals = {};

    for (var location in locations) {
      var tasks = location['tasks'];

      if (tasks != null) {
        for (var task in tasks) {
          var structures = task['structures'];

          Map<String, double> takenBackTotals = {};

          if (structures != null) {
            for (var structure in structures) {
              var takenBack = structure['takenBack'];

              if (takenBack is List && takenBack.isNotEmpty) {
                for (var takenback in takenBack) {
                  if (takenback != null &&
                      takenback['taken_back_name'] != null &&
                      takenback['quantity'] != null) {
                    takenBackTotals.update(
                      takenback['taken_back_name'],
                      (value) => (value + takenback['quantity']).toDouble(),
                      ifAbsent: () => (takenback['quantity']).toDouble(),
                    );
                  }
                }
              }
            }
          }

          locationWiseTakenBackTotals[location['locationNo'].toDouble()] =
              takenBackTotals;
        }
      }
    }

    return locationWiseTakenBackTotals;
  }

  Map<double, Map<String, double>> getLocationWiseLaborTotals(
      List<Map<String, dynamic>> locations) {
    Map<double, Map<String, double>> locationWiseLaborTotals = {};

    for (var location in locations) {
      var tasks = location['tasks'];

      if (tasks != null) {
        for (var task in tasks) {
          var structures = task['structures'];

          Map<String, double> laborTotals = {};

          if (structures != null) {
            for (var structure in structures) {
              var labour = structure['labour'];

              if (labour is List && labour.isNotEmpty) {
                for (var labor in labour) {
                  if (labor != null &&
                      labor['labour_name'] != null &&
                      labor['quantity'] != null) {
                    laborTotals.update(
                      labor['labour_name'],
                      (value) => (value + labor['quantity']).toDouble(),
                      ifAbsent: () => labor['quantity'].toDouble(),
                    );
                  }
                }
              }
            }
          }

          locationWiseLaborTotals[location['locationNo'].toDouble()] =
              laborTotals;
        }
      }
    }

    return locationWiseLaborTotals;
  }
}
