import 'package:flutter/cupertino.dart' hide Table;
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_a07/providers/crudl_table_providers/new_table_number_provider.dart';
import 'package:prbd_2526_a07/models/table.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/table_providers/selected_table_id_provider.dart';

import '../../../providers/crudl_table_providers/is_valid_table_number_provider.dart';

class TableNumberFormWidget extends ConsumerStatefulWidget{
  const TableNumberFormWidget({super.key});

  @override
  ConsumerState<TableNumberFormWidget> createState() => _TableNumberFormWidgetState();

}


class _TableNumberFormWidgetState extends ConsumerState<TableNumberFormWidget> {
  late ValidatingTextEditingController _tableNumberController;


  @override
  void initState() {
    super.initState();

    final newTableNumber = ref.read(newTableNumberProvider); // ATTENTION A NE PAS LE METTRE DANS LE VALIDATINGTEXTEDITINGCONTROLLER SINON PROBLEMES DE DEPENDENCES
    final selectedTableId = ref.read(selectedTableIdProvider);
    final selectedRestaurantId = ref.read(selectedRestaurantProvider);

    _tableNumberController = ValidatingTextEditingController(
      initialValue: '${newTableNumber ?? ''}',
      validator: Table.validateTableNumber,
      asyncValidator: (string) => Table.checkTableNumberUnicity(string, selectedTableId, selectedRestaurantId)
    );
    _tableNumberController.onAfterValidated = () => setState(() {
      final isValidTableNumber = ref.read(isValidTableNumberProvider.notifier).setValidationStatus(_tableNumberController.errorText == null);
    }); // pour dire qu'il faut refraichir l'etat de la page apres validation !!
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _tableNumberController,
      decoration: InputDecoration(
        errorText: _tableNumberController.errorText,
        labelText: 'Numéro de table',
        border: OutlineInputBorder(),
      ),
      onChanged:(value) =>  _setNewTableNumber(value),
      keyboardType: TextInputType.number,
    );
  }

  void _setNewTableNumber(String value) {
    ref.read(newTableNumberProvider.notifier).setValue(value);
  }
}