import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
part 'recordaudio_state.dart';

class RecordAudioCubit extends Cubit<RecordaudioState> {
  final AudioRecorder _myRecorder = AudioRecorder();
  final AudioEncoder encoder;
  final Function()? onRecordStart;
  final Function(String?, List<int>?, Duration?) onRecordEnd;
  final Function()? onRecordCancel;
  final Duration maxRecordLength;
  DateTime? recordStartTime;
  late Timer timer;
  final bool audioFile;
  ValueNotifier<Duration?> currentDuration = ValueNotifier(Duration.zero);
  // StreamSubscription? recorderStream;
  List<int> bytes = [];

  RecordAudioCubit(
      {required this.onRecordEnd,
      this.onRecordStart,
      this.onRecordCancel,
      required this.audioFile,
      required this.maxRecordLength,
      required this.encoder})
      : super(RecordAudioReady()) {
    timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (recordStartTime == null) return;
      currentDuration.value = DateTime.now().difference(recordStartTime!);
      if (currentDuration.value!.inMilliseconds >=
          maxRecordLength.inMilliseconds) {
        print('[chat_composer] 🔴 Audio passed max length');
        stopRecord();
      }
    });

    _myRecorder.onStateChanged().listen((event) {
      if (event == RecordState.record) {
        emit(RecordAudioStarted());
      }
      if (event == RecordState.stop) {
        emit(RecordAudioReady());
      }
    });

    _myRecorder.hasPermission().then((value) {
      print(value.toString());
    });
  }

  void toggleRecord({required bool canRecord}) {
    emit(canRecord ? RecordAudioReady() : RecordAudioClosed());
  }

  void startRecord() async {
    try {
      await _myRecorder.stop();
    } catch (e) {
      //ignore
    }

    currentDuration.value = Duration.zero;
    try {
      if (!kIsWeb) {
        bool hasStorage = await Permission.storage.isGranted;
        bool hasMic = await Permission.microphone.isGranted;

        if (!hasStorage || !hasMic) {
          if (!hasStorage) {
            hasStorage = (await Permission.storage.request()).isGranted;
          }
          if (!hasMic) {
            hasMic = (await Permission.microphone.request()).isGranted;
          }
          if (!hasStorage || !hasMic) {
            // Fluttertoast.showToast(msg: 'No permission to microphone!');
            // return;
          }
        }
      }
      if (onRecordStart != null) onRecordStart!();

      if (audioFile) {
        String dir =
            kIsWeb ? '' : (await getApplicationDocumentsDirectory()).path;
        String path = dir.isEmpty
            ? '${DateTime.now().millisecondsSinceEpoch}.aac'
            : '$dir/${DateTime.now().millisecondsSinceEpoch}.aac';
        await _myRecorder.start(RecordConfig(encoder: encoder), path: path);
      } else {
        bytes.clear();
        (await _myRecorder.startStream(RecordConfig(encoder: encoder)))
            .listen((event) {
          bytes.addAll(event);
        });
      }

      recordStartTime = DateTime.now();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Cannot access microphone!');
      print(e);
    }
  }

  void stopRecord() async {
    print('------------ Stop ----------------');
    //await _myRecorder.stop();
    try {
      String? result = await _myRecorder.stop();
      // if (result != null) {
      if (audioFile) {
        print('[chat_composer] 🟢 Audio path:  "$result');
      } else {
        print('[chat_composer] 🟢 Audio bytes length: ${bytes.length}');
      }
      onRecordEnd(result, bytes, currentDuration.value);
      recordStartTime = null;
      // }
    } finally {
      currentDuration.value = Duration.zero;
    }
    // emit(RecordAudioReady());
  }

  void cancelRecord() async {
    print('------------ Cancel ----------------');
    try {
      await _myRecorder.stop();
    } catch (ignore) {
      //ignore
    }
    // emit(RecordAudioReady());
    if (onRecordCancel != null) onRecordCancel!();
    currentDuration.value = Duration.zero;
    recordStartTime = null;
  }

  @override
  Future<void> close() async {
    try {
      await _myRecorder.dispose();
    } catch (e) {
      //ignore
    }
    // if (recorderStream != null) await recorderStream!.cancel();
    try {
      timer.cancel();
      // _myRecorder = null;
      // timer.cancel();
    } catch (e) {
      //ignore
    }
    return super.close();
  }
}
