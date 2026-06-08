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
import 'package:prbd_2526_a07/views/widgets/available_slots_widget.dart';
import 'package:prbd_2526_a07/views/widgets/date_time_picker_widget.dart';
import 'package:prbd_2526_a07/views/widgets/number_of_guests_widget.dart';
import 'package:prbd_2526_a07/views/widgets/reservation_slot_widget.dart';
import '../../models/reservation.dart';
import '../../providers/reservation_providers/capacity_check_provider.dart';
import '../../providers/reservation_providers/selected_slot_provider.dart';
import '../widgets/special_requests_widget.dart';
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
    final currentReservationState = ref.watch(currentReservationProvider(selectedReservationId));
    final currentReservationNotifier = ref.read(currentReservationProvider(selectedReservationId).notifier);

    final selectedReservationDateState = ref.watch(selectedReservationDateProvider);

    // on  va chercher les crenaux disponibles
    final selectedSlot = ref.watch(selectedSlotProvider);
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
            // retour a search_restaurant si c'est une nouvelle reservation
            if (selectedReservationId == 0)
              Navigator.pushReplacementNamed(context, '/search_restaurants_page');
            else // sinon on va vers le detail de la reservation
              Navigator.pushReplacementNamed(context, '/reservation_details_client_page');
          },
        ),
        title: Text('${selectedReservationId == 0 ? 'Nouvelle' : 'Modifier une'} réservation'),
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
                selectedReservationId == 0 ? // si nouvelle reservation, charger le nom du restaurant selectionnne, sinon charger le nom du restaurant de la reservation selectionnee
                currentRestaurantState.whenData((resto) =>
                    Text(resto.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                ).value! :
                currentReservationState.when(
                    data: (res) => Text(res!.restaurant!.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    error: (err, _) => Text("Error finding restaurant name"),
                    loading: () => CircularProgressIndicator()
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
                AvailableSlotsWidget(),
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
                SpecialRequestsWidget(),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed:
                  !specialRequestsNotifier.isValid() || selectedSlot == null
                      ? null
                      : () async {
                    // si le status de la reservation est confirmee, il faut afficher le popup qui va avertir du retour vers pending
                    if (selectedReservationId != 0 && currentReservationState.value!.status == Status.confirmed){
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog( // https://api.flutter.dev/flutter/material/AlertDialog-class.html
                            title: const Text('Modifier une réservation confirmée'),
                            content: const Text('Cette réservation est confirmée. La modifier la remettra en attente et les tables associées seront libérées. Souhaitez-vous continuer ?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await currentReservationNotifier.saveReservation(
                                      selectedDate: selectedReservationDateState.value!,
                                      selectedSlot: selectedSlot!,
                                      numberOfGuests: numberOfGuestsState,
                                      capacityCheck: capacityCheckState.value!,
                                      specialRequest: specialRequestsState.value);
                                  Navigator.pop(context, 'OK');
                                  Navigator.pushReplacementNamed(context, '/reservation_details_client_page');
                                },
                                child: const Text('Continuer', style: TextStyle(color: Colors.red),),
                              ),
                            ],
                          )
                      );
                    } else {
                      final savedReseravation = await currentReservationNotifier
                          .saveReservation(
                          selectedDate: selectedReservationDateState
                              .value!,
                          selectedSlot: selectedSlot!,
                          numberOfGuests: numberOfGuestsState,
                          capacityCheck: capacityCheckState.value!,
                          specialRequest: specialRequestsState.value);

                      selectedReservationId == 0
                          ? Navigator.pushReplacementNamed(context, '/home_client_page')
                          : Navigator.pushReplacementNamed(context, '/reservation_details_client_page');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text('${selectedReservationId == 0 ? "Créer" : "Modifier"} la réservation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

