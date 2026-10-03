import 'dart:convert';
import 'dart:io';

import 'local_data.dart';

class HttpFinanceApi implements FinanceApi {
  HttpFinanceApi(String baseUrl) : _baseUrl = Uri.parse(baseUrl);

  final Uri _baseUrl;
  final HttpClient _client = HttpClient()..connectionTimeout = const Duration(seconds: 3);

  @override
  Future<void> createAccount(Account account) async {
    await _request('POST', '/accounts', {
      'id': account.id,
      'name': account.name,
      'openingCents': account.openingCents.toString(),
    });
  }

  @override
  Future<void> createMovement(String accountId, Movement movement) async {
    await _request('POST', '/accounts/${Uri.encodeComponent(accountId)}/movements', {
      'id': movement.id,
      'type': movement.type.name,
      'description': movement.description,
      'amountCents': movement.cents.toString(),
      'occurredAt': movement.createdAt.toUtc().toIso8601String(),
    });
  }

  @override
  Future<int> readBalance(String accountId) async {
    final response = await _request(
      'GET',
      '/accounts/${Uri.encodeComponent(accountId)}',
    );
    final cents = (response as Map<String, dynamic>)['balanceCents'];
    if (cents is! String || !RegExp(r'^-?[0-9]+$').hasMatch(cents)) {
      throw const FormatException('La API devolvió un saldo inválido.');
    }
    return int.parse(cents);
  }

  Future<Object?> _request(String method, String path, [Map<String, Object>? body]) async {
    final request = await _client.openUrl(method, _baseUrl.resolve(path));
    request.headers.contentType = ContentType.json;
    if (body != null) request.write(jsonEncode(body));
    final response = await request.close().timeout(const Duration(seconds: 8));
    final responseText = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('API ${response.statusCode}: $responseText');
    }
    return responseText.isEmpty ? null : jsonDecode(responseText);
  }

  void close() => _client.close(force: true);
}
