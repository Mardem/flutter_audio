import 'package:get_it/get_it.dart';

import '../../../core/core.dart';
import '../../../main.dart';

class OnboardingDI extends BaseServiceLocator {
  @override
  GetIt locator = inject;

  @override
  Future<void> setServices() async {}

  @override
  Future<void> setRepositories() async {}

  @override
  Future<void> setViewModels() async {}
}
