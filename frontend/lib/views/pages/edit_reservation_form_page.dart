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
import '../widgets/available_slots_widget.dart';
import '../widgets/edit_reservation_description.dart';
import '../widgets/warning_widget.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const EditReservationFormPage(),
    ),
  );
}

class EditReservationFormPage extends ConsumerWidget {
  const EditReservationFormPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final simulatedTime = ref
        .watch(applicationTimeProvider)
        .value;

    // on a besoin du restaurant dans lequel on effectue la reservation
    final selectedRestaurantId = ref.read(selectedRestaurantProvider);
    final currentRestaurantState = ref.watch(
        currentRestaurantProvider(selectedRestaurantId));

    // on va chercher la reservation courante (donc si elle est nouvelle elle aura un id de 0)
    final selectedReservationId = ref.read(selectedReservationIdProvider);
    final currentReservationState = ref.watch(
        currentReservationProvider(selectedReservationId));
    final currentReservationNotifier = ref.read(
        currentReservationProvider(selectedReservationId).notifier);

    final selectedReservationDateState = ref.watch(
        selectedReservationDateProvider);

    // on  va chercher les crenaux disponibles
    final availableSlotsState = ref.watch(availableSlotsProvider);
    final selectedSlot = ref.watch(selectedSlotProvider);
    final selectedSlotNotifier = ref.read(selectedSlotProvider.notifier);
    //on regarde l'etat de la validation de la capacite
    final numberOfGuestsState = ref.watch(numberOfGuestsProvider);
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
            Navigator.pushReplacementNamed(
                context, '/reservation_details_client_page');
          },
        ),
        title: const Text('Modifier une réservation'),
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
                currentReservationState.whenData((e) =>
                    Text(
                      e!.restaurant!.name,
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    )).value!,
                const SizedBox(height: 24),
                DatePickerReservation(),
                const Divider(),
                const SizedBox(height: 24),
                const Text(
                  'Créneaux disponibles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                AvailableSlotsWidget(),
                const SizedBox(height: 24),
                const NumberOfGuestsWidget(),
                capacityCheckState.when(
                  loading: () => const SizedBox.shrink(),
                  // pour enlever l'espace pris
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
                EditReservationDescription(specialRequestsNotifier: specialRequestsNotifier),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    final savedReseravation = await currentReservationNotifier
                        .saveReservation(
                        selectedDate: selectedReservationDateState.value!,
                        selectedSlot: selectedSlot!,
                        numberOfGuests: numberOfGuestsState,
                        capacityCheck: capacityCheckState.value!,
                        specialRequest: specialRequestsState);
                    Navigator.pushReplacementNamed(
                        context, '/home_client_page');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier la réservation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}