import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/services.dart';

class crud_services_aucun_service_widget extends ConsumerWidget {

  final String day;

  const crud_services_aucun_service_widget({
    super.key,
    required this.day
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[100],
      child: ListTile(
        leading: const Icon(Icons.schedule, color: Colors.grey),
        title: Text(
          day,
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