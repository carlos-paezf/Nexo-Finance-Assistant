# Nexo — API NestJS/Prisma de PoC

API experimental para datos sintéticos: los endpoints financieros continúan sin autenticación; el flujo de sesión y grupos está protegido. No exponer a Internet ni usar con datos reales. La preferencia tecnológica de Nexo no aprueba esta versión ni el stack de producción.

## Requisitos y versiones de esta PoC

- Node `22.15.0` del entorno: compatible con NestJS `12.1.2` (Node >=20) y Prisma ORM `7.10.0` (Node `^20.19 || ^22.12 || >=24`).
- TypeScript `5.9.3`; Compose ofrece PostgreSQL `18`. La validación ejecutada usó PostgreSQL `17.6` en un clúster local aislado, compatible con Prisma.
- Cliente móvil: Flutter `3.47.6`, Dart `3.13.5` ejecutados en Windows para esta iteración; `path_provider` `2.1.6` quedó bloqueado en `pubspec.lock`.
- Las versiones fijadas son para reproducir esta PoC; versiones de producción y aprobación de DEC-004 siguen pendientes.

## Comandos

Desde esta carpeta, con Docker Desktop activo:

```powershell
Copy-Item .env.example .env
docker compose up -d postgres
npm install
npm run db:deploy
npm test
npm start
```

En este entorno Windows, el clúster PostgreSQL 17.6 existente de la PoC está en
`D:\Nexus\poc\.runtime\postgres-data` y escucha solo en `127.0.0.1:55432`.
Para arrancar ese clúster conservando sus datos y configuración, desde PowerShell:

```powershell
& 'C:\Program Files\PostgreSQL\17\bin\pg_ctl.exe' start `
  -D 'D:\Nexus\poc\.runtime\postgres-data' `
  -l 'D:\Nexus\poc\.runtime\postgres.log' `
  -o '-h 127.0.0.1 -p 55432' -w
```

La orden inicia el directorio existente; no inicializa ni sustituye el clúster.
El archivo `.env` local de esta PoC apunta a la base sintética exclusiva y no se
versiona. No imprimir ni copiar sus credenciales a logs.

`npm test` compila y ejecuta pruebas de servicio más integraciones HTTP/PostgreSQL. La suite de finanzas se omite si falta `DATABASE_URL`; la suite `auth-groups.http.spec` exige la base y falla si no está configurada. Con la base disponible, las integraciones levantan y reinician procesos NestJS y limpian solo sus fixtures sintéticos. `npm run test:postgres` ejecuta solo la integración financiera.

## Contrato

- `POST /accounts`: `{ id, name, openingCents }`.
- `POST /accounts/:accountId/movements`: `{ id, type, description, amountCents, occurredAt }`.
- `GET /accounts/:id`: detalle, movimientos y `balanceCents`.
- Los IDs estables son las claves únicas. Payload repetido devuelve el registro original; misma clave con distinto contenido devuelve HTTP 409. Importes viajan como strings de centavos y se guardan como PostgreSQL `BIGINT`/`BigInt`.

Los endpoints financieros existentes continúan sin autenticación. El flujo experimental de grupo añade `POST /groups` y `GET /groups`, ambos protegidos por Bearer: crea UUID en servidor y membresía activa del creador con `canChangeMode`; lista solo grupos del actor activo y devuelve revisión decimal. El body de creación acepta solo `name` (1–80 caracteres) y `type` (`PAREJA` o `FAMILIA`); rechaza IDs, miembros y permisos del cliente. La columna `name` se añadió aditivamente y registros anteriores reciben el nombre sintético `Grupo existente`. El modelo usa un creador inicial; invitaciones e incorporación de miembros siguen pendientes. El cambio autenticado sigue en `PATCH /groups/:groupId/mode`; el permiso presentado por Flutter solo controla la UI y el backend vuelve a autorizar desde PostgreSQL.

Este flujo no habilita autenticación financiera integral, invitaciones, transferencias ni acuerdos compartidos. La integración probada fue en PostgreSQL local dedicado a la PoC; no usar datos reales.

## Identidad y sesiones — laboratorio

- `POST /auth/register`, `POST /auth/login` y `POST /auth/logout` escuchan solo en `127.0.0.1`; credenciales usan `Cache-Control: no-store`.
- El PoC valida contraseña de 12–128 puntos de código y hasta 256 bytes UTF-8; conserva exactamente los caracteres recibidos. El correo se recorta y normaliza a minúsculas.
- Hash asíncrono de laboratorio: `scrypt`, `N=131072`, `r=8`, `p=1`, memoria máxima por operación 192 MiB, salt aleatorio de 16 bytes y salida de 64 bytes. Formato versionado incluye algoritmo, parámetros, salt y hash; se compara con `timingSafeEqual`.
- Solo se ejecuta un hash simultáneo y se limita a 60 intentos por minuto por proceso. No hay cola de hash; el límite se reinicia al reiniciar la API.
- El token de sesión tiene 32 bytes aleatorios; PostgreSQL conserva únicamente SHA-256. La sesión vence a las 8 horas y el logout deja revocación persistente.
- Es configuración experimental para datos sintéticos y loopback. No hay TLS, verificación de correo, recuperación de contraseña, purga de sesiones, límite distribuido ni adopción automática de UUID/membresías sintéticas existentes. No usar para producción.
