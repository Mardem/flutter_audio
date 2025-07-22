import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../domain/mqtt_repository.dart';

class MqttService implements MqttRepository {
  late final MqttServerClient _client;
  StreamSubscription? _subscription;

  final String server;
  final int port;
  final String clientIdentifier;

  final ValueNotifier<List<String>> _messageList = ValueNotifier([]);
  final ValueNotifier<String> _lastMessage = ValueNotifier('');

  MqttService({
    required this.server,
    this.port = 1883,
    required this.clientIdentifier,
  });

  @override
  ValueNotifier<List<String>> get messages => _messageList;

  @override
  ValueNotifier<String> get lastMessage => _lastMessage;

  @override
  Future<void> initialize() async {
    _client = MqttServerClient(server, clientIdentifier)
      ..port = port
      ..keepAlivePeriod = 20
      ..logging(on: false)
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean();

    _client.connectionMessage = connMess;

    try {
      await _client.connect();
      _client.updates?.listen(_onMessage);
    } catch (e) {
      _client.disconnect();
      rethrow;
    }
  }

  @override
  void publish(
    String topic,
    Map<String, dynamic> jsonMap, {
    MqttQos qos = MqttQos.atLeastOnce,
  }) {
    final jsonString = json.encode(jsonMap);
    final builder = MqttClientPayloadBuilder();

    builder.addUTF8String(jsonString);

    _client.publishMessage(topic, qos, builder.payload!);
    print('Publicado JSON em $topic: $jsonString');
  }

  @override
  void subscribe(String topic, {MqttQos qos = MqttQos.atMostOnce}) {
    _client.subscribe(topic, qos);
  }

  @override
  void unsubscribe(String topic) {
    _client.unsubscribe(topic);
  }

  @override
  void disconnect() {
    _subscription?.cancel();
    _client.disconnect();
  }

  @override
  void clearMessages() => _messageList.value = [];

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final recMess = event[0].payload as MqttPublishMessage;

    final message = MqttPublishPayload.bytesToStringAsString(
      recMess.payload.message,
    );

    final topic = event[0].topic;
    final formattedMessage = message;

    final updated = List<String>.from(_messageList.value);
    updated.insert(0, formattedMessage);

    _messageList.value = updated;
    _lastMessage.value = formattedMessage;
  }

  void _onSubscribed(String topic) => print('Inscrito em $topic');

  void _onDisconnected() => print('Desconectado do broker');

  void _onConnected() => print('Conectado ao broker');
}
