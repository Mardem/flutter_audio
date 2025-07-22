import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart';

class RecorderViewModel {
  Socket? socket;

  void connectSocket() {
    socket = io(
      'https://8e80a22b8f75.ngrok-free.app',
      OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );

    socket!
      ..onConnect((_) => print('✅ Conectado ao servidor'))
      ..onDisconnect((_) => print('❌ Desconectado'))
      ..onError((data) => print('❌ Erro no socket: $data'))
      ..connect();
  }

  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  Future<void> requestPermission() async =>
      await Permission.microphone.request();
}
