import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/material.dart';

import '../../../core/remote/mqtt/domain/mqtt_repository.dart';
import '../../../main.dart';
import '../vm/recorder_viewmodel.dart';

class RecorderPresentation extends StatefulWidget {
  const RecorderPresentation({super.key});

  @override
  State<RecorderPresentation> createState() => _RecorderPresentationState();
}

class _RecorderPresentationState extends State<RecorderPresentation> {
  int? sampleRate;
  bool isRecording = false;
  List<double> audio = [];
  List<double>? latestBuffer;
  double? recordingTime;
  StreamSubscription<List<double>>? audioSubscription;

  final RecorderViewModel vm = inject<RecorderViewModel>();

  final String _mqttTopic = 'flutter_chat/response';

  final MqttRepository _mqttRepo = inject<MqttRepository>();

  @override
  void initState() {
    super.initState();
    vm.connectSocket();
    _initMqttClient();
  }

  Future<void> _initMqttClient() async {
    await _mqttRepo.initialize().then((_) => _mqttRepo.subscribe(_mqttTopic));
  }

  Map<String, dynamic> _convertMessage({required String content}) {
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      print('Erro ao converter JSON: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(title: const Text('🎤 Recorder com Socket.IO')),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(25),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      isRecording ? "Mic: ON" : "Mic: OFF",
                      style: TextStyle(fontSize: 25, color: Colors.blue),
                    ),
                  ),
                  Text('Max amp: ${latestBuffer?.reduce(max)}'),
                  Text('Min amp: ${latestBuffer?.reduce(min)}'),
                  Text(
                    '${recordingTime?.toStringAsFixed(2)} seconds recorded.',
                  ),
                  ElevatedButton(
                    onPressed: isRecording ? stop : start,
                    child: isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
                  ),
                  Divider(),
                  Text(
                    'Mensagens transcrita:',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }

  /// Call-back on audio sample.
  void onAudio(List<double> buffer) async {
    audio.addAll(buffer);

    sampleRate ??= await AudioStreamer().actualSampleRate;
    recordingTime = audio.length / sampleRate!;

    if (vm.socket?.connected == true) {
      // Converte o List<double> em Int16 e depois em Uint8List
      final bytes = Int16List.fromList(
        buffer.map((e) => (e * 32767).toInt().clamp(-32768, 32767)).toList(),
      ).buffer.asUint8List();

      // Envia o buffer como único argumento
      vm.socket!.emit('audioStream', [bytes]);
    }

    setState(() => latestBuffer = buffer);
  }

  void handleError(Object error) {
    setState(() => isRecording = false);
    print(error);
  }

  void start() async {
    // Check permission to use the microphone.
    //
    // Remember to update the AndroidManifest file (Android) and the
    // Info.plist and pod files (iOS).
    if (!(await vm.checkPermission())) {
      await vm.requestPermission();
    }

    // Set the sampling rate - works only on Android.
    AudioStreamer().sampleRate = 16000;

    // Start listening to the audio stream.
    audioSubscription = AudioStreamer().audioStream.listen(
      onAudio,
      onError: handleError,
    );

    setState(() => isRecording = true);
  }

  /// Stop audio sampling.
  void stop() async {
    audioSubscription?.cancel();
    setState(() => isRecording = false);
  }
}
