import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/models/available_slots.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/available_slots_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/current_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/number_of_guests_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_date_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/special_request_provider.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/views/widgets/date_time_picker_widget.dart';
import 'package:prbd_2526_a07/views/widgets/number_of_guests_widget.dart';
import 'package:prbd_2526_a07/views/widgets/reservation_slot_widget.dart';
import '../../providers/reservation_providers/capacity_check_provider.dart';
import '../../providers/reservation_providers/selected_slot_provider.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ReservationFormPage(),
    ),
  );
}

class ReservationFormPage extends ConsumerWidget {
  const ReservationFormPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final simulatedTime = ref.watch(applicationTimeProvider).value;

    // on a besoin du restaurant dans lequel on effectue la reservation
    final selectedRestaurantId = ref.read(selectedRestaurantProvider);
    final currentRestaurantState = ref.watch(
      currentRestaurantProvider(selectedRestaurantId),
    );

    // on va chercher la reservation courante (donc si elle est nouvelle elle aura un id de 0)
    final selectedReservationId = ref.watch(selectedReservationIdProvider);
    final currentReservationState = ref.watch(
      currentReservationProvider(selectedReservationId),
    );
    final currentReservationNotifier = ref.read(currentReservationProvider(selectedReservationId).notifier);

    final selectedReservationDateState = ref.watch(selectedReservationDateProvider);

    // on  va chercher les crenaux disponibles
    final availableSlotsState = ref.watch(availableSlotsProvider);
    final selectedSlot = ref.watch(selectedSlotProvider);
    final selectedSlotNotifier = ref.read(selectedSlotProvider.notifier);
    //on regarde l'etat de la validation de la capacite
    final  numberOfGuestsState = ref.watch(numberOfGuestsProvider);
    final capacityCheckState = ref.watch(capacityCheckProvider);
    //notifier du special_request pour les validations
    final specialRequestsNotifier = ref.watch(specialRequestProvider.notifier);
    final specialRequestsState = ref.watch(specialRequestProvider);



    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // retour a search_restaurant
            Navigator.pushReplacementNamed(context, '/search_restaurants_page');
          },
        ),
        title: const Text('Nouvelle réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {},
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message:
                    'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat(
                    'EEEE dd/MM/yyyy HH:mm',
                    'fr_FR',
                  ).format(simulatedTime!),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  currentRestaurantState.value!.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                DatePickerReservation(),
                const Divider(),
                const SizedBox(height: 24),
                const Text(
                  'Créneaux disponibles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                availableSlotsState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Erreur: $error'),
                  data: (availableSlots) {
                    return Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: showSlots(availableSlots,
                      theme,
                      selectedSlot,
                      selectedSlotNotifier, ),
                    );
                  },
                ),
                const SizedBox(height: 24),
               const NumberOfGuestsWidget(),
                capacityCheckState.when(
                  loading: () => const SizedBox.shrink(), // pour enlever l'espace pris
                  error: (error, stack) => Text('Erreur capacité: $error'),
                  data: (hasEnoughCapacity) {
                    if (hasEnoughCapacity) {
                      return const SizedBox.shrink();
                    }
                    return const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: WarningWidget(
                        error:
                        'La capacité du restaurant pour ce créneau pourrait être insuffisante pour le nombre de convives demandé.',
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Demandes spéciales (optionnel)',
                    border: OutlineInputBorder(),
                    hintText: 'Allergies, préférences...',
                  ),
                  validator: specialRequestsNotifier.validate,
                  onChanged: specialRequestsNotifier.setSpecialRequest,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    final savedReseravation = await currentReservationNotifier.saveReservation(
                        selectedDate: selectedReservationDateState.value!,
                        selectedSlot: selectedSlot!,
                        numberOfGuests: numberOfGuestsState,
                        capacityCheck: capacityCheckState.value!,
                        specialRequest: specialRequestsState);
                    Navigator.pushReplacementNamed(context, '/home_client_page');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Créer la réservation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> showSlots(
      AvailableSlots availableSlots,
      ThemeData theme,
      String? selectedSlot,
      SelectedSlotNotifier selectedSlotNotifier,) {
    final slotsWidgets = <Widget>[];
    final slots = availableSlots.slots ?? [];

    if (slots.isEmpty && availableSlots.error != null) {
      return [WarningWidget(error: availableSlots.error!)];
    }

    for (var slot in availableSlots.slots!) {
      slotsWidgets.add(ReservationSlotWidget(theme: theme, slot: slot, selected: selectedSlot == slot, selectedSlotNotifier: selectedSlotNotifier, ));
    }

    return slotsWidgets;
  }
}

class WarningWidget extends StatelessWidget {
  const WarningWidget({super.key, required this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error!,
              style: TextStyle(color: Colors.orange, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
