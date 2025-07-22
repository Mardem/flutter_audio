import '../data/mqtt_service.dart';
import '../domain/mqtt_repository.dart';

class MqttFactory {
  static MqttRepository? _custom;

  static void register(MqttRepository repo) {
    _custom = repo;
  }

  static MqttRepository create({
    required String server,
    required String clientIdentifier,
    int port = 1883,
  }) {
    return _custom ??
        MqttService(
          server: server,
          clientIdentifier: clientIdentifier,
          port: port,
        );
  }

  static void reset() {
    _custom = null;
  }
}
