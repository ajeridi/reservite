import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationBarWidget extends StatelessWidget {

  final int currentIndex; //index page courante
  const NavigationBarWidget({
    super.key,required this.currentIndex
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex, // onglet actif
      onTap: (index) {
        switch (index){
          case 0:
            Navigator.pushReplacementNamed(context, '/manager_reservations_page');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/restaurant_management_services_page');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/restaurant_management_tables_page');
            break;
        }
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
}