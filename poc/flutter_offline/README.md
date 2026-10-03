# Nexo — cliente Flutter de PoC (T-005)

Prototipo con datos sintéticos. La preferencia de stack no constituye aprobación para producción ni del MVP. No usar datos reales: el archivo local no está cifrado y no hay autenticación/autorización.

## Desarrollo local

1. Iniciar PostgreSQL y NestJS con los pasos de [`../api/README.md`](../api/README.md).
2. Desde esta carpeta, ejecutar `flutter pub get` y `flutter test`.
3. Ejecutar `flutter run --dart-define=NEXO_API_URL=http://10.0.2.2:3000` en el emulador Android. Para iOS Simulator usar `http://127.0.0.1:3000`. En un equipo físico usar una URL HTTPS accesible desde el teléfono.

La estructura nativa Android/iOS debe generarse con Flutter al disponer del SDK. No se generó en el entorno que creó esta PoC. HTTP en emulador se limita a desarrollo local y puede requerir configuración clara de tráfico en Android; no habilitar tráfico HTTP en una compilación productiva.

## Flujo implementado

- Cuenta y cola de operaciones local, con ID estable creado antes de sincronizar.
- Movimientos en centavos enteros; el contrato HTTP envía centavos como cadenas para evitar precisión `number` en JavaScript.
- Cuenta primero, luego sus movimientos; si falla la cuenta, movimientos permanecen en cola.
- Replay idempotente con API, balance local provisional y balance confirmado por API mostrados por separado.
- Escrituras locales por revisiones únicas en el mismo directorio. No se reemplaza un destino existente, para evitar el fallo de renombrado en Windows. Conserva una revisión anterior solo si la limpieza falla.

Pruebas locales preparadas en `test/`: 100 movimientos tras reabrir el archivo, cola durable tras fallo/reintento, pérdida simulada de respuesta tras aceptación por API, y contrato HTTP con cents como strings. No son pruebas ejecutadas mientras Flutter/Dart no estén disponibles.
