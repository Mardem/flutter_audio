import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';

abstract class MqttRepository {
  Future<void> initialize();

  void publish(
    String topic,
    Map<String, dynamic> jsonMap, {
    MqttQos qos = MqttQos.atLeastOnce,
  });

  void subscribe(String topic, {MqttQos qos = MqttQos.atMostOnce});

  void unsubscribe(String topic);

  void disconnect();

  void clearMessages();

  ValueNotifier<List<String>> get messages;

  ValueNotifier<String> get lastMessage;
}
