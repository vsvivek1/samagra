import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:samagra/local_url.dart';

class UserRoleManagementTabs extends StatefulWidget {
  const UserRoleManagementTabs({super.key});

  @override
  State<UserRoleManagementTabs> createState() => _UserRoleManagementTabsState();
}

class _UserRoleManagementTabsState extends State<UserRoleManagementTabs> with TickerProviderStateMixin {
  final Dio dio = Dio(BaseOptions(baseUrl: "$localUrl/api"));

  final List<String> roles = ['employee', 'caretaker', 'eic', 'admin', 'ritu_user'];
  final List<Map<String, dynamic>> ibList = [
    {'id': 1, 'name': 'IB Kozhikode'},
    {'id': 2, 'name': 'IB Thrissur'},
    {'id': 3, 'name': 'IB Kaloor'},
  ];

  final TextEditingController _empSearchController = TextEditingController();
  List<Map<String, dynamic>> allUserRoles = [];
  bool loadingAllRoles = false;
  String? lastMessage;

  void fetchRolesByEmployeeCode() async {
    final code = _empSearchController.text.trim();
    setState(() => loadingAllRoles = true);
    try {
      final response = code.isEmpty
          ? await dio.get('/ibbooking/roles/all')
          : await dio.get('/ibbooking/roles/$code');

      allUserRoles = code.isEmpty
          ? List<Map<String, dynamic>>.from(response.data)
          : List<String>.from(response.data['roles']).map((r) => {
              'employee_code': code,
              'role': r,
              'ib_id': null,
              'ib_name': null
            }).toList();
    } catch (_) {
      allUserRoles = [];
    }
    setState(() => loadingAllRoles = false);
  }

  void showAddRoleDialog() async {
    String? role;
    int? ibId;
    final empCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Role"),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: empCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Employee Code"),
              ),
              DropdownButton<String>(
                value: role,
                hint: const Text("Select Role"),
                isExpanded: true,
                items: roles.map((r) => DropdownMenuItem<String>(value: r, child: Text(r))).toList(),
                onChanged: (val) => setState(() {
                  role = val;
                  if (role != 'caretaker' && role != 'eic') ibId = null;
                }),
              ),
              if (role == 'caretaker' || role == 'eic')
                DropdownButton<int>(
                  value: ibId,
                  hint: const Text("Select IB"),
                  isExpanded: true,
                  items: ibList.map<DropdownMenuItem<int>>((ib) {
                    return DropdownMenuItem<int>(value: ib['id'], child: Text(ib['name']));
                  }).toList(),
                  onChanged: (val) => setState(() => ibId = val),
                )
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Add"),
            onPressed: () async {
              final empCode = empCtrl.text.trim();
              if (empCode.isEmpty || role == null || ((role == 'caretaker' || role == 'eic') && ibId == null)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please complete all required fields"))
                );
                return;
              }
              try {
                final res = await dio.post('/ibbooking/roles/assign', data: {
                  'employee_code': empCode,
                  'role': role,
                  'ib_id': (role == 'caretaker' || role == 'eic') ? ibId : null,
                });


                lastMessage = res.data is Map && res.data.containsKey('message') ? res.data['message'] : 'Role assigned';
                Navigator.pop(context, true);
              
              } on DioException catch (e) {
                lastMessage = e.response?.data is Map && e.response?.data.containsKey('message') ? e.response?.data['message'] : 'Assign failed';
                Navigator.pop(context, false);
              }


            },
          )
        ],
      ),
    );

    if (result != null && result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lastMessage ?? 'Success')),
      );
      fetchRolesByEmployeeCode();
    } else if (result != null && !result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lastMessage ?? 'Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage User Roles")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _empSearchController,
                    decoration: const InputDecoration(
                      labelText: "Employee Code (leave blank for all)",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: fetchRolesByEmployeeCode,
                  child: const Text("Search"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (loadingAllRoles)
              const CircularProgressIndicator()
            else if (allUserRoles.isEmpty)
              const Text("No roles found")
            else
              Expanded(
                child: ListView.builder(
                  itemCount: allUserRoles.length,
                  itemBuilder: (context, index) {
                    final role = allUserRoles[index];
                    return ListTile(
                      title: Text("${role['employee_code']} - ${role['role']}${role['ib_name'] != null ? ' (${role['ib_name']})' : ''}"),
                      onTap: () => {}, // existing dialog call remains here
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddRoleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
