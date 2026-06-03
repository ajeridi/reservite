import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/reservation.dart';
import '../../providers/selected_reservation_id_provider.dart';
import '../../providers/user_role_provider.dart';

class assign_table_1_widget extends ConsumerWidget {

  final Reservation reservation;

  const assign_table_1_widget({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // on a besoin du notifier qui va stocker l'id de la reservation selectionee
    final selectedReservationIdNotifier = ref.read(selectedReservationIdProvider.notifier);
    // on doit voir le notifier de l'utilisateur connecte, pour connaitre son role et rediriger vers la bonne page de details
    final userRole = ref.watch(userRoleProvider).value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Réservation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('${reservation.numberOfGuests} convives'),
            Text('${DateFormat('EE dd/MM/yyyy à HH:mm', 'fr_FR')
                .format(reservation.datetime)}'),
          ],
        ),
      ),
    );
  }
}