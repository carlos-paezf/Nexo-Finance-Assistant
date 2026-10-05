# 06 — Bitácora y fuentes

[Fuente en Notion](https://app.notion.com/p/3eeaf67c2e9281ae981bd4ca40c4e368?pvs=204)

## 2 de octubre de 2026 — Agentes y eficiencia
A solicitud del usuario, se añadió la política de agentes, selección de modelos y minimización del consumo total de tokens. Se verificaron los modelos y la configuración actual de Codex, la disponibilidad de Impeccable/Ponytail en esta sesión y la instalación de UI UX Pro Max documentada por su autor.
Se prepara el paquete v1.1 con configuración de proyecto y cuatro agentes especializados. La línea base del producto sigue en v0.2: 238 requisitos. No se han medido ahorros reales ni instalado los componentes en la instancia local del usuario. [Política detallada](https://app.notion.com/p/3eeaf67c2e92814ca552db8b0a3093be).
## 2 de octubre de 2026 — Apertura del proyecto
Se creó el proyecto Nexo en Notion con su documentación inicial, a solicitud del usuario.
## Línea base registrada
- v0.1: 144 RF y 66 RNF, según catálogo de la conversación.
- v0.2: incorporación de administración y soporte, RF-145 a RF-163 y RNF-067 a RNF-075.
- Total v0.2: 163 RF, 75 RNF, 238 requisitos; 16 módulos funcionales y 11 categorías no funcionales.
## Fuente primaria
Conversación de definición de Nexo aportada en esta sesión. No se dispone de un enlace público a la conversación; no se inventa uno. El catálogo conserva los códigos y prioridades propuestos, con redacción resumida y normalizada.
## Nivel de validación
El inventario es preliminar. No se ha aprobado el MVP, seleccionado tecnología, verificado tasas comerciales ni realizado una revisión jurídica. No se han implementado funcionalidades.
## Hallazgos
- Solapamiento entre RF-007 y RF-139.
- Cierre de tickets RF-152 propuesto P1 frente a soporte inicial P0; requiere decisión.
- Varios RNF requieren umbrales y condiciones de prueba.
- Restricciones por plataforma de SMS, notificaciones y correo requieren validación técnica.
## Cómo mantener la documentación
Actualizar catálogo y bitácora ante cambios acordados. Registrar decisiones con estado confirmado, propuesto o pendiente. Vincular historias y pruebas a los identificadores existentes. La actualización se realiza durante el trabajo solicitado; no hay sincronización automática de futuras conversaciones.

## 3 de octubre de 2026 — Verificación de INICIO-CODEX.md

Se releyeron AGENTS.md, índice, política local de modelos/agentes, skills y
documentos de MVP. Se consultaron Notion (páginas de proyecto pertinentes),
OpenAI Docs y el repositorio fuente de UI UX Pro Max.

Hallazgos de configuración:
- `.codex/config.toml` y cuatro `.codex/agents/*.toml` presentes. Python
  `tomllib` validó sintaxis y valores configurados. El proyecto declara Luna High,
  máximo dos agentes auxiliares y Luna como modelo auxiliar predeterminado.
- La sesión ofrece Luna y Sol; una delegación/revisión independiente se completó
  con `gpt-6-sol`. La cuenta observada es Plus. Esto no demuestra autenticación en
  otro perfil o instalación.
- Ponytail, Impeccable y UI UX Pro Max aparecen disponibles en esta sesión.
  UI UX Pro Max ya estaba instalada globalmente bajo
  `C:\Users\cpaez\.agents\skills\ui-ux-pro-max`, con `SKILL.md`, datos y scripts.
  No se ejecutó instalador, no se creó duplicado y no se reemplazaron cambios.
- `codex --version` informa 0.142.0. `codex doctor` usó
  `C:\Users\CodexSandboxOffline\.codex`, sin credenciales, e informó fallas de
  conexión/certificados. No permite confirmar la carga de agentes del perfil
  principal. Los TOML son válidos; falta verificarlos desde una sesión nueva y
  autenticada de ese perfil.
- El panel expone porcentajes agregados (ventana 5 h 0%, semanal 12%), no tokens
  de esta tarea. Consumo atribuible: **N/D**.

Revisión financiera Sol encontró y ayudó a corregir tres problemas documentales:
CA-I2-05 confundía el importe de un caso anterior; la liquidación carecía de
clasificación como ingreso/egreso y efecto presupuestario; la frase de I2 podía
incluir los RF parciales. Aritmética de reparto de 100,01 COP verificada.
La regla de liquidación se registra como propuesta pendiente de DEC-008.

Notion se mantuvo actualizado: tres borradores nuevos (MVP, aceptación I1/I2 y
evaluación móvil/PoC) bajo el proyecto; actualización del plan y del estado de
skills/configuración pendiente de verificación final en las páginas 05 y 08.
Los catálogos de 163 RF y 75 RNF se conservaron. Los resúmenes de Notion enlazan
sus fuentes y apuntan a los detalles locales; no afirman pruebas de producto ni
decisiones aprobadas.

## 3 de octubre de 2026 — T-005: PoC Flutter parcial

Se preparó `poc/flutter_offline/` con datos sintéticos y Flutter como candidato
provisional. Incluye saldo inicial y movimientos con centavos enteros; JSON local
escrito a archivo temporal y renombrado; cola persistente; sincronización manual
contra API simulada idempotente; y una pantalla accesible con alta de cuenta,
saldo, historial y estados. Se usó `path_provider` como única dependencia runtime.

Pruebas escritas: 100 movimientos, reapertura del almacén y balance; estados
pendiente/error/sincronizado persistidos; formatos exactos COP; diez reintentos
con un efecto y conflicto por ID reutilizado con payload diferente. Una revisión
independiente Sol halló que la huella idempotente omitía fecha y que faltaba
afirmar persistencia de estados al reabrir; ambos defectos se corrigieron en
código y pruebas. Sin SDK Flutter/Dart en PATH, no se ejecutaron tests, analyzer,
build o app en dispositivo. No se afirma éxito de la PoC en runtime.

No se instalaron dependencias ni herramientas. El archivo local no se cifra;
API solo en memoria; no existe backend, sincronización automática, captura nativa,
prueba Android/iOS física ni verificación de energía/rendimiento. No usar datos
reales. T-005 sigue en progreso; DEC-004, MVP y arquitectura productiva siguen
pendientes. Evidencia y recomendación provisional en
[evaluación móvil](10-evaluacion-tecnologia-movil.md).

Verificaciones de cierre: `flutter --version` y `dart --version` no encontrados;
`flutter pub get`, `flutter test` y `flutter run` no se pudieron ejecutar.
`git diff --check` pasó con avisos LF/CRLF; los controles de consistencia de
archivos/fuente en Python pasaron. No son sustituto del análisis o test Dart.
Consumo de tokens de la tarea: N/D.

## 3 de octubre de 2026 — T-005: API y cliente offline de referencia

Por solicitud del usuario, se amplió el prototipo hacia su preferencia Flutter,
NestJS/TypeScript y PostgreSQL/Prisma. `poc/api/` implementa endpoints para
cuenta, movimientos y saldo con centavos en cadenas JSON, BigInt en servicio y
BIGINT/migración Prisma; IDs estables permiten replay y rechazan distinto
contenido con 409. `poc/flutter_offline/` reemplaza la API simulada por cliente
HTTP, mantiene almacenamiento local versionado, cuenta y cola pendientes, y
conserva separados saldo local provisional y confirmado por servidor.

Entorno verificado: Windows, Node v22.15.0, npm 10.9.2, NestJS 12.1.2, Prisma
7.10.0, TypeScript 5.9.3, PostgreSQL 18 definido en Compose, Flutter
`path_provider` 2.1.6 declarado. Versiones del backend son reproducibles en esta
PoC, no decisiones productivas. `npm test`: build correcto y 4/4 pruebas Node
pasaron (importe exacto, diez repeticiones, conflicto de clave y validación de
centavos). `npm audit` y `npm audit --omit=dev`: 0 vulnerabilidades tras overrides
de deepmerge-ts/mysql2. `npm run test:postgres`: build correcto, prueba omitida
por ausencia de `DATABASE_URL`; Docker está instalado pero el daemon no inició.
No hay evidencia de escritura/recuperación real en PostgreSQL.

`flutter test`: intentado, no ejecutable porque Flutter/Dart no se reconocen en
PATH. Las pruebas Dart de 100 movimientos, recuperación tras reapertura y replay
tras respuesta perdida están escritas pero sin ejecución/análisis/build. No se
validó emulador ni dispositivo Android/iOS físico. `git diff --check` se ejecutó
con avisos de normalización CRLF en docs. La revisión independiente Sol encontró
y se corrigió el riesgo Windows de renombrar sobre destino existente usando
revisiones únicas; los IDs estables y cents-string hacen idempotencia explícita.

Cobertura parcial: RF-016, RF-018, CA-I1-02 y RNF-022 a RNF-025; no se declara
completada sin verificar Flutter/PostgreSQL. Sin auth, control de acceso,
cifrado, segundo plano, captura nativa ni pruebas físicas; no usar datos reales.
T-005 sigue en progreso. Flutter/Nest/Prisma/PostgreSQL siguen preferencia, no
aprobación productiva; versiones, validación técnica y MVP pendientes. Consumo de
tokens de la tarea: N/D.

## 3 de octubre de 2026 — T-005: ejecución y validación en Windows

Preparación: SDK oficial Flutter 3.47.5/Dart 3.13.4 extraído en el área local
ignorada `poc/.runtime`; Windows elegido porque `flutter doctor -v` reconoció
Build Tools 2019 y `flutter devices` mostró el target Windows. Android SDK y
dispositivo físico no disponibles. Se generó scaffold `windows/`; no se cambió
el stack ni la migración. `integration_test` se añadió como dependencia de test
del SDK Flutter, con entradas nuevas en `pubspec.lock`; sus versiones existentes
permanecieron bloqueadas y `flutter pub get --enforce-lockfile` pasó.

PostgreSQL 17.6 quedó en un clúster/DB dedicado a la PoC, host loopback y puerto
55432, bajo `poc/.runtime/postgres-data`; API usa `.env` ignorado con
`DATABASE_URL` local. Se aplicó `20261003000000_init`. `npm test` (build y todos
los tests) pasó 5/5 con PostgreSQL real. La integración levanta NestJS en un
proceso hijo, crea cuenta e ingreso/gasto, reintenta cada operación 10 veces,
confirma balance de 10.765.433 centavos, reinicia el proceso, vuelve a reintentar,
verifica las dos filas y comprueba 409 al reutilizar ID con payload distinto.
La integración limpia la cuenta al terminar. `npm audit`: 0 vulnerabilidades.

Flutter: `pub get --enforce-lockfile` pasó, `analyze` sin issues y `test` 5/5.
`flutter test integration_test/finance_flow_test.dart -d windows` pasó 1/1 con
la app Windows real, conectada a la API y base reales. El recorrido visual crea
cuenta, añade ingreso/gasto, muestra COP 1.187,66, observa error con API caída,
rehidrata cola tras recrear el árbol UI, inicia NestJS y verifica los tres ítems
sincronizados y el saldo del servidor. El test recrea raíz/widget en el mismo
proceso desktop, no cierra y relanza el proceso ejecutable entero. `flutter run`
compiló Windows correctamente. La instancia normal puede levantarse con los
comandos exactos del README de `poc/flutter_offline/`.

Fallos corregidos con evidencia: analyzer encontró errores de sintaxis/typing
que se corrigieron; 100 movimientos expusieron que cleanup podía borrar la
revisión recién escrita por diferencias de path Windows, corregido comparando
nombre del archivo; se corrigió expectativa de orden descendente en historial.
La integración de UI pasó luego de esperar explícitamente la carga asíncrona y
desplazar la lista al verificar elementos fuera del viewport.

T-005 sigue en progreso: falta reinicio de proceso Flutter real, dispositivos
físicos Android/iOS, conectores/captura nativa, permisos, privacidad/auth, cifrado,
background, energía y rendimiento. Flutter + Nest + PostgreSQL/Prisma siguen
preferencia, no stack productivo aprobado; MVP, versiones de producción y DEC-004
pendientes. Datos usados fueron sintéticos; no usar la PoC con datos reales.
Consumo total de tokens atribuible a esta tarea: N/D.

Rama publicada para revisión: [feat/t005-runtime-validation](https://github.com/carlos-paezf/Nexo-Finance-Assistant/tree/feat/t005-runtime-validation).
Commit de implementación/documentación: `eb12ebea0615a33f4a0e09bb3781c86c03fb0c14` —
`test(poc): validate offline flow on Windows`. La rama quedó configurada para
seguir `origin/feat/t005-runtime-validation`; no se abrió PR.

## 5 de octubre de 2026 — T-005: validación de límites y relanzamiento Windows

Se ajustaron formularios y `NexoRepository` al contrato backend: ID ASCII
1–80, nombre de cuenta 1–80, descripción 1–200 e importes exactos hasta
`9223372036854775807` centavos. Las pruebas rechazan datos antes de escribir
cola/archivo. HTTP 400/409 se conserva en disco con causa y sin replay
automático; red/servidor quedan reintentables. La interfaz permite corregir un
movimiento rechazado y reencolarlo con ID nuevo. Conflicto 409 real/corrección
comprobados en flujo Windows.

`flutter analyze` pasó sin issues; `flutter test` 10/10, incluido 100 movimientos,
recuperación y replay; `npm test` 5/5 contra PostgreSQL real. La integración
Windows 1/1 verificó alta, ingreso/gasto, API offline, rechazo 409 con causa,
corrección, sincronización y saldo COP 1.187,66. La primera integración falló
al disponer controladores antes de finalizar la animación del diálogo; al mover
su ciclo de vida al propio diálogo, pasó.

El harness Release en `poc/flutter_offline/tool/verify_windows_restart.ps1`
sembró datos sintéticos, abrió el ejecutable offline, verificó la ventana,
terminó el proceso, reactivó NestJS y relanzó el `.exe`. PostgreSQL confirmó dos
movimientos y saldo 1.122.500 COP en centavos; un segundo cierre/relanzamiento
dejó dos filas. Log local ignorado:
`poc/.runtime/windows-restart-validation.log`. API 3011 e instancia visual final
permanecen abiertas.

`AGENTS.md` mantiene sus instrucciones y añade las reglas de vista ejecutable y
Conventional Commits del PR #1. T-005 sigue en progreso mientras falten
experimentos móviles físicos/nativos. Stack productivo, versiones, DEC-004 y
alcance del MVP siguen pendientes. Datos sintéticos solamente.

## 5 de octubre de 2026 — integración Windows de Privacidad y uso

Se recuperaron los tres archivos de referencia del commit fuente
`545bfa24378cb1ee4641683b831fc7c64ccfec2a`. `main.dart` conserva intactos sus
flujos de cuenta, validación financiera, rechazos, cola y sincronización; solo
incorpora el import y una acción de AppBar que abre la pantalla informativa.
El documento 11 quedó enlazado desde el índice. Sin dependencias nuevas ni
cambios a `pubspec.yaml`/lockfiles.

`flutter analyze`: sin issues. `flutter test`: 12/12, incluyendo cuenta
inexistente con almacenamiento fallido, lectura a escala 200% en 360×800 y
apertura del visor de licencias. El test del 200% necesitó `ensureVisible` para
no pulsar fuera de viewport y liberar SemanticsHandle antes de acabar.
`flutter build windows --release --dart-define=NEXO_API_URL=http://127.0.0.1:3011`
pasó. La ejecución visual Release (PID 24124) abrió la pantalla desde el AppBar
sin cuenta y conserva la ventana abierta. Datos en carpeta independiente; API
existente y otras instancias quedaron intactas. Captura/log locales ignorados:
`poc/.runtime/privacy-use-window.png` y
`poc/.runtime/privacy-use-windows-validation.log`.

Comando para reabrir la misma instancia:

```powershell
$env:NEXO_DATA_DIRECTORY = 'D:\Nexus\poc\.runtime\privacy-use-b6cb9cb59e624046b3789d99f3b9a71d'
& 'D:\Nexus\poc\flutter_offline\build\windows\x64\runner\Release\nexo_offline_poc.exe'
```

T-005 permanece abierta. La pantalla no representa conformidad ni aprobación
productiva; faltan los experimentos móviles y la revisión legal/accesibilidad
integral.

## 5 de octubre de 2026 — pruebas C-12: teclado, contraste y objetivos táctiles

La limpieza del test de lectura al 200% libera `SemanticsHandle` en `finally`;
la liberación sigue ocurriendo antes de navegar al visor de licencias. El test
de teclado inicia en `NexoPocApp`, usa eventos Tab, Shift+Tab, Enter y Espacio,
comprueba apertura, expansión/contracción, foco visible, licencias y retorno.
El test conserva los resets del viewport.

Con el tema Material 3 y la paleta Nexo, el viewport 360×800 y escalas 100%/200%,
pasaron `textContrastGuideline`, `labeledTapTargetGuideline`,
`androidTapTargetGuideline` e `iOSTapTargetGuideline` para contenido expandido
fuera de la vista inicial y el botón de licencias. Verificación final en
`D:\Nexus\poc\flutter_offline`: `flutter analyze` sin issues; `flutter test`
14/14; `git diff --check` sin errores. Pruebas widget automatizadas, no pruebas
en dispositivos Android/iOS ni certificación WCAG. La UI no cambió; se mantienen
la instancia Windows y sus datos sintéticos ya abiertos.

Comando de arranque visual documentado:

```powershell
$env:NEXO_DATA_DIRECTORY = 'D:\Nexus\poc\.runtime\privacy-use-b6cb9cb59e624046b3789d99f3b9a71d'
& 'D:\Nexus\poc\flutter_offline\build\windows\x64\runner\Release\nexo_offline_poc.exe'
```

T-005 continúa en progreso hasta completar los experimentos móviles, revisión
con lectores de pantalla y controles de producción. El MVP y la conformidad
productiva siguen pendientes.

## 5 de octubre de 2026 — cobertura completa C-12 y revisión Narrator

Se eliminó la paleta duplicada de la preparación de pruebas: la comprobación
de escala y guías reutiliza el `ThemeData` extraído de `NexoPocApp`. Con ancho
360 y escalas 100%/200%, el test comprueba vista inicial, 12/12 apartados
expandidos de uno en uno con contenido visible, y botón de licencias. En esos
estados se ejecutan `textContrastGuideline`, `labeledTapTargetGuideline`,
`androidTapTargetGuideline` e `iOSTapTargetGuideline`; mantiene scroll
explícito, verificación de excepciones y liberación del `SemanticsHandle`.
Resultado real: `flutter analyze` sin issues; `flutter test` 14/14;
`git diff --check` sin errores. Los tests de teclado siguen presentes.

La inspección de Narrator quedó bloqueada porque Narrator no estaba activo y
la instancia Windows previamente anotada (PID 24124) no estaba ejecutándose.
No se observaron anuncios, UI Automation ni orden de lectura. Pasos manuales
pendientes y comando de arranque Release con `NEXO_DATA_DIRECTORY` aislado:
abrir la instancia registrada en C-12, iniciar Narrator con Win+Ctrl+Enter,
recorrer título y secciones con teclado verificando nombre/rol/estado y orden,
abrir licencias con Enter y volver comprobando el anuncio de retorno. Sin
cambio de UI de producción, no fue necesario recompilar ni relanzar Windows.
T-005 continúa en progreso; validación nativa, móvil y aprobación productiva
siguen pendientes.

## 5 de octubre de 2026 — recorrido completo y UIA de Narrator

El test recorre los 12 cuerpos a 100%/200% y ancho 360 del comienzo visible
al final, con pasos solapados del 65% de la intersección viewport/Scrollable.
Cada posición ejecuta las cuatro guías y exige que el scroll avance, con tope
de 40 posiciones por cuerpo. Comprueba contención completa de encabezados y
licencias. `matchesSemantics` con `MaterialLocalizations` comprueba el nombre,
acción tap e hints para expandido/contraído, y el cuerpo presente/ausente.

Se creó `tool/inspect_windows_accessibility.ps1`, PowerShell UIA sin
dependencias, limitado a la ventana/PID dado y modo Release/Debug. Registra Name, HelpText, foco,
patrones Text/Value/Legacy/Invoke/ExpandCollapse y resultados tipados como
ausente, no soportado o fallo de consulta. Compara toggle y restaura el estado;
guarda JSON sintético en `poc/.runtime`.

Contra Release PoC PID 64884 y Narrator PID 93912, la sección expandida expuso
su cuerpo completo en ValuePattern.Value. Name/HelpText no reportados en ese
nodo; TextPattern y LegacyIAccessiblePattern no soportados. Se ejecutó además
`flutter run -d windows -t tool/windows_accessibility_probe.dart` en modo Debug
(PID 94880). El probe atribuye a Text un Name; SelectableText ofrece el texto
completo por ValuePattern; ExpansionTile con Semantics button entrega
Button/InvokePattern pero no HelpText, foco UIA ni ExpandCollapsePattern. La
sonda confirma la misma limitación en widgets Flutter genéricos, sin demostrar
si procede del SDK o del proveedor UIA. Licenses/Back/retorno se habían
verificado en evidencia anterior; no se repitieron en esta ejecución. No se modificó app/tests en esta iteración porque no quedó una
brecha exclusiva de PrivacyUsePage; sigue pendiente validación hablada manual.
Evidencia: `poc/.runtime/windows-accessibility-64884.json` y
`poc/.runtime/windows-accessibility-94880.json`; captura de UI expandida:
`poc/.runtime/t005-narrator-expanded.png` (todos locales/no versionados).

`flutter analyze tool/windows_accessibility_probe.dart` terminó sin issues; el
target Debug compiló y se ejecutó, y el inspector pasó en Release y probe.
`git diff --check` pasó sin errores. App/tests no cambiaron, así que no se
repitió flutter test. T-005 continúa en progreso; no se declara conformidad,
aprobación productiva ni validación móvil.

## 5 de octubre de 2026 — decisiones MVP, Android y grupos

El usuario confirmó Android como primera versión y Flutter, NestJS/TypeScript y
PostgreSQL/Prisma como base. Confirmó el núcleo MVP de finanzas personales y
grupos PAREJA/FAMILIA desde el inicio, con migración en ambos sentidos. La
confirmación no fija versiones ni prueba aptitud técnica/productiva; la
aprobación formal del MVP permanece pendiente. T-005 sigue en progreso.

Actualización de trazabilidad: el catálogo actual es 165 RF + 75 RNF (240), con
163 RF + 75 RNF (238) preservados como línea base v0.2 histórica. Se añadieron
RF-164 elección de tipo y RF-165 migración bilateral. Se mantiene el texto y
prioridad original de los 163 RF; P0 en los nuevos IDs es propuesta. RNF-052 se
actualizó para ambos tipos, sin inventar cardinalidad máxima de FAMILIA. La
matriz quedó en 55 completos, 2 parciales y 108 diferidos; incluye RF-139/142 y
RF-164/165, conserva diferidos RF-140/141/143/144 y deja RF-007 pendiente de
depuración.

Se especificó como propuesta un único modelo de grupo, autorización por recurso,
históricos inmutables, resolución sin expulsión automática en FAMILIA→PAREJA,
control de concurrencia, idempotencia y revalidación de cola offline. Revisión
independiente documental: permisos, privacidad y riesgo de pérdida contrastados;
no revisó código. Aún requieren decisión los límites familiares, acceso histórico
de miembros salientes y políticas de retención/eliminación/exportación. CA-I2-11
a CA-I2-17 definen pruebas futuras de tipo, ambas transiciones, acceso indebido,
reintentos, concurrencia, reparto entre tres y preservación histórica; no se han
ejecutado. Notion se sincronizó en las páginas enlazadas de RF/RNF, arquitectura,
MVP, aceptación I1/I2, evaluación, plan y bitácora. La lectura de regreso confirmó
contenido completo, sin truncamiento ni bloques desconocidos.
