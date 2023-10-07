import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
part 'recordaudio_state.dart';

class RecordAudioCubit extends Cubit<RecordaudioState> {
  final AudioRecorder _myRecorder = AudioRecorder();
  final AudioEncoder encoder;
  final Function()? onRecordStart;
  final Function(String?, Duration?) onRecordEnd;
  final Function()? onRecordCancel;
  final Duration maxRecordLength;
  DateTime? recordStartTime;
  late Timer timer;
  ValueNotifier<Duration?> currentDuration = ValueNotifier(Duration.zero);
  // StreamSubscription? recorderStream;

  RecordAudioCubit(
      {required this.onRecordEnd,
      this.onRecordStart,
      this.onRecordCancel,
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
      // _myRecorder.setSubscriptionDuration(const Duration(milliseconds: 200));
      // _myRecorder
      //     .startStream(const RecordConfig(encoder: AudioEncoder.aacEld))
      //     .then((v) {
      //       print('++++++++++++++=== record started!!!++++++++');
      //   v.listen((event) {
      //     bytes.addAll(event);
      //   });
      //   // recorderStream = v.listen((event) {
      //   //   Duration current = Duration(milliseconds: event.length);
      //   //   currentDuration.value = current;
      //   //   if (maxRecordLength != null) {
      //   //     if (current.inMilliseconds >= maxRecordLength!.inMilliseconds) {
      //   //       print('[chat_composer] 🔴 Audio passed max length');
      //   //       stopRecord();
      //   //     }
      //   //   }
      //   // });
      // }).catchError((err){
      //   print('ERRRRRRRRRRRRR');
      //   print('$err');
      // });
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
          if (!hasStorage) await Permission.storage.request();
          if (!hasMic) await Permission.microphone.request();
          print('[chat_composer] 🔴 Denied permissions');
          return;
        }
      }
      if (onRecordStart != null) onRecordStart!();

      String dir =
          kIsWeb ? '' : (await getApplicationDocumentsDirectory()).path;
      String path = dir.isEmpty
          ? '${DateTime.now().millisecondsSinceEpoch}.aac'
          : '$dir/${DateTime.now().millisecondsSinceEpoch}.aac';

      await _myRecorder.start(RecordConfig(encoder: encoder), path: path);
      recordStartTime = DateTime.now();
    } catch (e) {
      print(e);
    }
  }

  void stopRecord() async {
    print('------------ Stop ----------------');
    //await _myRecorder.stop();
    try {
      String? result = await _myRecorder.stop();
      if (result != null) {
        print('[chat_composer] 🟢 Audio path:  "$result');
        onRecordEnd(result, currentDuration.value);
        recordStartTime = null;
      }
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
