import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/user_role_provider.dart';

import '../../models/reservation.dart';

class ReservationDetailsWidget extends ConsumerWidget {
  const ReservationDetailsWidget({
    super.key,
    required this.currentReservationState,
  });

  final Reservation? currentReservationState;


  // methode qui retourne la couleur du status
  Color? statusColor(Status status) {
    return switch(status){
      Status.pending => Colors.orange,
      Status.confirmed => Colors.green,
      Status.completed => Colors.blue,
      Status.cancelled => Colors.red
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final userRole = ref.read(userRoleProvider).value;


    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userRole == 'manager') ... {
            const Text(
              'Détails de la réservation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8)
            },
            Row(
              children: [
                const Icon(Icons.restaurant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${currentReservationState?.restaurant.name}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${currentReservationState?.restaurant.address}, ${currentReservationState?.restaurant.city}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${currentReservationState?.restaurant.phone}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Date: ${DateFormat('EE dd/MM/yyyy', 'fr_FR').format(currentReservationState!.datetime)}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Heure: ${DateFormat('HH:mm', 'fr_FR').format(currentReservationState!.datetime)}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Nombre de convives: ${currentReservationState?.numberOfGuests}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info, size: 20),
                const SizedBox(width: 8),
                const Text('Statut: '),
                Chip(
                  label: Text(
                    '${currentReservationState?.statusToString()}',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: statusColor(currentReservationState!.status),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentReservationState?.specialRequests != null) ...[
              // faut rajouter les '...' pour inclure plusieurs widgets dans un if
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Demandes spéciales',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                currentReservationState?.specialRequests ?? '',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
