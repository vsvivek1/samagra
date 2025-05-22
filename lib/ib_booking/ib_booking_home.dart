import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:samagra/common.dart';
import 'package:samagra/ib_booking/add_food_menu_screen.dart';
import 'package:samagra/ib_booking/adminstrative_cancel_screen.dart';
import 'package:samagra/ib_booking/check_in_screen.dart';
import 'package:samagra/ib_booking/check_out_screen.dart';
import 'package:samagra/ib_booking/complaint_details.dart';
import 'package:samagra/ib_booking/complaint_list_screen.dart';
import 'package:samagra/ib_booking/complaints_screen.dart';
import 'package:samagra/ib_booking/ib_list.dart';
import 'package:samagra/ib_booking/ib_room_management.dart';
import 'package:samagra/ib_booking/my_bookings.dart';
import 'package:samagra/ib_booking/near_by_ib_screen.dart';
import 'package:samagra/ib_booking/user_management.dart';
import 'package:samagra/ib_booking/view_booking_screen.dart';
import 'package:samagra/ib_booking/view_food_menu_screen.dart';
import 'package:samagra/local_url.dart';
import 'package:samagra/ib_booking/add_ib_screen.dart';

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

     '/add_ib': (context) => const AddIbScreen(), //


     '/list_ibs':(context) => const IbListScreen(userRoles: [],),

     '/raise_omplaint':(context) => const ComplaintScreen(),

     '/my_complaints':(context) => const ComplaintListScreen(currentUserId: 1064767),

     '/add_food_menu':  (ctx) => const AddFoodMenuScreen(),
  '/view_food_menu': (ctx) => const ViewFoodMenuScreen(),

  '/check_in' : (ctx) => const CheckInScreen(),
    '/check_out' : (ctx) => const CheckOutScreen(),

    '/add_rooms':(ctx) => const IbRoomManagementScreen(),

    '/view_bookings' :(ctx) => const ViewBookingsScreen(),

       '/admin_cancel' :(ctx) => const AdministrativeCancelScreen(),

       '/my_bookings' :(ctx) => const ViewMyBookingsScreen(employeeCode: '1064767'),

       '/nearby_ib' :(ctx) => const NearbyIbsScreen(),



   //  '/complaintDetail':(context) => const ComplaintDetailScreen(),
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

      // API gives a List of maps like: [{"role":"ritu_user", "ib_id":null}]
      if (data is List) {
        roles = data.map<String>((e) => e['role'].toString()).toList();
      } else {
        roles = ['employee']; // fallback default
      }
    }

    if (roles.isEmpty && empCode.toString().isNotEmpty) {
      roles = ['employee'];
    }

    // Debug print
    print("Roles fetched for $empCode: $roles");

    // Load the menu
    final jsonData = await rootBundle.loadString('assets/ib_menu.json');
    final data = json.decode(jsonData);
    final fullMenu = List<Map<String, dynamic>>.from(data['menu']);

    // Filter menu based on roles
    menuItems = fullMenu.where((item) {
      final allowedRoles = List<String>.from(item['roles']);
      return allowedRoles.isEmpty || allowedRoles.any((role) => roles.contains(role));
    }).toList();

    print("Menu items visible: ${menuItems.map((e) => e['title']).toList()}");

    setState(() {});
  } catch (e) {
    print("❌ Error loading roles or menu: $e");
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
    "home":Icons.home
  };
}
