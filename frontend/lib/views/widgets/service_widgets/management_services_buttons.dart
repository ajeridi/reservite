import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../models/service.dart';

class ManagementServicesButtons extends StatelessWidget {
  final Service service;

  const ManagementServicesButtons({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        IconButton(
          icon: Icon(Icons.delete, color: service.isUsed! ? Colors.grey : Colors.red),
          onPressed: service.isUsed!
              ? null
              : () {
                  print('Delete service');
                },
          tooltip: service.isUsed!
              ? 'Impossible de supprimer : des réservations non annulées utilisent ce service'
              : 'Supprimer le service',
        ),
      ],
    );
  }
}
