import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/service.dart';

class service_pasvide_1_widget extends ConsumerWidget {

  final Service service;

  const service_pasvide_1_widget({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.schedule),
        title: const Text('Mardi'),
        subtitle: const Text('12:00 - 14:00, 19:00 - 22:00'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {},
              tooltip: 'Supprimer le service',
            ),
          ],
        ),
      ),
    );
  }
}