class ProcessMeasurements {
  Map<int, dynamic> measurementDetails;

  ProcessMeasurements(this.measurementDetails);

  getMeasuredQuantity(String materialName) {
    int totalQuantity = 0;
    // Iterate through the nested structure
    for (var tasks in measurementDetails.values) {
      for (var structure in tasks['structures']) {
        for (var materialInfo in structure['materials']) {
          String name = materialInfo['material']['material_name'];
          if (name == materialName) {
            totalQuantity += int.parse(materialInfo['material']['quantity']);
          }
        }
      }
    }
    // Return total quantity if material name found, otherwise return -1
    return totalQuantity > 0 ? totalQuantity : -1;
  }

  Map<String, int> listUniqueMaterials() {
    Map<String, int> materialQuantities = {};

    // Iterate through the nested structure
    measurementDetails.forEach((locationNo, tasks) {
      tasks['structures'].forEach((structure) {
        structure['materials'].forEach((materialInfo) {
          String materialName = materialInfo['material']['material_name'];
          int quantity = materialInfo['material']['quantity'];
          // Accumulate quantities for each material
          materialQuantities.update(materialName, (value) => value + quantity,
              ifAbsent: () => quantity);
        });
      });
    });

    return materialQuantities;
  }
}



  // Create an instance of ProcessMeasurements
  /* ProcessMeasurements processMeasurements =
      ProcessMeasurements(measurementDetails); */

  // Call the listUniqueMaterials method
/*   Map<String, int> uniqueMaterials = processMeasurements.listUniqueMaterials();

  // Print the result
  uniqueMaterials.forEach((material, quantity) {
    print('$material: $quantity');
  });
} */
