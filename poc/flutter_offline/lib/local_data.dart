import 'dart:convert';
import 'dart:io';

enum MovementType { income, expense }

enum SyncStatus { pending, synced, error }

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.openingCents,
    this.status = SyncStatus.pending,
  });

  final String id;
  final String name;
  final int openingCents;
  final SyncStatus status;

  Map<String, Object> toJson() => {
        'id': id,
        'name': name,
        'openingCents': openingCents,
        'status': status.name,
      };

  factory Account.fromJson(Map<String, dynamic> json, {bool legacy = false}) => Account(
        id: legacy ? 'legacy-account-v1' : json['id'] as String,
        name: json['name'] as String,
        openingCents: json['openingCents'] as int,
        status: legacy
            ? SyncStatus.pending
            : SyncStatus.values.byName(json['status'] as String),
      );

  Account withStatus(SyncStatus value) => Account(
        id: id,
        name: name,
        openingCents: openingCents,
        status: value,
      );
}

class Movement {
  const Movement({
    required this.id,
    required this.description,
    required this.cents,
    required this.type,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String description;
  final int cents;
  final MovementType type;
  final DateTime createdAt;
  final SyncStatus status;

  Map<String, Object> toJson() => {
        'id': id,
        'description': description,
        'cents': cents,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };

  factory Movement.fromJson(Map<String, dynamic> json) => Movement(
        id: json['id'] as String,
        description: json['description'] as String,
        cents: json['cents'] as int,
        type: MovementType.values.byName(json['type'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: SyncStatus.values.byName(json['status'] as String),
      );

  Movement withStatus(SyncStatus value) => Movement(
        id: id,
        description: description,
        cents: cents,
        type: type,
        createdAt: createdAt,
        status: value,
      );
}

class Snapshot {
  const Snapshot({
    this.account,
    this.movements = const [],
    this.serverBalanceCents,
    this.revision = 0,
  });

  final Account? account;
  final List<Movement> movements;
  final int? serverBalanceCents;
  final int revision;

  int get localBalanceCents => movements.fold(
        account?.openingCents ?? 0,
        (balance, item) => balance +
            (item.type == MovementType.income ? item.cents : -item.cents),
      );

  Map<String, Object?> toJson() => {
        'version': 2,
        'revision': revision,
        'account': account?.toJson(),
        'movements': movements.map((item) => item.toJson()).toList(),
        'serverBalanceCents': serverBalanceCents,
      };

  factory Snapshot.fromJson(Map<String, dynamic> json) {
    final version = json['version'];
    if (version != 1 && version != 2) {
      throw const FormatException('Versión de almacenamiento desconocida.');
    }
    final rawAccount = json['account'];
    return Snapshot(
      account: rawAccount == null
          ? null
          : Account.fromJson(
              Map<String, dynamic>.from(rawAccount as Map),
              legacy: version == 1,
            ),
      movements: (json['movements'] as List<dynamic>)
          .map((item) => Movement.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
      serverBalanceCents: json['serverBalanceCents'] as int?,
      revision: version == 1 ? 0 : json['revision'] as int,
    );
  }

  Snapshot copyWith({
    Account? account,
    List<Movement>? movements,
    int? serverBalanceCents,
    bool clearServerBalance = false,
    int? revision,
  }) =>
      Snapshot(
        account: account ?? this.account,
        movements: movements ?? this.movements,
        serverBalanceCents:
            clearServerBalance ? null : serverBalanceCents ?? this.serverBalanceCents,
        revision: revision ?? this.revision,
      );
}

class LocalStore {
  LocalStore(this.filePath);

  final String filePath;
  File get _file => File(filePath);

  Future<Snapshot> read() async {
    final parent = _file.parent;
    if (!await parent.exists()) return const Snapshot();
    final base = _file.uri.pathSegments.last;
    final candidates = <File>[];
    await for (final entry in parent.list()) {
      if (entry is File &&
          (entry.path == filePath ||
              RegExp('^${RegExp.escape(base)}\\.r[0-9]+\\.json$')
                  .hasMatch(entry.uri.pathSegments.last))) {
        candidates.add(entry);
      }
    }
    if (candidates.isEmpty) return const Snapshot();
    Snapshot? latest;
    for (final candidate in candidates) {
      final snapshot = Snapshot.fromJson(
        jsonDecode(await candidate.readAsString()) as Map<String, dynamic>,
      );
      if (latest == null || snapshot.revision > latest.revision) latest = snapshot;
    }
    return latest!;
  }

  Future<void> write(Snapshot snapshot) async {
    final file = _file;
    await file.parent.create(recursive: true);
    final destination = File('$filePath.r${snapshot.revision}.json');
    final temp = File('${destination.path}.tmp');
    await temp.writeAsString(jsonEncode(snapshot.toJson()), flush: true);
    await temp.rename(destination.path);
    final base = file.uri.pathSegments.last;
    await for (final entry in file.parent.list()) {
      if (entry is File &&
          entry.path != destination.path &&
          RegExp('^${RegExp.escape(base)}\\.r[0-9]+\\.json$')
              .hasMatch(entry.uri.pathSegments.last)) {
        try {
          await entry.delete();
        } on FileSystemException {
          // A committed newer revision remains readable if old-file cleanup fails.
        }
      }
    }
  }
}

abstract interface class FinanceApi {
  Future<void> createAccount(Account account);
  Future<void> createMovement(String accountId, Movement movement);
  Future<int> readBalance(String accountId);
}

class NexoRepository {
  NexoRepository(this.store, this.api);

  final LocalStore store;
  final FinanceApi api;
  Snapshot state = const Snapshot();

  Future<void> load() async => state = await store.read();

  Future<void> createAccount({required String id, required String name, required int openingCents}) async {
    if (state.account != null) throw StateError('La cuenta ya existe.');
    final normalized = name.trim();
    if (id.isEmpty || normalized.isEmpty || openingCents < 0) {
      throw ArgumentError('Revisa el ID, el nombre y el saldo inicial.');
    }
    await _save(state.copyWith(
      account: Account(id: id, name: normalized, openingCents: openingCents),
      clearServerBalance: true,
    ));
  }

  Future<void> addMovement({
    required String id,
    required String description,
    required int cents,
    required MovementType type,
    DateTime? createdAt,
  }) async {
    if (state.account == null) throw StateError('Primero crea una cuenta.');
    final label = description.trim();
    if (id.isEmpty || label.isEmpty || cents <= 0 || state.movements.any((m) => m.id == id)) {
      throw ArgumentError('Movimiento inválido o ID repetido.');
    }
    await _save(state.copyWith(movements: [
      Movement(
        id: id,
        description: label,
        cents: cents,
        type: type,
        createdAt: createdAt ?? DateTime.now().toUtc(),
        status: SyncStatus.pending,
      ),
      ...state.movements,
    ]));
  }

  Future<void> sync() async {
    final account = state.account;
    if (account == null) return;
    if (account.status != SyncStatus.synced) {
      try {
        await api.createAccount(account);
        await _save(state.copyWith(account: account.withStatus(SyncStatus.synced)));
      } catch (_) {
        await _save(state.copyWith(account: account.withStatus(SyncStatus.error)));
        return;
      }
    }
    for (final item in List<Movement>.of(state.movements)) {
      if (item.status == SyncStatus.synced) continue;
      try {
        await api.createMovement(account.id, item);
        await _replace(item.withStatus(SyncStatus.synced));
      } catch (_) {
        await _replace(item.withStatus(SyncStatus.error));
      }
    }
    try {
      final balance = await api.readBalance(account.id);
      await _save(state.copyWith(serverBalanceCents: balance));
    } on HttpException {
      // The local ledger remains usable while the API is unavailable.
    } on SocketException {
      // The local ledger remains usable while the API is unavailable.
    }
  }

  Future<void> _replace(Movement item) => _save(state.copyWith(
        movements: state.movements.map((m) => m.id == item.id ? item : m).toList(),
      ));

  Future<void> _save(Snapshot next) async {
    final committed = next.copyWith(revision: state.revision + 1);
    await store.write(committed);
    state = committed;
  }
}
