import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class AuthInitRepository extends GetxService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Waits until currentUser is not null
  Future<AuthInitRepository> init() async {
    if (_client.auth.currentUser == null) {
      // Listen to auth changes until a user is available
      await _client.auth.onAuthStateChange.firstWhere(
        (data) => data.session?.user != null,
      );
    }
    return this;
  }

  /// Optionally expose the user UID
  String get userId => _client.auth.currentUser?.id ?? '';
}
