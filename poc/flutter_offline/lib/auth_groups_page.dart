import 'dart:math';

import 'package:flutter/material.dart';

import 'auth_groups_api.dart';

class AuthGroupsPage extends StatefulWidget {
  const AuthGroupsPage({super.key, required this.apiBaseUrl, this.api});

  final String apiBaseUrl;
  final AuthGroupsApi? api;

  @override
  State<AuthGroupsPage> createState() => _AuthGroupsPageState();
}

class _ModeAttempt {
  const _ModeAttempt(this.group, this.destination, this.key);
  final NexoGroup group;
  final String destination;
  final String key;
}

class _AuthGroupsPageState extends State<AuthGroupsPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _groupName = TextEditingController();
  late final AuthGroupsApi _api = widget.api ?? AuthGroupsApi(widget.apiBaseUrl);
  bool _registering = true;
  bool _busy = false;
  bool _signedIn = false;
  String _newType = 'PAREJA';
  String? _error;
  String? _notice;
  String? _modeError;
  List<NexoGroup> _groups = const [];
  _ModeAttempt? _retry;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _groupName.dispose();
    _api.close();
    super.dispose();
  }

  String? _emailError(String? value) {
    final email = value?.trim().toLowerCase() ?? '';
    return email.length <= 254 &&
            RegExp(r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?\.[a-z]{2,}$")
                .hasMatch(email)
        ? null
        : 'Escribe un correo válido.';
  }

  String? _passwordError(String? value) {
    final password = value ?? '';
    final points = password.runes.length;
    return points >= 12 && points <= 128 &&
            utf8Length(password) <= 256
        ? null
        : 'Usa 12–128 caracteres y hasta 256 bytes UTF-8.';
  }

  int utf8Length(String value) => value.runes.fold<int>(
      0, (length, rune) => length + (rune <= 0x7f ? 1 : rune <= 0x7ff ? 2 : rune <= 0xffff ? 3 : 4));

  void _clearLocalSession() {
    _api.discardSession();
    _password.clear();
    _groups = const [];
    _retry = null;
    _signedIn = false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _authenticate() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
      _modeError = null;
      _groups = const [];
      _retry = null;
    });
    final email = _email.text.trim().toLowerCase();
    final password = _password.text;
    try {
      if (_registering) {
        await _api.register(email, password);
      } else {
        await _api.login(email, password);
      }
      if (!mounted) return;
      _password.clear();
      setState(() {
        _signedIn = true;
        _email.text = email;
      });
      await _refreshGroups(partOfOperation: true);
    } on AuthGroupsException catch (error) {
      if (!mounted) return;
      _password.clear();
      setState(() => _error = error.message);
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await _api.logout();
      if (mounted) setState(() => _notice = 'Sesión cerrada en el servidor.');
    } on AuthGroupsException catch (error) {
      if (mounted) setState(() => _notice = 'No se confirmó el cierre remoto: ${error.message}');
    } finally {
      _api.discardSession();
      if (mounted) {
        _password.clear();
        setState(() {
          _signedIn = false;
          _groups = const [];
          _retry = null;
          _busy = false;
        });
      }
    }
  }

  Future<void> _refreshGroups({bool partOfOperation = false}) async {
    if (!_api.hasSession || (_busy && !partOfOperation)) return;
    if (!partOfOperation) setState(() => _busy = true);
    try {
      final groups = await _api.listGroups();
      if (mounted) setState(() => _groups = groups);
    } on AuthGroupsException catch (error) {
      if (mounted) setState(() {
        if (error.statusCode == 401) _clearLocalSession();
        _error = error.message;
      });
    } finally {
      if (mounted && !partOfOperation) setState(() => _busy = false);
    }
  }

  Future<void> _createGroup() async {
    if (_busy) return;
    final name = _groupName.text.trim();
    if (name.runes.isEmpty || name.runes.length > 80) {
      setState(() => _error = 'El nombre debe tener entre 1 y 80 caracteres.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await _api.createGroup(name, _newType);
      if (!mounted) return;
      _groupName.clear();
      await _refreshGroups(partOfOperation: true);
      if (mounted) setState(() => _notice = 'Grupo creado.');
    } on AuthGroupsException catch (error) {
      if (error.temporary) {
        if (mounted) {
          const message = 'Resultado indeterminado. Consultando la lista; no se repetirá la creación automáticamente.';
          setState(() => _notice = message);
          _showMessage(message);
        }
        await _refreshGroups(partOfOperation: true);
      } else if (mounted) {
        setState(() {
          if (error.statusCode == 401) _clearLocalSession();
          _error = error.message;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _key() {
    final bytes = List<int>.generate(24, (_) => Random.secure().nextInt(256));
    return 'ui-${bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}';
  }

  Future<void> _confirmMode(NexoGroup group) async {
    if (_busy || !group.canChangeMode) return;
    final destination = group.type == 'PAREJA' ? 'FAMILIA' : 'PAREJA';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cambio de modo'),
        content: Text('Cambiar «${group.name}» a ${_typeLabel(destination)}. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _sendMode(_ModeAttempt(group, destination, _key()));
  }

  Future<void> _sendMode(_ModeAttempt attempt) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
      _modeError = null;
    });
    try {
      await _api.changeMode(
        groupId: attempt.group.id,
        destination: attempt.destination,
        expectedRevision: attempt.group.revision,
        idempotencyKey: attempt.key,
      );
      if (!mounted) return;
      _retry = null;
      _modeError = null;
      await _refreshGroups(partOfOperation: true);
      if (mounted) setState(() => _notice = 'Modo actualizado.');
    } on AuthGroupsException catch (error) {
      if (error.statusCode == 409) {
        _retry = null;
        await _refreshGroups(partOfOperation: true);
        if (mounted) {
          const message = 'El grupo cambió. Revisa el modo actual y confirma otra vez si aún deseas cambiarlo.';
          setState(() {
            _error = message;
            _modeError = message;
          });
        }
      } else {
        if (error.temporary) _retry = attempt;
        if (mounted) setState(() {
          if (error.statusCode == 401) _clearLocalSession();
          _error = error.message;
          _modeError = error.message;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _typeLabel(String type) => type == 'PAREJA' ? 'Pareja' : 'Familia';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Grupos')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Semantics(header: true, child: Text('Sesión y grupos', style: Theme.of(context).textTheme.headlineSmall)),
              const SizedBox(height: 8),
              const Text('Prueba experimental con datos sintéticos. Los grupos requieren conexión.'),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Semantics(liveRegion: true, child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
              ],
              if (_notice != null) ...[
                const SizedBox(height: 16),
                Semantics(liveRegion: true, child: Text(_notice!)),
              ],
              const SizedBox(height: 20),
              if (!_signedIn) _authForm() else _groupsView(),
              if (_busy) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(semanticsLabel: 'Operación en curso'),
              ],
            ],
          ),
        ),
      );

  Widget _authForm() => Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(_registering ? 'Crear cuenta de prueba' : 'Iniciar sesión', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Correo electrónico'),
            validator: _emailError,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            autofillHints: [_registering ? AutofillHints.newPassword : AutofillHints.password],
            decoration: const InputDecoration(labelText: 'Contraseña'),
            validator: _passwordError,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _busy ? null : _authenticate, child: Text(_registering ? 'Crear cuenta' : 'Iniciar sesión')),
          TextButton(
            onPressed: _busy ? null : () => setState(() { _registering = !_registering; _password.clear(); _error = null; }),
            child: Text(_registering ? 'Ya tengo una cuenta' : 'Crear una cuenta'),
          ),
        ]),
      );

  Widget _groupsView() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Sesión: ${_email.text}', style: Theme.of(context).textTheme.titleMedium),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _busy ? null : _logout, child: const Text('Cerrar sesión'))),
        const SizedBox(height: 20),
        Text('Crear grupo', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextFormField(
          controller: _groupName,
          maxLength: 80,
          decoration: const InputDecoration(labelText: 'Nombre del grupo'),
          validator: (value) {
            final length = value?.trim().runes.length ?? 0;
            return length < 1 || length > 80 ? 'Usa entre 1 y 80 caracteres.' : null;
          },
        ),
        Text('Tipo de grupo', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          ChoiceChip(
            label: const Text('Pareja'),
            selected: _newType == 'PAREJA',
            onSelected: _busy ? null : (_) => setState(() => _newType = 'PAREJA'),
          ),
          ChoiceChip(
            label: const Text('Familia'),
            selected: _newType == 'FAMILIA',
            onSelected: _busy ? null : (_) => setState(() => _newType = 'FAMILIA'),
          ),
        ]),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _busy ? null : _createGroup, icon: const Icon(Icons.group_add_outlined), label: const Text('Crear grupo')),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: Text('Tus grupos', style: Theme.of(context).textTheme.titleLarge)),
          IconButton(tooltip: 'Actualizar grupos', onPressed: _busy ? null : _refreshGroups, icon: const Icon(Icons.refresh)),
        ]),
        if (_groups.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Aún no tienes grupos.'))
        else
          ..._groups.map(_groupEntry),
        if (_modeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Semantics(liveRegion: true, child: Text(_modeError!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          ),
        if (_retry case final attempt?) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _sendMode(attempt),
            icon: const Icon(Icons.sync),
            label: const Text('Reintentar el mismo cambio'),
          ),
        ],
      ]);

  Widget _groupEntry(NexoGroup group) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Divider(height: 24),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(group.name),
          subtitle: Text('${_typeLabel(group.type)} · revisión ${group.revision}'),
        ),
        if (group.canChangeMode)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _busy ? null : () => _confirmMode(group),
              child: Text('Cambiar a ${_typeLabel(group.type == 'PAREJA' ? 'FAMILIA' : 'PAREJA')}'),
            ),
          )
        else
          const Text('Solo consulta'),
      ]);
}
