import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/services.dart';

class service_pasvide_2_widget extends ConsumerWidget {

  final Services service;

  const service_pasvide_2_widget({
    super.key,
    required this.service
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const Icon(Icons.schedule),
        title: const Text('Mercredi'),
        subtitle: const Text('12:00 - 14:00, 19:00 - 22:00'),
        children: [
          ListTile(
            title: const Text('12:00 - 14:00'),
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
          ListTile(
            title: const Text('19:00 - 22:00'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.grey[400]),
                  onPressed: null,
                  tooltip:
                  'Impossible de supprimer : des réservations non annulées utilisent ce service',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}