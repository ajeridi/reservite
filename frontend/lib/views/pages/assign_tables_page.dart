import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/selected_reservation_id_provider.dart';

import '../../providers/application_time_provider.dart';
import '../widgets/assign_table_1_widget.dart';

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
    final reservation = ref.watch(currentReservationProvider(ref.watch(selectedReservationIdProvider)));

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: assign_table_1_widget(reservation: reservation.value!),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Capacité totale: 6 places',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '✓ Capacité suffisante pour 4 convives',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: true,
                      onChanged: (_) {},
                      title: const Text('Table 1'),
                      subtitle: const Text(
                        'Capacité: 2 personnes',
                      ),
                      secondary: const Icon(Icons.table_restaurant),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: true,
                      onChanged: (_) {},
                      title: const Text('Table 2'),
                      subtitle: const Text(
                        'Capacité: 4 personnes',
                      ),
                      secondary: const Icon(Icons.table_restaurant),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: false,
                      onChanged: (_) {},
                      title: const Text('Table 3'),
                      subtitle: const Text(
                        'Capacité: 6 personnes',
                      ),
                      secondary: const Icon(Icons.table_restaurant),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.grey.shade100,
                    child: CheckboxListTile(
                      value: false,
                      onChanged: null,
                      title: Text(
                        'Table 4',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: Text(
                        'Occupée pour ce service',
                        style: TextStyle(
                          color: Colors.red.shade300,
                        ),
                      ),
                      secondary: Icon(
                        Icons.table_restaurant,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
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
