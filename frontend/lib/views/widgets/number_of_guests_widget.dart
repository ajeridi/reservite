import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/reservation_providers/number_of_guests_provider.dart';
import '../../providers/restaurant_providers/restaurant_capacity_provider.dart';

class NumberOfGuestsWidget extends ConsumerWidget {
  const NumberOfGuestsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numberOfGuests = ref.watch(numberOfGuestsProvider);
    final numberOfGuestsNotifier = ref.read(numberOfGuestsProvider.notifier);
    final restaurantCapacity = ref.watch(restaurantCapacityProvider);

    return ListTile(
      leading: const Icon(Icons.people),
      title: const Text('Nombre de convives'),
      subtitle: Text('$numberOfGuests'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: numberOfGuests > 1
                ? numberOfGuestsNotifier.decrement
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed:
            restaurantCapacity.when(
              data: (capacity) =>
                  numberOfGuests < capacity
                      ? numberOfGuestsNotifier.increment
                      : null,
              error: (err, _) => null,
              loading: () => null,
            ),
          ),
        ],
      ),
    );
  }
}