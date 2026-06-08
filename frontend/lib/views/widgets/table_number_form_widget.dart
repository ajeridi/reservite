import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/new_table_number_provider.dart';

class TableNumberFormWidget extends ConsumerWidget {
  const TableNumberFormWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final tableNumberState = ref.watch(newTableNumberProvider);

    return TextFormField(
      initialValue: '${tableNumberState ?? ''}',
      decoration: const InputDecoration(
        labelText: 'Numéro de table',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }
}