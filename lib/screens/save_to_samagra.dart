class SaveToSamagra {

  
  String generateMaterial(Map<String, dynamic> object, String id) {
    String mstMaterialStatusId = object['mst_material_status_id'];
    String wrkExecutionMaterialScheduleId =
        object['wrk_execution_material_schedule_id'];
    String mstMaterialId = object['mst_material_id'];

    return mstMaterialStatusId +
        '_' +
        wrkExecutionMaterialScheduleId +
        '_' +
        mstMaterialId +
        '_' +
        id;
  }

  // Other methods and properties can be added here as needed
}
