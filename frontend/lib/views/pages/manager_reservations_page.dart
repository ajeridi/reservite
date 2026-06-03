import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';
import 'package:prbd_2526_a07/providers/auth_provider.dart';
import 'package:prbd_2526_a07/providers/current_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/filtered_reservations_provider.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/views/widgets/reservation_widget.dart';

import '../../core/tools/my_provider_observer.dart';
import '../../models/reservation.dart';
import '../../providers/application_time_provider.dart';
import '../../providers/reservation_providers/reservations_provider.dart';
import '../widgets/data_error_widget.dart';

/*
  Utilisation de segmentedButton :
* https://medium.com/@eleu.ander/using-segmentedbutton-in-flutter-a-real-study-case-81fd81ce668d

* */

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    ProviderScope(
      observers: [MyProviderObserver()],
      retry: (int _, Object _) => null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: ManagerReservationsPage(),
      ),
    ),
  );
}

class ManagerReservationsPage extends ConsumerWidget {
  ManagerReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final idRestaurant = ref.watch(selectedRestaurantProvider); // recherche l'id du restaurant sélectionné
    final restaurantState = ref.watch(currentRestaurantProvider(idRestaurant)); // recherche du nom grâce à l'id

    // etat de connexion
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    // etat de la liste contenant toutes les reservations
    final reservationsState = ref.watch(reservationsProvider);
    final reservationNotifier = ref.read(reservationsProvider.notifier);
    // etat de la liste contenant les reservations filtrees
    final filteredReservationsState = ref.watch(filteredReservationsProvider);
    final filteredReservationsNotifier = ref.read(
      filteredReservationsProvider.notifier,
    );
    //observation du provider de la application_time
    final applicationTime = ref.watch(applicationTimeProvider);


// Il faut imbriquer le .when() de applicationTime autour du reservationsState.when()
    return reservationsState.when(
      data: (state) => applicationTime.when(
        data: (simulatedTime) => data(
          context,
          state,
          reservationNotifier,
          theme,
          filteredReservationsState,
          filteredReservationsNotifier,
          authNotifier,
          restaurantState,
          simulatedTime,
        ),
        error: (e, _) => DataErrorWidget(
          error: e,
          notifier: reservationNotifier,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => DataErrorWidget(
        error: err,
        stackTrace: StackTrace.current,
        notifier: reservationNotifier,
      ),
      loading: () => loading(),
    );
  }

  Widget data(
    BuildContext context,
    SplayTreeSet<Reservation> reservations,
    ReservationsNotifier notifier,
    ThemeData theme,
    SplayTreeSet<Reservation> filteredReservationsState,
    FilteredReservationsNotifier filteredReservationsNotifier,
    AuthNotifier authNotifier, AsyncValue<Restaurant> restaurantState,
      DateTime simulatedTime,
  ) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/my_restaurants_page');
          },
        ),
        title: restaurantState.whenData((restaurant) => Text(restaurant.name)).value, // https://stackoverflow.com/questions/67552886/futureprovider-using-whendata-shorthand
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              notifier.refresh();
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
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(simulatedTime),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              /* https://api.flutter.dev/flutter/material/SegmentedButton-class.html */
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: 'all',
                    icon: Icon(Icons.list, size: 24),
                    tooltip: 'Toutes',
                  ),
                  ButtonSegment(
                    value: 'pending',
                    icon: Icon(Icons.pending, size: 24, color: Colors.orange),
                    tooltip: 'En attente',
                  ),
                  ButtonSegment(
                    value: 'confirmed',
                    icon: Icon(
                      Icons.check_circle,
                      size: 24,
                      color: Colors.green,
                    ),
                    tooltip: 'Confirmées',
                  ),
                  ButtonSegment(
                    value: 'completed',
                    icon: Icon(
                      Icons.event_available,
                      size: 24,
                      color: Colors.blue,
                    ),
                    tooltip: 'Terminées',
                  ),
                  ButtonSegment(
                    value: 'cancelled',
                    icon: Icon(Icons.cancel, size: 24, color: Colors.red),
                    tooltip: 'Annulées',
                  ),
                ],
                selected: {filteredReservationsNotifier.filterStatus},
                onSelectionChanged: (Set<String> newSelection) {
                  filteredReservationsNotifier.filterStatus = newSelection
                      .first; // on enregistre le filtre de selection
                  // appeler la fonction filtrage du notifier des reservations filtrees pour update le state
                  filteredReservationsNotifier.updateFilter(reservations);
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  for (var reservation in filteredReservationsState)
                    ReservationCard(reservation: reservation),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget loading() {
  return Center(child: CircularProgressIndicator(color: Colors.black));
}
