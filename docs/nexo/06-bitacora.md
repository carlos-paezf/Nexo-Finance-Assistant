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
