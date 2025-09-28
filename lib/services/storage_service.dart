import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Remember Me functionality
  Future<void> saveLoginCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (rememberMe) {
      await _prefs?.setString('saved_email', email);
      await _prefs?.setString('saved_password', password);
      await _prefs?.setBool('remember_me', true);
    } else {
      await _prefs?.remove('saved_email');
      await _prefs?.remove('saved_password');
      await _prefs?.setBool('remember_me', false);
    }
  }

  Future<Map<String, dynamic>> getLoginCredentials() async {
    final email = _prefs?.getString('saved_email') ?? '';
    final password = _prefs?.getString('saved_password') ?? '';
    final rememberMe = _prefs?.getBool('remember_me') ?? false;

    return {'email': email, 'password': password, 'rememberMe': rememberMe};
  }

  Future<void> clearLoginCredentials() async {
    await _prefs?.remove('saved_email');
    await _prefs?.remove('saved_password');
    await _prefs?.setBool('remember_me', false);
  }

  // Auto-login functionality
  Future<bool> hasValidCredentials() async {
    final credentials = await getLoginCredentials();
    return credentials['rememberMe'] == true &&
        credentials['email'].isNotEmpty &&
        credentials['password'].isNotEmpty;
  }

  // User session management
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required bool isLoggedIn,
  }) async {
    await _prefs?.setString('user_id', userId);
    await _prefs?.setString('user_email', email);
    await _prefs?.setBool('is_logged_in', isLoggedIn);
  }

  Future<Map<String, dynamic>> getUserSession() async {
    final userId = _prefs?.getString('user_id') ?? '';
    final email = _prefs?.getString('user_email') ?? '';
    final isLoggedIn = _prefs?.getBool('is_logged_in') ?? false;

    return {'userId': userId, 'email': email, 'isLoggedIn': isLoggedIn};
  }

  Future<void> clearUserSession() async {
    await _prefs?.remove('user_id');
    await _prefs?.remove('user_email');
    await _prefs?.setBool('is_logged_in', false);
  }

  Future<bool> isUserLoggedIn() async {
    final session = await getUserSession();
    return session['isLoggedIn'] == true && session['userId'].isNotEmpty;
  }
}
