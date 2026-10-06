import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_offline_poc/api_client.dart';
import 'package:nexo_offline_poc/local_data.dart';

void main() {
  late HttpServer server;
  late HttpFinanceApi api;
  final received = <Map<String, dynamic>>[];
  int? rejectionStatus;
  String? rejectionMessage;

  setUp(() async {
    received.clear();
    rejectionStatus = null;
    rejectionMessage = null;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    unawaited(server.forEach((request) async {
      final body = request.method == 'GET'
          ? <String, dynamic>{}
          : jsonDecode(await utf8.decoder.bind(request).join())
              as Map<String, dynamic>;
      received
          .add({'method': request.method, 'path': request.uri.path, ...body});
      request.response.headers.contentType = ContentType.json;
      if (request.method == 'GET') {
        request.response.write(jsonEncode({'balanceCents': '10765433'}));
      } else {
        request.response.statusCode = rejectionStatus ?? HttpStatus.created;
        request.response.write(rejectionMessage == null
            ? '{}'
            : jsonEncode({'message': rejectionMessage}));
      }
      await request.response.close();
    }));
    api = HttpFinanceApi('http://${server.address.address}:${server.port}');
  });

  tearDown(() async {
    api.close();
    await server.close(force: true);
  });

  test('envía IDs estables y centavos como cadenas, y lee el balance exacto',
      () async {
    await api.createAccount(const Account(
      id: 'acct-1',
      name: 'Cuenta',
      openingCents: 10000000,
    ));
    await api.createMovement(
        'acct-1',
        Movement(
          id: 'op-1',
          description: 'Compra',
          cents: 1234567,
          type: MovementType.expense,
          createdAt: DateTime.utc(2026, 10, 3),
          status: SyncStatus.pending,
        ));
    final balance = await api.readBalance('acct-1');

    expect(received[0]['path'], '/accounts');
    expect(received[0]['openingCents'], '10000000');
    expect(received[1]['path'], '/accounts/acct-1/movements');
    expect(received[1]['amountCents'], '1234567');
    expect(received[1]['type'], 'expense');
    expect(balance, 10765433);
  });

  test('expone el código y la causa de un rechazo 400/409', () async {
    rejectionStatus = HttpStatus.conflict;
    rejectionMessage = 'El ID ya tiene otro contenido.';
    await expectLater(
      api.createAccount(const Account(
        id: 'acct-conflict',
        name: 'Cuenta',
        openingCents: 0,
      )),
      throwsA(isA<SyncApiException>()
          .having((error) => error.statusCode, 'statusCode', 409)
          .having((error) => error.message, 'message',
              'El ID ya tiene otro contenido.')
          .having((error) => error.isRejected, 'isRejected', true)),
    );
  });
}
