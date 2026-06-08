import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';

import '../../providers/reservation_providers/selected_reservation_date_provider.dart';

class DatePickerReservation extends ConsumerWidget {
  const DatePickerReservation({super.key,});


  @override
  Widget build(BuildContext context, WidgetRef ref){
    final theme = Theme.of(context);

    // on a besoin de chercher la premier date disponible
    final selectedReservationDateState = ref.watch(selectedReservationDateProvider);
    final selectedReservationDateNotifier = ref.read(selectedReservationDateProvider.notifier);
    final  applicationTime = ref.watch(applicationTimeProvider);
    final firstDate = applicationTime.value!; // date au dela de laquelle nous ne pouvons plus aller dans le passe

    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                // on va ouvrir le DatePicker, puis attendre la selection qui va etre stockee dans pickedDate
                final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedReservationDateState.value!,
                    firstDate: firstDate,
                    lastDate: DateTime(2030),
                );
                if (pickedDate != null){
                  selectedReservationDateNotifier.setDate(pickedDate);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Date'),
                          selectedReservationDateState.when(
                              data: (selected) => Text(DateFormat('EEEE dd/MM/yyyy', 'fr_FR').format(selected),
                              style: theme.textTheme.bodySmall,),
                            error: (e, _) => Text("Erreur de chargement de la date"),
                            loading: () => Text("Chargement de la date...")
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.remove),
          // si date selectionnee == premiere date, desactive le bouton - (bug quand on selectionne avec datetime, le bouton ne se desactive plus)
          onPressed: selectedReservationDateNotifier.isFirstDate(firstDate) ? null : ()  {
            selectedReservationDateNotifier.subtractDay();
          },
        ),
        IconButton(icon: const Icon(Icons.add), onPressed: () {
          selectedReservationDateNotifier.addDay();

        }),
        const SizedBox(width: 16),
      ],
    );
  }
}
