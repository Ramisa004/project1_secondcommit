import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class AudioUploadService {
  static final _supabase = Supabase.instance.client;

  static String generateFileName(String alertId) {
    return '$alertId.m4a';
  }

  static Future<String> uploadBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await _supabase.storage
        .from('panic-audio')
        .uploadBinary(fileName, bytes);

    print('UPLOAD READY: $fileName');
    return fileName;
  }
}


