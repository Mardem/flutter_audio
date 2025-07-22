import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class OnboardingPresentation extends StatefulWidget {
  const OnboardingPresentation({super.key});

  @override
  State<OnboardingPresentation> createState() => _OnboardingPresentationState();
}

class _OnboardingPresentationState extends State<OnboardingPresentation> {
  bool isRecording = false;
  String finalPath = '';
  final record = AudioRecorder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Para gravar o audio'),
              ElevatedButton(
                child: Text('Gravar'),
                onPressed: () async {
                  final Directory documentsDir = await getTemporaryDirectory();
                  final String path = '${documentsDir.path}/audio.wav';

                  if (await record.hasPermission()) {
                    setState(() {
                      isRecording = !isRecording;
                    });
                    await record.start(const RecordConfig(), path: path);
                  }
                },
              ),
              if (isRecording)
                ElevatedButton(
                  child: Text('Parar'),
                  onPressed: () async {
                    final path = await record.stop();
                    finalPath = finalPath;

                    setState(() {
                      isRecording = !isRecording;
                    });
                    print('caminho: $path');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadFile() async {
    final dio = Dio(BaseOptions(baseUrl: ''));

    final formData = FormData.fromMap({
      'medico_id': '1',
      'atendimento_id': '2',
      'arquivo': [
        await MultipartFile.fromFile(finalPath, filename: 'audio.wav'),
      ],
    });

    final response = await dio.post('/info', data: formData);
  }
}
