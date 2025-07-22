import 'package:get_it/get_it.dart';

abstract class BaseServiceLocatorInterface {
  late GetIt locator;
  Future<void> setServices();
  Future<void> setRepositories();
  Future<void> setViewModels();
}
