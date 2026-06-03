import 'package:flutter_riverpod/flutter_riverpod.dart';

// va contenir le creneau selectionne
final selectedSlotProvider = NotifierProvider<SelectedSlotNotifier, String?>(
  () => SelectedSlotNotifier(),
);

class SelectedSlotNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void setSelectedSlot(String selected) {
    state = selected;
  }

  void clear() {
    state = null;
  }
}
