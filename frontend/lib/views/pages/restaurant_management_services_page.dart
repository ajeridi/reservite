import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/core/tools/pick_date_time.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/current_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/service_providers/services_provider.dart';

import '../../models/services.dart';
import '../../providers/service_providers/selected_service_id_provider.dart';
import '../widgets/data_error_widget.dart';
import '../widgets/navigation_bar_widget.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RestaurantManagementServicesPage(),
    ),
  );
}

class RestaurantManagementServicesPage extends ConsumerWidget {
  const RestaurantManagementServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final idRestaurant = ref.watch(selectedRestaurantProvider);
    final restaurantState = ref.watch(currentRestaurantProvider(idRestaurant));
    final servicesState = ref.watch(servicesProvider);
    final servicesNotifier = ref.read(servicesProvider.notifier);
    final applicationTime = ref.watch(applicationTimeProvider);

    return servicesState.when(
      data: (services) => applicationTime.when(
        data: (simulatedTime) => _buildPage(
          context, ref, services, servicesNotifier,
          theme, simulatedTime, restaurantState,
        ),
        error: (e, _) => DataErrorWidget(error: e, notifier: servicesNotifier),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => DataErrorWidget(error: e, notifier: servicesNotifier),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildPage(
      BuildContext context,
      WidgetRef ref,
      List<Services> services,
      ServicesNotifier notifier,
      ThemeData theme,
      DateTime simulatedTime,
      AsyncValue restaurantState,
      ) {
    //  groupe les services par jour de la semaine
    final Map<int, List<Services>> servicesByDay = {};
    for (var service in services) {
      servicesByDay.putIfAbsent(service.dayOfWeek, () => []).add(service);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/manager_reservations_page');
          },
        ),
        title: restaurantState.whenData((r) => Text(r.name)).value,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => notifier.refresh(),
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
              child: GestureDetector(
                onTap: () async {
                  final newDatetime = await pickDateTime(context, initialDate: simulatedTime);
                  if (newDatetime != null) {
                    ref.read(applicationTimeProvider.notifier).setTime(newDatetime);
                  }
                },
                child: Tooltip(
                  message: 'Date/heure courante de l\'application.\nCliquez pour modifier.',
                  child: Text(
                    DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(simulatedTime),
                    style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // ✅ affiche les 7 jours, avec ou sans services
                for (int day = 1; day <= 7; day++)
                  _buildDayCard(context, ref, notifier, day, servicesByDay[day] ?? []),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'services_fab',
                onPressed: () {
                  // ✅ id = 0 = nouveau service
                  ref.read(selectedServiceIdProvider.notifier).setId(0);
                  Navigator.pushReplacementNamed(
                    context,
                    '/restaurant_management_service_details_page',
                  );
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarWidget(currentIndex: 1),
    );
  }

  Widget _buildDayCard(
      BuildContext context,
      WidgetRef ref,
      ServicesNotifier notifier,
      int day,
      List<Services> dayServices,
      ) {
    // ✅ pas de services ce jour-là
    if (dayServices.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.grey[100],
        child: ListTile(
          leading: const Icon(Icons.schedule, color: Colors.grey),
          title: Text(
            Services.dayOfWeekToString(day),
            style: TextStyle(color: Colors.grey[600]),
          ),
          subtitle: const Text('Aucun service', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    // ✅ un seul service ce jour-là
    if (dayServices.length == 1) {
      final service = dayServices.first;
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(Services.dayOfWeekToString(day)),
          subtitle: Text(
            '${DateFormat('HH:mm').format(service.startTime)} - ${DateFormat('HH:mm').format(service.endTime)}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _navigateToDetail(context, ref, service.id),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, ref, notifier, service.id),
                tooltip: 'Supprimer le service',
              ),
            ],
          ),
        ),
      );
    }

    // ✅ plusieurs services ce jour-là → ExpansionTile
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const Icon(Icons.schedule),
        title: Text(Services.dayOfWeekToString(day)),
        subtitle: Text(
          dayServices
              .map((s) => '${DateFormat('HH:mm').format(s.startTime)} - ${DateFormat('HH:mm').format(s.endTime)}')
              .join(', '),
        ),
        children: [
          for (var service in dayServices)
            ListTile(
              title: Text(
                '${DateFormat('HH:mm').format(service.startTime)} - ${DateFormat('HH:mm').format(service.endTime)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToDetail(context, ref, service.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, ref, notifier, service.id),
                    tooltip: 'Supprimer le service',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, WidgetRef ref, int serviceId) {
    ref.read(selectedServiceIdProvider.notifier).setId(serviceId);
    Navigator.pushReplacementNamed(context, '/restaurant_management_service_details_page');
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ServicesNotifier notifier, int serviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le service'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce service ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await notifier.delete(serviceId);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Oui', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}