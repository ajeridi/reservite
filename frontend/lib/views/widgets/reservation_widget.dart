import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/reservations_provider.dart';

import '../../models/reservation.dart';

class ReservationCard extends StatelessWidget {

  final Reservation reservation;

  const ReservationCard({
    super.key,
    required this.reservation,
  });



  @override
  Widget build(BuildContext context) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.restaurant, size: 40),
          title: Text(
              reservation.restaurant.name,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(reservation.restaurant.city),
                  const SizedBox(width: 12),
                  const SizedBox(width: 2),
                  const SizedBox(width: 12),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat('EE dd/MM/yyyy HH:mm', 'fr_FR')
                        .format(reservation.datetime)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 5,),
                  Icon(Icons.group, size: 14, color: Colors.black),
                  SizedBox(width: 4),
                  Text(
                    '${reservation.numberOfGuests} convives.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      );
    }
}
