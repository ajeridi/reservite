import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/user_role_provider.dart';

import '../../models/reservation.dart';
import '../../providers/reservation_providers/current_reservation_provider.dart';

class ReservationCard extends ConsumerWidget {

  final Reservation reservation;



  const ReservationCard({
    super.key,
    required this.reservation,
  });

  Icon getStatusIcon(Status status) {
    return switch(status){
      Status.pending => Icon(Icons.pending, color: Colors.orange, size: 32),
      Status.completed  =>
          Icon(Icons.event_available, color: Colors.blue, size: 32),
      Status.confirmed =>
          Icon(Icons.check_circle, color: Colors.green, size: 32),
      Status.cancelled => Icon(Icons.cancel, color: Colors.red, size: 32),
      _ => throw Exception('incorrect status'),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // on a besoin du notifier qui va stocker l'id de la reservation selectionee
    final selectedReservationIdNotifier = ref.read(selectedReservationIdProvider.notifier);
    // on doit voir le notifier de l'utilisateur connecte, pour connaitre son role et rediriger vers la bonne page de details
    final userRole = ref.watch(userRoleProvider).value;
    return
      Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: () async {
            // on definit l'id de la reservation selectionee
            selectedReservationIdNotifier.set(reservation.id);
            ref.invalidate(currentReservationProvider(reservation.id));
            // navigation vers la page de details de la reservation (differente en fonction du role)
            if (userRole == 'client')
              Navigator.pushReplacementNamed(context, '/reservation_details_client_page');
            if (userRole == 'manager')
              Navigator.pushNamed(context, '/reservation_details_manager_page');
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Tooltip(
                  message: '${reservation.statusToString()}',
                  child: getStatusIcon(reservation.status),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (userRole == 'client'? reservation.restaurant!.name : reservation.client.name), // nous savons que le client_name ne sera jamais null donc on se permet de mettre de !
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            (userRole == 'client' ? reservation.restaurant!.city! : reservation.restaurant!.name),
                            style: TextStyle(fontSize: 12, color: Colors
                                .grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormat('EE dd/MM/yyyy HH:mm', 'fr_FR')
                                .format(reservation.datetime)}',
                            style: TextStyle(fontSize: 14, color: Colors
                                .grey[600]),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.people, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${reservation.numberOfGuests} convives',
                            style: TextStyle(fontSize: 14, color: Colors
                                .grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      );
  }
}
