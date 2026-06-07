import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/auth_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/filtered_reservations_provider.dart';
import 'package:prbd_2526_a07/views/widgets/reservation_widget.dart';

import '../../core/tools/my_provider_observer.dart';
import '../../models/reservation.dart';
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
        home: HomeClientPage(),
      ),
    ),
  );
}

class HomeClientPage extends ConsumerWidget {
  HomeClientPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
    // temps simule
    final simulatedTime = ref.watch(applicationTimeProvider);

    return reservationsState.when(
      data: (state) => data(
        context,
        state,
        reservationNotifier,
        theme,
        filteredReservationsState,
        filteredReservationsNotifier,
        authNotifier,
        simulatedTime,
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
    AuthNotifier authNotifier,
    AsyncValue<DateTime> simulatedTime,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/search_restaurants_page',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              notifier.refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              authNotifier.logout();
              Navigator.pushReplacementNamed(context, '/login');
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
                  '${DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                                .format(simulatedTime.value!)}',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // redirection vers la page search_restaurant
          Navigator.pushReplacementNamed(context, '/search_restaurants_page');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle réservation'),
      ),
    );
  }
}

Widget loading() {
  return Center(child: CircularProgressIndicator(color: Colors.black));
}
