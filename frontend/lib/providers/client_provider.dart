import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' hide Client;
import 'package:prbd_2526_a07/core/tools/abstract_async_notifier.dart';
import '../models/client.dart';

final clientProvider = AsyncNotifierProvider<ClientNotifier, Client>(
    () => ClientNotifier(),
);

class ClientNotifier extends AbstractAsyncNotifier<Client> {
  @override
  FutureOr<Client> build() async {
    state = AsyncData(new Client());
    state = AsyncLoading();
    return await Client.getConnectedClient();
  }

  @override
  Future<void> refresh() {
    // TODO: implement refresh
    throw UnimplementedError();
  }

}
