
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedServiceProvider = NotifierProvider<SelectedServicesNotifier,Set<int>>(
    () => SelectedServicesNotifier(),
);

class SelectedServicesNotifier extends Notifier<Set<int>>{

  @override
  Set<int> build() {
    return {};
  }

  void toggle(int serviceId){
    if(state.contains(serviceId)){
      state = {...state}..remove(serviceId);
    }else{
      state =  {...state,serviceId};
    }
  }

  void clear(){
    state = {};
  }
}