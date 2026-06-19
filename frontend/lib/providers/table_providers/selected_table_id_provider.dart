import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTableIdProvider = NotifierProvider<SelectedTableIdNotifier, int>(
    () => SelectedTableIdNotifier(),
);

class SelectedTableIdNotifier extends Notifier<int> {
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