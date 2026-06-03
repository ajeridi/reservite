import 'package:flutter_riverpod/flutter_riverpod.dart';

final numberOfGuestsProvider =
NotifierProvider<NumberOfGuestsNotifier, int>(
  NumberOfGuestsNotifier.new,
);

class NumberOfGuestsNotifier extends Notifier<int> {
  @override
  int build() {
    return 2;
  }

  void increment() {
    state++;
  }

  void decrement() {
    if (state > 1) {
      state--;
    }
  }

  void setNumberOfGuests(int value) {
    if (value >= 1) {
      state = value;
    }
  }
}