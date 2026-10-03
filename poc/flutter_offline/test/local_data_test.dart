import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_offline_poc/local_data.dart';
import 'package:nexo_offline_poc/money.dart';

class TestApi implements FinanceApi {
  final accounts = <String, Account>{};
  final movements = <String, Movement>{};
  bool failAccount = false;
  bool failMovement = false;
  bool loseNextMovementReply = false;
  int movementEffects = 0;

  @override
  Future<void> createAccount(Account account) async {
    if (failAccount) throw const SocketException('offline');
    final existing = accounts[account.id];
    if (existing != null &&
        (existing.name != account.name || existing.openingCents != account.openingCents)) {
      throw const HttpException('409');
    }
    accounts.putIfAbsent(account.id, () => account);
  }

  @override
  Future<void> createMovement(String accountId, Movement movement) async {
    if (failMovement) throw const SocketException('offline');
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
    return movements.values.where((m) => m.accountIdForTest == accountId).fold(
      account.openingCents,
      (sum, movement) => sum +
          (movement.type == MovementType.income ? movement.cents : -movement.cents),
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
    expect(formatCop(123456), r'$1.234,56');
  });

  test('recupera cuenta y 100 movimientos pendientes tras reabrir el archivo', () async {
    final first = NexoRepository(store, api);
    await first.load();
    await first.createAccount(id: 'acct-1', name: 'Cuenta sintética', openingCents: 10000000);
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
    expect(reopened.state.movements.every((m) => m.status == SyncStatus.pending), isTrue);
    expect(reopened.state.localBalanceCents, 10000100);
    expect(reopened.state.movements.first.cents, 101);
  });

  test('estado de error y replay tras respuesta perdida sobreviven a reiniciar el repositorio', () async {
    final first = NexoRepository(store, api);
    await first.load();
    await first.createAccount(id: 'acct-retry', name: 'Cuenta', openingCents: 0);
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

  test('si cuenta falla offline, movimientos quedan locales pendientes y reintentan', () async {
    final repository = NexoRepository(store, api);
    await repository.load();
    await repository.createAccount(id: 'offline-acct', name: 'Cuenta', openingCents: 0);
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
