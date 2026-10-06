# 03 — Arquitectura y decisiones

[Fuente en Notion](https://app.notion.com/p/3eeaf67c2e92810da2ceeb9eddf4c898?pvs=204)

## Estado
Borrador de diseño con decisiones de producto confirmadas. El usuario confirmó
Android como primera plataforma, Flutter, NestJS + TypeScript y PostgreSQL +
Prisma como base; también confirmó MVP personal y grupos PAREJA/FAMILIA desde el
inicio con migración bilateral. T-005 conserva experimentos abiertos. Versiones,
validación técnica y aprobación formal del MVP siguen pendientes.
## Organización de la solución
- Aplicación móvil financiera para usuarios.
- Portal web independiente para administración y soporte.
- Plataforma de servicios compartida, con autorización por recurso y separación de permisos administrativos.
- Motor financiero determinístico independiente de la generación de texto con IA.
- Conectores desacoplados para captura, OCR, correo y fuentes de productos.
## Base tecnológica confirmada; detalle técnico pendiente
- Primera plataforma: Android.
- Móvil: Flutter.
- Backend: NestJS + TypeScript.
- Persistencia y acceso a datos: PostgreSQL + Prisma.
- Las versiones concretas, compatibilidad técnica completa, seguridad, rendimiento,
  conectores y aptitud productiva se validan antes de fijar versiones de producción.
- Colaboración: modelo único Group con tipo PAREJA/FAMILIA; la propuesta de
  entidad/campos y reglas de transición sigue sujeta a validación.
- Mercado financiero: condiciones y tasas versionadas, con fuentes verificables.
## Registro de decisiones
### DEC-001 — Aprendizaje de recomendaciones
Estado: confirmado por el usuario. Incorporar retroalimentación y medición de efectividad. Referencias: RF-089 a RF-091; RNF-048.
### DEC-002 — Explorador de ahorro e inversión
Estado: confirmado por el usuario. Comparar tasas y condiciones, estimar beneficios y conservar referencias. Referencias: RF-094 a RF-103; RNF-062 a RNF-066.
### DEC-003 — Administración y soporte
Estado: necesidad confirmada por el usuario. Portal administrativo, ayuda al usuario y centro de errores. Diseño web independiente y controles específicos: propuesta de línea base. Referencias: RF-145 a RF-163; RNF-067 a RNF-075.
### DEC-004 — Base tecnológica y plataforma inicial
Estado: confirmado por el usuario el 5 de octubre de 2026: Android como primera plataforma; Flutter, NestJS + TypeScript y PostgreSQL + Prisma. Las versiones concretas y validación técnica/productiva completa permanecen pendientes; T-005 no se cierra con esta decisión. La elección de base no aprueba reglas financieras propuestas.
### DEC-005 — Eficiencia en el desarrollo con Codex
Estado: principio confirmado por solicitud del usuario; enrutamiento inicial aplicado al paquete de configuración, ajustable por evidencia. Minimizar tokens totales de tareas aceptadas sin reducir calidad, seguridad o rendimiento de la app. Agente principal Luna; especialistas bajo demanda y escalamiento a Sol para cambios críticos. Máximo dos subagentes simultáneos además del principal. Usar Ponytail, Impeccable y capacidades pertinentes; comprobar instalaciones en el proyecto local. [Política de agentes y modelos](https://app.notion.com/p/3eeaf67c2e92814ca552db8b0a3093be).
## Plantilla de decisión futura
Identificador; fecha; estado; problema; alternativas; decisión; justificación; consecuencias; requisitos afectados; responsable y evidencia de aprobación.

## Grupo PAREJA/FAMILIA y migración — propuesta técnica, no decisión de reglas

Decisión de producto confirmada: el MVP incluye finanzas personales y grupos de
tipo PAREJA o FAMILIA desde el inicio; se podrá migrar en ambos sentidos. Se
propone un único `Group` con ID estable y `type`, membresías versionadas y eventos
auditables de cambio. PAREJA conserva dos integrantes conforme al RF-039; FAMILIA
admite múltiples integrantes conforme al RF-139, sin fijar un límite máximo aquí.
RF-164/165 registran elección y migración.

Reglas propuestas para aceptación y diseño: el backend autoriza cada lectura y
escritura por actor, grupo, recurso, acción y permiso vigente. Pertenecer al grupo
no publica cuentas ni movimientos privados (RF-131–133; RB-006). Gasto,
obligaciones, acuerdos y compensaciones compartidos conservan sus IDs e
instantánea de miembros/regla/vigencia; cambiar tipo no recalcula ni reasigna
históricos (RF-040–052; RB-001–003; RNF-042). La salida de un miembro conserva
sus datos personales y trazabilidad; acceso posterior a históricos compartidos,
retención y eliminación requieren regla explícita.

Propuesta experimental para T-005: cambio de tipo y modificación de membresía
son operaciones separadas. La transición de tipo es atómica y condicionada a una
revisión esperada; una revisión obsoleta produce conflicto visible. PAREJA→FAMILIA
conserva las membresías activas actuales y no exige invitar de nuevo. Añadir
miembros es una operación aparte y requiere invitación aceptada. PAREJA admite
como máximo dos miembros activos; FAMILIA puede conservar dos y admite más, sin
máximo definido aquí. FAMILIA→PAREJA con más de dos miembros activos se rechaza
hasta resolver explícitamente las membresías para quedar en cardinalidad válida;
no se expulsa ni elimina a nadie automáticamente.

También son propuestas experimentales: clave de idempotencia estable para
reintentos, rechazo de la misma clave con contenido distinto y revalidación de
identidad, permisos, membresías y revisión al reproducir la cola offline. La
política pura de PoC no demuestra atomicidad, persistencia, autorización HTTP ni
idempotencia de extremo a extremo. El backend debe autorizar cada lectura y
escritura por actor, grupo, recurso, acción y permiso vigente. Las reglas de
producción, cardinalidad familiar y tratamiento de históricos de miembros
salientes siguen pendientes de aprobación.

### Evidencia de persistencia experimental — 5 de octubre de 2026

La PoC añade `Group`, `GroupMembership` y `GroupModeOperation` mediante una
migración aditiva sobre el clúster sintético PostgreSQL existente. La función
interna `GroupModePersistence.change` revalida membresía y permiso desde la base,
bloquea el grupo durante la evaluación, actualiza tipo/revisión de forma
condicionada y guarda el recibo en la misma transacción. La clave se limita al
grupo/actor y su contenido canoniza grupo, actor, destino y revisión esperada;
el permiso se vuelve a comprobar antes de devolver un recibo repetido. Un trigger
temporal creado por la prueba provocó un error al guardar el recibo y confirmó
rollback del cambio.

`npm test` pasó 29/29 pruebas, sin omisiones, contra PostgreSQL real; incluye
11 casos de persistencia, concurrencia e idempotencia. Esta evidencia valida solo
la función interna y las tablas de la PoC. No demuestra autorización HTTP,
identidad de usuarios en producción, invitaciones, cola Flutter, preservación de
históricos financieros compartidos, despliegue ni criterios completos de T-005.
El bloqueo por grupo serializa cambios de tipo de ese grupo en esta PoC. Las
decisiones de producción siguen pendientes. La prueba cubre permiso revocado
antes del replay, no un intercalado controlado de revocación durante una
transición concurrente; el bloqueo compartido de la fila de membresía serializa
esa escritura durante la operación.

### Identidad y autorización HTTP experimental — 5 de octubre de 2026

Una migración aditiva incorpora `User` y `AuthSession`; conserva las tablas y
fixtures anteriores y no convierte automáticamente sus UUID en identidades.
Registro usa UUID generado por PostgreSQL, correo normalizado único y hash
versionado `scrypt` asíncrono (`N=131072`, `r=8`, `p=1`, salt de 16 bytes,
salida de 64 bytes, máximo 192 MiB por operación). El proceso permite un hash
concurrente y 60 intentos por minuto; ambos límites son locales al proceso.
Tokens aleatorios de 32 bytes se almacenan únicamente como SHA-256; las sesiones
persisten expiración de 8 horas y revocación.

`npm test` pasó 38/38 sin omisiones contra PostgreSQL real. Ocho subpruebas HTTP
cubren registro, colisión, credenciales, sesiones, logout, actor de grupo,
rechazo de identidad falsificada, idempotencia y reinicio de API; las once
subpruebas persistentes anteriores siguen pasando. Solo `PATCH
/groups/:groupId/mode` exige Bearer y deriva el actor de la sesión. Los endpoints
financieros continúan sin autenticar; no se demuestra autorización integral,
verificación de correo, recuperación, TLS ni validación Flutter/Android. RF-001,
RF-002 y RF-008 tienen cobertura experimental parcial; T-005 sigue abierto.

### Grupos HTTP y cliente Flutter — experimento de sesión — 5 de octubre de 2026

La migración aditiva `20261005020000_group_name` añade nombre de 1–80
caracteres a `Group` con valor sintético para filas existentes. `POST /groups`
crea UUID de servidor y membresía activa del creador con `canChangeMode` dentro
de una escritura anidada atómica; acepta solo nombre y tipo explícitos y rechaza
identidad, miembros o permisos del cliente. `GET /groups` filtra por membresía
activa del actor autenticado y expone metadata mínima y revisión decimal. Es un
experimento de creador único; invitaciones y miembros adicionales no están
implementados. `PATCH /groups/:groupId/mode` sigue consultando el permiso vigente
en PostgreSQL. Flutter mantiene Bearer en memoria y el AppBar abre la página
«Grupos» sin incorporar grupos a la cola financiera.

La suite `npm test` pasó 39/39 sin skips contra PostgreSQL real, incluyendo
pruebas HTTP de creación/listado, aislamiento entre dos usuarios y rechazo de
campos falsificados. `flutter analyze` no reportó problemas; `flutter test` pasó
22/22. La integración `integration_test/auth_groups_flow_test.dart -d windows`
pasó 1/1 con API NestJS y PostgreSQL reales: registro en la pantalla, inicio de
sesión, creación de ambos tipos, cambios bilaterales desde los controles de UI,
consulta de revisiones y logout. Una revisión independiente Sol de sesión y
permisos confirmó que el refresh serializado bloquea cambio de sesión concurrente,
que se verifica `mounted` antes de usar formularios y que el error de modo se
limpia al reintentar; pruebas nuevas cubren desmontaje durante registro/creación/
logout y aislamiento de listas al cambiar de usuario.

El runtime de inspección queda en Windows Debug con API loopback `127.0.0.1:3023`
y directorio local sintético independiente
`poc/.runtime/t005-auth-groups-20261005`; los comandos reproducibles están en el
README de la PoC Flutter. La ventana Release financiera previa se conservó.
Esto no valida Android ni hardware móvil, almacenamiento seguro de token,
autenticación financiera, verificación/recuperación de cuenta, TLS, invitaciones,
miembros múltiples, grupos offline ni reglas productivas/históricos. La cuenta
del test visual es sintética y sus fixtures PostgreSQL se limpian al terminar.
RF-001/RF-002/RF-008 tienen cobertura parcial; T-005 permanece en progreso.
