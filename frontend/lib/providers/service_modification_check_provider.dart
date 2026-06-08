import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/edit_service_form_provider.dart';
import 'package:prbd_2526_a07/providers/selected_services_provider.dart';

import '../models/services.dart';

/*
* Provider derive qui calcule, a chaque modification du formulaire, le nombre de
* reservations confirmees ou en attente qui se retrouveraient en dehors des
* nouvelles heures du service. Si ce nombre est > 0, la modification est interdite.
*
* Meme principe que capacity_check_provider pour le formulaire de reservation.
* */

final serviceModificationCheckProvider = AsyncNotifierProvider.autoDispose<
    ServiceModificationCheckNotifier, int>(
  ServiceModificationCheckNotifier.new,
);

class ServiceModificationCheckNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final selectedServiceId = ref.read(selectedServiceProvider);
    final form = ref.watch(editServiceFormProvider);

    // pas de verification en creation (id 0) ni tant que le formulaire est incomplet
    if (selectedServiceId == 0 || !form.isComplete) {
      return 0;
    }

    final count = await Services.countReservationsOutside(
      serviceId: selectedServiceId,
      dayOfWeek: form.dayOfWeek!,
      startTime: form.startTime,
      endTime: form.endTime,
    );

    return count ?? 0;
  }
}
