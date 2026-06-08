import 'package:record/record.dart';

class AudioRecordingService {
  static final AudioRecorder _recorder = AudioRecorder();

  static Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  static Future<void> startRecording() async {
    await _recorder.start(
      const RecordConfig(),
      path: 'panic_recording.m4a',
    );

    print('Recording file: panic_recording.m4a');
  }

  static Future<String?> stopRecording() async {
    return await _recorder.stop();
  }
}
