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
- [ ] T-005 — Validar Flutter conforme a la preferencia tecnológica del usuario, con API de referencia NestJS/TypeScript y PostgreSQL/Prisma; después probar capacidades de captura por plataforma. PoC parcial; no selecciona stack productivo.
- [ ] T-006 — Diseñar modelo de datos, permisos y sincronización offline.
- [ ] T-007 — Diseñar flujos y pantallas de app y portal administrativo.
- [ ] T-008 — Definir métricas de calidad, carga de referencia, recuperación y política de retención.
- [ ] T-009 — Validar permisos, proveedores, protección de datos y alcance de información financiera externa antes del lanzamiento.
- [ ] T-010 — Crear estrategia de pruebas de motor financiero, privacidad, deduplicación y soporte.
## Secuencia propuesta
1. Cerrar alcance, reglas y permisos.
2. Construir núcleo: usuarios, cuentas, movimientos, finanzas compartidas, presupuestos y metas.
3. Habilitar soporte básico, auditoría y observabilidad junto con el núcleo.
4. Incorporar captura, hábitos, aprendizaje e IA según viabilidad.
5. Incorporar comparación financiera y simulaciones con fuentes verificadas.
6. Ampliar a grupos familiares.
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

## Seguimiento T-005 — 3 de octubre de 2026

**En progreso; no marcar como completada.** Preferencia de referencia del usuario:
Flutter + NestJS/TypeScript + PostgreSQL/Prisma. Se implementó una API mínima y
un cliente Flutter con almacenamiento local y cola durable para datos sintéticos.
`npm test` pasó 4 pruebas Node de balance exacto, validación e idempotencia; el
`npm audit` no reportó vulnerabilidades. `npm run test:postgres` compiló pero
omitió su única prueba por no haber `DATABASE_URL`/servidor. `flutter test` no se
pudo ejecutar: Flutter/Dart no están instalados. Sin pruebas en Android/iOS
físicos. Evidencia detallada en [evaluación móvil](10-evaluacion-tecnologia-movil.md)
y los README de `poc/`.

El código de Flutter comprueba recuperación/reintentos solo cuando sus pruebas
se ejecuten; no atribuir esos criterios como validados todavía. Faltan validar
persistencia e idempotencia reales en PostgreSQL, ejecución Flutter, dispositivos,
seguridad/cifrado, capturas por plataforma, energía y rendimiento. T-005 sigue
abierta; versiones productivas, DEC-004 y aprobación de MVP pendientes.
