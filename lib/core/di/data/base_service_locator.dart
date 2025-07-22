import '../domain/base_service_locator_interface.dart';

abstract class BaseServiceLocator implements BaseServiceLocatorInterface {
  Future<void> initiate() async {
    await setServices();
    await setRepositories();
    await setViewModels();
  }
}
