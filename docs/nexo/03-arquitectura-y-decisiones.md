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
