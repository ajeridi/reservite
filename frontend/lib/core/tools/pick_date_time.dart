import 'package:flutter/material.dart';


// Retourne le DateTime ou null si l'utilisateur annule
Future<DateTime?> pickDateTime(
    BuildContext context, {
      required DateTime initialDate,
    }) async {
  // on pick la date
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  );

  if (pickedDate == null) return null;

  // choisir l'heure
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
  );

  if (pickedTime == null) return null; // annulé

  // return les deux en un seul DateTime
  return DateTime(
    pickedDate.year,
    pickedDate.month,
    pickedDate.day,
    pickedTime.hour,
    pickedTime.minute,
  );
}