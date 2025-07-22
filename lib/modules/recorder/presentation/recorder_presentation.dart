import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RecorderPresentation extends StatefulWidget {
  const RecorderPresentation({super.key});

  @override
  State<RecorderPresentation> createState() => _RecorderPresentationState();
}

class _RecorderPresentationState extends State<RecorderPresentation> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final StreamController<Uint8List> _controller = StreamController<Uint8List>();
  bool _isRecording = false;
  String? _filePath;
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _recorder.openRecorder();
    await Permission.microphone.request();
    _connectSocket();
  }

  void _connectSocket() {
    _socket = IO.io(
      'https://eb8bbd5d93bf.ngrok-free.app',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket?.connect();

    _socket?.onConnect((_) {
      print('✅ Conectado ao servidor socket');
    });
    
    _socket?.onError((data) {
      print('❌ Erro socket: $data');
    });
  }

  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = 'audio_teste.wav';
    _filePath = path;

    _controller.stream.listen((Uint8List data) {
      print('🔊 Enviando ${data.length} bytes para o socket');
      _socket?.emit('audioStream', data);
    });

    await _recorder.startRecorder(
      // toStream: _controller.sink,
      toFile: path,
      codec: Codec.pcm16WAV,
      audioSource: AudioSource.microphone,
    );

    setState(() => _isRecording = true);
    print('🎙️ Gravando: $path');
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    _controller.close();
    setState(() => _isRecording = false);
    print('🛑 Gravação encerrada em: $_filePath');
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _controller.close();
    _socket?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gravador e Socket")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: const Text("Iniciar Gravação"),
            ),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: const Text("Parar Gravação"),
            ),
          ],
        ),
      ),
    );
  }
}
