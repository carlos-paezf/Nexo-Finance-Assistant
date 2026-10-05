# 08 — Propuesta de MVP y depuración T-001/T-002

**Alcance confirmado parcialmente por el usuario — 5 de octubre de 2026.**
Línea base histórica v0.2: 163 RF y 75 RNF. Catálogo vigente: 165 RF y 75 RNF
(RF-164/165 añadidos sin alterar IDs, redacción ni prioridades originales).
Ningún requisito está implementado por esta actualización documental. La aprobación
formal de todo el MVP sigue pendiente.

## Recomendación de alcance

Alcance confirmado: finanzas personales y grupos tipo PAREJA o FAMILIA desde el
inicio, con posibilidad de migración bilateral. Se conservan el registro manual
en COP, gastos compartidos, saldos, privacidad y funcionamiento offline propuestos.
PAREJA conserva dos integrantes; FAMILIA admite múltiples integrantes, sin fijar
aquí un límite numérico. Las reglas de migración y el resto de alcance del piloto
se especifican abajo como propuestas pendientes de validación. Subgrupos y
presupuestos específicos, dependientes y metas familiares quedan fuera del núcleo
confirmado (RF-141, RF-143, RF-144); roles familiares avanzados RF-140 no se
incluyen automáticamente. No se incluyen integraciones bancarias ni IA.

La distribución vigente de la matriz es **55 RF completos como objetivo, 2
parciales y 108 diferidos** (165 total). Incluye RF-139 y RF-142 para el núcleo
familiar, además de RF-164/165. Los conteos anteriores de 51/2/110 describen la
matriz sobre la línea base de 163. “Completo” describe el alcance objetivo, no
cumplimiento probado. Las prioridades originales permanecen intactas; no hay
estimación de esfuerzo ni fecha comprometida.

El alcance confirmado del producto se conserva: aprendizaje (DEC-001), explorador de ahorro/inversión (DEC-002) y administración/soporte (DEC-003). Diferir su entrega no cancela esas decisiones.

