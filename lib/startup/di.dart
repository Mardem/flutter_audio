import '../modules/home/di/home_di.dart';

class InitAppModules {
  static Future<void> start() async {
    await HomeDI().initiate();
  }
}
