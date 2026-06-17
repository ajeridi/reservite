import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/current_table_provider.dart';
import 'package:prbd_2526_a07/providers/selected_table_id_provider.dart';

final isValidTableNumberProvider = NotifierProvider<IsValidTableNumberNotifier, bool>(
    () => IsValidTableNumberNotifier()
);

class IsValidTableNumberNotifier extends Notifier<bool> {
  @override
  bool build() {
    // on regarde si une table existe, dans ce cas la c'est initialise a vrai par defaut car la table a son propre numero
    final selectedTableId = ref.watch(selectedTableIdProvider);
    // si c'est 0, nouvelle table donc pas de numero et donc pas de numero valide par defaut -> false
    // si c'est pas 0, c'est que la nouvelle table existe et donc numero valide par defaut -> true
    return selectedTableId != 0;
  }

  void setValidationStatus(bool newValidationStatus) {
    state = newValidationStatus;
  }

}