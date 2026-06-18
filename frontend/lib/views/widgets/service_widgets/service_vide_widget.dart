import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/tools/datetime_utils.dart';

class EmptyServiceWidget extends ConsumerWidget {

  final int dayOfWeek;

  const EmptyServiceWidget({
    super.key,
    required this.dayOfWeek,
  });



  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[100],
      child: ListTile(
        leading: const Icon(Icons.schedule, color: Colors.grey),
        title: Text(
          DatetimeUtils.dayOfWeekToString(dayOfWeek),
          style: TextStyle(color: Colors.grey[600]),
        ),
        subtitle: const Text(
          'Aucun service',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}