Fuente: [catálogo funcional en Notion](https://app.notion.com/p/3eeaf67c2e92814ba10ac103f880c628) y [arquitectura y decisiones](https://app.notion.com/p/3eeaf67c2e92810da2ceeb9eddf4c898).

## Cobertura de los 165 requisitos funcionales vigentes

La matriz conserva los 163 IDs históricos de v0.2 y añade RF-164/165.

MVP = piloto completo, posterior al incremento interno I1. E1 = evolución temprana propuesta; E2 = evolución posterior sujeta a validación. Cada ID aparece en una sola columna de alcance. Los rangos son inclusivos. La columna de evolución indica el motivo o destino de los diferidos, no una aprobación de calendario.

| Módulo | MVP completo | MVP parcial | Diferido | Motivo o evolución |
| --- | --- | --- | --- | --- |
| Usuarios | RF-001 a RF-006, RF-008 | — | RF-007 | Pendiente T-002: aclarar solapamiento y cardinalidad sin perder trazabilidad |
| Cuentas | RF-009, RF-012 a RF-014 | — | RF-010 a RF-011, RF-015 | E1: crédito y obligaciones |
| Movimientos | RF-016, RF-020, RF-022 a RF-024 | — | RF-017 a RF-019, RF-021, RF-025 a RF-026 | E1: automatización y comodidad |
| Captura | — | — | RF-027 a RF-038 | E1: canales viables; E2: OCR |
| Finanzas compartidas | RF-039 a RF-047, RF-051 a RF-052 | — | RF-048 a RF-050 | E1: aportes, esfuerzo y simulaciones |
| Presupuestos | RF-053 a RF-055 | — | RF-056 a RF-060 | E1: alertas y predicción |
| Metas | — | — | RF-061 a RF-072 | E1: metas básicas; E2: simulaciones avanzadas |
| Asistente IA | — | — | RF-073 a RF-081 | E2: asistente con controles |
| Hábitos | — | — | RF-082 a RF-093 | E2: aprendizaje y hábitos |
| Ahorro e inversión | — | — | RF-094 a RF-103 | E2: fuentes y comparación |
| Simulación | — | — | RF-104 a RF-111 | E2: escenarios financieros |
| Calendario | — | — | RF-112 a RF-119 | E1: vencimientos y recordatorios |
| Analítica | RF-120 a RF-122, RF-129 | — | RF-123 a RF-128, RF-130 | E1: indicadores e informes |
| Privacidad | RF-131 a RF-133, RF-135 a RF-137 | — | RF-134, RF-138 | E2: controles específicos de IA y conectores antes de activarlos |
| Familia | RF-139, RF-142, RF-164 a RF-165 | — | RF-140 a RF-141, RF-143 a RF-144 | Núcleo FAMILIA confirmado; se difieren funciones familiares avanzadas |
| Administración | RF-145 a RF-151, RF-153 a RF-154, RF-157, RF-159 | RF-152, RF-156 | RF-155, RF-158, RF-160 a RF-163 | E1: soporte avanzado; E2: asistente |

### Límites que requieren aprobación explícita

- RF-152 parcial: asignación manual a soporte y cierre con motivo, fecha, actor y estado visible. Escalamiento y reglas automáticas se difieren a E1; el requisito completo continúa pendiente.
- RF-156 parcial: monitorizar API, persistencia y sincronización; conectores se añaden al habilitarlos. No se marca el RF completo mientras falte esa cobertura.
- RF-160 diferido: el MVP no habilita diagnóstico financiero ampliado. Soporte solo accede a metadatos operacionales permitidos. No se interpreta la ausencia del flujo como cumplimiento de RF-160.
- RF-080, RF-081, RF-134 y RF-138 diferidos: sin asistente ni conectores no existen esos flujos. Son condiciones obligatorias antes de activar las capacidades correspondientes; el núcleo debe funcionar sin ellas.
- RF-043 incluido: ingresos declarados, vigencia y consentimiento específico. Compartir la proporción puede permitir inferir ingresos relativos; el grupo no recibe movimientos privados. Proponer ingreso cero permitido, ambos ingresos cero impiden reparto proporcional y exigen elegir otra modalidad; los negativos se rechazan. Confirmar antes de implementar.
- RF-047 incluido: compensaciones registradas con trazabilidad, sin convertirse en gasto nuevo. Pagos parciales, devoluciones y anulación de gastos ya compensados requieren especificación en T-004; su definición y prueba son condición del piloto.
- Precisación propuesta para DEC-008, pendiente de aprobación: la liquidación de una obligación compartida entre integrantes actualiza el saldo por pagar y aparece como evento de compensación/transferencia; no se suma a los ingresos ni egresos consolidados ni al consumo de presupuesto. Debe poder distinguirse del gasto que liquida y actualizar saldos de cuenta.
- RF-051 se adelanta desde P1 para respaldar RNF-042. RF-136 se adelanta desde P1 para permitir salida y portabilidad; no incluye todos los informes de RF-130.
- RF-006 y RF-137 incluidos: salida del grupo y solicitud de eliminación necesitan reglas de conservación compartida, retención y exportación. No prometer borrado inmediato de todo histórico.
- RF-139 y RF-142 se adelantan al núcleo MVP para admitir FAMILIA con múltiples integrantes y distribuir obligaciones. RF-164/165 incorporan elección de tipo y migración bilateral. Se conserva la prioridad original de todos esos RF; incluirlos en alcance no cambia P2 a P0.
- La decisión de producto confirma grupo PAREJA/FAMILIA y migración; no confirma todos los detalles técnicos. Modelo único, revisiones, autorización por recurso, transición atómica, idempotencia, cola offline y preservación de snapshots son propuestas. No reasignar ni recalcular movimientos, saldos, obligaciones o acuerdos históricos al cambiar tipo.
- FAMILIA→PAREJA: propuesta de bloquear si quedan más de dos integrantes hasta registrar resolución explícita. No expulsar ni eliminar miembros automáticamente. Acceso histórico de quien sale, retención, exportación y eliminación siguen pendientes.
- RF-153: estado actualizado visible en la app y aviso dentro de ella; confirmar si se exige push o correo. RF-157: alertas críticas para operadores, independientes de los recordatorios financieros diferidos.

Se difieren expresamente P0 de crédito, lenguaje natural, etiquetas, aportes/esfuerzo al presupuesto, alertas, metas, calendario e indicadores avanzados. Esto reduce el piloto frente al catálogo P0 original y requiere decisión del usuario. Como alternativa, añadir metas básicas RF-061 a RF-066 y RF-070 aumenta el objetivo completo en 7 RF; volver a estimar y especificar relación aporte/movimiento antes de aprobar esa ampliación.

## Requisitos no funcionales y salida del piloto

Fuente: [75 RNF en Notion](https://app.notion.com/p/3eeaf67c2e9281ca8195c8068aa11e0d). Los RNF no se descartan por reducir el MVP.

- Aplicables al núcleo y operación: RNF-001 a RNF-010, RNF-012 a RNF-013, RNF-015 a RNF-020, RNF-022 a RNF-039, RNF-042 a RNF-043, RNF-050 a RNF-061 y RNF-067 a RNF-075.
- Activación condicionada a la funcionalidad diferida: RNF-011, RNF-014, RNF-021, RNF-040 a RNF-041, RNF-044 a RNF-049 y RNF-062 a RNF-066. Mantenerlos como barreras de entrada de captura, IA y proyecciones, sin declararlos satisfechos por ausencia.
- RNF-027, RNF-051 y RNF-059 permanecen como restricciones de diseño: el núcleo no depende de conectores y estos solo podrán incorporarse desacoplados y autorizados.
- Antes del piloto: autorización por recurso probada, importes exactos, sincronización sin duplicados, conflictos visibles, exportación y eliminación especificadas, restauración ensayada, panel con MFA/RBAC, auditoría y procedimientos de incidentes.
- T-008 debe cerrar dispositivos/red/carga, p95, batería/memoria, RPO/RTO, retención y protocolo de accesibilidad. T-009 debe validar privacidad y publicación. Su ausencia impide declarar listo el piloto.

## T-002 — Solapamientos y dependencias

| IDs | Hallazgo | Propuesta y alternativa | Estado |
| --- | --- | --- | --- |
| RF-007 / RF-139 | Ambos describen grupos múltiples; RF-007 no precisa el modo y RF-139 cubre grupos de más de dos. | Mantener los IDs y prioridades históricos; RF-139 se incluye en MVP para núcleo FAMILIA. T-002 aún debe resolver equivalencia o límites distintos sin eliminar trazabilidad. | Alcance familiar confirmado; depuración pendiente |
| RF-152 / RF-149 a RF-153 | Soporte P0 abre tickets, pero cierre aparece P1. | Recomendar asignación y cierre básicos en MVP bajo RF-152 parcial. Alternativa: adelantar RF-152 completo con escalamiento, ampliando alcance. No inventar RF-152a ni cambiar prioridad original. | Pendiente DEC-007 |
| RF-040 / RF-052 | Registro único frente a resultado sin doble conteo. | Mantener separados: persistencia y consolidado; probar ambos con el mismo gasto. | Propuesto, sin renumerar |
| RF-023 / RF-135 / RNF-038 | Corrección y auditoría transversal. | Compartir evidencia; RF-135 también cubre cambios distintos de movimientos. | Complementarios |
| RF-024 / RF-129 | Historial y filtros analíticos. | Reutilizar criterios; no considerar probado el dashboard con una prueba solo de historial. | Complementarios |
| RF-005 / RF-008 / RF-039 / RF-139 / RF-164 / RNF-052 | Invitación, permisos, espacio PAREJA, grupo FAMILIA y tipo explícito. | Mantener el mismo modelo de grupo; diferenciar modo/tipo y autorización. No inferir acceso privado por membresía. | Núcleo de producto confirmado; reglas técnicas propuestas |
| RF-165 / RF-006 / RF-051 / RF-131 / RB-003 / RNF-042 | Migración de tipo, salida, privacidad e históricos. | Mantener identidad; versionar cambio; preservar movimientos/acuerdos y permisos; requerir resolución explícita al reducir a PAREJA. | Dirección confirmada; protocolo y tratamiento de miembros salientes pendientes |
| RF-051 / RNF-042 | Historial P1 necesario para integridad inicial. | Adelantar historial/vigencia de acuerdos y conservar la distribución aplicada a cada gasto. | Propuesto en MVP |
| RF-063 / RF-013 / RF-016 | Un aporte futuro a una meta puede confundirse con nuevo gasto. | Definir vínculo y evitar contabilización adicional antes de E1. | Pendiente T-004 |

El análisis es documental. No cambia las tablas de la línea base histórica v0.2;
la adición vigente de RF-164/165 eleva el catálogo a 165 sin renumerar requisitos.

## Secuencia propuesta

1. **Decisión y especificación:** concretar DEC-005 a DEC-009, cardinalidad FAMILIA, reglas de salida/migración y matriz de permisos; base Android/stack confirmados, versiones y validación técnica pendientes.
2. **I1 interno:** registro personal manual, autenticación, cuentas, transferencias, trazabilidad y cola offline. Datos sintéticos; criterios en [09 — Primer incremento](09-primer-incremento-y-validacion.md). El núcleo de grupos PAREJA/FAMILIA y migración se valida en I2 antes del piloto MVP.
3. **I2 antes del piloto:** completar el núcleo de grupos PAREJA/FAMILIA, migración bilateral, distribuciones/compensaciones, presupuestos, dashboards, permisos compartidos, portabilidad/eliminación y portal de soporte; comprobar todos los RNF aplicables. Los criterios I2 no se consideran ejecutados.
4. **E1:** crédito/obligaciones, metas básicas, calendario, comodidad e informes; captura solo como paquete completo de permisos, extracción, revisión y deduplicación. Sin RF-034 a RF-038 y RF-138 no se activa un canal.
5. **E2:** aprendizaje, IA, explorador y simulaciones según alcance y evidencia; los grupos FAMILIA no se difieren, mientras subgrupos, dependientes y metas familiares siguen fuera del núcleo.

T-001 sigue pendiente de lista aprobada. T-002 tiene recomendación preparada, pero no una depuración aprobada. T-003/T-005 reciben insumos de planificación; no están completadas.

## Decisiones para el usuario

| Decisión | Recomendación | Qué falta resolver |
| --- | --- | --- |
| DEC-005 — MVP | Núcleo confirmado: finanzas personales y grupos PAREJA/FAMILIA desde inicio, con migración bilateral. Matriz actualizada: 55 completos, 2 parciales, 108 diferidos. | Aprobación formal del MVP, esfuerzo/calendario y restantes recortes. RF-007/RF-139 aún requieren depuración. |
| DEC-006 — Grupos | Decisión de producto confirmada: modelo debe ofrecer PAREJA/FAMILIA y migración en ambas direcciones. | Aprobar reglas propuestas de cardinalidad familiar, autorización, salida, concurrencia, idempotencia, cola offline e históricos. No alterar requisitos originales al resolver el solapamiento RF-007/RF-139. |
| DEC-007 — Soporte | RF-152 parcial; RF-156 parcial; RF-160 diferido con denegación absoluta del diagnóstico ampliado. | Confirmar alcance y canal de RF-153. |
| DEC-008 — Reglas financieras | Proponer centavos de COP, mayor residuo y desempate por ID estable; rechazar proporcional si suma de ingresos es cero. | Aprobar precisión, redondeo, consentimiento y tratamiento de compensaciones/salida. |
| DEC-009 — Offline y revocación | Revalidar permisos al sincronizar; rechazar operaciones revocadas conservando borrador privado; datos personales cedidos solo online en piloto. | Aceptar límites de caché compartida y política de retención/purga. Una revocación no borra remotamente un dispositivo desconectado. |
| DEC-004 — Tecnología | Android primera versión; Flutter, NestJS/TypeScript y PostgreSQL/Prisma confirmados. | Versiones concretas, compatibilidad integral, validación técnica/productiva y experiencia/costo del equipo. |

La decisión explícita del usuario confirma el núcleo descrito; no implica aprobación
formal del MVP completo ni convierte las reglas técnicas propuestas en decisiones.

## Fuentes y contraste

Consultados AGENTS.md, INICIO-CODEX.md, índice local, documentos 01 a 06 y MANIFIESTO.json de la raíz. La carpeta raíz contiene documentación; no se encontró código de aplicación ni manifiestos de instalación/pruebas en ella. No existe repositorio Git en D:\Nexus. No se instalaron dependencias ni se modificó implementación.

Notion: [principal](https://app.notion.com/p/3eeaf67c2e928135b4c6dd1d41f06290), [RF](https://app.notion.com/p/3eeaf67c2e92814ba10ac103f880c628), [RNF](https://app.notion.com/p/3eeaf67c2e9281ca8195c8068aa11e0d), [arquitectura](https://app.notion.com/p/3eeaf67c2e92810da2ceeb9eddf4c898), [reglas](https://app.notion.com/p/3eeaf67c2e92815b9783dcec6bee4ade), [plan](https://app.notion.com/p/3eeaf67c2e928101b31dfe0100cbb4d6), [bitácora](https://app.notion.com/p/3eeaf67c2e9281ae981bd4ca40c4e368) y [configuración](https://app.notion.com/p/3eeaf67c2e9281a69455e5410c500fb1).

Comparación automática: las 238 filas de requisitos coinciden en ID, texto y prioridad cuando existe; el cuerpo de arquitectura, reglas y plan coincide tras normalizar saltos de línea. Fechas de edición de las páginas 01 a 06 coinciden con MANIFIESTO.json (2026-10-03 UTC, aún 2 de octubre en Bogotá). La lectura del conector no informó campos de truncamiento/bloques desconocidos; no se interpreta su omisión como certificación. Se recuperaron ambos catálogos completos por conteo de filas.

La página 07 es configuración, no un séptimo catálogo. Se enlaza desde el índice sin copiar instrucciones externas. Los documentos 08 a 10 son borradores locales; sus resúmenes se publicaron en Notion el 3 de octubre. La página de MVP es https://app.notion.com/p/3eeaf67c2e92813aba56cfcb45d9032b. Los detalles de criterios y evaluación móvil se enlazan en el índice. Conciliar cambios futuros queda pendiente.

