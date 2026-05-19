import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../core/tools/my_provider_observer.dart';
import '../../models/restaurant.dart';
import '../../providers/restaurants_provider.dart';
import '../widgets/data_error_widget.dart';
import '../widgets/restaurantsWidget.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
      ProviderScope(
        observers: [MyProviderObserver()],
        retry: (int _, Object _) => null,
    child:
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SearchRestaurantsMockupScreen(),
    ),
  ));
}

class SearchRestaurantsMockupScreen extends ConsumerWidget {
  const SearchRestaurantsMockupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    final asyncState = ref.watch(restaurantProvider);
    final notifier = ref.read(restaurantProvider.notifier);

    return asyncState.when(
      data: (state) => data(state, notifier,theme, simulatedTime),
      error: (err, _) =>
          DataErrorWidget(
            error: err,
            stackTrace: StackTrace.current,
            notifier: notifier,
          ), loading: () =>
        data(
          asyncState.value ?? SplayTreeSet(),
          notifier,
          theme,
          simulatedTime,
        ),
    );
  }

  Widget data(
      SplayTreeSet<Restaurant> restaurants,
      RestaurantsNotifier notifier,
      dynamic theme, DateTime simulatedTime,
      ){

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: const Text('Rechercher un restaurant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {},
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher par nom, ville, description...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {},
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    color: Colors.orange.shade50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.orange.shade800,
                        ),
                        const SizedBox(width: 8),
                        if(restaurants.length > 5)
                          Expanded(
                            child: Text(
                              'Trop de résultats trouvés. Veuillez affiner votre recherche pour voir plus de restaurants.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        for(var restaurant in restaurants)
                          RestaurantCard( restaurant : restaurant),

                ],
              ),
            ),
          ],
        ),
      ),
        ],
      ),
      ),
    );
  }
}
