import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

class TestRecordPage extends StatefulWidget {
  const TestRecordPage({super.key});

  @override
  State<TestRecordPage> createState() => _TestRecordPageState();
}

class _TestRecordPageState extends State<TestRecordPage> {
  final record = AudioRecorder();
  Stream<RecordState>? stream;
  List<int> bytes = [];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Record test Composer'),
            ),
            body: Column(children: [
              Text('ddd'),
              MaterialButton(
                onPressed: () async {
                  bytes.clear();
                  if (await record.hasPermission()) {
                    (await record.startStream(
                        const RecordConfig(encoder: AudioEncoder.aacLc))).listen((event) {
                         bytes.addAll(event);
                         });
                    stream = record.onStateChanged();
                    setState(() {
                      
                    });
                  }
                },
                child: Text('Start record'),
              ),
              MaterialButton(
                onPressed: () async {
                  record.stop();
                },
                child: Text('Stop record'),
              ),
              if(stream != null)
              StreamBuilder<RecordState>(stream: stream, builder: ((context, snapshot) {
                
                return Text('${snapshot.data?.name} - ${bytes.length}');
              }))
            ])));
  }
}
