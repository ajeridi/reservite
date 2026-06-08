import 'package:flutter/cupertino.dart' hide Table;
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_a07/providers/new_table_number_provider.dart';
import 'package:prbd_2526_a07/models/table.dart';
import 'package:prbd_2526_a07/providers/selected_table_id_provider.dart';

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

    _tableNumberController = ValidatingTextEditingController(
      initialValue: '${newTableNumber ?? ''}',
      validator: Table.validateTableNumber,
      asyncValidator: (string) => Table.checkTableNumberUnicity(string, selectedTableId)
    );
    _tableNumberController.onAfterValidated = () => setState(() {}); // pour dire qu'il faut refraichir l'etat de la page apres validation !!
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
      keyboardType: TextInputType.number,
    );
  }
}