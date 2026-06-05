import 'package:flutter/cupertino.dart' hide Table;
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/table.dart';

class assign_table_3_widget extends ConsumerWidget {

  final Table table;


  const assign_table_3_widget({
    super.key,
    required this.table,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey.shade100,
      child: CheckboxListTile(
        value: false,
        onChanged: null,
        title: Text(
          'Table ${table.tableNumber}',
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
    );
  }
}