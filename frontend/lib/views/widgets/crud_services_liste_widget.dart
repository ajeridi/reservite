import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/services.dart';
import '../../providers/selected_services_provider.dart';
import '../../providers/services_provider.dart';

class crud_services_liste_widget extends ConsumerWidget {

  final String day;
  final List<Services> services;

  const crud_services_liste_widget({
    super.key,
    required this.day,
    required this.services
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesNotifier = ref.read(servicesProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const Icon(Icons.schedule),
        title: Text(day),
        subtitle: Text(services.map((s) =>
          '${DateFormat('HH:mm').format(s.startTime)} - ${DateFormat('HH:mm').format(s.endTime)}').join(', '),
        ),
        children: [
          for (final s in services)
            FutureBuilder<bool?>(
              future: servicesNotifier.canDelete(s.id),
              builder: (context, snapshot) {
                final canDelete = snapshot.data == true;
                return ListTile(
                  title:Text('${DateFormat('HH:mm').format(s.startTime)} - ${DateFormat('HH:mm').format(s.endTime)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Modifier le service',
                        onPressed: () {
                          ref.read(selectedServiceProvider.notifier).set(s.id);
                          Navigator.pushNamed(context, '/edit_service_page');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: canDelete ? Colors.red : Colors.grey[400]),
                        onPressed: canDelete
                            ? () => _showDeleteServiceDialog(context, ref, day: day, service: s)
                            : null,
                        tooltip: canDelete
                            ? 'Supprimer le service'
                            : 'Impossible de supprimer : des réservations non annulées utilisent ce service',
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}


String getNomDuJour(int date) {
  if (date == 1)
    return "Lundi";
  if (date == 2)
    return "Mardi";
  if (date == 3)
    return "Mercredi";
  if (date == 4)
    return "Jeudi";
  if (date == 5)
    return "Vendredi";
  if (date == 6)
    return "Samedi";
  if (date == 7)
    return "Dimanche";
  
  return "";
}


void _showDeleteServiceDialog(
    BuildContext context,
    WidgetRef ref, {
      required String day,
      required Services service,
    }) {
  final horaire =
      '${DateFormat('HH:mm').format(service.startTime)} - '
      '${DateFormat('HH:mm').format(service.endTime)}';

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Supprimer le service'),
      content: Text(
        'Êtes-vous sûr de vouloir supprimer le service du $day ($horaire) ?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();

            final ok = await ref.read(servicesProvider.notifier).delete(service.id);
            if (context.mounted && !ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Suppression impossible. Vérifiez que delete_service est déployé en base.',
                  ),
                ),
              );
            }
          },
          child: Text(
            'Supprimer',
            style: TextStyle(color: Colors.red[700]),
          ),
        ),
      ],
    ),
  );
}