import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/core/tools/datetime_utils.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';
import 'package:prbd_2526_a07/models/service.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/current_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/views/widgets/data_error_widget.dart';

import '../../providers/current_service_provider.dart';

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
    final simulatedTime = ref.watch(applicationTimeProvider).value!;

    final currentRestaurant = ref.read(currentRestaurantProvider(ref.read(selectedRestaurantProvider))).value!;
    final serviceId = ModalRoute.of(context)?.settings.arguments as int;
    final currentServiceState = ref.watch(currentServiceProvider(serviceId));
    final currentServiceNotifier = ref.read(currentServiceProvider(serviceId).notifier,);
    

    return currentServiceState.when(
      data: (service) => data(theme, simulatedTime, service, currentServiceNotifier, currentRestaurant, context),
      error: (e, _) =>
          DataErrorWidget(error: e, notifier: currentServiceNotifier),
      loading: () =>
          Center(child: Column(children: [CircularProgressIndicator()])),
    );
  }

  Scaffold data(ThemeData theme, DateTime simulatedTime, Service? service, CurrentServiceNotifier currentServiceNotifier, Restaurant currentRestaurant, BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text( service == null ? 'Ajouter un service' : 'Modifier le service'),
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
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 DropdownButtonFormField<String>(
                  initialValue: service == null ? null : DatetimeUtils.dayOfWeekToString(service.dayOfWeek),
                  decoration: const InputDecoration(
                    labelText: 'Jour',
                    border: OutlineInputBorder(),
                  ),
                  items:  [
                    for (int i = 1; i < 8; i++) ... [
                      DropdownMenuItem(value: DatetimeUtils.dayOfWeekToString(i), child: Text(DatetimeUtils.dayOfWeekToString(i))),
                    ]
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: 19,
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
                        initialValue: 0,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: 0,
                            child: const Text('00 min'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 15,
                            child: const Text('15 min'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 30,
                            child: const Text('30 min'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 45,
                            child: const Text('45 min'),
                          ),
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
                        initialValue: 22,
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
                        initialValue: 0,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: 0,
                            child: const Text('00 min'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 15,
                            child: const Text('15 min'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 30,
                            child: const Text('30 min'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 45,
                            child: const Text('45 min'),
                          ),
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
