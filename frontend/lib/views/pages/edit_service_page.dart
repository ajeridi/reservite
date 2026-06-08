import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/current_services_provider.dart';
import 'package:prbd_2526_a07/providers/edit_service_form_provider.dart';
import 'package:prbd_2526_a07/providers/selected_services_provider.dart';
import 'package:prbd_2526_a07/providers/service_modification_check_provider.dart';
import 'package:prbd_2526_a07/providers/services_provider.dart';

import '../../models/services.dart';
import '../widgets/data_error_widget.dart';

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

const Map<int, String> _daysOfWeek = {
  1: 'Lundi',
  2: 'Mardi',
  3: 'Mercredi',
  4: 'Jeudi',
  5: 'Vendredi',
  6: 'Samedi',
  7: 'Dimanche',
};

class EditServicePage extends ConsumerWidget {
  const EditServicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final simulatedTime = ref.watch(applicationTimeProvider).value;

    final selectedServiceId = ref.read(selectedServiceProvider);
    final currentServiceState =
        ref.watch(currentServiceProvider(selectedServiceId));
    final currentServiceNotifier =
        ref.read(currentServiceProvider(selectedServiceId).notifier);

    return currentServiceState.when(
      data: (service) => data(
        context,
        ref,
        service,
        currentServiceNotifier,
        theme,
        simulatedTime,
      ),
      error: (err, _) => DataErrorWidget(
        error: err,
        stackTrace: StackTrace.current,
        notifier: currentServiceNotifier,
      ),
      loading: () => loading(),
    );
  }

  Widget data(
    BuildContext context,
    WidgetRef ref,
    Services? service,
    CurrentServiceNotifier currentServiceNotifier,
    ThemeData theme,
    DateTime? simulatedTime,
  ) {
    final isNew = ref.read(selectedServiceProvider) == 0;

    final form = ref.watch(editServiceFormProvider);
    final formNotifier = ref.read(editServiceFormProvider.notifier);
    final checkState = ref.watch(serviceModificationCheckProvider);

    final outsideCount = checkState.value ?? 0;

    // validations sur les horaires (uniquement quand les 4 champs sont remplis)
    final bool timesFilled = form.startHour != null &&
        form.startMinute != null &&
        form.endHour != null &&
        form.endMinute != null;
    final int startMinutes =
        (form.startHour ?? 0) * 60 + (form.startMinute ?? 0);
    final int endMinutes = (form.endHour ?? 0) * 60 + (form.endMinute ?? 0);
    final bool endAfterStart = endMinutes > startMinutes;
    final bool durationAtLeastOneHour = (endMinutes - startMinutes) >= 60;

    String? timeError;
    if (timesFilled) {
      if (!endAfterStart) {
        timeError = "L'heure de fin doit être après l'heure de début";
      } else if (!durationAtLeastOneHour) {
        timeError = "La durée du service doit être d'au moins 1 heure";
      }
    }

    // on autorise l'enregistrement seulement si :
    //  - tous les champs du formulaire sont remplis
    //  - les horaires sont valides (fin > debut et duree >= 1h)
    //  - la verification est terminee
    //  - en modification, aucune reservation ne sortirait des nouvelles heures
    final canSave = form.isComplete &&
        timeError == null &&
        !checkState.isLoading &&
        (isNew || outsideCount == 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(
                context, '/restaurant_management_services_page');
          },
        ),
        title: Text(isNew ? 'Nouveau service' : 'Modifier le service'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Enregistrer',
            onPressed: canSave
                ? () => _save(context, ref, currentServiceNotifier, form, isNew)
                : null,
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
                DropdownButtonFormField<int>(
                  initialValue: form.dayOfWeek,
                  hint: const Text('Jour'),
                  decoration: const InputDecoration(
                    labelText: 'Jour',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final entry in _daysOfWeek.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) formNotifier.setDayOfWeek(value);
                  },
                ),
                if (outsideCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Modification impossible : $outsideCount '
                            '${outsideCount > 1 ? 'réservations confirmées ou en attente seraient' : 'réservation confirmée ou en attente serait'} '
                            'en dehors des horaires du service.',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: form.startHour,
                        hint: const Text('--'),
                        decoration: const InputDecoration(
                          labelText: 'Heure de début (heure)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 24; h++)
                            DropdownMenuItem<int>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} h'),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) formNotifier.setStartHour(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: form.startMinute,
                        hint: const Text('--'),
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem<int>(value: 0, child: Text('00 min')),
                          DropdownMenuItem<int>(value: 15, child: Text('15 min')),
                          DropdownMenuItem<int>(value: 30, child: Text('30 min')),
                          DropdownMenuItem<int>(value: 45, child: Text('45 min')),
                        ],
                        onChanged: (value) {
                          if (value != null) formNotifier.setStartMinute(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: form.endHour,
                        hint: const Text('--'),
                        decoration: const InputDecoration(
                          labelText: 'Heure de fin (heure)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 24; h++)
                            DropdownMenuItem<int>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} h'),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) formNotifier.setEndHour(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: form.endMinute,
                        hint: const Text('--'),
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem<int>(value: 0, child: Text('00 min')),
                          DropdownMenuItem<int>(value: 15, child: Text('15 min')),
                          DropdownMenuItem<int>(value: 30, child: Text('30 min')),
                          DropdownMenuItem<int>(value: 45, child: Text('45 min')),
                        ],
                        onChanged: (value) {
                          if (value != null) formNotifier.setEndMinute(value);
                        },
                      ),
                    ),
                  ],
                ),
                if (timeError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      timeError,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    CurrentServiceNotifier currentServiceNotifier,
    EditServiceForm form,
    bool isNew,
  ) async {
    try {
      if (isNew) {
        // creation : on passe par le notifier de la liste des services
        await ref.read(servicesProvider.notifier).create(
              dayOfWeek: form.dayOfWeek!,
              startTime: form.startTime,
              endTime: form.endTime,
            );
      } else {
        await currentServiceNotifier.updateService(
          dayOfWeek: form.dayOfWeek!,
          startTime: form.startTime,
          endTime: form.endTime,
        );
      }
      if (context.mounted) {
        Navigator.pushReplacementNamed(
            context, '/restaurant_management_services_page');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }
}

Widget loading() {
  return const Center(child: CircularProgressIndicator(color: Colors.black));
}
