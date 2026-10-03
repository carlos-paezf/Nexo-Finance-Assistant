# Nexo — cliente Flutter de PoC (T-005)

Prototipo con datos sintéticos. La preferencia de stack no constituye aprobación para producción ni del MVP. No usar datos reales: el archivo local no está cifrado y no hay autenticación/autorización.

## Desarrollo local

La PoC tiene target Windows generado y probado con Flutter `3.47.5` y Build Tools 2019. Android/iOS no están configurados en este entorno. El lockfile se conserva; se agregaron solo `integration_test` y sus dependencias transitivas del SDK para probar el flujo visual en Windows.

Desde PowerShell, deja PostgreSQL dedicado en `127.0.0.1:55432` y migrado; después levanta la API en una terminal:

```powershell
Set-Location D:\Nexus\poc\api
npm start
```

En otra terminal arranca la app Windows con API real:

```powershell
Set-Location D:\Nexus\poc\flutter_offline
& 'D:\Nexus\poc\.runtime\flutter\bin\flutter.bat' run -d windows --dart-define=NEXO_API_URL=http://127.0.0.1:3000
```

Para reproducir el flujo UI con API caída y reactivación, la integración arranca NestJS después de guardar y reabrir los datos locales. Desde esta carpeta:

```powershell
$env:NEXO_API_WORKDIR = (Resolve-Path ..\api).Path
& 'D:\Nexus\poc\.runtime\flutter\bin\flutter.bat' test integration_test/finance_flow_test.dart -d windows --dart-define=NEXO_API_URL=http://127.0.0.1:3000
```

El test requiere `node` en PATH, `.env` de API apuntando a la base exclusiva de la PoC y puerto 3000 libre. El caso crea una cuenta de COP 1.000,00, registra ingreso de COP 200,00 y gasto de COP 12,34; muestra COP 1.187,66, fuerza fallo offline, recrea la app sobre el mismo directorio persistente, levanta API real y comprueba cola sincronizada y saldo confirmado. En una prueba manual, detén y vuelve a iniciar NestJS y pulsa **Sincronizar con API**. Para Android Emulator sería `10.0.2.2`, pero esa plataforma no fue preparada aquí. No habilitar HTTP en compilaciones productivas.

## Flujo implementado

- Cuenta y cola de operaciones local, con ID estable creado antes de sincronizar.
- Movimientos en centavos enteros; el contrato HTTP envía centavos como cadenas para evitar precisión `number` en JavaScript.
- Cuenta primero, luego sus movimientos; si falla la cuenta, movimientos permanecen en cola.
- Replay idempotente con API, balance local provisional y balance confirmado por API mostrados por separado.
- Escrituras locales por revisiones únicas en el mismo directorio. No se reemplaza un destino existente, para evitar el fallo de renombrado en Windows. Conserva una revisión anterior solo si la limpieza falla.

Verificación ejecutada: `flutter pub get --enforce-lockfile`, `flutter analyze` sin issues, cinco pruebas de unidad/widget con `flutter test`, e integración desktop con `flutter test integration_test/finance_flow_test.dart -d windows ...`. La prueba de 100 movimientos recupera la lista al crear de nuevo el almacén; replay tras respuesta perdida produce un efecto; el flujo Windows ejercita alta, ingreso, gasto, error offline, reapertura del árbol UI y sincronización a PostgreSQL real.

La instancia en vivo no tiene autenticación ni cifrado; no usar datos reales. La prueba de integración recrea la app y el repositorio en el mismo proceso Windows para verificar rehidratación del archivo, pero no mata y relanza el ejecutable. La evaluación móvil aún requiere reinicio real del proceso y pruebas físicas Android/iOS.
