import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/models/table.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/current_table_provider.dart';
import 'package:prbd_2526_a07/providers/new_table_capacity_provider.dart';
import 'package:prbd_2526_a07/providers/new_table_number_provider.dart';
import 'package:prbd_2526_a07/providers/selected_table_id_provider.dart';
import 'package:prbd_2526_a07/views/widgets/data_error_widget.dart';

import '../widgets/table_capacity_chooser_widget.dart';
import '../widgets/table_number_form_widget.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const EditTablePage(),
    ),
  );
}

class EditTablePage extends ConsumerWidget {
  const EditTablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final simulatedTime = ref.watch(applicationTimeProvider);

    final selectedTableIdState= ref.watch(selectedTableIdProvider);
    final selectedTableIdNotifier = ref.read(selectedTableIdProvider.notifier);
    
    final currentTable = ref.watch(currentTableProvider(selectedTableIdState));
    final currentTableNotifier = ref.read(currentTableProvider(selectedTableIdState).notifier);

    final newTableNumber = ref.watch(newTableNumberProvider);
    final newCapacity = ref.watch(newTableCapacityProvider);

    return currentTable.when(
        data: (table) => data(selectedTableIdNotifier, context, theme, simulatedTime, table, currentTableNotifier, newTableNumber, newCapacity),
        error: (err, st) => DataErrorWidget(error: err, notifier: currentTableNotifier),
        loading: () => Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
            ],
          ),
        )
    );
  }

  Scaffold data(SelectedTableIdNotifier selectedTableIdNotifier, BuildContext context, ThemeData theme, AsyncValue<DateTime> simulatedTime, Table? table, CurrentTableNotifier currentTableNotifier, int? newTableNumber, int newCapacity) {
    return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          selectedTableIdNotifier.clear();
          Navigator.pushReplacementNamed(context, '/restaurant_management_tables_page');
        },
      ),
      title: table != null ? const Text('Modifier la table') : const Text('Nouvelle table'),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          tooltip: 'Enregistrer',
          onPressed: () async {
            if (await currentTableNotifier.validateAll(newTableNumber)){
              await currentTableNotifier.saveTable(newTableNumber, newCapacity);
              Navigator.pushReplacementNamed(context, '/restaurant_management_tables_page');
            }
            return null;
          },
          icon: const Icon(Icons.save),
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
                    .format(simulatedTime.value!),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TableNumberFormWidget(),
              const SizedBox(height: 16),
              const Text('Capacité'),
              TableCapacityChooserWidget(),
            ],
          ),
        ),
      ),
    ),
  );
  }
}

