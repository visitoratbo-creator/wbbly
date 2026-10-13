import 'dart:convert';
import 'package:http/http.dart' as http;

/// Stateless HTTP client for the PHP/PDO layer on alwaysdata.net.
/// Only auth, character creation, and equipment/progression saves go here.
class ApiClient {
  static const _base = 'https://gdvapi.alwaysdata.net/WobblyWizardsDB';

  final http.Client _http;
  String? _sessionToken;

  ApiClient({http.Client? client}) : _http = client ?? http.Client();

  String? get sessionToken => _sessionToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_sessionToken != null) 'X-WW-Session': _sessionToken!,
      };

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final res = await _http.post(
      Uri.parse('$_base/$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, utf8.decode(res.bodyBytes));
    }
    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    if (decoded is Map<String, dynamic>) {
      final tok = decoded['session_token'];
      if (tok is String && tok.isNotEmpty) _sessionToken = tok;
      return decoded;
    }
    throw const FormatException('Malformed JSON envelope');
  }

  Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) => _post('auth.php', {'op': 'register', 'username': username, 'password': password});

  Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) => _post('auth.php', {'op': 'login', 'username': username, 'password': password});

  Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> profile) =>
      _post('save_profile.php', {'profile': profile});

  Future<Map<String, dynamic>> loadProfile() => _post('load_profile.php', {});
}

class ApiException implements Exception {
  final int status;
  final String body;
  const ApiException(this.status, this.body);
  @override
  String toString() => 'ApiException($status): $body';
}