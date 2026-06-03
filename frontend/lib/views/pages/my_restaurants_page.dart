import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/auth_provider.dart';
import 'package:prbd_2526_a07/providers/restaurants_provider.dart';
import 'package:prbd_2526_a07/views/widgets/restaurantsWidget.dart';

import '../../core/tools/my_provider_observer.dart';
import '../../models/restaurant.dart';
import '../../providers/application_time_provider.dart';
import '../widgets/data_error_widget.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp
    (ProviderScope(
      observers: [MyProviderObserver()],
  retry: (int _, Object _) => null,child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    home: const MyRestaurantsPage(),
  )
  ));
}

class MyRestaurantsPage extends ConsumerWidget {
  const MyRestaurantsPage({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final applicationTime = ref.watch(applicationTimeProvider);

    final asyncState = ref.watch(restaurantProvider);
    final notifier = ref.read(restaurantProvider.notifier);

    final authNotifier = ref.read(authProvider.notifier);

    return asyncState.when(
      data: (state) => applicationTime.when(
        data: (simulatedTime) => data(state, notifier, theme, simulatedTime, authNotifier, context),
        error: (e, _) => DataErrorWidget(error: e, notifier: notifier),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => DataErrorWidget(error: err, stackTrace: StackTrace.current, notifier: notifier),
      loading: () => data(asyncState.value ?? SplayTreeSet(), notifier, theme, DateTime.now(), authNotifier, context),
    );
  }
    Widget data(
        SplayTreeSet<Restaurant> restaurants,
        RestaurantsNotifier notifier,
        dynamic theme, DateTime simulatedTime,
        AuthNotifier authNotifier,
        BuildContext context
    )
    {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mes restaurants'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Rafraîchir les données',
              onPressed: () {
                notifier.refresh();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Déconnexion (Benoît P.)',
              onPressed: () {
                authNotifier.logout();
                Navigator.pushReplacementNamed(context, '/login');
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
                    DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                        .format(simulatedTime),
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
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              for(var restaurant in restaurants)
                RestaurantCard( restaurant : restaurant),


            ],
          ),
        ),
      );
    }
  }



