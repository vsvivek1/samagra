import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samagra/local_url.dart';

class AddIbScreen extends StatefulWidget {
  final Map<String, dynamic>? ibData;
  const AddIbScreen({super.key, this.ibData});

  @override
  State<AddIbScreen> createState() => _AddIbScreenState();
}

class _AddIbScreenState extends State<AddIbScreen> {
  final Dio dio = Dio(BaseOptions(baseUrl: '$localUrl/api'));

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final addressController = TextEditingController();
  final districtController = TextEditingController();
  final pincodeController = TextEditingController();
  final phoneController = TextEditingController();

  File? imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.ibData != null) {
      nameController.text = widget.ibData!['name'] ?? '';
      locationController.text = widget.ibData!['location'] ?? '';
      addressController.text = widget.ibData!['address'] ?? '';
      districtController.text = widget.ibData!['district'] ?? '';
      pincodeController.text = widget.ibData!['pincode']?.toString() ?? '';
      phoneController.text = widget.ibData!['phone'] ?? '';
    }
  }

  Future<void> captureImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera);
    if (img != null) {
      setState(() {
        imageFile = File(img.path);
      });
    }
  }

  Future<void> submitIb() async {
    try {
      final formData = FormData.fromMap({
        'name': nameController.text,
        'location': locationController.text,
        'address': addressController.text,
        'district': districtController.text,
        'pincode': pincodeController.text,
        'phone': phoneController.text,
        if (imageFile != null)
          'photo': await MultipartFile.fromFile(imageFile!.path),
      });

      if (widget.ibData != null) {
        await dio.post('/ibbooking/ibs/update/${widget.ibData!['id']}', data: formData);
      } else {
        await dio.post('/ibbooking/ibs/create', data: formData);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved successfully")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to save")));
    }
  }

  Future<void> deleteIb() async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete IB"),
        content: const Text("Are you sure you want to delete this IB?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && widget.ibData?['id'] != null) {
      try {
        await dio.delete('/ibbooking/ibs/delete/${widget.ibData!['id']}');
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("IB deleted")));
        }
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delete failed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.ibData != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit IB" : "Add IB")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
            TextField(controller: districtController, decoration: const InputDecoration(labelText: 'District')),
            TextField(controller: pincodeController, decoration: const InputDecoration(labelText: 'Pincode'), keyboardType: TextInputType.number),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),

            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: captureImage,
                  icon: const Icon(Icons.camera),
                  label: const Text("Capture Photo"),
                ),
                const SizedBox(width: 10),
                if (imageFile != null) const Text("📸 Photo selected"),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: submitIb, child: Text(isEdit ? "Update IB" : "Add IB")),

            if (isEdit)
              TextButton(
                onPressed: deleteIb,
                child: const Text("Delete IB", style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
