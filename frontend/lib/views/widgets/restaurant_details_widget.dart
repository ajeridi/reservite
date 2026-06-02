import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/models/services.dart';
import 'package:prbd_2526_a07/providers/restaurants_provider.dart';
import 'package:prbd_2526_a07/providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';

import '../../providers/current_restaurant_provider.dart';
import 'data_error_widget.dart';

class RestaurantDetailsWidget extends ConsumerWidget {
  const RestaurantDetailsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final resto = ref.watch(currentRestaurantProvider(ref.read(selectedRestaurantProvider)));
    // id de la reservation selectionnee (a set a 0 si on redirige vers la page de reservation)
    final selectedReservationIdState = ref.watch(selectedReservationIdProvider); // on en a besoin pour build le notifier, et pouvoir set le state
    final selectedReservationIdNotifier = ref.read(selectedReservationIdProvider.notifier);

    return resto.when(
      data: 
      (restaurant) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resto.value!.name,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 4),
            Text(4.5.toStringAsFixed(1)),
            const SizedBox(width: 16),
            Text(resto.value!.getPriceRange()),
            const SizedBox(width: 16),
            const Icon(Icons.location_on, size: 16),
            const SizedBox(width: 4),
            Text(resto.value!.city!),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.place, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                resto.value!.address,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(resto.value!.description ?? ''),
        const SizedBox(height: 24),
        const Text(
          'Horaires',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            'Lundi',
                            style:
                            TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            getServiceOfDay(1, resto.value!.services),
                            style: const TextStyle(
                                fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            'Mardi',
                            style:
                            TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            getServiceOfDay(2, resto.value!.services),
                            style: const TextStyle(
                                fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            'Mercredi',
                            style:
                            TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            getServiceOfDay(3, resto.value!.services),
                            style: const TextStyle(
                                fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            'Jeudi',
                            style:
                            TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            getServiceOfDay(4, resto.value!.services),
                            style: const TextStyle(
                                fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            'Vendredi',
                            style:
                            TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            getServiceOfDay(5, resto.value!.services),
                            style: const TextStyle(
                                fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            'Samedi',
                            style:
                            TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            getServiceOfDay(6, resto.value!.services),
                            style: const TextStyle(
                                fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            'Dimanche',
                            style:
                            TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            getServiceOfDay(7, resto.value!.services),
                            style: const TextStyle(
                                fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // comme c'est la creation d'une nouvelle reservation, il faut set le selected_reservation_id a 0
              selectedReservationIdNotifier.set(0);
              // redirection vers la page de creation/edition d'une reservation
              Navigator.pushReplacementNamed(context, '/reservation_form_page');
            },
            icon: const Icon(Icons.add),
            label: const Text('Réserver'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    ),loading:() => Center(child: CircularProgressIndicator()),
      error: (err, _) =>
          DataErrorWidget(
            error: err,
            stackTrace: StackTrace.current,
            notifier: ref.read(restaurantProvider.notifier),
          )
    );
    
  }
}

String getServiceOfDay (int dayOfWeek, SplayTreeSet<Services>? services){
  String times ='';
  if(services != null) {
    for (var service in services) {
      if (service.dayOfWeek == dayOfWeek) {
        times += '${DateFormat('HH:mm', 'fr_FR').format(service.startTime)}' + ' - ' + '${DateFormat('HH:mm', 'fr_FR').format(service.endTime)}'+
                "\n";
      }
    }
  }
  return times;
}
