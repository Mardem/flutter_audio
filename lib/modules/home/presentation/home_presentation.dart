import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_realtime/main.dart';

import '../../../core/remote/mqtt/domain/mqtt_repository.dart';

class HomePresentation extends StatefulWidget {
  const HomePresentation({super.key});

  @override
  State<HomePresentation> createState() => _HomePresentationState();
}

class _HomePresentationState extends State<HomePresentation> {
  final String _mqttTopic = 'flutter_chat/response';

  final MqttRepository _mqttRepo = inject<MqttRepository>();

  final TextEditingController _topicCtrl = TextEditingController(
    text: 'flutter_chat/response',
  );
  final TextEditingController _messageCtrl = TextEditingController(
    text: 'Olá, essa é minha primeira mensagem!',
  );

  @override
  void initState() {
    super.initState();
    _initMqttClient();
  }

  Future<void> _initMqttClient() async {
    await _mqttRepo.initialize().then((_) => _mqttRepo.subscribe(_mqttTopic));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Flutter Realtime - MQTT'),
              TextField(
                controller: _topicCtrl,
                decoration: InputDecoration(labelText: 'Tópico'),
              ),
              TextField(
                controller: _messageCtrl,
                decoration: InputDecoration(labelText: 'Mensagem'),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final topic = _topicCtrl.text;
                      final msg = _messageCtrl.text;
                      _mqttRepo.publish(topic, {'message': msg});
                    },
                    child: Text('Publicar'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _mqttRepo.clearMessages(),
                    child: Text('Limpar mensagens'),
                  ),
                ],
              ),
              ValueListenableBuilder<String>(
                valueListenable: _mqttRepo.lastMessage,
                builder: (BuildContext context, String? value, _) {
                  return Text(value?.toString() ?? '');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _convertMessage({required String content}) {
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      print('Erro ao converter JSON: $e');
      return {};
    }
  }
}
