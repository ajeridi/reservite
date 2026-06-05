import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/user_role_provider.dart';

class RestaurantCard extends ConsumerWidget {
  final Restaurant restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // recherche du notifier de la reservation selectionnee pour pouvoir la mettre a jour quand on clique sur une carte de restaurant
    final selectedRestaurantNotifier = ref.read(
      selectedRestaurantProvider.notifier,
    );

    final userRole = ref.watch(userRoleProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.restaurant, size: 40),
        title: Text(restaurant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(restaurant.city ?? ''),
                const SizedBox(width: 12),
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  '${restaurant.rating}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Text(
                  restaurant.getPriceRange(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  if (restaurant.date != null)
                    Text(
                      'Dernière réservation: ${restaurant.getLastDate()}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              if (restaurant.reservPending != 0 &&
                  restaurant.reservPending != null)
                Row(
                  children: [
                    Icon(Icons.pending, size: 14, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      '${restaurant.reservPending} demandes en attente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          selectedRestaurantNotifier.setValue(restaurant.id);
          Navigator.pushReplacementNamed(
            context,
            (userRole.value == 'manager'
                ? '/manager_reservations_page'
                : '/restaurant_details_page'),
          );
        },
      ),
    );
  }
}
