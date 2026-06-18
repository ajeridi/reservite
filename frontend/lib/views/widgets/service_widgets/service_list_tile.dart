import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/service.dart';

class ServiceListTile extends StatelessWidget {
  const ServiceListTile({
    super.key,
    required this.service,
  });

  final Service service;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${DateFormat("HH:mm", "fr_FR").format(service.startTime)} - ${DateFormat("HH:mm", "fr_FR").format(service.endTime)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.grey[400]),
            onPressed: null,
            tooltip:
            'Impossible de supprimer : des réservations non annulées utilisent ce service',
          ),
        ],
      ),
    );
  }
}
