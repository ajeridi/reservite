import 'dart:collection';

import 'package:flutter/cupertino.dart' hide Table;
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/table.dart';

import '../../models/reservation.dart';
import '../../providers/selected_tables_provider.dart';

class assign_table_4_widget extends ConsumerWidget {

  final Reservation reservation;
  final SplayTreeSet<Table> tables;

  const assign_table_4_widget({
    super.key,
    required this.reservation,
    required this.tables,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTableProvider);

    int totalCapacity = 0;
    for (Table t in tables) {
      if (selected.contains(t.id)) {
        totalCapacity += t.capacity;
      }
    }

    final guests = reservation.numberOfGuests;
    final ok = totalCapacity >= guests;

    final empty = selected.isEmpty;

    return Card(
      color: empty
        ? Colors.grey.shade100
        : (ok ? Colors.green.shade50 : Colors.yellow.shade50),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              empty
                  ? Icons.info_outline
                  : (ok ? Icons.check_circle : Icons.error),
              color: empty
                  ? Colors.grey
                  : (ok ? Colors.green[700] : Colors.yellow[700]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    empty
                        ? 'Sélectionnez une ou plusieurs tables'
                        : 'Capacité totale: $totalCapacity places',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!empty) ...[
                    const SizedBox(height: 4),
                    Text(
                      ok ? '✓ Capacité suffisante pour $guests convives' : '✗ Capacité insuffisante pour $guests convives',
                      style: TextStyle(
                        fontSize: 14,
                        color: ok ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}