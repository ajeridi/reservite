import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservations_provider.dart';
import 'package:prbd_2526_a07/providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/views/widgets/data_error_widget.dart';
import 'package:prbd_2526_a07/views/widgets/reservation_details_widget.dart';

import '../../models/reservation.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ReservationDetailsManagerPage(),
    ),
  );
}

String updateStatusMessage(Status status) {
  return switch (status) {
    Status.pending => "Confirmer et assigner les tables",
    Status.confirmed => "Marquer comme terminée",
    Status.completed => "",
    Status.cancelled => "",
  };
}

IconData updateStatusIcon(Status status) {
  return switch (status) {
    Status.pending => Icons.table_restaurant,
    Status.confirmed => Icons.check_circle,
    Status.completed => Icons.cancel,
    Status.cancelled => Icons.cancel,
  };
}

class ReservationDetailsManagerPage extends ConsumerWidget {
  const ReservationDetailsManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);



    // observation de la liste des reservations car currentReservation vient de la
    final selectedReservationId = ref.watch(selectedReservationIdProvider);
    final currentReservation = ref.watch(currentReservationProvider(selectedReservationId));
    final currentReservationNotifier = ref.read(
      currentReservationProvider(selectedReservationId).notifier,
    );

    //observation du provider de la application_time
    final applicationTime = ref.watch(applicationTimeProvider);

    return currentReservation.when
      (data: (reservation) =>applicationTime.when(
        data: (simulatedTime) => 
          data(context, 
              currentReservationNotifier, 
              theme, 
              simulatedTime, 
              reservation),
        error: (e, _) => DataErrorWidget(error: e,
                                          notifier: currentReservationNotifier),
        loading: () => Center(child: CircularProgressIndicator()),
    ),
      error: (e, _) =>DataErrorWidget(error: e, notifier: currentReservationNotifier),
      loading: () => const Center(child: CircularProgressIndicator(),));
  }

  Scaffold data(
      BuildContext context, 
      CurrentReservationNotifier currentReservationNotifier, 
      ThemeData theme, 
      DateTime simulatedTime, 
      Reservation? currentReservation) {
    //pour tests
    //final simulatedTimeTest = DateTime(2024, 10, 4, 16, 0);
   // final canTerminate = currentReservation?.status == Status.confirmed &&
     //   !simulatedTimeTest.isBefore(currentReservation!.datetime);

    // terminer si la date appTime est >= à la date de reservation
    final canTerminate = currentReservation?.status == Status.confirmed &&
       !simulatedTime.isAfter(currentReservation!.datetime);


    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // redirection vers la page des reservations pour le manager
            Navigator.pushReplacementNamed(
              context,
              '/manager_reservations_page',
            );
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations client',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person, size: 20),
                          SizedBox(width: 8),
                          Text('Nom: ${currentReservation?.client!.name}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, size: 20),
                          SizedBox(width: 8),
                          Text('Email: ${currentReservation?.client.email}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Téléphone: ${currentReservation?.client.phone == '' ? 'Non renseigné' : currentReservation?.client.phone}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ReservationDetailsWidget(
                currentReservationState: currentReservation,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tables assignées',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (currentReservation?.tables.length == 0)
                Text('Aucune table assignee ${currentReservation!.status == Status.cancelled ? '' : '(en attente de confirmation)'}')
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var table in currentReservation!.tables)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.table_restaurant, size: 20),
                                const SizedBox(width: 8),
                                Text('Table ${table.tableNumber}'),
                                const SizedBox(width: 16),
                                Text(
                                  '(${table.capacity} places)',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              if (currentReservation!.status != Status.completed &&
                  currentReservation!.status != Status.cancelled) ...[
                ElevatedButton.icon(
                  onPressed: canTerminate ? () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Expanded(
                          child: AlertDialog(
                            title: Text('Terminer la réservation'),
                            content: Text('Voulez-vous marquer cette résservation commme terminée?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Non'),
                              ),
                              TextButton(
                                onPressed: () {
                                  currentReservationNotifier.complete();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Oui',
                                style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } : null, //null = btn disabled
                  icon: Icon(updateStatusIcon(currentReservation!.status)),
                  label: Text(updateStatusMessage(currentReservation!.status)),
                ),
                // message d'advertisement si la reservation ne peut pas être terminée a cause de l'appliTime
                if(!canTerminate)
                  const Padding(padding: EdgeInsets.only(top: 4.0),
                  child: Text('La réservation ne peut pas être terminée que durant son service ou après celui-ci',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),),),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Expanded(
                          child: AlertDialog(
                            title: Text('Annuler la réservation'),
                            content: Text('Êtes-vous sûr de vouloir annuler cette réservation?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Non'),
                              ),
                              TextButton(
                                onPressed: () {
                                  currentReservationNotifier.cancel();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Oui',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Annuler'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
