# 09 — Primer incremento y validación

**Borrador — 2 de octubre de 2026. No implementado ni probado en producto.**
Relacionado con T-001, T-003, T-004, T-006, T-008 y T-010.

## Objetivo y alcance I1

Incremento interno con datos sintéticos: una persona se autentica, registra ingresos/gastos en sus cuentas, transfiere entre ellas y recupera lo registrado tras perder conexión. El MVP incluye también I2; I1 no es un lanzamiento ni satisface la matriz completa.

- Objetivo completo en I1: RF-001 a RF-004, RF-009, RF-012 a RF-014, RF-016, RF-020, RF-023 a RF-024.
- Cobertura parcial en I1: RF-022 (personal/transferencia, compartido en I2), RF-131 (aislamiento entre propietarios, separación compartida en I2), RF-135 (trazabilidad de operaciones disponibles, resto en I2).
- I2 completa los demás RF previstos como completos en [08 — MVP](08-propuesta-mvp-y-depuracion.md), incluidos soporte, pareja y presupuestos. RF-152 y RF-156 mantienen la cobertura parcial descrita allí; ninguna cobertura parcial cuenta como RF completo.
- Seguridad y offline se diseñan desde I1: RNF-001 a RNF-008, RNF-010, RNF-015 a RNF-017, RNF-020, RNF-022 a RNF-026, RNF-028 a RNF-031, RNF-033 a RNF-036, RNF-038, RNF-043, RNF-050, RNF-053 a RNF-057, RNF-060.
- Dependencias para empezar implementación: DEC-004 tecnológica, DEC-005 alcance y decisiones relevantes DEC-008/009; precisar moneda, permisos, almacenamiento local, retención y contratos de sincronización. No elegir automáticamente NestJS, Prisma ni PostgreSQL.

## Criterios de aceptación propuestos de I1

Los casos describen pruebas futuras. Los importes son datos de prueba, no ofertas o asesoría financiera.

