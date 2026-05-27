import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prbd_2526_a07/views/pages/home_client_page.dart';
import 'package:prbd_2526_a07/views/pages/login_page.dart';
import 'package:prbd_2526_a07/views/pages/manager_reservations_page.dart';
import 'package:prbd_2526_a07/views/pages/my_restaurants_page.dart';
import 'package:prbd_2526_a07/views/pages/reservation_details_client_page.dart';
import 'package:prbd_2526_a07/views/pages/reservation_details_manager_page.dart';
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
      },
    );
  }
}
