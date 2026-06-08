import 'package:supabase_flutter/supabase_flutter.dart';

class TrustedContactService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> getTrustedContacts() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final response = await _supabase
        .from('trusted_contacts')
        .select()
        .eq('user_id', user.id);

    return List<Map<String, dynamic>>.from(response);
  }
}
