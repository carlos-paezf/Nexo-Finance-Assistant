import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  evaluateGroupModeChange,
  GroupModeAuthorization,
  GroupSnapshot,
} from '../src/groups/group-mode';

const snapshot = (type: GroupSnapshot['type'], activeMembers = 2): GroupSnapshot => ({
  id: 'group-1',
  type,
  revision: 4,
  members: Array.from({ length: activeMembers }, (_, index) => ({
    userId: `user-${index + 1}`,
    active: true,
  })),
});

const authorization: GroupModeAuthorization = {
  actorId: 'user-1',
  groupId: 'group-1',
  actorActive: true,
  canChangeMode: true,
};

test('PAREJA→FAMILIA conserva el grupo y avanza la revisión con dos miembros', () => {
  assert.deepEqual(evaluateGroupModeChange(snapshot('PAREJA'), 'FAMILIA', 4, authorization), {
    ok: true,
    kind: 'patch',
    patch: { id: 'group-1', type: 'FAMILIA', revision: 5 },
  });
});

test('FAMILIA→PAREJA permite dos miembros activos', () => {
  assert.deepEqual(evaluateGroupModeChange(snapshot('FAMILIA'), 'PAREJA', 4, authorization), {
    ok: true,
    kind: 'patch',
    patch: { id: 'group-1', type: 'PAREJA', revision: 5 },
  });
});

test('FAMILIA→PAREJA cuenta solo miembros activos', () => {
  const group: GroupSnapshot = {
    ...snapshot('FAMILIA', 2),
    members: [
      { userId: 'user-1', active: true },
      { userId: 'user-2', active: true },
      { userId: 'user-3', active: false },
    ],
  };
  assert.deepEqual(evaluateGroupModeChange(group, 'PAREJA', 4, authorization), {
    ok: true,
    kind: 'patch',
    patch: { id: 'group-1', type: 'PAREJA', revision: 5 },
  });
});

test('FAMILIA→PAREJA rechaza tres activos sin alterar la entrada', () => {
  const group = snapshot('FAMILIA', 3);
  const before = structuredClone(group);
  assert.deepEqual(evaluateGroupModeChange(group, 'PAREJA', 4, authorization), {
    ok: false,
    reason: 'TOO_MANY_ACTIVE_MEMBERS',
  });
  assert.deepEqual(group, before);
});

test('rechaza actor inactivo, sin permiso o autorizado para otro grupo sin parche', () => {
  const group = snapshot('PAREJA');
  const before = structuredClone(group);
  const inactive = evaluateGroupModeChange(group, 'FAMILIA', 4, {
    ...authorization,
    actorActive: false,
  });
  const forbidden = evaluateGroupModeChange(group, 'FAMILIA', 4, {
    ...authorization,
    canChangeMode: false,
  });
  const otherGroup = evaluateGroupModeChange(group, 'FAMILIA', 4, {
    ...authorization,
    groupId: 'group-2',
  });
  assert.deepEqual(inactive, { ok: false, reason: 'ACTOR_INACTIVE' });
  assert.deepEqual(forbidden, { ok: false, reason: 'FORBIDDEN' });
  assert.deepEqual(otherGroup, { ok: false, reason: 'FORBIDDEN' });
  assert.deepEqual(group, before);
});

test('rechaza actor cuya membresía no está activa sin cambios parciales', () => {
  const group: GroupSnapshot = {
    ...snapshot('PAREJA'),
    members: [
      { userId: 'user-1', active: false },
      { userId: 'user-2', active: true },
    ],
  };
  const before = structuredClone(group);
  assert.deepEqual(evaluateGroupModeChange(group, 'FAMILIA', 4, authorization), {
    ok: false,
    reason: 'ACTOR_INACTIVE',
  });
  assert.deepEqual(group, before);
});

test('rechaza actor que no pertenece al snapshot aunque el contexto lo marque activo', () => {
  assert.deepEqual(evaluateGroupModeChange(snapshot('PAREJA'), 'FAMILIA', 4, {
    ...authorization,
    actorId: 'user-3',
  }), { ok: false, reason: 'ACTOR_INACTIVE' });
});

test('rechaza revisiones malformadas, inválidas y obsoletas sin cambios parciales', () => {
  const group = snapshot('PAREJA');
  const before = structuredClone(group);
  for (const revision of [-1, '4', Number.NaN, 1.5, Number.MAX_SAFE_INTEGER + 1]) {
    assert.deepEqual(evaluateGroupModeChange(group, 'FAMILIA', revision, authorization), {
      ok: false,
      reason: 'INVALID_REVISION',
    });
  }
  assert.deepEqual(evaluateGroupModeChange(group, 'FAMILIA', 3, authorization), {
    ok: false,
    reason: 'STALE_REVISION',
  });
  assert.deepEqual(evaluateGroupModeChange(
    { ...group, revision: Number.NaN },
    'FAMILIA',
    4,
    authorization,
  ), { ok: false, reason: 'INVALID_REVISION' });
  assert.deepEqual(group, before);
});

test('rechaza incremento que desbordaría la revisión sin mutar el grupo', () => {
  const group = { ...snapshot('PAREJA'), revision: Number.MAX_SAFE_INTEGER };
  const before = structuredClone(group);
  assert.deepEqual(evaluateGroupModeChange(
    group,
    'FAMILIA',
    Number.MAX_SAFE_INTEGER,
    authorization,
  ), { ok: false, reason: 'INVALID_REVISION' });
  assert.deepEqual(group, before);
});

test('rechaza destino inválido sin cambios parciales', () => {
  const group = snapshot('PAREJA');
  const before = structuredClone(group);
  assert.deepEqual(evaluateGroupModeChange(group, 'AMIGOS', 4, authorization), {
    ok: false,
    reason: 'INVALID_DESTINATION',
  });
  assert.deepEqual(group, before);
});

test('mismo tipo y revisión vigente produce no-op', () => {
  assert.deepEqual(evaluateGroupModeChange(snapshot('FAMILIA'), 'FAMILIA', 4, authorization), {
    ok: true,
    kind: 'noop',
  });
});

test('no muta entradas congeladas', () => {
  const group: GroupSnapshot = Object.freeze({
    id: 'group-1',
    type: 'PAREJA',
    revision: 4,
    members: Object.freeze([
      Object.freeze({ userId: 'user-1', active: true }),
      Object.freeze({ userId: 'user-2', active: true }),
    ]),
  });
  const auth = Object.freeze({ ...authorization });
  assert.deepEqual(evaluateGroupModeChange(group, 'FAMILIA', 4, auth), {
    ok: true,
    kind: 'patch',
    patch: { id: 'group-1', type: 'FAMILIA', revision: 5 },
  });
  assert.deepEqual(group, {
    id: 'group-1',
    type: 'PAREJA',
    revision: 4,
    members: [
      { userId: 'user-1', active: true },
      { userId: 'user-2', active: true },
    ],
  });
});
