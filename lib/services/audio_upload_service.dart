import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class AudioUploadService {
  static String getPublicUrl(String fileName) {
  return _supabase.storage
      .from('panic-audio')
      .getPublicUrl(fileName);
}
  static final _supabase = Supabase.instance.client;

  static String generateFileName(String alertId) {
    return '$alertId.m4a';
  }

  static Future<Uint8List> fetchBlobBytes(String blobUrl) async {
    final response = await http.get(Uri.parse(blobUrl));

    return response.bodyBytes;
  }

  static Future<String> uploadBlobUrl({
    required String blobUrl,
    required String fileName,
  }) async {
    final bytes = await fetchBlobBytes(blobUrl);

    await uploadBytes(
      bytes: bytes,
      fileName: fileName,
    );

    return fileName;
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


