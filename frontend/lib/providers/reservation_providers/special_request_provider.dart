import 'package:flutter_riverpod/flutter_riverpod.dart';

final specialRequestProvider = NotifierProvider<SpecialRequestNotifier, String>(
  SpecialRequestNotifier.new,
);

class SpecialRequestNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void setSpecialRequest(String value) {
    state = value;
  }

  String? validate(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return null;
    }

    if (text.length < 10) {
      return 'La demande spéciale doit contenir au moins 10 caractères.';
    }
    return null;
  }

  void clear() {
    state = '';
  }
}
