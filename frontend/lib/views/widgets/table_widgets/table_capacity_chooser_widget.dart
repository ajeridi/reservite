import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/crudl_table_providers/new_table_capacity_provider.dart';

class TableCapacityChooserWidget extends ConsumerWidget {
  const TableCapacityChooserWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final capacity = ref.watch(newTableCapacityProvider);
    final capacityNotifier = ref.read(newTableCapacityProvider.notifier);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed:
              capacity > capacityNotifier.getMinimumCapacity()
                  ? () => capacityNotifier.decrement()
                  : null,
          tooltip: capacityNotifier.reasonOfNotDecrementing(),
        ),
        Text(
          ' ${capacity} personnes',
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            capacityNotifier.increment();
          },
        ),
      ],
    );
  }
}

