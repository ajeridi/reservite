import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

import '../../providers/reservation_providers/special_request_provider.dart';

class EditReservationDescription extends ConsumerStatefulWidget {
  final SpecialRequestNotifier specialRequestsNotifier;

  const EditReservationDescription({
    super.key,
    required this.specialRequestsNotifier,
  });

  @override
  ConsumerState<EditReservationDescription> createState() =>
      _EditReservationDescriptionState();
}

class _EditReservationDescriptionState extends ConsumerState<EditReservationDescription> {
  late final editingController = TextEditingController(text: _getSpecialRequest());

  @override
  Widget build(BuildContext context) {
    final specialRequestsNotifier = ref.read(specialRequestProvider.notifier);
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Demandes spéciales (optionnel)',
        border: OutlineInputBorder(),
        hintText: 'Allergies, préférences...',
      ),
      validator: specialRequestsNotifier.validate,
      controller: editingController,
      onChanged: specialRequestsNotifier.setSpecialRequest,
      maxLines: 3,
    );
  }

  String? _getSpecialRequest() {
    final selectedReservation = ref.read(selectedReservationIdProvider);
    final currentReservation = ref.watch(currentReservationProvider(selectedReservation));

    return currentReservation.value?.specialRequests;
  }

}