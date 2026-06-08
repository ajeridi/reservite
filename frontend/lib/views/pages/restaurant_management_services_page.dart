import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/current_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/restaurants_provider.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/selected_services_provider.dart';
import 'package:prbd_2526_a07/providers/services_provider.dart';

import '../../models/restaurant.dart';
import '../../models/services.dart';
import '../../providers/application_time_provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/bottom_navigation_bar_widget.dart';
import '../widgets/crud_services_aucun_service_widget.dart';
import '../widgets/crud_services_liste_widget.dart';
import '../widgets/data_error_widget.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RestaurantManagementServicesPage(),
    ),
  );
}

class RestaurantManagementServicesPage extends ConsumerWidget {
  const RestaurantManagementServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final simulatedTime = ref.watch(applicationTimeProvider).value;

    final selectedRestaurantId = ref.read(selectedRestaurantProvider);
    final restaurant = ref.watch(
        currentRestaurantProvider(selectedRestaurantId)).value;

    final servicesState = ref.watch(servicesProvider);
    final serviceNotifier = ref.read(servicesProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);

    final selectedServicesNotifier = ref.read(selectedServiceProvider.notifier);

    final Map<int, String> dayOfWeeks = HashMap();
    dayOfWeeks.addAll({1: 'Lundi', 2: 'Mardi', 3: 'Mercredi', 4: 'Jeudi', 5: 'Vendredi', 6: 'Samedi', 7: 'Dimanche'});


    return servicesState.when(
      data: (state) => data(
              context,
              ref,
              state,
              serviceNotifier,
              theme,
              authNotifier,
              simulatedTime,
              restaurant,
              selectedServicesNotifier,
              dayOfWeeks
          ),
      error: (err, _) =>
          DataErrorWidget(
            error: err,
            stackTrace: StackTrace.current,
            notifier: serviceNotifier,
          ),
      loading: () => loading(),
    );
  }

  Widget data(
      BuildContext context,
      WidgetRef ref,
      List<Services> services,
      ServicesNotifier serviceNotifier,
      ThemeData theme,
      AuthNotifier authNotifier,
      DateTime? simulatedTime,
      Restaurant? restaurant,
      SelectedServiceNotifier selectedServicesNotifier,
      Map<int, String> dayOfWeeks
      ) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/my_restaurants_page');
          },
        ),
        title: Text(restaurant!.name),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
            },
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message:
                'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                      .format(simulatedTime!),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
               for (final entry in dayOfWeeks.entries)
                 Builder(
                   builder: (context) {
                     final dayServices = services
                         .where((s) => s.dayOfWeek == entry.key)
                         .toList();
                     if (dayServices.isEmpty) {
                       return crud_services_aucun_service_widget(day: entry.value);
                     }
                     return crud_services_liste_widget(
                       key: ValueKey(dayServices.map((s) => s.id).join('-')),
                       day: entry.value,
                       services: dayServices,
                     );
                   },
                 ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'services_fab',
                onPressed: () {
                  // id 0 = nouveau service (formulaire vide)
                  ref.read(selectedServiceProvider.notifier).set(0);
                  Navigator.pushNamed(context, '/edit_service_page');
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(currentIndex: 1),
    );
  }
}

Widget loading() {
  return Center(child: CircularProgressIndicator(color: Colors.black));
}
