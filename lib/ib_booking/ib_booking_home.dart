import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:samagra/common.dart';
import 'package:samagra/ib_booking/user_management.dart';
import 'package:samagra/local_url.dart';

// Import your target screens here


class IbBookingHomeScreen extends StatefulWidget {
  const IbBookingHomeScreen({Key? key}) : super(key: key);

  @override
  _IbBookingHomeScreenState createState() => _IbBookingHomeScreenState();
}

class _IbBookingHomeScreenState extends State<IbBookingHomeScreen> {
  List<Map<String, dynamic>> menuItems = [];
  List<String> roles = [];
  bool loading = true;
  var user;

  // ✅ Local route map inside this class
  final Map<String, WidgetBuilder> localRoutes = {
    '/user_management': (context) => const UserRoleManagementTabs(),
    // '/book_ib': (context) => const BookIbScreen(),
    // '/view_bookings': (context) => const BookingListScreen(),
    // '/food_requests': (context) => const FoodRequestScreen(),
  };

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final userData = await getUser();
    user = userData['user'];
    await loadUserRolesAndMenu();
    setState(() => loading = false);
  }

  Future<void> loadUserRolesAndMenu() async {
    try {
      final empCode = user['employee_code'];

      final roleResponse = await http.get(Uri.parse('$localUrl/ibbooking/roles/$empCode'));
      if (roleResponse.statusCode == 200) {
        final data = json.decode(roleResponse.body);
        roles = data is List
            ? data.map<String>((e) => e['role'].toString()).toList()
            : List<String>.from(data['roles']);
      }

      if (roles.isEmpty && empCode.toString().isNotEmpty) {
        roles = ['employee'];
      }

      final jsonData = await rootBundle.loadString('assets/ib_menu.json');
      final data = json.decode(jsonData);
      final fullMenu = List<Map<String, dynamic>>.from(data['menu']);

      menuItems = fullMenu.where((item) {
        final allowedRoles = List<String>.from(item['roles']);
        return allowedRoles.isEmpty || allowedRoles.any((role) => roles.contains(role));
      }).toList();

      setState(() {});
    } catch (e) {
      print("Error loading menu or roles: $e");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/ib/home.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 Welcome Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Welcome, ${user['name']}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                    ),
                  ),
                ),
                // 🌀 Menu Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: menuItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.85),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(12),
                          elevation: 5,
                        ),
                        onPressed: () {
                          final routeName = item['route'];
                          final builder = localRoutes[routeName];

                          if (builder != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: builder),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Route '${item['title']}' not found")),
                            );
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              IconsMap[item['icon']] ?? Icons.widgets,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final Map<String, IconData> IconsMap = {
    "book_online": Icons.book_online,
    "calendar_today": Icons.calendar_today,
    "report_problem": Icons.report_problem,
    "assignment": Icons.assignment,
    "restaurant_menu": Icons.restaurant_menu,
    "fastfood": Icons.fastfood,
    "people_alt": Icons.people_alt,
    "engineering": Icons.engineering,
    "admin_panel_settings": Icons.admin_panel_settings,
  };
}
