import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_slot_provider.dart';

class ReservationSlotWidget extends ConsumerWidget {
  const ReservationSlotWidget({
    super.key,
    required this.theme,
    required this.slot,
  });

  final ThemeData theme;
  final String slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    //recherche du slot selectionne pour savoir si faut highlight ou pas
    final selectedSlotState = ref.watch(selectedSlotProvider);
    final selectedSlotNotifier = ref.read(selectedSlotProvider.notifier);
    final selected = selectedSlotState == slot;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        selectedSlotNotifier.setSelectedSlot(slot);
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            DateFormat('HH:mm', 'fr_FR',).format(DateTime.parse("00000000 $slot")),
            style: TextStyle(
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
