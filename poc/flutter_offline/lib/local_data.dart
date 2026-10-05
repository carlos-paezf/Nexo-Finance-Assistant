import 'dart:convert';
import 'dart:io';

enum MovementType { income, expense }

enum SyncStatus { pending, synced, error }

class SyncApiException implements Exception {
  const SyncApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  bool get isRejected => statusCode == 400 || statusCode == 409;
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.openingCents,
    this.status = SyncStatus.pending,
    this.syncError,
    this.syncRejected = false,
  });

  final String id;
  final String name;
  final int openingCents;
  final SyncStatus status;
  final String? syncError;
  final bool syncRejected;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'openingCents': openingCents,
        'status': status.name,
        'syncError': syncError,
        'syncRejected': syncRejected,
      };

  factory Account.fromJson(Map<String, dynamic> json, {bool legacy = false}) =>
      Account(
        id: legacy ? 'legacy-account-v1' : json['id'] as String,
        name: json['name'] as String,
        openingCents: json['openingCents'] as int,
        status: legacy
            ? SyncStatus.pending
            : SyncStatus.values.byName(json['status'] as String),
        syncError: legacy ? null : json['syncError'] as String?,
        syncRejected: legacy ? false : json['syncRejected'] as bool? ?? false,
      );

  Account withStatus(SyncStatus value,
          {String? error, bool rejected = false}) =>
      Account(
        id: id,
        name: name,
        openingCents: openingCents,
        status: value,
        syncError: error,
        syncRejected: rejected,
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
    this.syncError,
    this.syncRejected = false,
  });

  final String id;
  final String description;
  final int cents;
  final MovementType type;
  final DateTime createdAt;
  final SyncStatus status;
  final String? syncError;
  final bool syncRejected;

  Map<String, Object?> toJson() => {
        'id': id,
        'description': description,
        'cents': cents,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'syncError': syncError,
        'syncRejected': syncRejected,
      };

  factory Movement.fromJson(Map<String, dynamic> json) => Movement(
        id: json['id'] as String,
        description: json['description'] as String,
        cents: json['cents'] as int,
        type: MovementType.values.byName(json['type'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: SyncStatus.values.byName(json['status'] as String),
        syncError: json['syncError'] as String?,
        syncRejected: json['syncRejected'] as bool? ?? false,
      );

  Movement withStatus(SyncStatus value,
          {String? error, bool rejected = false}) =>
      Movement(
        id: id,
        description: description,
        cents: cents,
        type: type,
        createdAt: createdAt,
        status: value,
        syncError: error,
        syncRejected: rejected,
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
        (balance, item) =>
            balance +
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
          .map((item) =>
              Movement.fromJson(Map<String, dynamic>.from(item as Map)))
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
        serverBalanceCents: clearServerBalance
            ? null
            : serverBalanceCents ?? this.serverBalanceCents,
        revision: revision ?? this.revision,
      );
}

class LocalStore {
  LocalStore(this.filePath);

  final String filePath;
  File get _file => File(filePath);

  bool _isRevision(File candidate, String base) {
    final name = candidate.uri.pathSegments.last;
    final prefix = '$base.r';
    if (!name.startsWith(prefix) || !name.endsWith('.json')) return false;
    return int.tryParse(name.substring(prefix.length, name.length - 5)) != null;
  }

  Future<Snapshot> read() async {
    final parent = _file.parent;
    if (!await parent.exists()) return const Snapshot();
    final base = _file.uri.pathSegments.last;
    final candidates = <File>[];
    await for (final entry in parent.list()) {
      if (entry is File &&
          (entry.path == filePath || _isRevision(entry, base))) {
        candidates.add(entry);
      }
    }
    if (candidates.isEmpty) return const Snapshot();
    Snapshot? latest;
    for (final candidate in candidates) {
      final snapshot = Snapshot.fromJson(
        jsonDecode(await candidate.readAsString()) as Map<String, dynamic>,
      );
      if (latest == null || snapshot.revision > latest.revision)
        latest = snapshot;
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
          entry.uri.pathSegments.last != destination.uri.pathSegments.last &&
          _isRevision(entry, base)) {
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

  Future<void> createAccount(
      {required String id,
      required String name,
      required int openingCents}) async {
    if (state.account != null) throw StateError('La cuenta ya existe.');
    final normalized = name.trim();
    if (!_validId(id) ||
        normalized.isEmpty ||
        normalized.length > 80 ||
        openingCents < 0 ||
        openingCents > _maxPgBigint) {
      throw ArgumentError(
          'El ID debe tener hasta 80 caracteres válidos, el nombre entre 1 y 80 caracteres y el saldo entre 0 y el máximo permitido.');
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
    if (!_validId(id) ||
        label.isEmpty ||
        label.length > 200 ||
        cents <= 0 ||
        cents > _maxPgBigint ||
        state.movements.any((m) => m.id == id)) {
      throw ArgumentError(
          'El ID debe tener hasta 80 caracteres válidos, la descripción entre 1 y 200 caracteres y el importe debe ser positivo y válido.');
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

  Future<void> correctRejectedMovement({
    required String previousId,
    required String id,
    required String description,
    required int cents,
  }) async {
    Movement? previous;
    for (final item in state.movements) {
      if (item.id == previousId) previous = item;
    }
    if (previous == null || !previous.syncRejected) {
      throw StateError(
          'Solo puedes corregir movimientos rechazados por la API.');
    }
    final label = description.trim();
    if (!_validId(id) ||
        label.isEmpty ||
        label.length > 200 ||
        cents <= 0 ||
        cents > _maxPgBigint ||
        state.movements.any((item) => item.id == id && item.id != previousId)) {
      throw ArgumentError(
          'Revisa la descripción y el importe antes de guardar.');
    }
    await _save(state.copyWith(
        movements: state.movements
            .map(
              (item) => item.id == previousId
                  ? Movement(
                      id: id,
                      description: label,
                      cents: cents,
                      type: item.type,
                      createdAt: item.createdAt,
                      status: SyncStatus.pending,
                    )
                  : item,
            )
            .toList()));
  }

  Future<void> correctRejectedAccount({
    required String id,
    required String name,
    required int openingCents,
  }) async {
    final account = state.account;
    final normalized = name.trim();
    if (account == null || !account.syncRejected) {
      throw StateError('Solo puedes corregir una cuenta rechazada por la API.');
    }
    if (!_validId(id) ||
        normalized.isEmpty ||
        normalized.length > 80 ||
        openingCents < 0 ||
        openingCents > _maxPgBigint) {
      throw ArgumentError(
          'Revisa el ID, el nombre y el saldo inicial antes de guardar.');
    }
    await _save(state.copyWith(
      account: Account(id: id, name: normalized, openingCents: openingCents),
      clearServerBalance: true,
    ));
  }

  Future<void> sync() async {
    final account = state.account;
    if (account == null || account.syncRejected) return;
    if (account.status != SyncStatus.synced) {
      try {
        await api.createAccount(account);
      } catch (error) {
        final failure = _syncFailure(error);
        await _save(state.copyWith(
            account: account.withStatus(
          SyncStatus.error,
          error: failure.$1,
          rejected: failure.$2,
        )));
        return;
      }
      await _save(
          state.copyWith(account: account.withStatus(SyncStatus.synced)));
    }
    for (final item in List<Movement>.of(state.movements)) {
      if (item.status == SyncStatus.synced || item.syncRejected) continue;
      try {
        await api.createMovement(account.id, item);
      } catch (error) {
        final failure = _syncFailure(error);
        await _replace(item.withStatus(
          SyncStatus.error,
          error: failure.$1,
          rejected: failure.$2,
        ));
        continue;
      }
      await _replace(item.withStatus(SyncStatus.synced));
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

  static const _maxPgBigint = 9223372036854775807;
  static final _idPattern = RegExp(r'^[A-Za-z0-9_-]{1,80}$');

  bool _validId(String id) => _idPattern.hasMatch(id);

  (String, bool) _syncFailure(Object error) {
    if (error is SyncApiException) return (error.message, error.isRejected);
    if (error is SocketException)
      return ('No hay conexión con la API. Se volverá a intentar.', false);
    if (error is HttpException) return (error.message, false);
    return (
      'No se pudo sincronizar. Se conservaron los datos para reintentar.',
      false
    );
  }

  Future<void> _replace(Movement item) => _save(state.copyWith(
        movements:
            state.movements.map((m) => m.id == item.id ? item : m).toList(),
      ));

  Future<void> _save(Snapshot next) async {
    final committed = next.copyWith(revision: state.revision + 1);
    await store.write(committed);
    state = committed;
  }
}
