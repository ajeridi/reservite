import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/models/reservation.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/review_providers/new_rating_provider.dart';
import 'package:prbd_2526_a07/views/widgets/data_error_widget.dart';
import 'package:prbd_2526_a07/views/widgets/reviews/star_selection_widget.dart';

import '../../providers/review_providers/new_comment_provider.dart';
import '../widgets/reviews/review_comment_widget.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ReservationReviewPage(),
    ),
  );
}

class ReservationReviewPage extends ConsumerWidget {
  const ReservationReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final simulatedTime = ref.watch(applicationTimeProvider);

    final selectedReservationId = ref.watch(selectedReservationIdProvider);
    final currentReservation = ref.watch(currentReservationProvider(selectedReservationId));
    final currentReservationNotifier = ref.read(currentReservationProvider(selectedReservationId).notifier);

    return currentReservation.when(
        data: (reservation) => data(context, theme, simulatedTime, reservation, ref),
        error: (err, st) => DataErrorWidget(error: err, notifier: currentReservationNotifier),
        loading: () => Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
            ],
          ),
        )
    );


  }

  Scaffold data(BuildContext context, ThemeData theme, AsyncValue<DateTime> simulatedTime, Reservation? reservation, WidgetRef ref) {
    return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          //ref.read(newRatingProvider.notifier).clear();
          ref.read(newCommentProvider.notifier).clear();
          Navigator.pushReplacementNamed(context, '/reservation_details_client_page');
        },
      ),
      title: Text('${reservation!.review != null ? 'Modifier' : 'Ajouter'} un avis'),
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
              message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
              child: Text(
                DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(simulatedTime.value!),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // --- Infos de la réservation ---
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                      children: [
                        Icon(Icons.restaurant, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '${reservation!.restaurant!.name}',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 8),
                        Text('${reservation!.restaurant!.city}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE dd/MM/yyyy', 'fr_FR').format(reservation!.datetime),
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 8),
                        Text('${reservation!.numberOfGuests} convives', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // -----------------------------------------------
            // CAS 1 — Réservation terminée, pas encore d'avis
            // -----------------------------------------------
            //_sectionTitle('Cas 1 — Laisser un avis'),
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //const Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
                    StarSelectionWidget(),
                    const SizedBox(height: 8),
                    const SizedBox(height: 12),
                    ReviewCommentWidget(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.send),
                            label: const Text('Publier mon avis'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  // helper pour les titres de section
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
