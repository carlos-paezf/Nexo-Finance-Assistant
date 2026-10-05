# 05 — Plan inicial y seguimiento

[Fuente en Notion](https://app.notion.com/p/3eeaf67c2e928101b31dfe0100cbb4d6?pvs=204)

## Estado general
Documentación inicial completada. Especificación detallada e implementación pendientes. Sin fechas de entrega ni responsables asignados.
## Trabajo inmediato
- [x] Crear el espacio del proyecto y documentación.
- [x] Consolidar 163 RF y 75 RNF con identificadores originales.
- [x] Registrar propuestas técnicas, decisiones y reglas iniciales.
- [ ] T-001 — Validar el alcance P0 y reducirlo a un MVP realizable. Entregable: lista aprobada de requisitos y exclusiones por etapa.
- [ ] T-002 — Depurar solapamientos RF-007/RF-139 y resolver prioridad del cierre básico de tickets RF-152. Conservar trazabilidad.
- [ ] T-003 — Redactar historias y criterios de aceptación de usuarios, movimientos y privacidad.
- [ ] T-004 — Especificar distribución, redondeo, compensaciones y conservación de históricos con ejemplos verificables.
- [ ] T-005 — Validar Flutter conforme a la preferencia tecnológica del usuario, con API de referencia NestJS/TypeScript y PostgreSQL/Prisma; después probar capacidades de captura por plataforma. PoC parcial; no selecciona stack productivo.
- [ ] T-006 — Diseñar modelo de datos, permisos y sincronización offline.
- [ ] T-007 — Diseñar flujos y pantallas de app y portal administrativo.
- [ ] T-008 — Definir métricas de calidad, carga de referencia, recuperación y política de retención.
- [ ] T-009 — Validar permisos, proveedores, protección de datos y alcance de información financiera externa antes del lanzamiento.
- [ ] T-010 — Crear estrategia de pruebas de motor financiero, privacidad, deduplicación y soporte.
## Secuencia propuesta
1. Cerrar alcance, reglas y permisos.
2. Construir núcleo: usuarios, cuentas, movimientos, finanzas compartidas, presupuestos y metas.
3. Habilitar soporte básico, auditoría y observabilidad junto con el núcleo.
4. Incorporar captura, hábitos, aprendizaje e IA según viabilidad.
5. Incorporar comparación financiera y simulaciones con fuentes verificadas.
6. Ampliar a grupos familiares.
La secuencia es una propuesta de planificación, no un compromiso de calendario.
## Plantilla de trazabilidad
Por requisito: ID; módulo; prioridad; estado; historia de usuario; reglas; criterios de aceptación; dependencias; pruebas; versión; responsable; enlaces de evidencia.
## Primer ejemplo de aceptación — borrador
RF-052: dado un gasto compartido confirmado de 100.000 COP, cuando se consulta el consolidado del grupo, el gasto total aumenta 100.000 COP una sola vez aunque ambos integrantes visualicen el registro. Las obligaciones individuales deben sumar exactamente el importe. Relacionados: RF-040, RF-041; RNF-037, RNF-039.
RF-160: sin autorización vigente, soporte no puede obtener información financiera ampliada. Con autorización, solo accede al alcance concedido; al vencer o revocarse, se deniega un nuevo acceso y queda auditoría.
## Control de cambios
Todo cambio de requisito conserva ID, fecha, motivo y estado de aprobación. Las nuevas funcionalidades continúan la numeración existente.

## Seguimiento — 3 de octubre de 2026

T-001/T-002 siguen abiertas y sin aprobación. La propuesta de 51 RF completos,
2 parciales y 110 diferidos está en [08 — MVP y depuración](08-propuesta-mvp-y-depuracion.md)
y su resumen se publicó en Notion. No se actualiza el estado de las tareas hasta
validar el alcance y resolver las decisiones pendientes.

El análisis financiero propuso que liquidar una obligación compartida actualiza
la deuda y los saldos de cuenta, sin crear ingreso, egreso consolidado ni consumo
de presupuesto. Queda sujeto a DEC-008 y cubierto por CA-I2-02/05. Se corrigió
CA-I2-05 para citar el gasto concreto de CA-I2-02. RF-152 y RF-156 conservan sus
coberturas parciales, no se cuentan como completos.

La preferencia del usuario es Flutter + NestJS/TypeScript + PostgreSQL/Prisma.
La PoC acotada documentada en T-005 aporta pruebas de servicio, pero la ejecución
Flutter y la integración PostgreSQL están pendientes. No aprueba versiones
productivas, DEC-004 ni MVP. T-003, T-004 y T-008 no se dan por completadas.
Los criterios de I1/I2 siguen sin ejecución; las páginas resumen ya están en
Notion.

Configuración: `.codex/config.toml` y cuatro agentes existen y pasan sintaxis
TOML. Esta sesión dispone de Ponytail, Impeccable y UI UX Pro Max; la última ya
estaba instalada globalmente y no se duplicó. El CLI 0.142.0 corrió en un perfil
aislado sin credenciales ni conectividad y no permite confirmar allí la carga de
los agentes del perfil principal. Una revisión independiente con `gpt-6-sol` sí
se completó en el cliente de esta tarea.

## Seguimiento T-005 — iteración de ejecución Windows

**En progreso; no marcar como completada.** Preferencia de referencia del usuario:
Flutter + NestJS/TypeScript + PostgreSQL/Prisma. Flutter 3.47.5/Dart 3.13.4,
Windows desktop con Visual Studio Build Tools 2019 y PostgreSQL 17.6 local,
aislado en `poc/.runtime` puerto 55432. No se habilitó Android; doctor no encontró
Android SDK ni dispositivo Android conectado.

Evidencia ejecutada: `flutter pub get --enforce-lockfile` conservó lockfile base
y agregó `integration_test`; `flutter analyze` sin issues; `flutter test` pasó
5/5. `npm run db:deploy` aplicó la migración existente; `npm test` con
`DATABASE_URL` real pasó 5/5, incluyendo HTTP a NestJS que reinicia el proceso,
valida COP 107.654,33, 10 replays por operación, 409 ante contenido distinto y
dos movimientos persistidos. `flutter test integration_test/finance_flow_test.dart
-d windows ...` pasó 1/1 en la app Windows real: alta, ingreso, gasto, saldo,
error offline, rehidratación al recrear el árbol de app, API disponible y cola
sincronizada. Se corrigió el borrado accidental de la revisión local actual al
comparar rutas Windows por nombre; el analyzer encontró y corrigió tres errores
de compilación/typing antes de pasar.

La ejecución de la integración de UI recrea la app y el repositorio en el mismo
proceso; no prueba relanzar el ejecutable Windows completo. Falta validar ese
ciclo real, dispositivos físicos Android/iOS, captura nativa, permisos, seguridad
con cifrado/auth, segundo plano, energía y rendimiento. T-005 sigue abierta;
versiones productivas, DEC-004, validación completa y aprobación del MVP pendientes.
Comandos reproducibles en los README de [`poc/api`](../../poc/api/README.md) y
[`poc/flutter_offline`](../../poc/flutter_offline/README.md).
Implementación y documentación publicadas en la rama
[`feat/t005-runtime-validation`](https://github.com/carlos-paezf/Nexo-Finance-Assistant/tree/feat/t005-runtime-validation),
commit `eb12ebea0615a33f4a0e09bb3781c86c03fb0c14`.

## Seguimiento T-005 — límites, rechazos y relanzamiento Windows — 5 de octubre de 2026

**En progreso.** Se alinearon formularios/repositorio Flutter con los límites
validados por `FinanceService`: ID ASCII de 1–80, nombre 1–80, descripción
1–200, importes exactos hasta PostgreSQL `BIGINT`. Pruebas confirman que datos
inválidos no se persisten en la cola. HTTP 400/409 quedan guardados con causa
como rechazos no reintentables; red/servidor quedan reintentables. La interfaz
permite corregir cuentas o movimientos rechazados y reencolarlos con una clave
nueva.

Evidencia Windows: `flutter analyze` limpio; `flutter test` 10/10; `npm test` con
PostgreSQL real 5/5; integración de interfaz 1/1 con conflicto 409 real,
corrección y saldo COP 1.187,66. El harness
`poc/flutter_offline/tool/verify_windows_restart.ps1` cerró el ejecutable Release
tras un primer arranque offline, reactivó NestJS, relanzó el `.exe`, rehidrató y
sincronizó 2 movimientos. PostgreSQL mostró `1122500` centavos y exactamente 2
filas; un segundo replay no duplicó. Evidencia de procesos en
`poc/.runtime/windows-restart-validation.log`; la última app y API 3011 quedan
disponibles.

Se añadió a `AGENTS.md` la regla de vista previa ejecutable y commits
Conventional Commits preparada en PR #1. T-005 permanece abierta: faltan
experimentos físicos Android/iOS y captura nativa, permisos, seguridad/auth,
cifrado, segundo plano, energía y rendimiento. Flutter + NestJS/TypeScript +
PostgreSQL/Prisma sigue siendo preferencia para la PoC; DEC-004, versiones
productivas, validación técnica completa y aprobación del MVP continúan
pendientes. Solo se usaron datos sintéticos.

## Seguimiento T-005 — integración de Privacidad y uso — 5 de octubre de 2026

Integrados en `feat/t005-runtime-validation` los archivos de referencia del
commit fuente `545bfa24378cb1ee4641683b831fc7c64ccfec2a`. En `main.dart` solo se
añadieron el import y el acceso desde el AppBar. No cambiaron validadores,
corrección de rechazos HTTP 400/409, sincronización, URL de API, almacenamiento
local ni dependencias/lockfiles.

Verificación real en Flutter Windows: `flutter analyze` sin issues y `flutter
test` 12/12. Los tests nuevos pasan apertura sin cuenta cuando falla el
almacenamiento; y texto al 200% en viewport 360×800, controles accesibles y
apertura de `LicensePage`. Se ajustó el desplazamiento del test fuente, que
inicialmente intentaba tocar un encabezado fuera del viewport. Build Release
Windows exitoso. La instancia PID 24124 quedó abierta en Privacidad y uso con
un directorio vacío e independiente. Captura y log locales (ignorados):
`poc/.runtime/privacy-use-window.png` y
`poc/.runtime/privacy-use-windows-validation.log`.

Arranque reproducible de la instancia actual:

```powershell
$env:NEXO_DATA_DIRECTORY = 'D:\Nexus\poc\.runtime\privacy-use-b6cb9cb59e624046b3789d99f3b9a71d'
& 'D:\Nexus\poc\flutter_offline\build\windows\x64\runner\Release\nexo_offline_poc.exe'
```

T-005 continúa en progreso. La pantalla es informativa, no captura aceptación;
cumplimiento, documentos productivos, accesibilidad integral y validación móvil
siguen pendientes.
