
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a07/models/services.dart';

final currentServiceProvider = AsyncNotifierProvider.family<CurrentServiceNotifier, Services?, int>(
       CurrentServiceNotifier.new,
);

class CurrentServiceNotifier extends AbstractAsyncNotifier<Services?> {
  CurrentServiceNotifier(this.id);

  final int id;
  @override
  Future<Services?> build() async {
    state = AsyncData(null);
    state = AsyncLoading();
    try {
      if(id != 0) {
        return await Services.getService(id);
      }else return null;
    } catch (e, st) {
      throw Exception('Something went wrong.\nPlease try again later.');
    }
  }

  @override
  Future<void> refresh() async {
    state = AsyncLoading();
    try {
      state = AsyncData(await Services.getService(id));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }


}