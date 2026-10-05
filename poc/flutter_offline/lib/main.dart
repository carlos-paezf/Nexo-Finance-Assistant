import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'api_client.dart';
import 'local_data.dart';
import 'money.dart';

void main() => runApp(const NexoPocApp());

class NexoPocApp extends StatelessWidget {
  const NexoPocApp(
      {super.key,
      this.apiBaseUrl,
      this.supportDirectoryProvider,
      this.idProvider});

  final String? apiBaseUrl;
  final Future<Directory> Function()? supportDirectoryProvider;
  final String Function()? idProvider;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Nexo · prueba sin conexión',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF176B55),
            surface: const Color(0xFFF8FAF8),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAF8),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: LedgerPage(
          apiBaseUrl: apiBaseUrl,
          supportDirectoryProvider: supportDirectoryProvider,
          idProvider: idProvider,
        ),
      );
}

class LedgerPage extends StatefulWidget {
  const LedgerPage(
      {super.key,
      this.apiBaseUrl,
      this.supportDirectoryProvider,
      this.idProvider});

  final String? apiBaseUrl;
  final Future<Directory> Function()? supportDirectoryProvider;
  final String Function()? idProvider;

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountName = TextEditingController();
  final _opening = TextEditingController(text: '0');
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final _random = Random.secure();
  late final HttpFinanceApi _api = HttpFinanceApi(
    widget.apiBaseUrl ??
        const String.fromEnvironment('NEXO_API_URL',
            defaultValue: 'http://127.0.0.1:3000'),
  );
  late final Future<Directory> Function() _supportDirectory =
      widget.supportDirectoryProvider ?? getApplicationSupportDirectory;
  NexoRepository? _repository;
  MovementType _type = MovementType.expense;
  bool _busy = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    try {
      final testDirectory = Platform.environment['NEXO_DATA_DIRECTORY'];
      final directory = testDirectory == null
          ? await _supportDirectory()
          : Directory(testDirectory);
      final repository = NexoRepository(
        LocalStore('${directory.path}/nexo_offline_poc.json'),
        _api,
      );
      await repository.load();
      if (!mounted) return;
      setState(() {
        _repository = repository;
        _busy = false;
      });
      if (Platform.environment['NEXO_SYNC_ON_START'] == '1') {
        await repository.sync();
        if (mounted) setState(() {});
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _loadError = 'No se pudo abrir el almacenamiento local.';
      });
    }
  }

  int? _cents(TextEditingController controller, {bool allowZero = false}) {
    final parsed = parseCopCents(controller.text, allowZero: allowZero);
    return parsed == null ? null : int.tryParse(parsed);
  }

  int? _accountCents() => _cents(_opening, allowZero: true);

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(() => _repository!.createAccount(
          id: _newId(),
          name: _accountName.text,
          openingCents: _cents(_opening, allowZero: true)!,
        ));
  }

  Future<void> _addMovement() async {
    if (!_formKey.currentState!.validate()) return;
    final cents = _cents(_amount)!;
    final saved = await _run(() => _repository!.addMovement(
          id: _newId(),
          description: _description.text,
          cents: cents,
          type: _type,
        ));
    if (saved && mounted && _repository != null) {
      _description.clear();
      _amount.clear();
    }
  }

  String _newId() =>
      widget.idProvider?.call() ??
      '${DateTime.now().toUtc().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

  Future<bool> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error is ArgumentError
                  ? error.message.toString()
                  : 'No se guardó. Revisa los datos e inténtalo de nuevo.')),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _api.close();
    _accountName.dispose();
    _opening.dispose();
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = _repository;
    return Scaffold(
      appBar: AppBar(title: const Text('Nexo · prueba sin conexión')),
      body: _busy && repository == null
          ? const Center(
              child:
                  CircularProgressIndicator(semanticsLabel: 'Abriendo cuenta'),
            )
          : _loadError != null
              ? Center(child: Text(_loadError!))
              : SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                          children: [
                            if (repository?.state.account == null)
                              _accountForm()
                            else ...[
                              _balance(repository!.state),
                              const SizedBox(height: 20),
                              _movementForm(),
                              const SizedBox(height: 20),
                              _syncPanel(repository),
                              const SizedBox(height: 24),
                              Semantics(
                                header: true,
                                child: Text('Movimientos',
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                              ),
                              const SizedBox(height: 8),
                              if (repository.state.movements.isEmpty)
                                const Text(
                                    'Aún no hay movimientos. Registra un ingreso o un gasto.')
                              else
                                ...repository.state.movements
                                    .map(_movementTile),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _accountForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crea una cuenta',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
              'Los datos se guardan en este dispositivo. Usa información sintética.'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _accountName,
            decoration: const InputDecoration(labelText: 'Nombre de la cuenta'),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Escribe un nombre para la cuenta.'
                : value.trim().length > 80
                    ? 'Usa hasta 80 caracteres.'
                    : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _opening,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Saldo inicial (COP)'),
            validator: (value) => _accountCents() == null
                ? 'Usa COP válido, con máximo dos decimales y dentro del rango permitido.'
                : null,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _createAccount,
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text('Guardar cuenta'),
          ),
        ],
      );

  Widget _balance(Snapshot snapshot) => Semantics(
        label:
            'Saldo local ${formatCop(snapshot.localBalanceCents)} pesos colombianos',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(snapshot.account!.name,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Saldo en este dispositivo (incluye pendientes)',
                style: Theme.of(context).textTheme.bodyMedium),
            Text(formatCop(snapshot.localBalanceCents),
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(snapshot.serverBalanceCents == null
                ? 'Saldo confirmado por API: aún no consultado'
                : 'Saldo confirmado por API: ${formatCop(snapshot.serverBalanceCents!)}'),
          ],
        ),
      );

  Widget _movementForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text('Nuevo movimiento',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 12),
          SegmentedButton<MovementType>(
            segments: const [
              ButtonSegment(value: MovementType.income, label: Text('Ingreso')),
              ButtonSegment(value: MovementType.expense, label: Text('Gasto')),
            ],
            selected: {_type},
            onSelectionChanged: (selection) =>
                setState(() => _type = selection.first),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Descripción'),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Escribe una descripción.'
                : value.trim().length > 200
                    ? 'Usa hasta 200 caracteres.'
                    : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Importe (COP)',
              helperText: 'Hasta dos decimales; por ejemplo, 1234,56',
            ),
            validator: (value) => _cents(_amount) == null
                ? 'Ingresa un importe positivo en COP, con hasta dos decimales y dentro del rango permitido.'
                : null,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _addMovement,
            icon: const Icon(Icons.add),
            label: Text(
                'Guardar ${_type == MovementType.income ? 'ingreso' : 'gasto'}'),
          ),
        ],
      );

  Widget _syncPanel(NexoRepository repository) {
    final movements = repository.state.movements;
    final account = repository.state.account!;
    final pending = (account.status == SyncStatus.pending ? 1 : 0) +
        movements.where((m) => m.status == SyncStatus.pending).length;
    final errors = (account.status == SyncStatus.error ? 1 : 0) +
        movements.where((m) => m.status == SyncStatus.error).length;
    final retryable =
        (account.status == SyncStatus.error && !account.syncRejected ? 1 : 0) +
            (account.syncRejected
                ? 0
                : movements
                    .where((m) =>
                        m.status == SyncStatus.pending ||
                        (m.status == SyncStatus.error && !m.syncRejected))
                    .length);
    final synced = (account.status == SyncStatus.synced ? 1 : 0) +
        movements.where((m) => m.status == SyncStatus.synced).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sincronización', style: Theme.of(context).textTheme.titleLarge),
        Text('$pending pendientes · $synced sincronizados · $errors con error'),
        if (account.syncError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Semantics(
              liveRegion: true,
              child: Text(
                account.syncRejected
                    ? 'La API rechazó la cuenta (400/409): ${account.syncError}'
                    : 'Error temporal de la cuenta: ${account.syncError}',
                key: const ValueKey('account-sync-error'),
              ),
            ),
          ),
        if (account.syncRejected)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _busy ? null : _correctAccount,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Corregir cuenta'),
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: _busy || pending + retryable == 0
                  ? null
                  : () async => _run(repository.sync),
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar con API'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
            'La cuenta y los movimientos pendientes se conservan en el dispositivo.'),
      ],
    );
  }

  Widget _movementTile(Movement movement) {
    final income = movement.type == MovementType.income;
    final status = switch (movement.status) {
      SyncStatus.pending => 'Pendiente de sincronizar',
      SyncStatus.synced => 'Sincronizado',
      SyncStatus.error when movement.syncRejected =>
        'Rechazado por la API; registro conservado',
      SyncStatus.error => 'Error temporal; se puede reintentar',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(income ? Icons.arrow_downward : Icons.arrow_upward,
              semanticLabel: income ? 'Ingreso' : 'Gasto'),
          title: Text(movement.description),
          subtitle: Text([
            '${income ? 'Ingreso' : 'Gasto'} · $status',
            if (movement.syncError != null)
              movement.syncRejected
                  ? 'Rechazo API (400/409): ${movement.syncError}'
                  : movement.syncError!,
          ].join('\n')),
          trailing: Text('${income ? '+' : '−'}${formatCop(movement.cents)}',
              textAlign: TextAlign.end),
        ),
        if (movement.syncRejected)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _busy ? null : () => _correctMovement(movement),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Corregir registro'),
            ),
          ),
      ],
    );
  }

  Future<void> _correctMovement(Movement movement) async {
    final correction = await showDialog<(String, String)?>(
      context: context,
      builder: (_) => _MovementCorrectionDialog(movement: movement),
    );
    if (correction == null || !mounted) return;
    final cents = int.parse(parseCopCents(correction.$2)!);
    await _run(() => _repository!.correctRejectedMovement(
          previousId: movement.id,
          id: _newId(),
          description: correction.$1,
          cents: cents,
        ));
    if (mounted) setState(() {});
  }

  Future<void> _correctAccount() async {
    final account = _repository?.state.account;
    if (account == null) return;
    final correction = await showDialog<(String, String)?>(
      context: context,
      builder: (_) => _AccountCorrectionDialog(account: account),
    );
    if (correction == null || !mounted) return;
    final openingCents =
        int.parse(parseCopCents(correction.$2, allowZero: true)!);
    await _run(() => _repository!.correctRejectedAccount(
          id: _newId(),
          name: correction.$1,
          openingCents: openingCents,
        ));
  }
}

