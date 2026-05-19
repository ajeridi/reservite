import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/core/tools/my_provider_observer.dart';

import '../../models/reservation.dart';
import '../../providers/reservations_provider.dart';
import '../widgets/data_error_widget.dart';
import '../widgets/reservation_widget.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
      ProviderScope(
        observers: [MyProviderObserver()],
        retry: (int _, Object _ ) => null,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const MyReservationsPage(),
        ),
    )
  );
}

class MyReservationsPage extends ConsumerWidget {
  const MyReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);


    final reservationsState = ref.watch(reservationsProvider);
    final reservationNotifier = ref.read(reservationsProvider.notifier);

    return reservationsState.when(
        data: (state) => data(state, reservationNotifier, theme, simulatedTime),
        error: (err, _) =>
            DataErrorWidget(
              error: err,
              stackTrace: StackTrace.current,
              notifier: reservationNotifier,
            ),
        loading: () => loading(),
    );
  }

  Widget data(List<Reservation> reservations,
      ReservationsNotifier notifier, ThemeData theme, DateTime simulatedTime) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes reservations'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              notifier.refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion (Benoît P.)',
            onPressed: () {},
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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            for (var reservation in reservations)
              ReservationCard(reservation: reservation,),
          ],
        ),
      ),
    );
  }
}

Widget loading() {
  return Center(child: CircularProgressIndicator(color: Colors.black));
}


