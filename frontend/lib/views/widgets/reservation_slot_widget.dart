import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReservationSlotWidget extends StatelessWidget {
  const ReservationSlotWidget({
    super.key,
    required this.theme,
    required this.slot,
  });

  final ThemeData theme;
  final String slot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          slot,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
