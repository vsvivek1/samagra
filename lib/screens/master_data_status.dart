import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samagra/screens/call_api_and_pull_masters.dart';

class MasterDataStatus {
  final bool materialExists;
  final bool labourExists;
  final String? materialLastUpdated;
  final String? labourLastUpdated;
  final bool materialNeedsRefresh;
  final bool labourNeedsRefresh;

  MasterDataStatus({
    required this.materialExists,
    required this.labourExists,
    this.materialLastUpdated,
    this.labourLastUpdated,
    required this.materialNeedsRefresh,
    required this.labourNeedsRefresh,
  });
}

Future<MasterDataStatus> checkMasterDataStatus() async {
  final storage = FlutterSecureStorage();
  final now = DateTime.now();

  String? materialJson = await storage.read(key: 'getMaterialGroupMaster');
  String? labourJson = await storage.read(key: 'getLabourGroupMaster');
  String? materialUpdatedAt = await storage.read(key: 'getMaterialGroupMasterUpdatedAt');
  String? labourUpdatedAt = await storage.read(key: 'getLabourGroupMasterUpdatedAt');

  bool materialExists = materialJson != null && materialJson.isNotEmpty;
  bool labourExists = labourJson != null && labourJson.isNotEmpty;

  bool materialNeedsRefresh = false;
  bool labourNeedsRefresh = false;

  if (materialUpdatedAt != null) {
    final materialDate = DateTime.tryParse(materialUpdatedAt);
    if (materialDate != null) {
      final difference = now.difference(materialDate).inDays;
      materialNeedsRefresh = difference > 7;
    }
  }

  if (labourUpdatedAt != null) {
    final labourDate = DateTime.tryParse(labourUpdatedAt);
    if (labourDate != null) {
      final difference = now.difference(labourDate).inDays;
      labourNeedsRefresh = difference > 7;
    }
  }

  return MasterDataStatus(
    materialExists: materialExists,
    labourExists: labourExists,
    materialLastUpdated: materialUpdatedAt,
    labourLastUpdated: labourUpdatedAt,
    materialNeedsRefresh: materialNeedsRefresh,
    labourNeedsRefresh: labourNeedsRefresh,
  );
}

Future<void> ensureMastersAreUpToDate(BuildContext context) async {
  final status = await checkMasterDataStatus();

  if (status.materialNeedsRefresh || status.labourNeedsRefresh || 
      !status.materialExists || !status.labourExists) {
    // Show AlertDialog to user
    bool refreshConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Required'),
          content: Text(
            'Material or Labour master data is missing or outdated.\nDo you want to refresh now?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // User said No
              },
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // User said Yes
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    ) ?? false;

    if (refreshConfirmed) {
      // User accepted → refresh data
      await callApiAndSaveLabourGroupMasterInSecureStorage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masters refreshed successfully.')),
      );
    }
  } else {
    print('Master data is up to date.');
  }
}
