import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';
import 'package:prbd_2526_a07/models/services.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/current_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/selected_services_provider.dart';
import 'package:prbd_2526_a07/providers/services_per_day_provider.dart';
import '../../models/service.dart';
import '../../providers/application_time_provider.dart';
import '../widgets/data_error_widget.dart';
import '../widgets/service_widgets/service_day_card.dart';
import '../widgets/service_widgets/service_vide_widget.dart';

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
    final simulatedTime = ref.watch(applicationTimeProvider);

    final servicesPerDayState = ref.watch(servicesPerDayProvider);
    final servicesNotifier = ref.read(servicesPerDayProvider.notifier);
    final selectedServiceIdNotifier = ref.read(
        selectedServiceIdProvider.notifier);

    final currentRestaurant = ref.watch(currentRestaurantProvider(ref.read(selectedRestaurantProvider))).value;

    return servicesPerDayState.when(
      data: (servicesPerDay) => data(
            context,
            theme,
            simulatedTime.value!,
            servicesPerDay,
            servicesNotifier,
            selectedServiceIdNotifier,
            currentRestaurant,
          ),
      error: (err, _) => DataErrorWidget(error: err, notifier: servicesNotifier),
      loading: () =>
          Center(child: Column(children: [CircularProgressIndicator()])),
    );
  }

  Scaffold data(
      BuildContext context,
      ThemeData theme,
      DateTime simulatedTime,
      Map<int, Services>servicesPerDay,
      ServicesPerDayNotifier servicesNotifier,
      SelectedServiceIdNotifier selectedTableIdNotifier, Restaurant? currentRestaurant,
      ) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/my_restaurants_page');
              },
            ),
            title: Text(currentRestaurant!.name), // on sait que le restaurant ne sera jamais null, car nous avions du cliquer sur un restaurant pour afficher les services
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Rafraîchir les données',
                onPressed: () {
                  servicesNotifier.refresh();
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
                          .format(simulatedTime),
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
                    // iteration et ajout des cartes de services
                    for (int day in servicesPerDay.keys) // pour chaque jour du map de services
                      ServiceDayCard(services: servicesPerDay[day]!, dayOfWeek: day,), // on cree la carte du jour avec les services
                  ],
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'services_fab',
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 1,
            onTap: (_) {},
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Réservations',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'Services',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.table_restaurant),
                label: 'Tables',
              ),
            ],
          ),
        );
      }
    }
