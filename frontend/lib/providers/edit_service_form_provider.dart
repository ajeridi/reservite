import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/current_services_provider.dart';
import 'package:prbd_2526_a07/providers/selected_services_provider.dart';

/*
* Etat du formulaire de creation/modification d'un service.
* On stocke le jour, l'heure/minute de debut et l'heure/minute de fin.
*
* - En modification (id != 0) : l'etat initial vient du service courant.
* - En creation (id == 0) : tous les champs sont vides (null).
*
* Les champs sont nullable pour pouvoir afficher un formulaire vide (cas "Nouveau service").
* */

class EditServiceForm {
  final int? dayOfWeek;
  final int? startHour;
  final int? startMinute;
  final int? endHour;
  final int? endMinute;

  const EditServiceForm({
    this.dayOfWeek,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
  });

  EditServiceForm copyWith({
    int? dayOfWeek,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return EditServiceForm(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  // tous les champs doivent etre remplis pour pouvoir enregistrer
  bool get isComplete =>
      dayOfWeek != null &&
      startHour != null &&
      startMinute != null &&
      endHour != null &&
      endMinute != null;

  // format attendu par PostgreSQL pour un type time : 'HH:MM:SS'
  String get startTime =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';

  String get endTime =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';
}

final editServiceFormProvider =
    NotifierProvider.autoDispose<EditServiceFormNotifier, EditServiceForm>(
  EditServiceFormNotifier.new,
);

class EditServiceFormNotifier extends Notifier<EditServiceForm> {
  @override
  EditServiceForm build() {
    final selectedServiceId = ref.read(selectedServiceProvider);

    // creation : formulaire vide
    if (selectedServiceId == 0) {
      return const EditServiceForm();
    }

    // modification : on pre-remplit depuis le service courant
    final service = ref.watch(currentServiceProvider(selectedServiceId)).value;
    if (service == null) {
      return const EditServiceForm();
    }

    return EditServiceForm(
      dayOfWeek: service.dayOfWeek,
      startHour: service.startTime.hour,
      startMinute: service.startTime.minute,
      endHour: service.endTime.hour,
      endMinute: service.endTime.minute,
    );
  }

  void setDayOfWeek(int value) => state = state.copyWith(dayOfWeek: value);

  void setStartHour(int value) => state = state.copyWith(startHour: value);

  void setStartMinute(int value) => state = state.copyWith(startMinute: value);

  void setEndHour(int value) => state = state.copyWith(endHour: value);

  void setEndMinute(int value) => state = state.copyWith(endMinute: value);
}
