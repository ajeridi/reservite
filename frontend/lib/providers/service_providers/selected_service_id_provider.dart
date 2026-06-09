
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedServiceIdProvider = NotifierProvider<SelectedServiceIdNotifier, int>(
        () => SelectedServiceIdNotifier());

class SelectedServiceIdNotifier extends Notifier<int>{


  @override
  int build() =>0;

  void setId(int id){
    state = id;
  }
}