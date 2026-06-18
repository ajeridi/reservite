import 'dart:collection';
import 'package:prbd_2526_a07/models/service.dart';

class Services {
  final SplayTreeSet<Service> services = SplayTreeSet.of([]);

  Services(Iterable<Service> s) {
    this.services.addAll(s);
  }

  bool add(Service service){
    return services.add(service);
  }


  @override
  String toString() {
    return _printServicesStartEndTimes();
  }

  String _printServicesStartEndTimes() {
    int i = 0;
    String startEndTImes = '';
    while (i < services.length - 1){
      Service service = services.elementAt(i++);
      startEndTImes += service.startEndTimeString() + ",";
    }
    Service lastService = services.elementAt(i);
    startEndTImes += lastService.startEndTimeString();
    return startEndTImes;
  }

}