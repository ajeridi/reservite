import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/models/reservation.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/views/widgets/data_error_widget.dart';

import '../../core/tools/pick_date_time.dart';
import '../../providers/application_time_provider.dart';
import '../../providers/reservation_providers/current_reservation_provider.dart';
import '../../providers/reservation_providers/selected_reservation_id_provider.dart';
import '../widgets/btn_annulation_widget.dart';
import '../widgets/reservation_details_widget.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ReservationDetailsClientPage(),
    ),
  );
}

class ReservationDetailsClientPage extends ConsumerWidget {
  const ReservationDetailsClientPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final applicationTime = ref.watch(applicationTimeProvider);

    // on a besoin d'aller chercher la reservation selectionnee
    final selectedReservationIdState = ref.watch(selectedReservationIdProvider);
    final currentReservationState = ref.watch(
      currentReservationProvider(selectedReservationIdState),
    ); // utilisation  de value pour extraire la Reservation de <AsyncValue<Reservation>>
    final currentReservationNotifier = ref.read(
      currentReservationProvider(selectedReservationIdState).notifier,
    );

    return currentReservationState.when(
      data: (reservation) => applicationTime.when(                    // ✅
        data: (simulatedTime) => data(context,ref, reservation, currentReservationNotifier, theme, simulatedTime),
        error: (e, _) => DataErrorWidget(error: e, notifier: currentReservationNotifier),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => DataErrorWidget(error: e, notifier: currentReservationNotifier, stackTrace: StackTrace.current),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold data(
      BuildContext context,
      WidgetRef ref,
      Reservation? reservation,
      CurrentReservationNotifier currentReservationNotifier,
      ThemeData theme,
      DateTime simulatedTime,
      ) {
    return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // nettoyage des providers lorsqu'on quitte la page (+ d'infos sur le invalidate https://riverpod.dev/docs/concepts2/refs#resetting-a-providers-state)
          ref.invalidate(currentReservationProvider);
          ref.invalidate(selectedReservationIdProvider);
          Navigator.pushReplacementNamed(context, '/home_client_page');
        },
      ),
      title: const Text('Détails de la réservation'),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Rafraîchir les données',
          onPressed: () {
            currentReservationNotifier.refresh();
          },
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
            //GestureDetector pour detecter la touche
            child : GestureDetector(
              onTap: () async{
                final newDatetime = await pickDateTime(
                  context,
                  initialDate: simulatedTime,
                );
                if(newDatetime != null){
                  //on met à jour le provider avec la nouvelle date
                  ref.read(applicationTimeProvider.notifier).setTime(newDatetime);
                }
              },
            child: Tooltip(
              message:
                  'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
              child: Text(
                DateFormat(
                  'EEEE dd/MM/yyyy HH:mm',
                  'fr_FR',
                ).format(simulatedTime),
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
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReservationDetailsWidget(
              currentReservationState: reservation,
            ),
            const SizedBox(height: 24),
            if (reservation != null && reservation.canEdit())
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                        reservation.datetime.isBefore(simulatedTime)
                            ? null
                            : () {
                        Navigator.pushReplacementNamed(context, '/reservation_form_page');
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),

                    ),
                  ),
                  const SizedBox(width: 8),
                  btnaAnulationWidget(currentReservationNotifier : currentReservationNotifier),
                ],
              ),
            const SizedBox(height: 10,),
            if (reservation != null && reservation!.status == Status.completed)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/reservation_review_page');
                        },
                        icon: const Icon(Icons.reviews),
                        label: Text('${reservation!.review != null ? 'Modifier votre avis' : 'Ajouter un avis'}')
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
  }
}

