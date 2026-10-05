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
- [ ] T-005 — Validar en Android la base confirmada por el usuario (Flutter, NestJS/TypeScript, PostgreSQL/Prisma); completar captura y demás experimentos. PoC parcial; versiones y validación productiva pendientes.
- [ ] T-006 — Diseñar modelo de datos, permisos y sincronización offline.
- [ ] T-007 — Diseñar flujos y pantallas de app y portal administrativo.
- [ ] T-008 — Definir métricas de calidad, carga de referencia, recuperación y política de retención.
- [ ] T-009 — Validar permisos, proveedores, protección de datos y alcance de información financiera externa antes del lanzamiento.
- [ ] T-010 — Crear estrategia de pruebas de motor financiero, privacidad, deduplicación y soporte.
## Secuencia propuesta
1. Cerrar alcance, reglas y permisos.
2. Construir núcleo: usuarios, cuentas, movimientos personales, grupos PAREJA/FAMILIA y migración bilateral, finanzas compartidas y presupuestos; metas según alcance aprobado.
3. Habilitar soporte básico, auditoría y observabilidad junto con el núcleo.
4. Incorporar captura, hábitos, aprendizaje e IA según viabilidad.
5. Incorporar comparación financiera y simulaciones con fuentes verificadas.
6. Precisar reglas familiares pendientes: cardinalidad FAMILIA, salida y acceso a históricos compartidos.
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

## Seguimiento T-005 — validación automatizada de C-12 — 5 de octubre de 2026

Se reforzó el test de teclado desde `NexoPocApp`: Tab alcanza el control de
privacidad y los apartados; Espacio expande/contrae; Enter abre Privacidad y uso,
el visor de licencias y el retorno con Shift+Tab/Espacio. El test confirma que
el control enfocado coincide con su objetivo y queda visible en el viewport.
Se conserva el `SemanticsHandle` del test al 200% dentro de `try/finally` y se
mantiene su liberación antes de abrir `LicensePage`.

En viewport 360×800, las guías `textContrastGuideline`,
`labeledTapTargetGuideline`, `androidTapTargetGuideline` e
`iOSTapTargetGuideline` pasan para el apartado de accesibilidad expandido y el
control de licencias, a escalas 100% y 200%. Evidencia automatizada Flutter
Test; no equivale a auditoría WCAG integral ni a validación en dispositivos.
Comprobaciones finales: `flutter analyze` sin issues y `flutter test` 14/14;
tests específicos de teclado, lectura ampliada y guías también pasaron.
`git diff --check` pasó. No cambió la UI ejecutable, así que se conserva la
instancia Windows existente. Comando para abrir una nueva instancia sintética:

```powershell
$env:NEXO_DATA_DIRECTORY = 'D:\Nexus\poc\.runtime\privacy-use-b6cb9cb59e624046b3789d99f3b9a71d'
& 'D:\Nexus\poc\flutter_offline\build\windows\x64\runner\Release\nexo_offline_poc.exe'
```

T-005 permanece en progreso. Narrator/TalkBack/VoiceOver, dispositivos móviles,
objetivos táctiles nativos y accesibilidad integral quedan pendientes. No se
declara conformidad ni aprobación productiva.

## Seguimiento T-005 — cobertura completa de Privacidad y uso — 5 de octubre de 2026

La prueba de escala/guías ahora extrae el tema real de `NexoPocApp`, sin
configuración duplicada. En 360×800 recorre la vista inicial, cada una de las
12 secciones por separado con su contenido visible y el botón de licencias a
100%/200%. Las cuatro guías Flutter de contraste, controles nombrados y
objetivos Android/iOS se ejecutan en esos estados. Flutter Test pasó; el teclado
se mantiene cubierto por su test existente. Verificación final desde
`poc/flutter_offline`: `flutter analyze` sin issues; `flutter test` 14/14;
`git diff --check` sin errores.

Narrator no se pudo observar: no estaba activo y la instancia Windows previa
(PID 24124) tampoco estaba ejecutándose al comprobarlo. Se conserva pendiente
la validación manual de anuncios, nombre/rol/estado, orden y regreso desde
licencias. Procedimiento y comando Release con carpeta de datos sintéticos
independiente están documentados en C-12. Como no cambió la UI de producción,
no se recompiló ni relanzó Windows. T-005 sigue en progreso; no se declara
validación de lector nativo, móvil ni conformidad productiva.

### Actualización T-005 — recorrido completo y UIA — 5 de octubre de 2026

Se reforzó C-12 para recorrer los cuerpos desde el inicio visible hasta el fin
con desplazamientos solapados del 65% del área útil (intersección del viewport
con `Scrollable`). Cada posición comprueba visibilidad y ejecuta las cuatro
guías; el test falla si no avanza y limita cada cuerpo a 40 posiciones.
Cabeceras y licencias deben estar contenidas completamente en el área. Los
matchers del SDK validan nombre, tap e hints localizados para expansión y
contracción, más aparición/desaparición del texto.

