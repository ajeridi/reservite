import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../providers/current_reservation_provider.dart';

class btnaAnulationWidget extends StatelessWidget {
  const btnaAnulationWidget({
    super.key,
    required this.currentReservationNotifier,
  });
  final CurrentReservationNotifier currentReservationNotifier;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () => {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Expanded(
                child: AlertDialog(
                  title: Text('Annuler la réservation'),
                  content: Text('Êtes-vous sûr de vouloir annuler cette réservation?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Non'),
                    ),
                    TextButton(
                      onPressed: () {
                        currentReservationNotifier.cancel();
                        Navigator.of(context).pop();
                      },
                      child: Text('Oui',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          )
          //currentReservationNotifier.cancel();
        },
        icon: const Icon(Icons.cancel),
        label: const Text('Annuler'),
      ),
    );
  }
}
