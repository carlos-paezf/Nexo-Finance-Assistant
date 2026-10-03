# 03 — Arquitectura y decisiones

[Fuente en Notion](https://app.notion.com/p/3eeaf67c2e92810da2ceeb9eddf4c898?pvs=204)

## Estado
Borrador de diseño. Flutter, NestJS + TypeScript y PostgreSQL + Prisma son la
preferencia tecnológica del usuario y se ejercitan en una PoC acotada. La PoC no
aprueba versiones productivas, validación técnica completa, DEC-004 ni alcance
del MVP. T-005 obtuvo evidencia automatizada en Windows y PostgreSQL 17.6; quedan
pendientes dispositivos físicos, captura por plataforma, seguridad y rendimiento.
## Organización de la solución
- Aplicación móvil financiera para usuarios.
- Portal web independiente para administración y soporte.
- Plataforma de servicios compartida, con autorización por recurso y separación de permisos administrativos.
- Motor financiero determinístico independiente de la generación de texto con IA.
- Conectores desacoplados para captura, OCR, correo y fuentes de productos.
## Tecnologías propuestas
- Móvil: Flutter, preferencia del usuario; selección productiva pendiente.
- Backend: NestJS + TypeScript, preferencia del usuario; validación pendiente.
- Persistencia: PostgreSQL + Prisma, preferencia del usuario; validación pendiente.
- Colaboración: Household, Membership y permisos granulares; propuesta de modelo.
- Mercado financiero: condiciones y tasas versionadas, con fuentes verificables.
## Registro de decisiones
### DEC-001 — Aprendizaje de recomendaciones
Estado: confirmado por el usuario. Incorporar retroalimentación y medición de efectividad. Referencias: RF-089 a RF-091; RNF-048.
### DEC-002 — Explorador de ahorro e inversión
Estado: confirmado por el usuario. Comparar tasas y condiciones, estimar beneficios y conservar referencias. Referencias: RF-094 a RF-103; RNF-062 a RNF-066.
### DEC-003 — Administración y soporte
Estado: necesidad confirmada por el usuario. Portal administrativo, ayuda al usuario y centro de errores. Diseño web independiente y controles específicos: propuesta de línea base. Referencias: RF-145 a RF-163; RNF-067 a RNF-075.
### DEC-004 — Selección tecnológica
Estado: preferencia tecnológica declarada por el usuario el 3 de octubre de 2026: Flutter, NestJS + TypeScript y PostgreSQL + Prisma. La PoC T-005 usa esta combinación con versiones acotadas, sin seleccionar stack de producción. Siguen pendientes versiones productivas, validación técnica, conectores, seguridad, experiencia de equipo y aprobación del MVP. Esta preferencia no aprueba reglas financieras propuestas.
### DEC-005 — Eficiencia en el desarrollo con Codex
Estado: principio confirmado por solicitud del usuario; enrutamiento inicial aplicado al paquete de configuración, ajustable por evidencia. Minimizar tokens totales de tareas aceptadas sin reducir calidad, seguridad o rendimiento de la app. Agente principal Luna; especialistas bajo demanda y escalamiento a Sol para cambios críticos. Máximo dos subagentes simultáneos además del principal. Usar Ponytail, Impeccable y capacidades pertinentes; comprobar instalaciones en el proyecto local. [Política de agentes y modelos](https://app.notion.com/p/3eeaf67c2e92814ca552db8b0a3093be).
## Plantilla de decisión futura
Identificador; fecha; estado; problema; alternativas; decisión; justificación; consecuencias; requisitos afectados; responsable y evidencia de aprobación.
