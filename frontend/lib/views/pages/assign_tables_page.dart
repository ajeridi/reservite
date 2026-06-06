import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/models/table.dart';
import 'package:prbd_2526_a07/providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

import '../../core/tools/pick_date_time.dart';
import '../../providers/application_time_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/selected_tables_provider.dart';
import '../../providers/tables_provider.dart';
import '../widgets/assign_table_1_widget.dart';
import '../widgets/assign_table_2_widget.dart';
import '../widgets/assign_table_3_widget.dart';
import '../widgets/assign_table_4_widget.dart';
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
      home: const AssignTablesPage(),
    ),
  );
}

class AssignTablesPage extends ConsumerWidget {
  const AssignTablesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final simulatedTime = ref.watch(applicationTimeProvider).value;
    final reservation = ref.watch(
      currentReservationProvider(ref.watch(selectedReservationIdProvider)),
    );

    final tablesState = ref.watch(tablesProvider);
    final tableNotifier = ref.read(tablesProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);

    return tablesState.when(
      data: (state) => data(
        context,
        ref,
        state,
        tableNotifier,
        theme,
        authNotifier,
        simulatedTime,
        reservation,
      ),
      error: (err, _) => DataErrorWidget(
        error: err,
        stackTrace: StackTrace.current,
        notifier: tableNotifier,
      ),
      loading: () => loading(),
    );
  }

  Widget data(
    BuildContext context,
    WidgetRef ref,
    List<Table> tables,
    TablesNotifier tableNotifier,
    ThemeData theme,
    AuthNotifier authNotifier,
    DateTime? simulatedTime,
    AsyncValue reservation,
  ) {
    final res = reservation.value;
    if (res == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Assigner des tables'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              tableNotifier.refresh();
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
              //GestureDetector pour detecter la touche
              child: GestureDetector(
                onTap: () async {
                  final newDatetime = await pickDateTime(
                    context,
                    initialDate: simulatedTime,
                  );
                  if (newDatetime != null) {
                    //on met à jour le provider avec la nouvelle date
                    ref
                        .read(applicationTimeProvider.notifier)
                        .setTime(newDatetime);
                  }
                },
                child: Tooltip(
                  message:
                      'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                  child: Text(
                    DateFormat(
                      'EEEE dd/MM/yyyy HH:mm',
                      'fr_FR',
                    ).format(simulatedTime!),
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: assign_table_1_widget(reservation: reservation.value!),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: assign_table_4_widget(
                reservation: reservation.value!,
                tables: tables,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sélectionnez les tables disponibles',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  for (final table in tables)
                    FutureBuilder<bool?>(
                      future: Table.is_occupee(idtable: table.id),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return assign_table_3_widget(table: table);
                        }
                        return assign_table_2_widget(table: table);
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final reservationId = ref.read(
                      selectedReservationIdProvider,
                    );
                    final selected = ref.read(selectedTableProvider);
                    await ref
                        .read(
                          currentReservationProvider(reservationId).notifier,
                        )
                        .confirmWithSelectedTables(selected);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Réservation confirmée avec les tables assignées',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pushReplacementNamed(
                      context,
                      '/manager_reservations_page',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Confirmer la réservation'),
                ),
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
