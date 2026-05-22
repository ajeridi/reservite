
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
* Etat qui va stocker l'id du restaurant selectionne, afin de recuperer l'id lors de la requete
* pour avoir les reservations d'un restaurant pour un manager
* */

final selectedRestaurantProvider =
    NotifierProvider<SelectedRestaurantNotifier, int>(
        () => SelectedRestaurantNotifier(),
    );

class SelectedRestaurantNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setValue(int selectedRestaurantId){
    state = selectedRestaurantId;
  }
}