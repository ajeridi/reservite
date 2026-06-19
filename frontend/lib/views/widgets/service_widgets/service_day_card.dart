import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/views/widgets/service_widgets/management_services_buttons.dart';
import 'package:prbd_2526_a07/views/widgets/service_widgets/service_list_tile.dart';
import 'package:prbd_2526_a07/views/widgets/service_widgets/service_vide_widget.dart';

import '../../../../models/services.dart';
import '../../../../models/service.dart';
import '../../../core/tools/datetime_utils.dart';

class ServiceDayCard extends StatelessWidget {
  const ServiceDayCard({
    super.key,
    required this.services,
    required this.dayOfWeek,
  });

  // Set de tous les services du jour de la carte
  final Services services;
  final int dayOfWeek;

  @override
  Widget build(BuildContext context) {
    // 3, aucun services, 1 seul service, plusieurs services

    if (services.isEmpty()) {
      return EmptyServiceWidget(dayOfWeek: dayOfWeek);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      // si on a plus d'une reservation on afficher un expansion tile, sinon on affiche un simple list tile avec une seule reservation
      child: services.length() > 1
          ? ExpansionTile(
              leading: const Icon(Icons.schedule),
              title: Text(DatetimeUtils.dayOfWeekToString(dayOfWeek)),
              subtitle: Text(services.toString()),
              children: [
                for (Service service in services.getAll())
                  ServiceListTile(service: service),
              ],
            )
          : ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(DatetimeUtils.dayOfWeekToString(dayOfWeek)),
              subtitle: Text(services.toString()),
              trailing: ManagementServicesButtons(service: services.getFirst(),)
            ),
    );
  }
}