El inspector PowerShell UIA se ejecutó contra Release PoC PID 64884, con
Narrator PID 93912 activo. Tras el toggle, el cuerpo completo de `SelectableText`
aparece como `ValuePattern.Value`; `Name`/`HelpText` están ausentes y
`TextPattern`/`LegacyIAccessiblePattern` no están soportados. La sonda
independiente Windows Debug (target `tool/windows_accessibility_probe.dart`,
PID 94880) reproduce estos mapeos: `Text` reporta Name; `SelectableText` reporta
el valor completo; `ExpansionTile` con semántica de botón reporta
`Button`/`InvokePattern`, sin HelpText, foco UIA o patrón ExpandCollapse. Los
12 encabezados de la PoC mantienen Name/rol/InvokePattern y orden; licencias y
retorno vía Back siguen verificados. La sonda no determina si la limitación
restante corresponde a Flutter o al proveedor Windows. Voz de Narrator no
capturable desde las herramientas; validación hablada manual pendiente.
Evidencia: `poc/.runtime/windows-accessibility-64884.json` y
`poc/.runtime/windows-accessibility-94880.json` (sintéticos/no versionados).
No se cambió la app ni los tests; no se añade otro arreglo productivo mientras
el comportamiento restante se reproduce en el probe. T-005 continúa en progreso.

`flutter analyze tool/windows_accessibility_probe.dart`: sin issues.
`flutter run -d windows -t tool/windows_accessibility_probe.dart` compiló y
ejecutó el target Debug separado. El inspector se ejecutó para ambas ventanas;
los JSON conservan PID, modo/estado declarado, patrones y resultados de
consulta. `git diff --check` pasó sin errores. App/tests no cambiaron, así que
no se repite la suite Flutter. El PID Release 64884 permanece como instancia
visual disponible; el proceso Debug de la sonda (94880) se cerró al terminar.

Comandos UIA reproducibles, desde `poc/flutter_offline`:

```powershell
pwsh -NoProfile -File .\tool\inspect_windows_accessibility.ps1 -ProcessId 64884 -RunMode Release -InitialState Collapsed
& '..\.runtime\flutter\bin\flutter.bat' run -d windows -t tool/windows_accessibility_probe.dart
pwsh -NoProfile -File .\tool\inspect_windows_accessibility.ps1 -ProcessId 94880 -RunMode Debug -SectionName 'ExpansionTile probe synthetic' -InitialState Collapsed
```
Comando visual Release con `NEXO_DATA_DIRECTORY` independiente:

```powershell
$env:NEXO_DATA_DIRECTORY = 'D:\Nexus\poc\.runtime\privacy-use-b6cb9cb59e624046b3789d99f3b9a71d'
& 'D:\Nexus\poc\flutter_offline\build\windows\x64\runner\Release\nexo_offline_poc.exe'
```

T-005 continúa en progreso. La plataforma Android y la base tecnológica están
confirmadas; versiones, validación productiva y aprobación formal del MVP,
voz Narrator y lectores móviles siguen pendientes.

## Seguimiento T-005 — decisiones de producto y migración de grupos — 5 de octubre de 2026

El usuario confirmó Android primera versión, Flutter/NestJS-TypeScript/
PostgreSQL-Prisma como base y MVP con finanzas personales y grupos PAREJA/FAMILIA
desde el inicio, con migración bilateral. Versiones concretas, validación técnica
y aprobación formal del MVP siguen pendientes. T-005 continúa en progreso.

Se actualizó catálogo vigente a 165 RF + 75 RNF (240); se conserva línea base
histórica v0.2 de 163 RF + 75 RNF (238), con RF-164/165 nuevos y prioridades
propuestas. RNF-052 refleja PAREJA/FAMILIA, sin fijar el máximo familiar. Matriz
MVP: 55 RF completos, 2 parciales, 108 diferidos; adelanta RF-139/142 y añade
RF-164/165 sin cambiar prioridades originales. RF-140/141/143/144 permanecen
diferidos; RF-007 sigue pendiente de depuración.

Arquitectura y CA-I2-11 a CA-I2-17 contienen modelo único, autorización por
recurso, conservación histórica, resolución explícita al convertir FAMILIA con
miembros sobrantes, concurrencia optimista, idempotencia y replay offline. Una
revisión independiente documental comprobó permisos y riesgo de pérdida; no es
revisión de código. Cardinalidad familiar restante, acceso histórico de miembros
salientes, retención, exportación/eliminación y detalles de reglas siguen como
propuestas o pendientes. No se ejecutaron pruebas de producto por ser una
actualización de especificación. Notion se sincronizó en las páginas enlazadas de
RF/RNF, arquitectura, MVP, aceptación I1/I2, evaluación, plan y bitácora; lectura
de regreso confirmó contenido completo, sin truncamiento ni bloques desconocidos.

## Seguimiento T-005 — política experimental de cambio de modo — 5 de octubre de 2026

Se precisó como propuesta experimental que PAREJA→FAMILIA conserva miembros
activos y no implica invitación; incorporar miembros sigue separado y requiere
invitación aceptada. PAREJA admite hasta dos activos; FAMILIA puede conservar
dos. FAMILIA→PAREJA con más de dos activos se rechaza hasta resolver membresías.
Se añadió política pura `evaluateGroupModeChange` y 12 pruebas node:test sobre
conversiones, cardinalidad, autorización confiable, revisión, no-op e inmutabilidad.
Revisión independiente Sol: sin defectos bloqueantes; cobertura de casos faltantes
añadida. `npm test`: build correcto, 16/17 pruebas pasan; la integración PostgreSQL
no pudo conectar con `127.0.0.1:55432`. Las pruebas unitarias no acreditan
persistencia, atomicidad, replay offline ni autorización HTTP. T-005 sigue en
progreso; CA-I2-11 a CA-I2-17 completos siguen pendientes.
