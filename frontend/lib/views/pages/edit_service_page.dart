import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';
import 'package:prbd_2526_a07/models/service.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/current_service_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/current_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/views/widgets/data_error_widget.dart';

import '../../core/tools/datetime_utils.dart';

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

class EditServicePage extends ConsumerStatefulWidget {
  const EditServicePage({super.key});

  @override
  ConsumerState<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends ConsumerState<EditServicePage> {

  bool _initialized = false; // boolean qui va indiquer si la page s'est deja initilisee ou pas, pour eviter de perdre les inputs et d'avoir une reinitialisation des valeurs des fields a chaque validation

  String? _dayOfWeek;
  int? _startHour;
  int? _startMinutes;
  int? _endHour;
  int? _endMinutes;

  String? _asyncError;
  String? _dayOfWeekError;
  String? _startTimeError;
  String? _endTimeError;
  String? _timeError;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = ref.watch(applicationTimeProvider).value!;

    final currentRestaurant = ref
        .read(currentRestaurantProvider(ref.read(selectedRestaurantProvider)))
        .value!;
    final serviceId = ModalRoute.of(context)?.settings.arguments as int;
    final currentServiceState = ref.watch(currentServiceProvider(serviceId));
    final currentServiceNotifier = ref.read(
      currentServiceProvider(serviceId).notifier,
    );

    return currentServiceState.when(
      data: (service) => data(
        theme,
        simulatedTime,
        service,
        currentServiceNotifier,
        currentRestaurant,
        context,
      ),
      error: (e, _) =>
          DataErrorWidget(error: e, notifier: currentServiceNotifier),
      loading: () =>
          Center(child: Column(children: [CircularProgressIndicator()])),
    );
  }

  Scaffold data(
    ThemeData theme,
    DateTime simulatedTime,
    Service? service,
    CurrentServiceNotifier currentServiceNotifier,
    Restaurant currentRestaurant,
    BuildContext context,
  ) {

    // pour eviter de reinitialiser deux fois les valeurs initiales
    if (!_initialized){{
      _initialized = true;
      _dayOfWeek = service == null ? null : DatetimeUtils.dayOfWeekToString(service.dayOfWeek);
      _startHour = service?.startTime.hour;
      _startMinutes = service?.startTime.minute;
      _endHour = service?.endTime.hour;
      _endMinutes = service?.endTime.minute;
    }}

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          service == null ? 'Ajouter un service' : 'Modifier le service',
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Enregistrer',
            onPressed: noErrors() ? () {} : null,
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
                  initialValue: _dayOfWeek,
                  decoration: const InputDecoration(
                    labelText: 'Jour',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (int i = 1; i < 8; i++) ...[
                      DropdownMenuItem(
                        value: DatetimeUtils.dayOfWeekToString(i),
                        child: Text(DatetimeUtils.dayOfWeekToString(i)),
                      ),
                    ],
                  ],
                  onChanged: (value) {
                    setState(() {
                      _dayOfWeek = value;
                      validateAll();
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_dayOfWeekError != null)
                  Text(_dayOfWeekError!, style: TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _startHour,
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
                        onChanged: (hour) {
                          setState(() {
                            _startHour = hour;
                            validateAll();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _startMinutes,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: makeMinutesDropdowns(currentRestaurant),
                        onChanged: (minute) {
                          setState(() {
                            _startMinutes = minute;
                            validateAll();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_startTimeError != null)
                  Text(_startTimeError!, style: TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _endHour,
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
                        onChanged: (hour) {
                          setState(() {
                            _endHour = hour;
                            validateAll();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _endMinutes,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: makeMinutesDropdowns(currentRestaurant),
                        onChanged: (minute) {
                          setState(() {
                            _endMinutes = minute;
                            validateAll();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                if (_endTimeError != null)
                  Text(_endTimeError!, style: TextStyle(color: Colors.red)),
                if (_timeError != null)
                  Text(_timeError!, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<int?>> makeMinutesDropdowns(Restaurant restaurant) {
    List<DropdownMenuItem<int?>> minutes = List.empty(growable: true);
    final slotDuration = restaurant.slotDuration;
    for (int min = 0; min < 60; min = min + slotDuration!) {
      minutes.add(
        DropdownMenuItem<int?>(value: min, child: Text(minutesToString(min))),
      );
    }
    return minutes;
  }

  String minutesToString(int minute) {
    if (minute == 0) return "00 min";
    return '$minute min';
  }

  void validateAll() {
    print(_dayOfWeek);
    print(_startHour);
    print(_startMinutes);
    print(_endHour);
    print(_endMinutes);
    // verification de l'existance des inputs
    _dayOfWeekError = (_dayOfWeek == null)
        ? 'Veuillez selectionner un jour'
        : null;
    _startTimeError = (_startHour == null || _startMinutes == null)
        ? 'Veuillez selectionner une heure/minute de debut'
        : null;
    _endTimeError = (_endHour == null || _endMinutes == null)
        ? 'Veuillez selectionner une heure/minute de fin'
        : null;

    // verification que l'heure de fin est apres l'heure de debut et que la duree du service doit etre d'au moins une heure
    if (_startTimeError == null && _endTimeError == null) {
      final startTime = TimeOfDay(hour: _startHour!, minute: _startMinutes!);
      final endTime = TimeOfDay(hour: _endHour!, minute: _endMinutes!);
      if (startTime.isAfter(endTime))
        _timeError =
            'L'
            'heure de fin doit etre apres l'
            'heure de debut';
      else if (differenceInMinutes(startTime, endTime) < 60)
        _timeError =
            'La duree du service doit etre d'
            'au moins une heure';
      else
        _timeError = null;
    }
  }

  int differenceInMinutes(TimeOfDay startTime, TimeOfDay endTime) {
    final startTimeInMinutes = startTime.hour * 60 + startTime.minute;
    final endTimeInMinutes = endTime.hour * 60 + endTime.minute;
    return endTimeInMinutes - startTimeInMinutes;
  }

  bool noErrors() {
    return _dayOfWeek != null &&
        _startHour != null &&
        _startMinutes != null &&
        _endHour != null &&
        _endMinutes != null &&
        _startTimeError == null &&
        _endTimeError == null &&
        _dayOfWeekError == null &&
        _timeError == null &&
        _asyncError == null;
  }
}
