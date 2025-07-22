import 'package:flutter/material.dart';

import 'modules/recorder/presentation/recorder_presentation.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State createState() {
    return AppState();
  }
}

class AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'Flutter Realtime',
      debugShowCheckedModeBanner: false,
      home: RecorderPresentation(),
    );
    return app;
  }
}
