import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/table.dart';

import '../../providers/table_providers/selected_tables_provider.dart';

class assign_table_2_widget extends ConsumerWidget {

  final Table table;

  const assign_table_2_widget({
    super.key,
    required this.table,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTableProvider);
    final notifier = ref.read(selectedTableProvider.notifier);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: CheckboxListTile(
          value: selected.contains(table.id),
          onChanged: (_) {
            notifier.toggle(table.id);
          },
          title: Text('Table ${table.tableNumber}'),
          subtitle: Text(
            'Capacité: ${table.capacity} personnes',
          ),
          secondary: const Icon(Icons.table_restaurant),
        ),
      );
  }
}