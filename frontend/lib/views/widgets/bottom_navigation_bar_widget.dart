import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({super.key, this.currentIndex = 0});

  // index de l'onglet actif (0 = Reservations, 1 = Services, 2 = Tables)
  final int currentIndex;

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState extends State<BottomNavigationBarWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.currentIndex,
      onTap: _onItemTapped,
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

  void _onItemTapped(int index) {
    // on ne re-navigue pas vers l'onglet deja actif
    if (index == widget.currentIndex) return;

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/manager_reservations_page');
    }

    if (index == 1) {
      Navigator.pushReplacementNamed(context, '/restaurant_management_services_page');
    }

    if (index == 2) {
      // Navigator.pushReplacementNamed(context, '/manager_reservations_page'); à mettre plus-tard
    }
  }

}