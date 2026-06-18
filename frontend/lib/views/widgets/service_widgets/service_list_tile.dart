import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/views/widgets/service_widgets/management_services_buttons.dart';

import '../../../../models/service.dart';

class ServiceListTile extends StatelessWidget {
  const ServiceListTile({
    super.key,
    required this.service,
  });

  final Service service;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${DateFormat("HH:mm", "fr_FR").format(service.startTime)} - ${DateFormat("HH:mm", "fr_FR").format(service.endTime)}'),
      trailing: ManagementServicesButtons(service: service)
    );
  }
}
