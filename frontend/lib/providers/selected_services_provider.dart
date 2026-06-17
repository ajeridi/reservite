import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedServiceIdProvider = NotifierProvider<SelectedServiceIdNotifier, int>(
      () => SelectedServiceIdNotifier(),
);

class SelectedServiceIdNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void set(int newId){
    state = newId;
  }

  void clear(){
    state = 0;
  }

}