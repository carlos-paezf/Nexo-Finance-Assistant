# Nexo — API NestJS/Prisma de PoC

API sin autenticación para datos sintéticos. No exponer a Internet ni usar con datos reales. La preferencia tecnológica de Nexo no aprueba esta versión ni el stack de producción.

## Requisitos y versiones de esta PoC

- Node `22.15.0` del entorno: compatible con NestJS `12.1.2` (Node >=20) y Prisma ORM `7.10.0` (Node `^20.19 || ^22.12 || >=24`).
- TypeScript `5.9.3`; Compose ofrece PostgreSQL `18`. La validación ejecutada usó PostgreSQL `17.6` en un clúster local aislado, compatible con Prisma.
- Cliente móvil: Flutter `3.47.5`, Dart `3.13.4`; Windows desktop seleccionado. `path_provider` `2.1.6` quedó bloqueado en `pubspec.lock`.
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

`npm test` compila y ejecuta pruebas de servicio más la integración HTTP/PostgreSQL. La integración se omite si falta `DATABASE_URL`; con base disponible levanta y reinicia un proceso NestJS, verifica reintentos, saldo y conflicto, y limpia la cuenta sintética. `npm run test:postgres` ejecuta solo esa integración. La conexión local del ejemplo solo es para desarrollo.

## Contrato

- `POST /accounts`: `{ id, name, openingCents }`.
- `POST /accounts/:accountId/movements`: `{ id, type, description, amountCents, occurredAt }`.
- `GET /accounts/:id`: detalle, movimientos y `balanceCents`.
- Los IDs estables son las claves únicas. Payload repetido devuelve el registro original; misma clave con distinto contenido devuelve HTTP 409. Importes viajan como strings de centavos y se guardan como PostgreSQL `BIGINT`/`BigInt`.

Este alcance no implementa usuarios, autorización, permisos por recurso, transferencias ni acuerdos compartidos. La integración probada fue en PostgreSQL local dedicado a la PoC; no usar datos reales.
