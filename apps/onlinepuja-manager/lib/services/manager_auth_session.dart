import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Executive Authentication & Security Session for OnlinePuja Manager
class ManagerAuthSession extends ChangeNotifier {
  static const String _prefToken = 'op_manager_token';
  static const String _prefEmail = 'op_manager_email';
  static const String _prefName = 'op_manager_name';
  static const String _prefPin = 'op_manager_pin';
  static const String _prefIsLocked = 'op_manager_is_locked';

  static const String loginEndpoint = 'https://onlinepuja.live/api/manager/login';

  bool _initialized = false;
  bool _isAuthenticated = false;
  bool _isLocked = false;
  String? _token;
  String _email = 'admin@onlinepuja.live';
  String _name = 'Online Puja Admin';
  String? _masterPin;

  bool get isInitialized => _initialized;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLocked => _isLocked;
  String? get token => _token;
  String get email => _email;
  String get name => _name;
  bool get hasPin => _masterPin != null && _masterPin!.isNotEmpty;

  ManagerAuthSession() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_prefToken);
      _email = prefs.getString(_prefEmail) ?? 'admin@onlinepuja.live';
      _name = prefs.getString(_prefName) ?? 'Online Puja Admin';
      _masterPin = prefs.getString(_prefPin);
      _isLocked = prefs.getBool(_prefIsLocked) ?? (_token != null);

      _isAuthenticated = _token != null && _token!.isNotEmpty;
    } catch (_) {
      _isAuthenticated = false;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// Login with Superadmin Email & Password
  Future<({bool success, String message})> loginWithPassword({
    required String email,
    required String password,
    String? setPin,
  }) async {
    try {
      final client = http.Client();
      http.Response res;
      try {
        res = await client.post(
          Uri.parse(loginEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'email': email.trim(),
            'password': password,
          }),
        ).timeout(const Duration(seconds: 25));
      } finally {
        client.close();
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(res.body);
      } catch (e) {
        return (
          success: false,
          message: 'Server returned non-JSON response (HTTP ${res.statusCode}).',
        );
      }

      final Map<dynamic, dynamic> data = (decoded is Map) ? decoded : {};

      if (res.statusCode == 200 && data['success'] == true) {
        _token = data['token']?.toString() ?? 'session_ok';
        final userRaw = data['user'];
        if (userRaw is Map) {
          _email = userRaw['email']?.toString() ?? email;
          _name = userRaw['name']?.toString() ?? 'Online Puja Admin';
        }

        if (setPin != null && setPin.length == 4) {
          _masterPin = setPin;
        }

        _isAuthenticated = true;
        _isLocked = false;

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefToken, _token!);
          await prefs.setString(_prefEmail, _email);
          await prefs.setString(_prefName, _name);
          await prefs.setBool(_prefIsLocked, false);
          if (_masterPin != null) {
            await prefs.setString(_prefPin, _masterPin!);
          }
        } catch (storageErr) {
          debugPrint('SharedPreferences save warning: $storageErr');
        }

        notifyListeners();
        return (
          success: true,
          message: data['message']?.toString() ?? 'Authenticated 🙏',
        );
      } else {
        final msg = data['message']?.toString() ??
            data['error']?.toString() ??
            'Authentication failed (HTTP ${res.statusCode})';
        return (success: false, message: msg);
      }
    } catch (e) {
      debugPrint('Manager login exception: $e');
      return (
        success: false,
        message: 'Connection error ($e). Please check your internet connection.',
      );
    }
  }

  /// Unlock with 4-Digit Quick PIN
  bool unlockWithPin(String pin) {
    if (_masterPin != null && _masterPin == pin) {
      _isLocked = false;
      SharedPreferences.getInstance().then((p) => p.setBool(_prefIsLocked, false));
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Set or update the 4-digit Master Quick PIN
  Future<void> setMasterPin(String pin) async {
    _masterPin = pin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefPin, pin);
    notifyListeners();
  }

  /// Instant lock command center
  void lockApp() {
    _isLocked = true;
    SharedPreferences.getInstance().then((p) => p.setBool(_prefIsLocked, true));
    notifyListeners();
  }

  /// Full executive logout
  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;
    _isLocked = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefToken);
    await prefs.remove(_prefIsLocked);
    notifyListeners();
  }
}
