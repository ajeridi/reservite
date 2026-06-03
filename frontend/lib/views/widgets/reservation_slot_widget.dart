import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_slot_provider.dart';

class ReservationSlotWidget extends StatelessWidget {
  const ReservationSlotWidget({
    super.key,
    required this.theme,
    required this.slot,
    required this.selectedSlotNotifier,
    this.selected = false,
  });

  final ThemeData theme;
  final String slot;
  final bool selected;
  final SelectedSlotNotifier selectedSlotNotifier;

  @override
  Widget build(BuildContext context) {
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
            slot,
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
