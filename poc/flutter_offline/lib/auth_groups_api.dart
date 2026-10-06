import 'dart:async';
import 'dart:convert';
import 'dart:io';

class AuthGroupsException implements Exception {
  const AuthGroupsException(this.statusCode, this.message, {this.temporary = false});

  final int? statusCode;
  final String message;
  final bool temporary;

  @override
  String toString() => message;
}

class NexoGroup {
  const NexoGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.revision,
    required this.canChangeMode,
  });

  final String id;
  final String name;
  final String type;
  final String revision;
  final bool canChangeMode;

  factory NexoGroup.fromJson(Map<String, dynamic> json) => NexoGroup(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        revision: json['revision'] as String,
        canChangeMode: json['canChangeMode'] == true,
      );
}

class AuthGroupsApi {
  AuthGroupsApi(String baseUrl)
      : _baseUrl = Uri.parse(baseUrl),
        _client = HttpClient()..connectionTimeout = const Duration(seconds: 3);

  final Uri _baseUrl;
  final HttpClient _client;
  String? _token;
  bool get hasSession => _token != null;

  Future<Map<String, dynamic>> register(String email, String password) =>
      _credentialRequest('/auth/register', email, password);

  Future<Map<String, dynamic>> login(String email, String password) =>
      _credentialRequest('/auth/login', email, password);

  Future<Map<String, dynamic>> _credentialRequest(
      String path, String email, String password) async {
    final result = await _request('POST', path, body: {'email': email, 'password': password});
    final payload = _map(result);
    final token = payload['token'];
    if (token is! String || token.isEmpty) {
      throw const AuthGroupsException(null, 'La API devolvió una sesión inválida.');
    }
    _token = token;
    return payload;
  }

  Future<void> logout() async {
    if (_token == null) return;
    await _request('POST', '/auth/logout');
    _token = null;
  }

  void discardSession() => _token = null;

  Future<NexoGroup> createGroup(String name, String type) async =>
      NexoGroup.fromJson(_map(await _request('POST', '/groups', body: {
        'name': name,
        'type': type,
      })));

  Future<List<NexoGroup>> listGroups() async {
    final payload = await _request('GET', '/groups');
    if (payload is! List) {
      throw const AuthGroupsException(null, 'La API devolvió una lista inválida.');
    }
    return payload.map((item) => NexoGroup.fromJson(_map(item))).toList();
  }

  Future<Map<String, dynamic>> changeMode({
    required String groupId,
    required String destination,
    required String expectedRevision,
    required String idempotencyKey,
  }) async => _map(await _request(
        'PATCH',
        '/groups/${Uri.encodeComponent(groupId)}/mode',
        body: {'destination': destination, 'expectedRevision': expectedRevision},
        idempotencyKey: idempotencyKey,
      ));

  Future<Object?> _request(String method, String path,
      {Map<String, Object>? body, String? idempotencyKey}) async {
    final requestToken = _token;
    try {
      final request = await _client.openUrl(method, _baseUrl.resolve(path))
          .timeout(const Duration(seconds: 8));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
      if (requestToken != null) request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $requestToken');
      if (idempotencyKey != null) request.headers.set('Idempotency-Key', idempotencyKey);
      if (body != null) request.write(jsonEncode(body));
      final response = await request.close().timeout(const Duration(seconds: 8));
      final text = await response.transform(utf8.decoder).join().timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (response.statusCode == HttpStatus.unauthorized && _token == requestToken) _token = null;
        throw AuthGroupsException(response.statusCode, _message(text, response.statusCode),
            temporary: response.statusCode >= 500 || response.statusCode == 408 || response.statusCode == 429);
      }
      if (text.isEmpty) return null;
      try {
        return jsonDecode(text);
      } on FormatException {
        throw const AuthGroupsException(null, 'La API devolvió una respuesta inválida.');
      }
    } on AuthGroupsException {
      rethrow;
    } on SocketException {
      throw const AuthGroupsException(null, 'No hay conexión con la API.', temporary: true);
    } on TimeoutException {
      throw const AuthGroupsException(null, 'La API tardó demasiado. Puedes reintentar.', temporary: true);
    } on HttpException {
      throw const AuthGroupsException(null, 'No se pudo completar la solicitud.', temporary: true);
    }
  }

  String _message(String body, int status) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        final message = json['message'];
        if (message is String) return message;
        if (message is List) return message.whereType<String>().join(' ');
      }
    } on FormatException {
      // Un fallback seguro mantiene visible el estado HTTP.
    }
    return switch (status) {
      400 => 'La solicitud fue rechazada. Revisa los datos.',
      401 => 'La sesión expiró o no es válida. Inicia sesión de nuevo.',
      403 => 'No tienes permiso para esta acción.',
      409 => 'El grupo cambió. Actualiza la lista y confirma de nuevo.',
      _ => 'La API respondió con error HTTP $status.',
    };
  }

  Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const AuthGroupsException(null, 'La API devolvió una respuesta inválida.');
  }

  void close() {
    _token = null;
    _client.close(force: true);
  }
}
