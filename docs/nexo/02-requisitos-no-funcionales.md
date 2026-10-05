# 02 — Requisitos no funcionales (75)

[Fuente en Notion](https://app.notion.com/p/3eeaf67c2e9281ca8195c8068aa11e0d?pvs=204)

## Línea base v0.2
**75 requisitos en 11 categorías.** Fuente: conversación proporcionada. Los objetivos de medición son iniciales y requieren condiciones de prueba y umbrales completos antes de aprobar la especificación.

## Seguridad


| ID | Requerimiento |
| --- | --- |
| RNF-001 | HTTPS/TLS vigente en comunicaciones cliente-servidor. |
| RNF-002 | Cifrado apropiado en reposo de información financiera. |
| RNF-003 | Hash resistente y específico para contraseñas. |
| RNF-004 | Autorización backend en cada operación privada o compartida. |
| RNF-005 | No solicitar ni almacenar credenciales bancarias, CVV ni información sensible innecesaria. |
| RNF-006 | Tokens en almacenamiento seguro del sistema operativo. |
| RNF-007 | Eventos de seguridad sin datos confidenciales. |
| RNF-008 | Mínimo privilegio en permisos, servicios e integraciones. |


## Privacidad y protección de datos


| ID | Requerimiento |
| --- | --- |
| RNF-009 | Ajustarse a legislación colombiana aplicable, especialmente Ley 1581 de 2012 y reglamentación; validación jurídica pendiente. |
| RNF-010 | Privacidad desde el diseño y por defecto. |
| RNF-011 | Minimizar datos de SMS, correos y notificaciones. |
| RNF-012 | Pertenecer al grupo no concede acceso a datos privados. |
| RNF-013 | Autorizaciones específicas, informadas, verificables y revocables cuando corresponda. |
| RNF-014 | Controles contractuales y técnicos de proveedores IA sobre tratamiento, conservación y uso. |
| RNF-015 | Políticas de retención, exportación y eliminación. |


## Rendimiento


| ID | Requerimiento |
| --- | --- |
| RNF-016 | Registro manual simple en menos de 10 segundos en pruebas de usabilidad. |
| RNF-017 | Consultas principales inferiores a 2 segundos en p95 bajo carga de referencia por definir. |
| RNF-018 | Movimientos compartidos visibles en ambos dispositivos en menos de 5 segundos con conexión estable. |
| RNF-019 | Analítica mediante agregaciones y paginación. |
| RNF-020 | Consumo controlado de batería, memoria y datos; umbrales pendientes. |
| RNF-021 | Procesar alertas externas sin bloquear la interfaz. |


## Disponibilidad y resiliencia


| ID | Requerimiento |
| --- | --- |
| RNF-022 | Consulta sin conexión de información sincronizada. |
| RNF-023 | Almacenamiento temporal de registros creados sin conexión. |
| RNF-024 | Sincronización idempotente con identificadores para evitar duplicados. |
| RNF-025 | Conflictos simultáneos sin pérdida silenciosa de datos. |
| RNF-026 | Copias de seguridad y recuperación verificable. |
| RNF-027 | Fallas de conectores sin impedir registro manual ni funciones básicas. |


## Usabilidad y accesibilidad


| ID | Requerimiento |
| --- | --- |
| RNF-028 | Priorizar información crítica y minimizar carga cognitiva. |
| RNF-029 | Adaptación a resoluciones y tamaños de pantalla. |
| RNF-030 | WCAG 2.2 AA como referencia aplicable; alcance y pruebas pendientes. |
| RNF-031 | No comunicar estados únicamente con color. |
| RNF-032 | Gráficos con títulos, unidades, leyendas y alternativas textuales. |
| RNF-033 | Menor número razonable de interacciones frecuentes. |
| RNF-034 | Lenguaje claro y explicación de conceptos técnicos. |
| RNF-035 | Formato COP y convenciones colombianas. |


## Integridad financiera


| ID | Requerimiento |
| --- | --- |
| RNF-036 | Importes con representación decimal exacta; evitar flotantes. |
| RNF-037 | Fuente única para movimientos compartidos. |
| RNF-038 | Trazabilidad de correcciones relevantes. |
| RNF-039 | Redondeo explícito y verificable de distribuciones. |
| RNF-040 | Separar capital, rendimiento bruto, costos, impuestos y neto estimado. |
| RNF-041 | Validación y deduplicación de importaciones. |
| RNF-042 | Cambios de acuerdos sin alterar automáticamente históricos consolidados. |


## IA responsable


| ID | Requerimiento |
| --- | --- |
| RNF-043 | Cálculos críticos mediante lógica determinística verificable. |
| RNF-044 | Fundamentos, supuestos y limitaciones de recomendaciones. |
| RNF-045 | No inventar movimientos, saldos, productos, tasas ni fuentes. |
| RNF-046 | No convertir recomendaciones automáticamente en operaciones sin autorización. |
| RNF-047 | Hábitos contextualizados sin juicios descalificadores. |
| RNF-048 | Aprendizaje de retroalimentación con controles de privacidad. |
| RNF-049 | Distinguir educación, simulaciones y recomendaciones de servicios de asesoría que pudieran estar regulados; alcance jurídico pendiente. |


## Arquitectura y mantenibilidad


| ID | Requerimiento |
| --- | --- |
| RNF-050 | Separar presentación, negocio, persistencia e integraciones. |
| RNF-051 | Conectores SMS, correo, notificaciones, OCR y entidades desacoplados. |
| RNF-052 | El modelo admite grupos PAREJA y FAMILIA. PAREJA se limita a dos integrantes; FAMILIA admite múltiples integrantes. La cardinalidad familiar restante debe definirse antes del piloto, sin asumir un máximo. |
| RNF-053 | Pruebas unitarias e integración de componentes críticos. |
| RNF-054 | Migraciones versionadas. |
| RNF-055 | Observabilidad y diagnóstico sin datos sensibles. |
| RNF-056 | Evolución sin comprometer históricos financieros. |


## Interoperabilidad


| ID | Requerimiento |
| --- | --- |
| RNF-057 | Contemplar Android e iOS respetando restricciones. |
| RNF-058 | Exportación estructurada interoperable. |
| RNF-059 | Integraciones oficiales o expresamente autorizadas. |
| RNF-060 | Uso de app sin integración bancaria. |
| RNF-061 | Identificar capacidades exclusivas por plataforma. |


## Información financiera externa


| ID | Requerimiento |
| --- | --- |
| RNF-062 | Fuente y fecha de consulta de tasas y condiciones. |
| RNF-063 | Identificar referencias desactualizadas; no presentarlas como ofertas vigentes verificadas. |
| RNF-064 | Diferenciar tasas promocionales, variables, fijas y rentabilidades no garantizadas. |
| RNF-065 | Criterios transparentes sin favorecer patrocinios encubiertos. |
| RNF-066 | Declarar capitalización, inflación, aportaciones y condiciones de proyecciones. |


## Operación administrativa y soporte


| ID | Requerimiento |
| --- | --- |
| RNF-067 | Aislamiento lógico del panel respecto a app de usuario. |
| RNF-068 | MFA y RBAC administrativos. |
| RNF-069 | Anonimizar o seudonimizar reportes cuando corresponda y eliminar datos sensibles. |
| RNF-070 | Auditoría no alterable por operadores ordinarios. |
| RNF-071 | Retención y acceso controlado en observabilidad. |
| RNF-072 | Fallas de soporte sin bloquear núcleo financiero. |
| RNF-073 | Diagnósticos con impacto mínimo en batería, rendimiento y red. |
| RNF-074 | Procedimientos documentados de incidentes críticos de seguridad. |
| RNF-075 | Correlación por identificadores técnicos sin datos financieros privados. |


## Métricas por completar
Definir carga concurrente, tamaño de historial, dispositivos y red de referencia; disponibilidad objetivo; RPO/RTO; límites de batería y memoria; retención de logs; frecuencia de actualización de fuentes; protocolo de accesibilidad y restauración.
Las menciones a normativa y estándares documentan el alcance preliminar; no constituyen una revisión de vigencia o cumplimiento.
