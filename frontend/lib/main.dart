import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prbd_2526_a07/views/pages/assign_tables_page.dart';
import 'package:prbd_2526_a07/views/pages/edit_service_page.dart';
import 'package:prbd_2526_a07/views/pages/edit_table_page.dart';
import 'package:prbd_2526_a07/views/pages/home_client_page.dart';
import 'package:prbd_2526_a07/views/pages/login_page.dart';
import 'package:prbd_2526_a07/views/pages/manager_reservations_page.dart';
import 'package:prbd_2526_a07/views/pages/my_restaurants_page.dart';
import 'package:prbd_2526_a07/views/pages/reservation_details_client_page.dart';
import 'package:prbd_2526_a07/views/pages/reservation_details_manager_page.dart';
import 'package:prbd_2526_a07/views/pages/reservation_form_page.dart';
import 'package:prbd_2526_a07/views/pages/restaurant_details_page.dart';
import 'package:prbd_2526_a07/views/pages/restaurant_management_services_page.dart';
import 'package:prbd_2526_a07/views/pages/restaurant_management_tables_page.dart';
import 'package:prbd_2526_a07/views/pages/search_restaurants_page.dart';
import 'package:prbd_2526_a07/views/pages/signup_page.dart';

import 'core/tools/my_provider_observer.dart';
import 'core/tools/params.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(
      ProviderScope(
        observers: [MyProviderObserver()],
        retry: (int _, Object _) => null,
        child: const MyApp()
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Params.init();
    return MaterialApp(
      title: 'ReserVite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginMockupScreen(),
        '/signup': (context) => const SignupMockupScreen(),
        '/home_client_page': (context) => HomeClientPage(),
        '/my_restaurants_page': (context) => MyRestaurantsPage(),
        '/manager_reservations_page' : (context) => ManagerReservationsPage(),
        '/reservation_details_client_page' : (context) => ReservationDetailsClientPage(),
        '/reservation_details_manager_page' : (context) => ReservationDetailsManagerPage(),
        '/search_restaurants_page' : (context) => SearchRestaurantsScreen(),
        '/restaurant_details_page' : (context) => RestaurantDetailsPage(),
        '/reservation_form_page' : (context) => ReservationFormPage(),
        '/assign_tables_page' : (context) => AssignTablesPage(),
        '/restaurant_management_tables_page' : (context) => RestaurantManagementTablesPage(),
        '/edit_table_page' : (context) => EditTablePage(),
        '/restaurant_management_services_page' : (context) => RestaurantManagementServicesPage(),
        '/edit_service_page' : (context) => EditServicePage()
      },
    );
  }
}