| Caso y trazabilidad | Dado / cuando | Resultado esperado y evidencia futura |
| --- | --- | --- |
| CA-I1-01 — RF-001 a RF-004; RNF-003, RNF-006 | Una persona se registra, entra, actualiza preferencias, sale y recupera acceso. | Flujos exitosos y errores controlados; recuperación de un solo uso y caducada rechazada; sesión cerrada no autoriza llamadas; tokens no aparecen en logs. Prueba de integración y revisión de almacenamiento. |
| CA-I1-02 — RF-009, RF-012, RF-016; RNF-036, RNF-043 | Cuenta con saldo inicial 100.000,00 COP; ingreso 20.000,00 y gasto 12.345,67. | Saldo exacto 107.654,33; ingreso del periodo 20.000,00 y gasto 12.345,67; el saldo inicial no crea ingreso del periodo. Rechazar importes inválidos y precisión excesiva según DEC-008. |
| CA-I1-03 — RF-013, RF-022; RB-004 | A tiene 100.000,00 y B 0,00; transferencia propia de 30.000,00. | A = 70.000,00, B = 30.000,00, patrimonio total constante; ingresos/egresos del periodo no aumentan. Operación atómica: ningún fallo deja solo una parte aplicada. |
| CA-I1-04 — RF-023, RF-135; RNF-038 | Gasto 100,00 se corrige a 80,00 y después se anula. | Efecto final cero, sin borrar historial; actor, fecha, motivo y versiones consultables. Reintentar corrección/anulación no aplica efecto dos veces. |
| CA-I1-05 — RF-014, RF-024; RNF-056 | Cuenta con movimientos se archiva. | Historial permanece y puede buscarse; propuesta: nuevos registros en la cuenta archivada se rechazan hasta reactivación. Definir si reactivación se incluye antes de programarla. |
| CA-I1-06 — RF-020, RF-024 | Hay categorías y subcategorías personales; se filtra por categoría y periodo. | Resultados y totales corresponden solo al filtro y propietario; vacíos y límites de periodo explícitos. Cambiar categoría preserva trazabilidad y no altera importe. |
| CA-I1-07 — RF-131; RNF-004, RNF-008, RNF-010 | Usuario B conoce el ID de cuenta o movimiento privado de A e intenta leer, editar, anular o buscarlo. | Backend deniega todas las rutas, consultas y agregaciones; sin exposición de saldos, títulos ni existencia innecesaria. Probar también sin sesión y con sesión revocada. |
| CA-I1-08 — RNF-022, RNF-023, RNF-002 | Tras sincronizar, se desconecta, crea 10 registros y reinicia la app. | Consulta datos propios en caché y recupera los 10 registros pendientes sin pérdida; estado pendiente visible; almacenamiento financiero protegido. Cambiar de usuario no expone caché anterior. |
| CA-I1-09 — RNF-024; RF-016, RF-013 | La API confirma una operación pero la respuesta se pierde; se reintenta 10 veces con el mismo ID. | Un único efecto persistido y un único resultado estable. El mismo ID con contenido distinto se rechaza. Probar gastos y transferencia de dos partes. |
| CA-I1-10 — RNF-025, RNF-038 | Dos dispositivos editan la misma versión de un gasto antes de sincronizar. | Una edición se confirma; la otra se informa como conflicto con ambas versiones y resolución explícita. Ninguna política de última escritura borra silenciosamente datos. |
| CA-I1-11 — RNF-004, RNF-024 | Sesión revocada o cuenta archivada antes de reenviar la cola. | Servidor revalida sesión, recurso y versión; no aplica la operación. Borrador permanece privado y visible para resolverlo tras autenticar al propietario. |
| CA-I1-12 — RNF-016, RNF-028 a RNF-031, RNF-033 a RNF-035 | Usuario registra un gasto simple en la plataforma candidata con teclado y lector de pantalla. | Propuesta de protocolo: 5 participantes, 3 registros por persona tras una práctica; medir desde formulario abierto hasta confirmación. Todos los registros válidos en menos de 10 s; cualquier incumplimiento se documenta. Etiquetas accesibles, foco visible, error en texto y formato COP correcto. Alcance WCAG aún por completar. |
| CA-I1-13 — RNF-017, RNF-019 | Consulta de historial con paginación y filtros. | Propuesta de carga: 20 sesiones concurrentes, 10.000 movimientos por usuario, 100 lecturas por sesión, red 100 ms RTT; p95 inferior a 2 s. Registrar hardware, versión, resultados y errores; cifras de carga pendientes de T-008. |
| CA-I1-14 — RNF-026, RNF-055 | Restaurar una copia en entorno aislado y forzar errores de registro/sincronización. | Saldos y conteos coinciden con la copia; medir tiempo y pérdida potencial para fijar RPO/RTO. Logs conservan correlación técnica sin importes privados, texto libre, credenciales o tokens. |

## Criterios adicionales obligatorios antes del piloto I2

