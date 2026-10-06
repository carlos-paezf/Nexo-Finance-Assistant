# Nexo — cliente Flutter de PoC (T-005)

Prototipo con datos sintéticos. La preferencia de stack no constituye aprobación para producción ni del MVP. No usar datos reales: el ledger local no está cifrado y sus endpoints financieros no tienen autenticación/autorización. La página experimental de grupos usa registro/sesión HTTP; el token solo vive en memoria.

## Desarrollo local

La PoC tiene target Windows generado y probado con Flutter `3.47.6`, Dart `3.13.5` y Build Tools 2019. Android/iOS no están configurados en este entorno. El lockfile se conserva; se agregaron solo `integration_test` y sus dependencias transitivas del SDK para probar el flujo visual en Windows. La versión anotada describe este runner de PoC; selección y versiones productivas siguen pendientes.

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
& 'D:\Nexus\poc\.runtime\flutter\bin\flutter.bat' test integration_test/finance_flow_test.dart -d windows --dart-define=NEXO_API_URL=http://127.0.0.1:3011
```

La integración requiere `node` en PATH y `.env` de API apuntando a la base exclusiva de la PoC; administra e inicia su propia API en 3011 para no interferir con una API de desarrollo en 3000. Crea una cuenta COP 1.000,00, ingreso COP 200,00 y gasto COP 12,34; prueba caída offline, recupera archivo, sincroniza y muestra COP 1.187,66. Además, precrea una operación con el mismo ID en otra cuenta para obtener un 409 real; verifica que la causa quede visible, el movimiento se conserve y la corrección cree otro ID antes de sincronizar. El proceso visual anterior también prueba la pantalla con campos dentro del contrato.

Orden de ejecución: deja libre el puerto 3011 y ejecuta primero esta integración, que administra e inicia su API de prueba. Cuando termine, inicia la API persistente en el puerto elegido y después la instancia Windows para revisión visual. No mantengas la API persistente ocupando 3011 durante la integración.

Para comprobar cierre y relanzamiento real del ejecutable Windows contra PostgreSQL dedicado, compila con API en puerto libre 3011 y ejecuta la orquestación desde esta carpeta:

```powershell
& 'D:\Nexus\poc\.runtime\flutter\bin\flutter.bat' build windows --release --dart-define=NEXO_API_URL=http://127.0.0.1:3011
& .\tool\verify_windows_restart.ps1 -Port 3011
```

El script usa una carpeta nueva bajo `poc/.runtime`, inicia el `.exe` offline, termina el proceso, reactiva NestJS, relanza la app con reintento de inicio solo para este experimento, consulta filas/saldo en la API y abre una última instancia visual sincronizada. Evidencia: `poc/.runtime/windows-restart-validation.log`. En la ejecución registrada: 2 movimientos y saldo `1122500` centavos después del primer relanzamiento; un segundo replay mantuvo 2 filas. El API y la última ventana quedan ejecutándose. Variables `NEXO_DATA_DIRECTORY` y `NEXO_SYNC_ON_START` se reservan al harness de prueba.

## Flujo implementado

- Cuenta y cola de operaciones local; el repositorio valida ID `[A-Za-z0-9_-]{1,80}`, nombre 1–80, descripción 1–200 y centavos exactos dentro de PostgreSQL `BIGINT` antes de escribir el archivo.
- Movimientos en centavos enteros; el contrato HTTP envía centavos como cadenas para evitar precisión `number` en JavaScript.
- Cuenta primero, luego sus movimientos; si falla la cuenta, movimientos permanecen en cola.
- Replay idempotente con API, balance local provisional y balance confirmado por API mostrados por separado.
- Rechazos 400/409 conservan estado y mensaje del backend sin replay automático; un movimiento se puede corregir y encolar con un nuevo ID. Errores de red/servidor siguen como reintentables.
- Escrituras locales por revisiones únicas en el mismo directorio. No se reemplaza un destino existente, para evitar el fallo de renombrado en Windows. Conserva una revisión anterior solo si la limpieza falla.

Verificación ejecutada: `flutter pub get --enforce-lockfile`, `flutter analyze` sin issues, 10 pruebas en `flutter test`, integración desktop 1/1 y cierre/relanzamiento del `.exe` Release. Las pruebas locales demuestran que entradas inválidas no se escriben a la cola; recuperan 100 movimientos; replay tras respuesta perdida mantiene un efecto; la integración visual verifica alta, ingreso, gasto, caída offline, respuesta 409, causa visible, corrección y saldo confirmado en PostgreSQL.

La instancia en vivo no tiene autenticación ni cifrado; no usar datos reales. Android/iOS físicos, captura nativa, permisos, cifrado, segundo plano, energía y rendimiento siguen sin validar; T-005 continúa en progreso.

## Sesión y grupos experimentales

Desde el AppBar se abre «Grupos», independiente de la cola financiera. El registro/inicio de sesión obtiene una sesión de laboratorio; Flutter conserva el token únicamente en memoria y lo descarta al cerrar sesión, cambiar de pantalla o recibir HTTP 401. Crear/listar Pareja y Familia y cambiar de modo requieren conexión. La pantalla usa `canChangeMode` solo para presentar la acción; PostgreSQL reautoriza. Reintentos de modo conservan clave/payload y 409 requiere nueva consulta y confirmación. La creación no se repite automáticamente ante respuesta perdida.

Integración automatizada Windows contra la API y PostgreSQL reales (el harness reserva puerto libre, arranca y detiene su API; requiere `.env` ya configurado en `poc/api`):

```powershell
Set-Location D:\Nexus\poc\flutter_offline
$line = Get-Content ..\api\.env | Where-Object { $_ -match '^DATABASE_URL=' } | Select-Object -First 1
$env:DATABASE_URL = $line.Substring('DATABASE_URL='.Length)
$env:NEXO_API_WORKDIR = (Resolve-Path ..\api).Path
& 'D:\flutter\bin\flutter.bat' test integration_test/auth_groups_flow_test.dart -d windows
```

En la ejecución documentada el test de integración creó la cuenta en UI, inició sesión, creó ambos tipos, cambió Pareja→Familia→Pareja desde la confirmación visible, consultó revisiones por API y cerró sesión. La sesión de verificación posterior permitió leer revisiones persistidas. La prueba no cubre invitaciones ni integrantes adicionales; migración y grupos usan membresía de creador único. La petición de registro visual se realiza una vez por harness y elimina solo sus fixtures.

La instancia de revisión dejada abierta para esta iteración usa API loopback `127.0.0.1:3023`, Flutter Windows Debug y `D:\Nexus\poc\.runtime\t005-auth-groups-20261005`. Para reproducirla, inicia el API compilado desde `poc/api` y luego la ventana:

```powershell
$line = Get-Content .env | Where-Object { $_ -match '^DATABASE_URL=' } | Select-Object -First 1
$env:DATABASE_URL = $line.Substring('DATABASE_URL='.Length)
$env:PORT = '3023'
Start-Process -FilePath (Get-Command node).Source -ArgumentList 'dist/src/main.js' -WorkingDirectory (Get-Location).Path -WindowStyle Hidden

Set-Location D:\Nexus\poc\flutter_offline
$env:NEXO_DATA_DIRECTORY = 'D:\Nexus\poc\.runtime\t005-auth-groups-20261005'
& 'D:\flutter\bin\flutter.bat' build windows --debug --dart-define=NEXO_API_URL=http://127.0.0.1:3023
& '.\build\windows\x64\runner\Debug\nexo_offline_poc.exe'
```

Esta vista no agrega grupos al ledger ni autentica rutas financieras. Android, almacenamiento seguro de token, recuperación de cuenta, correo verificado, TLS, invitaciones, sincronización offline de grupos y validación móvil continúan pendientes.
