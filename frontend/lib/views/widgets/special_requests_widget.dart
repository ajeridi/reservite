import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/special_request_provider.dart';

import '../../models/reservation.dart';


class SpecialRequestsWidget extends ConsumerStatefulWidget {
  const SpecialRequestsWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SpecialRequestsWidgetState();

}


class _SpecialRequestsWidgetState extends ConsumerState<SpecialRequestsWidget> {

  late final TextEditingController _specialRequestsController = TextEditingController(text: getInitialSpecialRequests());

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Demandes spéciales (optionnel)',
        border: OutlineInputBorder(),
        hintText: 'Allergies, préférences...',
      ),
      controller: _specialRequestsController,
      validator: Reservation.validateSpecialRequests,
      onChanged: (newSpecialRequests) => _setSpecialRequestsState(newSpecialRequests),
      maxLines: 3,
    );
  }


  String getInitialSpecialRequests() {
      final specialRequest = ref.watch(specialRequestProvider);
      return specialRequest;
  }

  void _setSpecialRequestsState(String newSpecialRequests){
    ref.read(specialRequestProvider.notifier).setSpecialRequest(newSpecialRequests);
  }
}
