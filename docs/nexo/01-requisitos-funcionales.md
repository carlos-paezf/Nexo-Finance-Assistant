# 01 — Requisitos funcionales (163)

[Fuente en Notion](https://app.notion.com/p/3eeaf67c2e92814ba10ac103f880c628?pvs=204)

## Línea base v0.2
**163 requisitos en 16 módulos.** Fuente: conversación de definición de Nexo proporcionada por el usuario. Redacción normalizada para consulta, conservando identificadores, contenido y prioridades.
P0: propuesta para MVP; P1: evolución temprana; P2: evolución avanzada. Priorización pendiente de validación.

## Usuarios y autenticación


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-001 | El sistema deberá permitir: Registro por correo. | P0 |
| RF-002 | El sistema deberá permitir: Inicio y cierre de sesión seguros. | P0 |
| RF-003 | El sistema deberá permitir: Recuperación de credenciales. | P0 |
| RF-004 | El sistema deberá permitir: Perfil y preferencias personales. | P0 |
| RF-005 | El sistema deberá permitir: Vincular dos cuentas mediante invitación autorizada. | P0 |
| RF-006 | El sistema deberá permitir: Desvincularse conservando información personal. | P0 |
| RF-007 | El sistema deberá permitir: Grupos con múltiples integrantes. | P2 |
| RF-008 | El sistema deberá permitir: Roles y permisos del grupo. | P0 |


## Cuentas y productos financieros


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-009 | El sistema deberá permitir: Registrar cuentas, billeteras y efectivo. | P0 |
| RF-010 | El sistema deberá permitir: Tarjetas de crédito: cupos, corte y pago. | P0 |
| RF-011 | El sistema deberá permitir: Préstamos, deudas y obligaciones. | P0 |
| RF-012 | El sistema deberá permitir: Administrar saldos. | P0 |
| RF-013 | El sistema deberá permitir: Transferencias propias sin duplicar ingresos ni egresos. | P0 |
| RF-014 | El sistema deberá permitir: Archivar cuentas conservando historial. | P0 |
| RF-015 | El sistema deberá permitir: Registrar cambios de tasas y condiciones de obligaciones. | P1 |


## Movimientos


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-016 | El sistema deberá permitir: Ingresos y egresos manuales. | P0 |
| RF-017 | El sistema deberá permitir: Registro por lenguaje natural escrito. | P0 |
| RF-018 | El sistema deberá permitir: Dictado por voz. | P1 |
| RF-019 | El sistema deberá permitir: Categorización automática. | P1 |
| RF-020 | El sistema deberá permitir: Categorías y subcategorías personalizadas. | P0 |
| RF-021 | El sistema deberá permitir: Etiquetas. | P0 |
| RF-022 | El sistema deberá permitir: Clasificación personal, compartida o transferencia propia. | P0 |
| RF-023 | El sistema deberá permitir: Editar, corregir o anular con trazabilidad. | P0 |
| RF-024 | El sistema deberá permitir: Buscar y filtrar historial. | P0 |
| RF-025 | El sistema deberá permitir: Movimientos recurrentes. | P1 |
| RF-026 | El sistema deberá permitir: Adjuntar soportes y comprobantes. | P1 |


## Captura de movimientos


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-027 | El sistema deberá permitir: Notificaciones bancarias autorizadas en Android. | P1 |
| RF-028 | El sistema deberá permitir: Interpretar alertas de Nu, Nequi y entidades compatibles. | P1 |
| RF-029 | El sistema deberá permitir: Extraer SMS mediante mecanismos autorizados. | P1 |
| RF-030 | El sistema deberá permitir: Capturar correos financieros autorizados. | P1 |
| RF-031 | El sistema deberá permitir: OCR de comprobantes. | P2 |
| RF-032 | El sistema deberá permitir: Importar CSV y Excel. | P1 |
| RF-033 | El sistema deberá permitir: Extraer importe, fecha, entidad, cuenta, descripción y tipo cuando estén disponibles. | P1 |
| RF-034 | El sistema deberá permitir: Detectar duplicados entre canales. | P1 |
| RF-035 | El sistema deberá permitir: Bandeja pendiente de confirmación. | P1 |
| RF-036 | El sistema deberá permitir: Confirmar, corregir o descartar detecciones. | P1 |
| RF-037 | El sistema deberá permitir: Configurar emisores y canales autorizados. | P1 |
| RF-038 | El sistema deberá permitir: Excluir información sensible innecesaria. | P1 |


## Finanzas compartidas


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-039 | El sistema deberá permitir: Espacio conjunto para dos usuarios. | P0 |
| RF-040 | El sistema deberá permitir: Registro único de gastos compartidos. | P0 |
| RF-041 | El sistema deberá permitir: Calcular obligación de cada integrante. | P0 |
| RF-042 | El sistema deberá permitir: Distribución 50/50. | P0 |
| RF-043 | El sistema deberá permitir: Distribución proporcional a ingresos declarados. | P0 |
| RF-044 | El sistema deberá permitir: Porcentajes personalizados. | P0 |
| RF-045 | El sistema deberá permitir: Asignación total a un integrante. | P0 |
| RF-046 | El sistema deberá permitir: Registrar quién pagó. | P0 |
| RF-047 | El sistema deberá permitir: Saldos pendientes y compensaciones. | P0 |
| RF-048 | El sistema deberá permitir: Aportaciones individuales al presupuesto conjunto. | P0 |
| RF-049 | El sistema deberá permitir: Esfuerzo relativo respecto a ingresos. | P0 |
| RF-050 | El sistema deberá permitir: Simular modelos de distribución. | P1 |
| RF-051 | El sistema deberá permitir: Historial de acuerdos y cambios. | P1 |
| RF-052 | El sistema deberá permitir: Evitar múltiples contabilizaciones en consolidados. | P0 |


## Presupuestos


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-053 | El sistema deberá permitir: Presupuestos individuales y compartidos. | P0 |
| RF-054 | El sistema deberá permitir: Límites por categoría y periodo. | P0 |
| RF-055 | El sistema deberá permitir: Consumo y saldo disponible. | P0 |
| RF-056 | El sistema deberá permitir: Alertas por porcentaje del límite. | P0 |
| RF-057 | El sistema deberá permitir: Excesos recurrentes. | P1 |
| RF-058 | El sistema deberá permitir: Proyección al cierre del periodo. | P1 |
| RF-059 | El sistema deberá permitir: Alertas predictivas de excesos. | P1 |
| RF-060 | El sistema deberá permitir: Sugerir ajustes según historial. | P1 |


## Metas


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-061 | El sistema deberá permitir: Metas individuales y conjuntas. | P0 |
| RF-062 | El sistema deberá permitir: Importe, fecha y prioridad. | P0 |
| RF-063 | El sistema deberá permitir: Aportaciones manuales. | P0 |
| RF-064 | El sistema deberá permitir: Aportes por integrante. | P0 |
| RF-065 | El sistema deberá permitir: Avance e importe pendiente. | P0 |
| RF-066 | El sistema deberá permitir: Ahorro mensual necesario. | P0 |
| RF-067 | El sistema deberá permitir: Simular aportaciones y fechas. | P0 |
| RF-068 | El sistema deberá permitir: Impacto de inflación. | P1 |
| RF-069 | El sistema deberá permitir: Categorías populares con referencias del mercado. | P1 |
| RF-070 | El sistema deberá permitir: Varias metas simultáneas. | P0 |
| RF-071 | El sistema deberá permitir: Impacto entre metas por asignación de recursos. | P1 |
| RF-072 | El sistema deberá permitir: Fondo de emergencia. | P1 |


## Asistente financiero con IA


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-073 | El sistema deberá permitir: Consultas en lenguaje natural. | P1 |
| RF-074 | El sistema deberá permitir: Analizar datos financieros autorizados. | P1 |
| RF-075 | El sistema deberá permitir: Recomendaciones contextualizadas. | P1 |
| RF-076 | El sistema deberá permitir: Explicar indicadores y resultados. | P1 |
| RF-077 | El sistema deberá permitir: Oportunidades de ahorro. | P1 |
| RF-078 | El sistema deberá permitir: Alternativas de planificación. | P1 |
| RF-079 | El sistema deberá permitir: Fundamentos y supuestos de recomendaciones. | P1 |
| RF-080 | El sistema deberá permitir: Confirmación antes de registrar o modificar mediante asistente. | P0 |
| RF-081 | El sistema deberá permitir: Desactivar IA conservando funciones básicas. | P0 |


## Hábitos y aprendizaje


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-082 | El sistema deberá permitir: Patrones de gasto potencialmente perjudiciales. | P1 |
| RF-083 | El sistema deberá permitir: Gastos hormiga y compras recurrentes significativas. | P1 |
| RF-084 | El sistema deberá permitir: Incumplimientos presupuestarios frecuentes. | P1 |
| RF-085 | El sistema deberá permitir: Tendencias de endeudamiento y dependencia del crédito. | P1 |
| RF-086 | El sistema deberá permitir: Evolución de hábitos. | P1 |
| RF-087 | El sistema deberá permitir: Planes de mejora personalizados. | P1 |
| RF-088 | El sistema deberá permitir: Retos voluntarios de ahorro. | P1 |
| RF-089 | El sistema deberá permitir: Impacto económico de cambios adoptados. | P1 |
| RF-090 | El sistema deberá permitir: Retroalimentación de utilidad. | P1 |
| RF-091 | El sistema deberá permitir: Adaptar recomendaciones según retroalimentación. | P1 |
| RF-092 | El sistema deberá permitir: Vincular ahorro con metas. | P1 |
| RF-093 | El sistema deberá permitir: Diferenciar patrones individuales y compartidos. | P1 |


## Ahorro e inversión


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-094 | El sistema deberá permitir: Referencias de cuentas remuneradas e inversiones. | P1 |
| RF-095 | El sistema deberá permitir: Tasas y rentabilidades publicadas. | P1 |
| RF-096 | El sistema deberá permitir: Comparar tasas, liquidez, costos, condiciones y riesgos. | P1 |
| RF-097 | El sistema deberá permitir: Fuente y vigencia. | P1 |
| RF-098 | El sistema deberá permitir: Rendimiento bruto por importe, plazo y tasa. | P1 |
| RF-099 | El sistema deberá permitir: Rendimiento neto con costos e impuestos conocidos. | P1 |
| RF-100 | El sistema deberá permitir: Aportaciones periódicas. | P1 |
| RF-101 | El sistema deberá permitir: Relacionar alternativas con metas. | P1 |
| RF-102 | El sistema deberá permitir: Protección de depósitos y riesgos. | P1 |
| RF-103 | El sistema deberá permitir: Comparar según preferencias y restricciones declaradas. | P1 |


## Simulación de decisiones


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-104 | El sistema deberá permitir: Cambios en ingresos y gastos. | P1 |
| RF-105 | El sistema deberá permitir: Compras importantes y nuevas obligaciones. | P1 |
| RF-106 | El sistema deberá permitir: Ahorro frente a amortización de deudas. | P1 |
| RF-107 | El sistema deberá permitir: Disminución temporal de ingresos. | P1 |
| RF-108 | El sistema deberá permitir: Autonomía del fondo de emergencia. | P1 |
| RF-109 | El sistema deberá permitir: Escenarios conservador, base y alternativo. | P1 |
| RF-110 | El sistema deberá permitir: Impacto sobre metas. | P1 |
| RF-111 | El sistema deberá permitir: Variables, limitaciones y supuestos. | P1 |


## Calendario y automatizaciones


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-112 | El sistema deberá permitir: Calendario individual y compartido. | P0 |
| RF-113 | El sistema deberá permitir: Vencimientos y compromisos. | P0 |
| RF-114 | El sistema deberá permitir: Recordatorios de registro. | P0 |
| RF-115 | El sistema deberá permitir: Recordar movimientos pendientes. | P1 |
| RF-116 | El sistema deberá permitir: Vencimientos próximos. | P0 |
| RF-117 | El sistema deberá permitir: Resúmenes diarios, semanales o mensuales. | P1 |
| RF-118 | El sistema deberá permitir: Silencio y frecuencia de notificaciones. | P0 |
| RF-119 | El sistema deberá permitir: Evitar recordatorios de acciones completadas. | P1 |


## Analítica


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-120 | El sistema deberá permitir: Dashboard individual. | P0 |
| RF-121 | El sistema deberá permitir: Dashboard conjunto. | P0 |
| RF-122 | El sistema deberá permitir: Ingresos, egresos y flujo de caja. | P0 |
| RF-123 | El sistema deberá permitir: Comparación de periodos. | P0 |
| RF-124 | El sistema deberá permitir: Capacidad y tasa de ahorro. | P0 |
| RF-125 | El sistema deberá permitir: Gastos fijos y variables. | P0 |
| RF-126 | El sistema deberá permitir: Proporcionalidad entre integrantes. | P0 |
| RF-127 | El sistema deberá permitir: Indicadores de endeudamiento. | P1 |
| RF-128 | El sistema deberá permitir: Evolución de metas y patrimonio registrado. | P1 |
| RF-129 | El sistema deberá permitir: Filtros por fecha, cuenta, categoría y tipo. | P0 |
| RF-130 | El sistema deberá permitir: Exportación de informes y movimientos estructurados. | P1 |


## Privacidad y colaboración


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-131 | El sistema deberá permitir: Separar datos privados y compartidos. | P0 |
| RF-132 | El sistema deberá permitir: Autorizar visualización de datos personales. | P0 |
| RF-133 | El sistema deberá permitir: Revocar permisos. | P0 |
| RF-134 | El sistema deberá permitir: Evitar revelación de información privada por IA. | P0 |
| RF-135 | El sistema deberá permitir: Historial de modificaciones relevantes. | P0 |
| RF-136 | El sistema deberá permitir: Exportar datos personales. | P1 |
| RF-137 | El sistema deberá permitir: Solicitar eliminación conforme a obligaciones legales. | P0 |
| RF-138 | El sistema deberá permitir: Autorizaciones específicas de conectores e IA. | P0 |


## Finanzas familiares


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-139 | El sistema deberá permitir: Grupos de más de dos integrantes. | P2 |
| RF-140 | El sistema deberá permitir: Roles familiares diferenciados. | P2 |
| RF-141 | El sistema deberá permitir: Subgrupos y presupuestos específicos. | P2 |
| RF-142 | El sistema deberá permitir: Distribución entre múltiples participantes. | P2 |
| RF-143 | El sistema deberá permitir: Perfiles dependientes con acceso limitado. | P2 |
| RF-144 | El sistema deberá permitir: Metas familiares y aportaciones múltiples. | P2 |


## Administración y soporte


| ID | Requerimiento | Prioridad |
| --- | --- | --- |
| RF-145 | El sistema deberá permitir: Panel administrativo web independiente. | P0 |
| RF-146 | El sistema deberá permitir: Autenticación administrativa con MFA. | P0 |
| RF-147 | El sistema deberá permitir: Roles y permisos de soporte. | P0 |
| RF-148 | El sistema deberá permitir: Indicadores y estado general. | P0 |
| RF-149 | El sistema deberá permitir: Solicitudes de soporte desde la app. | P0 |
| RF-150 | El sistema deberá permitir: Tickets identificados y trazables. | P0 |
| RF-151 | El sistema deberá permitir: Clasificación por tipo, impacto y prioridad. | P0 |
| RF-152 | El sistema deberá permitir: Asignar, escalar y cerrar. | P1 |
| RF-153 | El sistema deberá permitir: Notificar estado al usuario. | P0 |
| RF-154 | El sistema deberá permitir: Recopilar errores técnicos no sensibles. | P0 |
| RF-155 | El sistema deberá permitir: Agrupar errores repetitivos. | P1 |
| RF-156 | El sistema deberá permitir: Monitorizar API, base de datos, sincronización y conectores. | P0 |
| RF-157 | El sistema deberá permitir: Alertas operativas críticas. | P0 |
| RF-158 | El sistema deberá permitir: Configuraciones operativas con control de acceso. | P1 |
| RF-159 | El sistema deberá permitir: Auditar acciones administrativas sensibles. | P0 |
| RF-160 | El sistema deberá permitir: Diagnóstico ampliado con autorización específica. | P0 |
| RF-161 | El sistema deberá permitir: Base de conocimiento y FAQ. | P1 |
| RF-162 | El sistema deberá permitir: Asistente de soporte. | P2 |
| RF-163 | El sistema deberá permitir: Estadísticas y tiempos de resolución. | P1 |


## Restricciones y observaciones
No se solicitarán contraseñas bancarias, números completos de tarjeta ni CVV. Los conectores dependen de permisos y capacidades de cada plataforma.
RF-007 y RF-139 se solapan en grupos múltiples: se conservan ambos hasta depurar la línea base sin perder trazabilidad. RF-152 sitúa cierre de tickets en P1, aunque un soporte P0 operativo necesita un mecanismo básico de resolución; pendiente de ajustar.
