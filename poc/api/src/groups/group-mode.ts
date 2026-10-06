export type GroupMode = 'PAREJA' | 'FAMILIA';

export type GroupSnapshot = Readonly<{
  id: string;
  type: GroupMode;
  revision: number;
  members: readonly Readonly<{ userId: string; active: boolean }>[];
}>;

// El backend deriva este contexto; no se acepta del cuerpo de la solicitud.
export type GroupModeAuthorization = Readonly<{
  actorId: string;
  groupId: string;
  actorActive: boolean;
  canChangeMode: boolean;
}>;

export type GroupModeRejection =
  | 'ACTOR_INACTIVE'
  | 'FORBIDDEN'
  | 'INVALID_DESTINATION'
  | 'INVALID_REVISION'
  | 'STALE_REVISION'
  | 'TOO_MANY_ACTIVE_MEMBERS';

export type GroupModeResult =
  | Readonly<{ ok: false; reason: GroupModeRejection }>
  | Readonly<{ ok: true; kind: 'noop' }>
  | Readonly<{
      ok: true;
      kind: 'patch';
      patch: Readonly<{ id: string; type: GroupMode; revision: number }>;
    }>;

export function evaluateGroupModeChange(
  snapshot: GroupSnapshot,
  destination: unknown,
  expectedRevision: unknown,
  authorization: GroupModeAuthorization,
): GroupModeResult {
  if (!authorization.actorActive ||
      !snapshot.members.some((member) => member.userId === authorization.actorId && member.active)) {
    return { ok: false, reason: 'ACTOR_INACTIVE' };
  }
  if (authorization.groupId !== snapshot.id || !authorization.canChangeMode) {
    return { ok: false, reason: 'FORBIDDEN' };
  }
  if (destination !== 'PAREJA' && destination !== 'FAMILIA') {
    return { ok: false, reason: 'INVALID_DESTINATION' };
  }
  if (typeof expectedRevision !== 'number' || !Number.isSafeInteger(expectedRevision) || expectedRevision < 0 ||
      !Number.isSafeInteger(snapshot.revision) || snapshot.revision < 0) {
    return { ok: false, reason: 'INVALID_REVISION' };
  }
  if (expectedRevision !== snapshot.revision) {
    return { ok: false, reason: 'STALE_REVISION' };
  }
  if (destination === snapshot.type) {
    return { ok: true, kind: 'noop' };
  }
  if (snapshot.revision === Number.MAX_SAFE_INTEGER) {
    return { ok: false, reason: 'INVALID_REVISION' };
  }
  if (destination === 'PAREJA' && snapshot.members.filter((member) => member.active).length > 2) {
    return { ok: false, reason: 'TOO_MANY_ACTIVE_MEMBERS' };
  }
  return {
    ok: true,
    kind: 'patch',
    patch: { id: snapshot.id, type: destination, revision: snapshot.revision + 1 },
  };
}
