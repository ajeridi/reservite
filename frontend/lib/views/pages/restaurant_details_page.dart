import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';

import '../../providers/application_time_provider.dart';
import '../../providers/current_restaurant_provider.dart';
import '../widgets/restaurant_details_widget.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RestaurantDetailsPage(),
    ),
  );
}

class RestaurantDetailsPage extends ConsumerWidget {
  const RestaurantDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resto = ref.watch(
      currentRestaurantProvider(ref.read(selectedRestaurantProvider)),
    );

    final theme = Theme.of(context);
    final applicationTime = ref.watch(applicationTimeProvider);

    return applicationTime.when(
      data: (simulatedTime) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/my_restaurants_page');
            },
          ),
          title: const Text('Détails du restaurant'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Rafraîchir les données',
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/restaurant_details_page',
                );
              },
            ),
          ],
          elevation: 2,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Tooltip(
                  message:
                      'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                  child: Text(
                    DateFormat(
                      'EEEE dd/MM/yyyy HH:mm',
                      'fr_FR',
                    ).format(simulatedTime),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: RestaurantDetailsWidget(),
          ),
        ),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
