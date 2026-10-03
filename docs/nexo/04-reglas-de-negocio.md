# 04 — Reglas de negocio y privacidad

[Fuente en Notion](https://app.notion.com/p/3eeaf67c2e92815b9783dcec6bee4ade?pvs=204)

## Reglas iniciales extraídas de la conversación
### RB-001 — Un registro compartido
Un gasto compartido conserva una fuente única y se cuenta una vez en el consolidado. El pagador real y las obligaciones de los integrantes son conceptos diferentes. RF-040, RF-046, RF-052; RNF-037.
### RB-002 — Distribución del gasto
Admitir 50/50, proporcional a ingresos declarados, porcentajes personalizados o asignación total. Definir casos de ingreso cero, ingresos variables, vigencia y ajuste del residuo de redondeo antes de implementar. RF-041 a RF-049; RNF-039.
### RB-003 — Históricos y acuerdos
Los nuevos acuerdos no recalculan automáticamente registros históricos consolidados. Conservar cambios y vigencia. RF-051; RNF-042.
### RB-004 — Transferencias propias
No considerar una transferencia entre cuentas propias como nuevo ingreso o gasto. RF-013.
### RB-005 — Confirmación y deduplicación
Los movimientos detectados pasan por bandeja de revisión; permitir confirmar, corregir o descartar. Detectar duplicados entre canales, conservando evidencia de la decisión. RF-034 a RF-036; RNF-041.
### RB-006 — Privacidad en pareja
La pertenencia al grupo no permite consultar datos privados. Las recomendaciones y hallazgos individuales no se comparten sin autorización. RF-131 a RF-134; RNF-012.
### RB-007 — Soporte limitado
Por defecto, soporte consulta datos operacionales: versión, sistema operativo, error, fecha, identificador y estado de sincronización. Diagnóstico ampliado exige autorización específica, alcance, motivo, vencimiento y auditoría. Excluir secretos, OTP, credenciales y datos bancarios sensibles. RF-160; RNF-069, RNF-075.
### RB-008 — IA y cálculos
Cálculos críticos determinísticos. La IA explica evidencia y supuestos; solicita confirmación para registrar o modificar. RF-079 a RF-081; RNF-043 a RNF-046.
### RB-009 — Bienestar y voluntariedad
Los planes y retos son voluntarios y adaptados al contexto. Evitar restricciones perjudiciales sobre alimentación, salud y gastos esenciales. RF-087, RF-088; RNF-047.
### RB-010 — Productos y proyecciones
Registrar fuente, fecha y condiciones; diferenciar rentabilidad garantizada y no garantizada. Separar resultados brutos y netos estimados. No usar ejemplos de tasas como ofertas verificadas. RF-095 a RF-102; RNF-040, RNF-062 a RNF-066.
### RB-011 — Oportunidades de ahorro
Antes de sugerir el destino del ahorro, considerar obligaciones, liquidez, fondo de emergencia, horizonte y tolerancia al riesgo declarada. No ejecutar operaciones automáticamente.
### RB-012 — Independencia comercial
Identificar patrocinios y referidos; impedir que alteren encubiertamente criterios de comparación. RNF-065.
## Casos pendientes de especificación
Reembolsos, devoluciones, pagos parciales, anulación de gastos compensados, salida del grupo, aportes a metas vinculados a movimientos, conflictos offline y permisos al terminar una autorización.
