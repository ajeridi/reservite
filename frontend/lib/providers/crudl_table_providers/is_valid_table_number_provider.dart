import 'package:flutter_riverpod/flutter_riverpod.dart';

final isValidTableNumberProvider = NotifierProvider<IsValidTableNumberNotifier, bool>(
    () => IsValidTableNumberNotifier()
);

class IsValidTableNumberNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setValidationStatus(bool newValidationStatus) {
    state = newValidationStatus;
  }

}