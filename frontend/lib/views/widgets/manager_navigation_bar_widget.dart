import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManagerNavigationBarWidget extends StatelessWidget {
  final int selected;

  const ManagerNavigationBarWidget({
    super.key,
    required this.selected,
  });


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selected,
      onTap: (selectedPath) {
        navigateToSelectedPage(context, selectedPath);
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
    );
  }

  void navigateToSelectedPage(BuildContext context, int selectedPath) {
    switch (selectedPath){
      case 0:
        if (selected != 0) Navigator.pushReplacementNamed(context, '/manager_reservations_page');
        break;
      case 1:
        if (selected != 1) Navigator.pushReplacementNamed(context, '/restaurant_management_services_page');
        break;
      case 2 :
        if (selected != 2) Navigator.pushReplacementNamed(context, '/restaurant_management_tables_page');
        break;
      default :
        break;
    }
  }
}
