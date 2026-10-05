import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_offline_poc/local_data.dart';
import 'package:nexo_offline_poc/money.dart';

class TestApi implements FinanceApi {
  final accounts = <String, Account>{};
  final movements = <String, Movement>{};
  bool failAccount = false;
  int accountAttempts = 0;
  Object? nextAccountError;
  bool failMovement = false;
  bool loseNextMovementReply = false;
  int movementEffects = 0;
  int movementAttempts = 0;
  Object? nextMovementError;

  @override
  Future<void> createAccount(Account account) async {
    accountAttempts++;
    if (failAccount) throw const SocketException('offline');
    final error = nextAccountError;
    nextAccountError = null;
    if (error != null) throw error;
    final existing = accounts[account.id];
    if (existing != null &&
        (existing.name != account.name ||
            existing.openingCents != account.openingCents)) {
      throw const HttpException('409');
    }
    accounts.putIfAbsent(account.id, () => account);
  }

  @override
  Future<void> createMovement(String accountId, Movement movement) async {
    movementAttempts++;
    if (failMovement) throw const SocketException('offline');
    final error = nextMovementError;
    nextMovementError = null;
    if (error != null) throw error;
    if (!accounts.containsKey(accountId)) throw const HttpException('404');
    _accountByMovement[movement.id] = accountId;
    final existing = movements[movement.id];
    if (existing != null) {
      if (existing.description != movement.description ||
          existing.cents != movement.cents ||
          existing.type != movement.type ||
          existing.createdAt != movement.createdAt ||
          existing.accountIdForTest != accountId) {
        throw const HttpException('409');
      }
      return;
    }
    movements[movement.id] = movement;
    movementEffects++;
    if (loseNextMovementReply) {
      loseNextMovementReply = false;
      throw const SocketException('response lost after commit');
    }
  }

  @override
  Future<int> readBalance(String accountId) async {
    final account = accounts[accountId];
    if (account == null) throw const HttpException('404');
    return movements.values
        .where((m) => m.accountIdForTest == accountId)
        .fold<int>(
          account.openingCents,
          (sum, movement) =>
              sum +
              (movement.type == MovementType.income
                  ? movement.cents
                  : -movement.cents),
        );
  }
}

extension on Movement {
  String get accountIdForTest => _accountByMovement[id] ?? '';
}

final _accountByMovement = <String, String>{};