| Caso y trazabilidad | Escenario | Resultado esperado |
| --- | --- | --- |
| CA-I2-01 — RF-005, RF-006, RF-008, RF-039; RNF-012, RNF-052 | Invitación aceptada, repetida, caducada y a un tercer integrante; salida de uno. | Solo aceptación autorizada vincula dos cuentas; terceros rechazados; salir conserva datos propios y deniega nuevas operaciones compartidas según política aprobada. |
| CA-I2-02 — RF-040 a RF-047, RF-052; RNF-036, RNF-037, RNF-039 | A paga 100.000,00 al 50/50; luego B registra compensación de 50.000,00 a A. | Consolidado de gasto = 100.000,00 una sola vez; obligaciones 50.000,00 por persona, deuda inicial B→A 50.000,00 y saldo pendiente final 0. La compensación actualiza los saldos de cuenta y se registra como liquidación, pero no crea ingreso, egreso consolidado ni consumo de presupuesto para ninguna persona. |
| CA-I2-03 — RF-041 a RF-045; RNF-039 | Gasto 100,01 repartido 50/50, proporcional 2:1, personalizado 60/40 y asignación total. | Propuesta con unidad 0,01: 50,01 + 50,00; 66,67 + 33,34; 60,01 + 40,00; 100,01 + 0,00. Mayor residuo y empate por ID estable; porcentajes inválidos rechazados; ingreso cero probado según DEC-008. |
| CA-I2-04 — RF-051; RNF-042 | Acuerdo cambia de 50/50 a 60/40 tras consolidar el gasto. | Importe y obligaciones históricas permanecen intactos; nuevos gastos usan acuerdo vigente y conservan su versión. |
| CA-I2-05 — RF-053 a RF-055, RF-120 a RF-122, RF-129; RNF-037 | Presupuesto 200.000,00; incluir el gasto compartido de 100.000,00 descrito en CA-I2-02, la liquidación de 50.000,00 de ese caso y una transferencia entre cuentas propias. | Consumo compartido 100.000,00 y disponible 100.000,00; la liquidación y transferencia propia no añaden ingreso, egreso consolidado ni consumo de presupuesto. Vistas personal/conjunta y filtros coherentes sin sumar dos veces el gasto. |
| CA-I2-06 — RF-131 a RF-133; RNF-004, RNF-012, RNF-013 | Pareja solicita datos privados, recibe permiso específico y luego se revoca. | Sin permiso: denegación; con permiso: solo alcance; tras revocar: nuevas lecturas/escrituras denegadas. Probar también búsquedas, exportación y cola offline. Definir y medir purga al reconectar sin prometer borrado instantáneo offline. |
| CA-I2-07 — RF-145 a RF-151, RF-152 parcial, RF-153, RF-159; RNF-067, RNF-068, RNF-070 | Usuario abre ticket; operador entra con MFA, clasifica, asigna y cierra con motivo. | Identificador y estados trazables, aviso visible al usuario; actor ordinario no altera auditoría. Operador sin rol no accede; usuario no ve tickets ajenos. |
| CA-I2-08 — RF-154, RF-156 parcial, RF-157; RNF-055, RNF-069, RNF-072, RNF-075 | Caen soporte o sincronización; se intenta consultar datos financieros desde soporte. | Núcleo sigue registrando; errores y alertas usan datos operacionales mínimos. Diagnóstico ampliado siempre denegado al estar RF-160 diferido; adjuntos/textos del ticket requieren minimización. |
| CA-I2-09 — RF-136, RF-137; RNF-015, RNF-058 | Usuario exporta y solicita eliminación con gastos compartidos. | Exportación propia estructurada sin datos privados ajenos; solicitud rastreable y ejecutada conforme a política aprobada. Evidenciar tratamiento de copias, auditoría y registros compartidos retenidos. |
| CA-I2-10 — RNF-018, RNF-020 | Dos dispositivos conectados y activos reciben un movimiento compartido. | Visible en ambos en menos de 5 s bajo red de referencia; 100 registros propuestos para medición. Medir aparte suspensión/reanudación, batería y datos; no extrapolar a ejecución continua en segundo plano. |

RNF-018 no limita el tiempo mientras un sistema operativo suspende la app. Esta delimitación es propuesta para aprobación; si se exige 5 s también suspendida, T-005 debe demostrar viabilidad antes de aceptar el requisito.

## Evidencia y condiciones de cierre

Cada prueba futura conservará versión, plataforma/dispositivo, datos sintéticos, pasos, resultado y evidencia sin secretos. Exigir casos positivos, negativos y reintentos, no solo capturas de pantalla. Umbrales aún pendientes impiden declarar cumplimiento del RNF.

La tarea actual solo verifica consistencia documental, cobertura de IDs y enlaces locales. No hay comandos de build/test de aplicación identificados en esta carpeta documental. Estos casos no se han ejecutado; la prueba de concepto tampoco.

Fuentes: [RF](https://app.notion.com/p/3eeaf67c2e92814ba10ac103f880c628), [RNF](https://app.notion.com/p/3eeaf67c2e9281ca8195c8068aa11e0d), [reglas de negocio](https://app.notion.com/p/3eeaf67c2e92815b9783dcec6bee4ade) y [plan](https://app.notion.com/p/3eeaf67c2e928101b31dfe0100cbb4d6). Las precisiones operativas y métricas adicionales de este documento son propuestas nuevas.

