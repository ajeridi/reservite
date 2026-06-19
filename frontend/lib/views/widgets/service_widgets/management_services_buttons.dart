import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/datetime_utils.dart';
import 'package:prbd_2526_a07/providers/services_per_day_provider.dart';
import '../../../../models/service.dart';

class ManagementServicesButtons extends ConsumerWidget {
  final Service service;

  const ManagementServicesButtons({super.key, required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: const Icon(Icons.edit), onPressed: () {
          Navigator.pushNamed(context,'/edit_service_page' ,
          arguments: service.id);
        }),
        IconButton(
          icon: Icon(
            Icons.delete,
            color: service.isUsed! ? Colors.grey : Colors.red,
          ),
          onPressed: service.isUsed!
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      // https://api.flutter.dev/flutter/material/AlertDialog-class.html
                      title: const Text('Supprimer le service'),
                      content: Text(
                        'Etes vous sur de vouloir supprimer le service du ${DatetimeUtils.dayOfWeekToString(service.dayOfWeek)} (${service.startEndTimeString()}) ?',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await ref
                                .read(servicesPerDayProvider.notifier)
                                .deleteService(service);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Service supprimé avec succès'),
                                duration: Duration(milliseconds: 800),
                              ),
                            );
                            Navigator.pop(context, 'OK');
                          },
                          child: const Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
          tooltip: service.isUsed!
              ? 'Impossible de supprimer : des réservations non annulées utilisent ce service'
              : 'Supprimer le service',
        ),
      ],
    );
  }
}
