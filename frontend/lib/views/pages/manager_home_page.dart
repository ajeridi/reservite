import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prbd_2526_a07/views/pages/manager_reservations_page.dart';
import 'package:prbd_2526_a07/views/pages/restaurant_management_services_page.dart';
import 'package:prbd_2526_a07/views/pages/restaurant_management_tables_page.dart';

// voir tuto 1 section 7 pour changer une partie d'une page en fonction de la selection sur un rail de navigation
class ManagerHomePage extends StatefulWidget {
  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = ManagerReservationsPage();
        break;
      case 1:
        page = RestaurantManagementServicesPage();
        break;
      case 2:
        page = RestaurantManagementTablesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),

            ],
          ),
          bottomNavigationBar:  BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            onTap: (selectedPath) {
              setState(() {
                selectedIndex = selectedPath;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Réservations',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'Services',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.table_restaurant),
                label: 'Tables',
              ),
            ],
          ),
        );
      },
    );
  }
}
