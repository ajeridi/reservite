import 'package:flutter/cupertino.dart' hide Table;
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/table.dart';
import 'package:prbd_2526_a07/providers/selected_table_id_provider.dart';

class TableCardWidget extends ConsumerWidget {

  final Table table;

  const TableCardWidget({
    super.key,
    required this.table,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final selectedTableNotifier = ref.read(selectedTableIdProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.table_restaurant, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Table ${table.tableNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${table.capacity} personnes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                selectedTableNotifier.set(table.id);
                Navigator.pushReplacementNamed(context, '/edit_table_page');
              },
            ),
          ],
        ),
      ),
    );
  }
}
