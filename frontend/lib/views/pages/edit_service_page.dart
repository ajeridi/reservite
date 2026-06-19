import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';
import 'package:prbd_2526_a07/models/service.dart';
import 'package:prbd_2526_a07/providers/crudl_service_providers/current_service_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/current_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/selected_services_provider.dart';

import '../../providers/application_time_provider.dart';
import '../widgets/data_error_widget.dart';


/*
Faire passer l'argument dans un pushNamed
https://stackoverflow.com/questions/53304340/navigator-pass-arguments-with-pushnamed
 */
void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const EditServicePage(),
    ),
  );
}

class EditServicePage extends ConsumerWidget {
  const EditServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final simulatedTime = ref
        .watch(applicationTimeProvider)
        .value;

    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    final selectedServiceId = arguments['serviceId'];

    final serviceState = ref.watch(currentServiceProvider(selectedServiceId));
    final serviceStateNotifier = ref.watch(currentServiceProvider(selectedServiceId).notifier);

    final selectedIdRestaurant = ref.read(selectedRestaurantProvider);
    final currentRestaurant = ref.watch(currentRestaurantProvider(selectedIdRestaurant));

    return serviceState.when(
      data: (state) => data(
              context,
              ref,
              theme,
              simulatedTime,
              state,
              serviceStateNotifier,
              selectedIdRestaurant,
              currentRestaurant
          ),
      error: (err, _) =>
          DataErrorWidget(
            error: err,
            stackTrace: StackTrace.current,
            notifier: serviceStateNotifier,
          ),
      loading: () => loading(),
    );
  }

  Widget data(
      BuildContext context,
      WidgetRef ref,
      ThemeData theme,
      DateTime? simulatedTime,
      Service? state,
      CurrentServiceNotifier serviceStateNotifier,
      int selectedIdRestaurant,
      AsyncValue<Restaurant> currentRestaurant,
      ) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop((context));
          },
        ),
        title: const Text('Modifier le service'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Enregistrer',
            onPressed: () {},
            icon: const Icon(Icons.save),
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
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                      .format(simulatedTime!),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: serviceStateNotifier.getDays(state!.dayOfWeek) ,
                  decoration: const InputDecoration(
                    labelText: 'Jour',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Lundi', child: Text('Lundi')),
                    DropdownMenuItem(value: 'Mardi', child: Text('Mardi')),
                    DropdownMenuItem(value: 'Mercredi', child: Text('Mercredi')),
                    DropdownMenuItem(value: 'Jeudi', child: Text('Jeudi')),
                    DropdownMenuItem(value: 'Vendredi', child: Text('Vendredi')),
                    DropdownMenuItem(value: 'Samedi', child: Text('Samedi')),
                    DropdownMenuItem(value: 'Dimanche', child: Text('Dimanche')),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: state.startTime.hour,
                        decoration: const InputDecoration(
                          labelText: 'Heure de début (heure)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 24; h++)
                            DropdownMenuItem<int?>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} h'),
                            ),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: state.startTime.minute,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<int?>(value: 0, child: const Text('00 min')),
                          if (currentRestaurant.value!.slotDuration == 15)
                          DropdownMenuItem<int?>(value: 15, child: const Text('15 min')),
                          DropdownMenuItem<int?>(value: 30, child: const Text('30 min')),
                          if (currentRestaurant.value!.slotDuration == 15)
                          DropdownMenuItem<int?>(value: 45, child: const Text('45 min')),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: state.endTime.hour,
                        decoration: const InputDecoration(
                          labelText: 'Heure de fin (heure)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 24; h++)
                            DropdownMenuItem<int?>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} h'),
                            ),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: state.endTime.minute,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<int?>(value: 0, child: const Text('00 min')),
                          if (currentRestaurant.value!.slotDuration == 15)
                            DropdownMenuItem<int?>(value: 15, child: const Text('15 min')),
                          DropdownMenuItem<int?>(value: 30, child: const Text('30 min')),
                          if (currentRestaurant.value!.slotDuration == 15)
                            DropdownMenuItem<int?>(value: 45, child: const Text('45 min')),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget loading() {
  return Center(child: CircularProgressIndicator(color: Colors.black));
}