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
- [ ] T-005 — Seleccionar tecnología móvil y validar con prueba de concepto las capacidades de captura por plataforma.
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

## Cierre de cada iteración — regla confirmada el 3 de octubre de 2026
El usuario solicita seguimiento visual de la app y un commit después de cada
iteración. Para cambios en la app, entregar una instancia ejecutable con datos
sintéticos, preferentemente Flutter Web para revisión visual, y emulador o
dispositivo para capacidades nativas. Registrar plataforma, URL o comando de
arranque, flujo revisado y verificaciones pendientes.

Después de las verificaciones y actualización documental, crear un commit
coherente conforme a [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).
Entregar su SHA y mensaje. Separar cambios ajenos y evitar commits vacíos.
Las instrucciones permanentes están en AGENTS.md. Si no es posible ejecutar la
app, registrar el bloqueo; la vista previa no se considera validada.

