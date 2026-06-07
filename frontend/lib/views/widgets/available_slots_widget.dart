import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/available_slots_provider.dart';
import 'package:prbd_2526_a07/views/widgets/reservation_slot_widget.dart';
import 'package:prbd_2526_a07/views/widgets/warning_widget.dart';

import '../../models/available_slots.dart';

class AvailableSlotsWidget extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final availableSlotsState = ref.watch(availableSlotsProvider);

    return availableSlotsState.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Text('Erreur: $error'),
        data: (availableSlots) {
          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: showSlots(
              availableSlots,
              theme,
            ),
          );
        },
      );
  }

  List<Widget> showSlots(
      AvailableSlots availableSlots,
      ThemeData theme,
      ) {
    final slotsWidgets = <Widget>[];
    final slots = availableSlots.slots ?? [];

    if (slots.isEmpty && availableSlots.error != null) {
      return [WarningWidget(error: availableSlots.error!)];
    }

    for (var slot in availableSlots.slots!) {
      slotsWidgets.add(ReservationSlotWidget(theme: theme, slot: slot));
    }
    return slotsWidgets;
  }
}