class _AccountCorrectionDialog extends StatefulWidget {
  const _AccountCorrectionDialog({required this.account});
  final Account account;

  @override
  State<_AccountCorrectionDialog> createState() =>
      _AccountCorrectionDialogState();
}

class _AccountCorrectionDialogState extends State<_AccountCorrectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.account.name);
  late final _opening = TextEditingController(
    text: formatCop(widget.account.openingCents)
        .replaceAll(r'$', '')
        .replaceAll('.', ''),
  );

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Corregir cuenta rechazada'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                maxLength: 80,
                decoration:
                    const InputDecoration(labelText: 'Nombre de la cuenta'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escribe un nombre para la cuenta.'
                    : null,
              ),
              TextFormField(
                controller: _opening,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Saldo inicial (COP)'),
                validator: (value) =>
                    parseCopCents(value ?? '', allowZero: true) == null
                        ? 'Ingresa un saldo inicial válido.'
                        : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, (_name.text, _opening.text));
              }
            },
            child: const Text('Guardar corrección'),
          ),
        ],
      );
}

class _MovementCorrectionDialog extends StatefulWidget {
  const _MovementCorrectionDialog({required this.movement});
  final Movement movement;

  @override
  State<_MovementCorrectionDialog> createState() =>
      _MovementCorrectionDialogState();
}

class _MovementCorrectionDialogState extends State<_MovementCorrectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _description =
      TextEditingController(text: widget.movement.description);
  late final _amount = TextEditingController(
    text: formatCop(widget.movement.cents)
        .replaceAll(r'$', '')
        .replaceAll('.', ''),
  );

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Corregir movimiento rechazado'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _description,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escribe una descripción.'
                    : null,
              ),
              TextFormField(
                controller: _amount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Importe (COP)'),
                validator: (value) => parseCopCents(value ?? '') == null
                    ? 'Ingresa un importe positivo válido.'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, (_description.text, _amount.text));
              }
            },
            child: const Text('Guardar corrección'),
          ),
        ],
      );
}
