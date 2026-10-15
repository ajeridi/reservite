import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/available_slots_provider.dart';

// va contenir le creneau selectionne
final selectedSlotProvider = NotifierProvider.autoDispose<SelectedSlotNotifier, String?>(
  () => SelectedSlotNotifier(),
);

class SelectedSlotNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void setSelectedSlot(String? selected) {
    state = selected;
  }

  void clear() {
    state = null;
  }
}
