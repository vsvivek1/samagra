import 'package:get/get.dart';

Map<String, dynamic> formatTaskResponse( response) {


  return {
    "count": response["count"],
    "tasks": (response["tasks"] ?? []).map((task) {
      return {
        "id": task["id"],
        "task_code": task["task_code"],
        "task_name": task["task_name"],
        "mst_sbu_id": task["mst_sbu_id"],
        "mst_category_id": task["mst_category_id"],
        "mst_uom_id": task["mst_uom_id"],
        "is_planning_supported": task["is_planning_supported"],
        "status_flag": task["status_flag"],
        "start_date": task["start_date"],
        "end_date": task["end_date"],
        "structures": (task["structures"] ?? []).map((structure) {
          var structureDetails = structure["structure"] ?? {};
          return {
            "id": structure["id"],
            "structure_code": structureDetails["structure_code"] ?? "",
            "structure_name": structureDetails["structure_name"] ?? "",
            "mst_uom_id": structureDetails["mst_uom_id"],
            "materials": (structureDetails["mst_structure_materials"] ?? [])
                .map((material) {
              var materialDetails = material["mst_material"] ?? {};
              return {
                "id": material["id"],
                "material_code": materialDetails["material_code"] ?? "",
                "material_name": materialDetails["material_name"] ?? "",
                "quantity": material["quantity"] ?? "0",
                "is_return": material["is_return"] ?? false,
              };
            }).toList(),
            "labours": (structureDetails["mst_structure_labours"] ?? [])
                .map((labour) {
              var labourDetails = labour["mst_labour"] ?? {};
              return {
                "id": labour["id"],
                "labour_code": labourDetails["code"] ?? "",
                "labour_name": labourDetails["name"] ?? "",
                "quantity": labour["quantity_product"] ?? "0",
                "rate": labourDetails["rate"] ?? "0.0",
              };
            }).toList(),
          };
        }).toList(),
      };
    }).toList(),
  };
}
