import 'package:flutter_realtime/modules/recorder/di/recorder_di.dart';

import '../modules/home/di/home_di.dart';

class InitAppModules {
  static Future<void> start() async {
    await HomeDI().initiate();
    await RecorderDI().initiate();
  }
}
