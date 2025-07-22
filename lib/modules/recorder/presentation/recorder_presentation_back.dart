import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

const SERVER_URL = 'https://eb8bbd5d93bf.ngrok-free.app';

class RecorderPresentation extends StatefulWidget {
  const RecorderPresentation({super.key});

  @override
  State<RecorderPresentation> createState() => _RecorderPresentationState();
}

class _RecorderPresentationState extends State<RecorderPresentation> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final StreamController<Uint8List> _audioStream =
      StreamController<Uint8List>();
  IO.Socket? _socket;
  bool _isRecording = false;

  static const int sampleRate = 16000;
  static const int numChannels = 1;
  static const Codec codec = Codec.pcm16WAV;
  static const int bufferSize = 8192;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 50));
  }

  void _connectSocket() {
    _socket = IO.io(
      SERVER_URL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..onConnect((_) => print('✅ Conectado ao servidor'))
      ..onDisconnect((_) => print('❌ Desconectado'))
      ..connect();
  }

  Future<void> _startRecording() async {
    _connectSocket();

    // Caminho do arquivo para salvar localmente
    final Directory dir = await getApplicationDocumentsDirectory();
    final String filePath =
        '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

    // Ouve os dados do microfone e envia via socket
    _audioStream.stream.listen((Uint8List data) {
      print('🔊 Pacote de áudio capturado: ${data.length} bytes');

      if (_socket?.connected == true) {
        _socket!.emit('audioStream', data);
      }
    });

    await _recorder.startRecorder(
      codec: codec,
      sampleRate: sampleRate,
      numChannels: numChannels,
      toStream: _audioStream.sink,
      toFile: filePath,
      bufferSize: bufferSize,
    );

    print('🎙️ Gravando em: $filePath');

    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    try {
      // Para a gravação e recupera o caminho do arquivo salvo
      final String? filePath = await _recorder.stopRecorder();

      if (filePath != null) {
        print('🛑 Gravação finalizada. Arquivo salvo em: $filePath');
      } else {
        print('⚠️ Gravação parada, mas sem caminho de arquivo retornado.');
      }

      // Encerra a comunicação com o socket
      _socket?.disconnect();
      print('🔌 Socket desconectado.');

      // Fecha o stream
      await _audioStream.close();
      print('🛠️ Stream de áudio fechado.');

      setState(() => _isRecording = false);
    } catch (e) {
      print('❌ Erro ao parar a gravação: $e');
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎤 Recorder via Socket.IO')),
      body: Center(
        child: ElevatedButton(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          child: Text(_isRecording ? '🛑 Parar' : '🎙️ Gravar e Enviar'),
        ),
      ),
    );
  }
}
