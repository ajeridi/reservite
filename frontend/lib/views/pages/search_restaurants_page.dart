import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/providers/filtered_restaurants_provider.dart';

import '../../core/tools/my_provider_observer.dart';
import '../../models/restaurant.dart';
import '../../providers/application_time_provider.dart';
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
      home: const SearchRestaurantsScreen(),
    ),
  ));
}
String search = '';

class SearchRestaurantsScreen extends ConsumerWidget {
  const SearchRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final applicationTime = ref.watch(applicationTimeProvider);



    final asyncState = ref.watch(restaurantProvider);
    final notifier = ref.read(restaurantProvider.notifier);

    final filterRestaurantState = ref.watch(filteredRestaurantsProvider);
    final filterRestoNotifier = ref.read(filteredRestaurantsProvider.notifier);

    return asyncState.when(
      data: (state) => applicationTime.when(                          // ✅
        data: (simulatedTime) => data(state, notifier, theme, simulatedTime, filterRestaurantState, filterRestoNotifier, context),
        error: (e, _) => DataErrorWidget(error: e, notifier: notifier),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => DataErrorWidget(error: err, stackTrace: StackTrace.current, notifier: notifier),
      loading: () => data(asyncState.value ?? SplayTreeSet(), notifier, theme, DateTime.now(), filterRestaurantState, filterRestoNotifier, context),
    );
  }

  Widget data(
      SplayTreeSet<Restaurant> restaurants,
      RestaurantsNotifier notifier,
      dynamic theme, DateTime simulatedTime, SplayTreeSet<Restaurant> filterRestaurantState,
      FilteredRestaurantsNotifier filterRestoNotifier,
      BuildContext context,
      ){

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home_client_page');
          },
        ),
        title: const Text('Rechercher un restaurant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              print(search);
              filterRestoNotifier.refresh(search);},
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
                onChanged: (s) {
                  search = s;
                  filterRestoNotifier.updateFilter(restaurants, s);
                  },
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  if(filterRestaurantState.length > 5)
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
                        for(var restaurant in filterRestaurantState)
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
