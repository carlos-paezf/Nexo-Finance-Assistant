import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'api_client.dart';
import 'local_data.dart';
import 'money.dart';

void main() => runApp(const NexoPocApp());

class NexoPocApp extends StatelessWidget {
  const NexoPocApp({super.key});

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
        home: const LedgerPage(),
      );
}

class LedgerPage extends StatefulWidget {
  const LedgerPage({super.key});

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
    const String.fromEnvironment(
      'NEXO_API_URL',
      defaultValue: 'http://127.0.0.1:3000',
    ),
  );
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
      final directory = await getApplicationSupportDirectory();
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
      '${DateTime.now().toUtc().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

  Future<bool> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se guardó. Revisa los datos e inténtalo de nuevo.')),
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
          ? const Center(child: CircularProgressIndicator semanticsLabel: 'Abriendo cuenta')
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
                                    style: Theme.of(context).textTheme.titleLarge),
                              ),
                              const SizedBox(height: 8),
                              if (repository.state.movements.isEmpty)
                                const Text('Aún no hay movimientos. Registra un ingreso o un gasto.')
                              else
                                ...repository.state.movements.map(_movementTile),
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
          Text('Crea una cuenta', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Los datos se guardan en este dispositivo. Usa información sintética.'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _accountName,
            decoration: const InputDecoration(labelText: 'Nombre de la cuenta'),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Escribe un nombre para la cuenta.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _opening,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Saldo inicial (COP)'),
            validator: (value) => _cents(_opening, allowZero: true) == null
                ? 'Usa COP con máximo dos decimales.'
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
        label: 'Saldo local ${formatCop(snapshot.localBalanceCents)} pesos colombianos',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(snapshot.account!.name, style: Theme.of(context).textTheme.titleMedium),
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
            child: Text('Nuevo movimiento', style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 12),
          SegmentedButton<MovementType>(
            segments: const [
              ButtonSegment(value: MovementType.income, label: Text('Ingreso')),
              ButtonSegment(value: MovementType.expense, label: Text('Gasto')),
            ],
            selected: {_type},
            onSelectionChanged: (selection) => setState(() => _type = selection.first),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Descripción'),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Escribe una descripción.'
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
                ? 'Ingresa un importe mayor que cero, con hasta dos decimales.'
                : null,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _addMovement,
            icon: const Icon(Icons.add),
            label: Text('Guardar ${_type == MovementType.income ? 'ingreso' : 'gasto'}'),
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
    final synced = (account.status == SyncStatus.synced ? 1 : 0) +
        movements.where((m) => m.status == SyncStatus.synced).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sincronización', style: Theme.of(context).textTheme.titleLarge),
        Text('$pending pendientes · $synced sincronizados · $errors con error'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: _busy || pending + errors == 0
                  ? null
                  : () async => _run(repository.sync),
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar con API'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('La cuenta y los movimientos pendientes se conservan en el dispositivo.'),
      ],
    );
  }

  Widget _movementTile(Movement movement) {
    final income = movement.type == MovementType.income;
    final status = switch (movement.status) {
      SyncStatus.pending => 'Pendiente de sincronizar',
      SyncStatus.synced => 'Sincronizado',
      SyncStatus.error => 'Error de sincronización; puedes reintentar',
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(income ? Icons.arrow_downward : Icons.arrow_upward,
          semanticLabel: income ? 'Ingreso' : 'Gasto'),
      title: Text(movement.description),
      subtitle: Text('${income ? 'Ingreso' : 'Gasto'} · $status'),
      trailing: Text('${income ? '+' : '−'}${formatCop(movement.cents)}',
          textAlign: TextAlign.end),
    );
  }
}
