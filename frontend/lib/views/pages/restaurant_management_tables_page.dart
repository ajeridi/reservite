import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/models/table.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/selected_table_id_provider.dart';
import 'package:prbd_2526_a07/providers/tables_provider.dart';
import 'package:prbd_2526_a07/views/widgets/data_error_widget.dart';
import 'package:prbd_2526_a07/views/widgets/manager_navigation_bar_widget.dart';

import '../widgets/table_widgets/table_card_widget.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RestaurantManagementTablesPage(),
    ),
  );
}

class RestaurantManagementTablesPage extends ConsumerWidget {
  const RestaurantManagementTablesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final simulatedTime = ref.watch(applicationTimeProvider);

    final tablesState = ref.watch(tablesProvider);
    final tablesNotifier = ref.read(tablesProvider.notifier);
    final selectedTableIdNotifier = ref.read(selectedTableIdProvider.notifier);


    return tablesState.when(
        data: (tables) => data(context, theme, simulatedTime.value!, tables, tablesNotifier, selectedTableIdNotifier),
        error: (err, _) => DataErrorWidget(error: err, notifier: tablesNotifier),
        loading: () => Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
    );
  }

  Scaffold data(BuildContext context, ThemeData theme, DateTime simulatedTime, List<Table> tables, TablesNotifier tablesNotifier, SelectedTableIdNotifier selectedTableIdNotifier) {
    return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/my_restaurants_page');
        },
      ),
      title: const Text('Le Gourmet'),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Rafraîchir les données',
          onPressed: () {
            tablesNotifier.refresh();
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
              for (var table in tables)
                TableCardWidget(table: table),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'tables_fab',
              onPressed: () {
                selectedTableIdNotifier.set(0);
                Navigator.pushReplacementNamed(context, '/edit_table_page');
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: ManagerNavigationBarWidget(selected: 2),
  );
  }
}
