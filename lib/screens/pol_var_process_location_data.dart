import 'package:samagra/screens/location_processor.dart';

LocationProcessor locationProcessor = LocationProcessor();

polvarProcessLocationData(measurementDetails1) {
  List<Map<String, dynamic>> measurementDetails =
      List<Map<String, dynamic>>.from(measurementDetails1);
  print('------------');

  Map<String, double> totalMaterialQuantities =
      locationProcessor.getTotalMaterialQuantities(measurementDetails);
  Map<String, double> totalTakenBackQuantities =
      locationProcessor.getTotalTakenBackQuantities(measurementDetails);
  Map<String, double> totalLaborQuantities =
      locationProcessor.getTotalLaborQuantities(measurementDetails);

  print('Total Material Quantities88888888888:');

  totalMaterialQuantities.forEach((name, quantity) {
    print('$name: $quantity');
  });
  print('Total Material Quantitie ENDs88888888888:');

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

  Map<double, Map<String, double>> locationWiseMaterialTotals =
      locationProcessor.getLocationWiseMaterialTotals(measurementDetails);
  Map<double, Map<String, double>> locationWiseTakenBackTotals =
      locationProcessor.getLocationWiseTakenBackTotals(measurementDetails);
  Map<double, Map<String, double>> locationWiseLaborTotals =
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
