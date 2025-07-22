import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import '../../../core/remote/mqtt/di/mqtt_factory.dart';
import '../../../core/remote/mqtt/domain/mqtt_repository.dart';
import '../../../main.dart';

class HomeDI extends BaseServiceLocator {
  @override
  GetIt locator = inject;

  @override
  Future<void> setServices() async {
    inject.registerFactory<MqttRepository>(
      () => MqttFactory.create(
        server: 'broker.emqx.io',
        clientIdentifier:
            'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  @override
  Future<void> setRepositories() async {}

  @override
  Future<void> setViewModels() async {}
}
