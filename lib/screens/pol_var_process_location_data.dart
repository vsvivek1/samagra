import 'package:samagra/screens/location_processor.dart';

LocationProcessor locationProcessor = LocationProcessor();

polvarProcessLocationData(measurementDetails) {
  print('------------');

  Map<String, int> totalMaterialQuantities =
      locationProcessor.getTotalMaterialQuantities(measurementDetails);
  Map<String, int> totalTakenBackQuantities =
      locationProcessor.getTotalTakenBackQuantities(measurementDetails);
  Map<String, int> totalLaborQuantities =
      locationProcessor.getTotalLaborQuantities(measurementDetails);

  print('Total Material Quantities:');

  totalMaterialQuantities.forEach((name, quantity) {
    print('$name: $quantity');
  });

  // {
  //   // TODO: implement forEach
  //   throw UnimplementedError();
  // }

  print('\nTotal TakenBack Quantities:');
  totalTakenBackQuantities.forEach((name, quantity) {
    print('$name: $quantity');
  });

  print('\nTotal Labor Quantities:');
  totalLaborQuantities.forEach((name, quantity) {
    print('$name: $quantity');
  });

  Map<int, Map<String, int>> locationWiseMaterialTotals =
      locationProcessor.getLocationWiseMaterialTotals(measurementDetails);
  Map<int, Map<String, int>> locationWiseTakenBackTotals =
      locationProcessor.getLocationWiseTakenBackTotals(measurementDetails);
  Map<int, Map<String, int>> locationWiseLaborTotals =
      locationProcessor.getLocationWiseLaborTotals(measurementDetails);

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

  print('------------');
}
