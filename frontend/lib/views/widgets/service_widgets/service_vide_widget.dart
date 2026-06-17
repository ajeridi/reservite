import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/services.dart';
import '../../../providers/selected_services_provider.dart';

class service_vide_widget extends ConsumerWidget {

  final Services service;
  const service_vide_widget({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[100],
      child: ListTile(
        leading: const Icon(Icons.schedule, color: Colors.grey),
        title: Text(
          getJour(service.dayOfWeek),
          style: TextStyle(color: Colors.grey[600]),
        ),
        subtitle: const Text(
          'Aucun service',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }


  String getJour(int day_of_week) {
    if (day_of_week == 1)
      return 'Lundi';
    if (day_of_week == 2)
      return 'Mardi';
    if (day_of_week == 3)
      return 'Mercredi';
    if (day_of_week == 4)
      return 'Jeudi';
    if (day_of_week == 5)
      return 'Vendredi';
    if (day_of_week == 6)
      return 'Samedi';
    if (day_of_week == 7)
      return 'Dimanche';

    return '';
  }
}