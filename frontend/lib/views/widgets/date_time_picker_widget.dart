import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DatePickerReservation extends StatefulWidget {
  const DatePickerReservation({super.key});

  @override
  State<DatePickerReservation> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePickerReservation> {
  DateTime? selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2024, 12, 4),
      firstDate: DateTime(2024),
      lastDate: DateTime(2040),
    );

    setState(() {
      selectedDate = pickedDate;
    });
  }

  void addDay() {
    selectedDate = selectedDate!.add(
      const Duration(days: 1),
    ); // https://api.flutter.dev/flutter/dart-core/DateTime/add.html
  }

  void subtractDay() {
    selectedDate = selectedDate!.subtract(
      const Duration(days: 1),
    ); // https://api.flutter.dev/flutter/dart-core/DateTime/add.html
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _selectDate();
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
                          Text(
                            selectedDate != null
                                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                : 'No date selected',
                            style: theme.textTheme.bodySmall,
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
          onPressed: () {
            subtractDay();
          },
        ),
        IconButton(icon: const Icon(Icons.add), onPressed: () {
          print("add day");

        }),
        const SizedBox(width: 16),
      ],
    );
  }
}