void main() {
  late Directory directory;
  late LocalStore store;
  late TestApi api;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('nexo-poc-');
    store = LocalStore('${directory.path}/state.json');
    api = TestApi();
    _accountByMovement.clear();
  });

  tearDown(() async => directory.delete(recursive: true));

  test('COP usa centavos enteros sin precisión implícita', () {
    expect(parseCopCents('1234,56'), '123456');
    expect(parseCopCents('0,00', allowZero: true), '0');
    expect(parseCopCents('12,345'), isNull);
    expect(parseCopCents('92233720368547758,07'), '9223372036854775807');
    expect(parseCopCents('92233720368547758,08'), isNull);
    expect(formatCop(123456), r'$1.234,56');
  });

  test('validación idéntica a la API impide encolar datos fuera de contrato',
      () async {
    final repository = NexoRepository(store, api);
    await repository.load();
    await expectLater(
      repository.createAccount(id: 'bad/id', name: 'Cuenta', openingCents: 0),
      throwsArgumentError,
    );
    await expectLater(
      repository.createAccount(id: 'acct', name: 'x' * 81, openingCents: 0),
      throwsArgumentError,
    );
    await repository.createAccount(
        id: 'acct-valid', name: 'Cuenta', openingCents: 0);
    for (final description in ['', 'x' * 201]) {
      await expectLater(
        repository.addMovement(
          id: 'op-valid',
          description: description,
          cents: 1,
          type: MovementType.income,
        ),
        throwsArgumentError,
      );
    }
    await expectLater(
      repository.addMovement(
        id: 'invalid/id',
        description: 'válido',
        cents: 1,
        type: MovementType.income,
      ),
      throwsArgumentError,
    );
    expect(repository.state.movements, isEmpty);
    expect((await store.read()).movements, isEmpty);
  });

  test(
      'rechazo 409 conserva causa y registro sin replay; corregirlo genera operación nueva',
      () async {
    final repository = NexoRepository(store, api);
    await repository.load();
    await repository.createAccount(
        id: 'acct-reject', name: 'Cuenta', openingCents: 0);
    await repository.addMovement(
      id: 'stable-op',
      description: 'Ingreso',
      cents: 12345,
      type: MovementType.income,
    );
    api.nextMovementError =
        const SyncApiException(409, 'El ID ya existe con otro contenido.');
    await repository.sync();
    final rejected = repository.state.movements.single;
    expect(rejected.status, SyncStatus.error);
    expect(rejected.syncRejected, isTrue);
    expect(rejected.syncError, contains('otro contenido'));

    final reopened = NexoRepository(LocalStore(store.filePath), api);
    await reopened.load();
    await reopened.sync();
    expect(reopened.state.movements.single.id, 'stable-op');
    expect(reopened.state.movements.single.syncError, rejected.syncError);
    expect(api.movementAttempts, 1);

    await reopened.correctRejectedMovement(
      previousId: 'stable-op',
      id: 'stable-op-fixed',
      description: 'Ingreso corregido',
      cents: 12345,
    );
    expect(reopened.state.movements.single.id, 'stable-op-fixed');
    expect(reopened.state.movements.single.status, SyncStatus.pending);
    await reopened.sync();
    expect(reopened.state.movements.single.status, SyncStatus.synced);
  });

  test('rechazo 409 de cuenta se conserva hasta corregir y cambia la clave',
      () async {
    final repository = NexoRepository(store, api);
    await repository.load();
    await repository.createAccount(
        id: 'acct-old', name: 'Cuenta', openingCents: 0);
    api.nextAccountError =
        const SyncApiException(409, 'El ID de cuenta ya existe.');
    await repository.sync();
    expect(repository.state.account!.syncRejected, isTrue);
    expect(repository.state.account!.syncError, 'El ID de cuenta ya existe.');

    final reopened = NexoRepository(LocalStore(store.filePath), api);
    await reopened.load();
    await reopened.sync();
    expect(api.accountAttempts, 1);
    expect(reopened.state.account!.id, 'acct-old');

    await reopened.correctRejectedAccount(
      id: 'acct-new',
      name: 'Cuenta corregida',
      openingCents: 1250,
    );
    await reopened.sync();
    expect(reopened.state.account!.id, 'acct-new');
    expect(reopened.state.account!.status, SyncStatus.synced);
    expect(reopened.state.account!.openingCents, 1250);
    expect(api.accountAttempts, 2);
  });

  test('error temporal reintenta mientras rechazo HTTP 400 queda retenido',
      () async {
    final repository = NexoRepository(store, api);
    await repository.load();
    await repository.createAccount(
        id: 'acct-temp', name: 'Cuenta', openingCents: 0);
    await repository.addMovement(
      id: 'op-temp',
      description: 'Gasto',
      cents: 250,
      type: MovementType.expense,
    );
    api.failMovement = true;
    await repository.sync();
    expect(repository.state.movements.single.syncRejected, isFalse);
    api.failMovement = false;
    api.nextMovementError = const SyncApiException(400, 'Importe inválido.');
    await repository.sync();
    expect(repository.state.movements.single.syncRejected, isTrue);
    expect(repository.state.movements.single.syncError, 'Importe inválido.');
  });

  test('recupera cuenta y 100 movimientos pendientes tras reabrir el archivo',
      () async {
    final first = NexoRepository(store, api);
    await first.load();
    await first.createAccount(
        id: 'acct-1', name: 'Cuenta sintética', openingCents: 10000000);
    for (var i = 0; i < 100; i++) {
      final id = 'op-$i';
      _accountByMovement[id] = 'acct-1';
      await first.addMovement(
        id: id,
        description: 'Movimiento $i',
        cents: i.isEven ? 101 : 99,
        type: i.isEven ? MovementType.income : MovementType.expense,
        createdAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: i)),
      );
    }

    final reopened = NexoRepository(LocalStore(store.filePath), api);
    await reopened.load();
    expect(reopened.state.movements, hasLength(100));
    expect(reopened.state.account!.status, SyncStatus.pending);
    expect(
        reopened.state.movements.every((m) => m.status == SyncStatus.pending),
        isTrue);
    expect(reopened.state.localBalanceCents, 10000100);
    expect(reopened.state.movements.first.cents, 99);
  });

  test(
      'estado de error y replay tras respuesta perdida sobreviven a reiniciar el repositorio',
      () async {
    final first = NexoRepository(store, api);
    await first.load();
    await first.createAccount(
        id: 'acct-retry', name: 'Cuenta', openingCents: 0);
    _accountByMovement['stable-op'] = 'acct-retry';
    await first.addMovement(
      id: 'stable-op',
      description: 'Ingreso',
      cents: 12345,
      type: MovementType.income,
      createdAt: DateTime.utc(2026, 10, 3),
    );
    api.loseNextMovementReply = true;
    await first.sync();
    expect(first.state.movements.single.status, SyncStatus.error);
    expect(api.movementEffects, 1);

    final reopened = NexoRepository(LocalStore(store.filePath), api);
    await reopened.load();
    expect(reopened.state.account!.status, SyncStatus.synced);
    expect(reopened.state.movements.single.status, SyncStatus.error);
    await reopened.sync();
    expect(reopened.state.movements.single.status, SyncStatus.synced);
    expect(reopened.state.serverBalanceCents, 12345);
    expect(api.movementEffects, 1);

    final reopenedAgain = NexoRepository(LocalStore(store.filePath), api);
    await reopenedAgain.load();
    expect(reopenedAgain.state.movements.single.status, SyncStatus.synced);
    expect(reopenedAgain.state.serverBalanceCents, 12345);
  });

  test(
      'si cuenta falla offline, movimientos quedan locales pendientes y reintentan',
      () async {
    final repository = NexoRepository(store, api);
    await repository.load();
    await repository.createAccount(
        id: 'offline-acct', name: 'Cuenta', openingCents: 0);
    await repository.addMovement(
      id: 'offline-op',
      description: 'Gasto local',
      cents: 250,
      type: MovementType.expense,
    );
    api.failAccount = true;
    await repository.sync();
    expect(repository.state.account!.status, SyncStatus.error);
    expect(repository.state.movements.single.status, SyncStatus.pending);
    final reopened = NexoRepository(LocalStore(store.filePath), api);
    await reopened.load();
    expect(reopened.state.account!.status, SyncStatus.error);
  });
}
