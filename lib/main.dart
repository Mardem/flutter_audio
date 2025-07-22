import 'package:flutter/material.dart';
import 'package:flutter_realtime/startup/di.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';

// Instância global do GetIt para injeção de dependências.
final GetIt inject = GetIt.instance;

main() async {
  // Define o locale padrão da aplicação como Português do Brasil.
  Intl.defaultLocale = 'pt_BR';

  // Garante que os bindings do Flutter estejam inicializados
  // antes de executar qualquer código assíncrono.
  WidgetsFlutterBinding.ensureInitialized();
  await InitAppModules.start();
  
  initializeDateFormatting('pt_BR', null).then((_) => runApp(const App()));
}
