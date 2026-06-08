import 'package:supabase_flutter/supabase_flutter.dart';

class PanicAlertService {
  static final _supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>> createAlert({
    required double latitude,
    required double longitude,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final response = await _supabase
        .from('panic_alerts')
        .insert({
          'user_id': user.id,
          'latitude': latitude,
          'longitude': longitude,
        })
        .select()
        .single();

    return response;
  }
}
