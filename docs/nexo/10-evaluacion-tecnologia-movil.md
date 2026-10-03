# 10 — Evaluación de tecnología móvil

**Recomendación provisional — 2 de octubre de 2026. DEC-004 sigue pendiente.**
Requisitos: RF-016, RF-018, RF-026 a RF-038; RNF-006, RNF-018, RNF-020 a RNF-025, RNF-051, RNF-057, RNF-059 a RNF-061.

## Recomendación

Usar **Flutter como candidata para la prueba de concepto** del núcleo móvil offline y los adaptadores nativos de captura Android, conforme a la preferencia tecnológica registrada en Notion el 3 de octubre de 2026. La selección definitiva de móvil sigue pendiente en DEC-004. La documentación oficial ofrece patrones de datos locales/remotos y canales hacia código de plataforma; no prueba que sea más rápido, barato o seguro que Ionic.

Si el equipo ya domina Angular/TypeScript y puede mantener adaptadores Kotlin/Swift, **Ionic + Angular + Capacitor** es una alternativa igualmente viable que puede reducir aprendizaje. No se conoce la experiencia del equipo ni se han medido tiempos. El portal web independiente no obliga a compartir framework con móvil.

La preferencia de stack registrada en Notion es Flutter, NestJS + TypeScript y PostgreSQL + Prisma. No se aprobaron versiones, dependencias productivas, backend ni base de datos; esta PoC no los valida.

## Comparación basada en requisitos

| Criterio | Flutter | Ionic + Angular + Capacitor | Consecuencia para Nexo |
| --- | --- | --- | --- |
| Datos offline: RNF-022 a RNF-025 | Guía oficial para combinar fuentes local/remota y reintentar sincronización [F1]. | Requiere seleccionar y validar almacenamiento local y lógica de sincronización; el puente nativo permite integrar SDKs [C1]. | En ambos: cola persistente, idempotencia, conflictos y permisos son responsabilidad del producto. No vienen resueltos por elegir framework. |
| Captura Android: RF-027/RF-028 | Canales de plataforma conectan Dart con código Android/iOS [F2]. | Plugins Android integran SDKs desde Java/Kotlin [C1]. | Ambos pueden envolver el mismo servicio nativo; ninguno garantiza acceso a contenido bancario. |
| Segundo plano: RNF-018/RNF-020 | Procesos en segundo plano mediante isolates y mecanismos de plataforma [F3]. | Background Runner documenta límites del sistema y frecuencia no garantizada [C2]. | Sincronizar al abrir/reanudar y recuperar conectividad; no prometer captura ni sincronización continua. |
| Datos sensibles: RNF-002/RNF-006 | Elegir almacenamiento protegido y validar plugins. | Igual requisito; no asumir que preferencias o almacenamiento web basten para datos financieros. | Exigir PoC de persistencia, cierre de sesión y aislamiento entre usuarios. |
| Equipo y portal | Añade Dart si el equipo no lo conoce; el portal mantiene decisión propia. | Posible reutilización de conocimientos TypeScript/Angular si existen. | Preferencia Flutter anotada en Notion; experiencia del equipo y coste de mantenimiento siguen sin medirse. |
| Android/iOS: RNF-057/RNF-061 | Sujeto a permisos y APIs nativas. | Sujeto a los mismos permisos y APIs nativas. | El framework no elimina diferencias de capacidad entre plataformas. |

[F1] [Flutter: Offline-first support](https://docs.flutter.dev/app-architecture/design-patterns/offline-first).
[F2] [Flutter: Platform channels](https://docs.flutter.dev/platform-integration/platform-channels).
[F3] [Flutter: Background processes](https://docs.flutter.dev/packages-and-plugins/background-processes).
[C1] [Capacitor: Android Plugin Guide](https://capacitorjs.com/docs/plugins/android).
[C2] [Capacitor: Background Runner](https://capacitorjs.com/docs/apis/background-runner).
Fuentes primarias consultadas durante esta tarea. La guía estable de Capacitor consultada indica v8; eso no aprueba fijar una versión.

## Captura por plataforma y límites de evidencia

| Canal | Evidencia consultada | Propuesta de alcance |
| --- | --- | --- |
| Notificaciones Android, RF-027/RF-028 | Android ofrece NotificationListenerService, con restricciones de dispositivo/perfil y servicio [A1]. | PoC con permiso explícito, emisores permitidos y notificaciones sintéticas. Validar contenido disponible por banco/versión con autorización antes de prometer Nu o Nequi. No confundir permiso de mostrar notificaciones propias con permiso de leer otras. |
| Notificaciones iOS, RNF-057/RNF-061 | User Notifications y su extensión de servicio gestionan notificaciones dirigidas a la propia app [A2]. | Inferencia de diseño: no basar captura bancaria iOS en lectura general de notificaciones ajenas; no se verificó una API pública que la habilite. Mantener entrada manual y explorar importación autorizada. |
| SMS Android, RF-029 | Google Play restringe permisos SMS y contempla gestión de dinero basada en SMS como posible excepción sujeta a revisión [A3]. | No afirmar prohibición absoluta ni aprobación de Nexo. Confirmar elegibilidad, declaración y alternativa menos invasiva antes de incluirlo; no es requisito de arranque del MVP. |
| SMS iOS, RF-029 | IdentityLookup se presenta como filtrado/reporte de SMS y llamadas; no documenta aquí un importador financiero general [A4]. | No comprometer lectura general del buzón. La página dinámica no entregó detalle suficiente para una validación de viabilidad. Queda pendiente investigación específica si el canal se vuelve prioritario. |
| Correo, RF-030 | No se investigaron proveedores ni permisos OAuth en esta tarea. | Evaluar API oficial, permisos mínimos, revocación y retención en E1. No leer un buzón sin autorización ni inferir capacidad por framework. |
| OCR, voz y archivos, RF-018/RF-026/RF-031/RF-032 | No se validaron motores ni plugins concretos. | Evaluación separada: selección explícita de archivo/imagen, permisos mínimos, deduplicación y confirmación. No elegir dependencias hasta especificar formatos y privacidad. |

[A1] [Android: NotificationListenerService](https://developer.android.com/reference/android/service/notification/NotificationListenerService).
[A2] [Apple: User Notifications](https://developer.apple.com/documentation/usernotifications).
[A3] [Google Play: SMS/Call Log permissions](https://support.google.com/googleplay/android-developer/answer/10208820?hl=en).
[A4] [Apple: SMS and Call Reporting](https://developer.apple.com/documentation/identitylookup).

La política de Play consultada muestra también un aviso de cambio futuro sobre verificación por llamadas con vigencia anunciada para enero de 2027; no se toma ese aviso como permiso SMS aprobado ni como regla ya efectiva para Nexo. Esta revisión técnica no certifica aceptación en tiendas.

## Sincronización propuesta, independiente del framework

- Base local protegida y operaciones pendientes durables; ID estable por operación creado antes del envío.
- El servidor valida identidad, permisos vigentes y versión; confirma una sola operación por ID. Reusar ID con otro contenido produce conflicto.
- Conservar versiones ante edición concurrente y pedir resolución explícita; evitar sobrescritura financiera silenciosa.
- Reintentar al reanudar/recuperar conexión, con estado visible. Segundo plano como mejora sujeta al sistema operativo.
- RNF-018: medir menos de 5 s con dos apps activas y red de referencia, sujeto a aprobación del alcance. Capacitor documenta intervalos de tareas repetidas Android de al menos 15 minutos e intervalos iOS no garantizados [C2]; no confundirlos con sincronización interactiva.
- Autorizaciones revocadas se rechazan al reenviar. Definir purga de caché al reconectar y limitar datos personales cedidos a lectura online en el piloto. Datos ya vistos o almacenados por un dispositivo desconectado no se pueden retirar instantáneamente.

Estas son propuestas de comportamiento, no un diseño de tablas o servicios aprobado.

## Prueba de concepto propuesta para T-005

Usar datos sintéticos y un Android físico y un iPhone físico; registrar versiones/modelos y probar al menos dos fabricantes Android si la captura pasa a alcance. Disponibilidad de entorno de compilación iOS pendiente; esta tarea no lo inspecciona ni configura.

| Experimento | Criterio de decisión | Evidencia requerida |
| --- | --- | --- |
| Persistencia offline | Crear 100 movimientos, terminar/reabrir la app y recuperar los 100 sin pérdida. | Conteos, integridad de importes y estado de cola. |
| Reintentos/conflictos | Diez reintentos por ID no duplican; dos ediciones incompatibles se conservan para resolución. | Casos CA-I1-09/10 y pruebas del servidor. |
| Puente Android | Con permiso concedido, capturar evento sintético compatible; al revocarlo, dejar de ingerir nuevos eventos. | Prueba por dispositivo, sin payload privado en logs. Separar app suspendida de detención forzada. |
| Reanudación/energía | Medir latencia, batería, memoria y red en activo, suspensión y ahorro de energía. | Resultados separados; T-008 fija umbrales antes de declarar aprobación. |
| Seguridad | Tokens y caché protegidos, cambio de usuario aislado, permiso revocado rechazado al sincronizar. | Pruebas negativas de CA-I1-07/11 y CA-I2-06. |
| Paridad útil iOS | Registro manual, persistencia y reanudación funcionan aun sin captura de alertas externas. | Evidencia en iPhone físico; no simular equivalencia de conectores. |

Comenzar con Flutter si no hay preferencia técnica informada; contrastar Ionic si hay experiencia web existente o la PoC revela coste excesivo. Elegir según requisitos críticos superados y coste real de mantener almacenamiento/conectores, no por una puntuación inventada. Si ningún candidato cumple, revisar la arquitectura o el alcance antes de aprobar DEC-004.

## Resultado parcial de T-005 — 3 de octubre de 2026

La preferencia tecnológica del usuario es Flutter + NestJS/TypeScript + PostgreSQL/Prisma. La PoC en `poc/` ejercita el flujo sintético cuenta/movimientos: el cliente Flutter mantiene operaciones locales con centavos exactos, cola durable y sincronización HTTP; NestJS expone alta, registro y consulta de saldo con claves idempotentes; Prisma define migración PostgreSQL y persistencia en `BIGINT`. UI calmada, controles legibles y estados textualizados. Solo runtime Flutter `path_provider`; backend versiones de reproducción en su `package.json` y lockfile.

**Verificación ejecutada en Windows:** Node 22.15.0/npm 10.9.2. `npm test` compiló Prisma Client 7.10.0 y TypeScript y pasó 4 pruebas Node: saldo COP exacto, diez repeticiones sin duplicar, conflicto 409 por mismo ID/diferente payload, y rechazo de decimal/desbordamiento. `npm audit` y `npm audit --omit=dev` reportaron 0 vulnerabilidades después de actualizar overrides transitivos. `npm run test:postgres` compiló y reportó 1 prueba omitida por falta de `DATABASE_URL`/servidor; Docker daemon no está disponible. Por ello no se probó la idempotencia real de Postgres ni reinicio del proceso backend.

`flutter test` se intentó desde `poc/flutter_offline/` y falló porque el comando Flutter no se reconoce; tampoco están instalados Flutter/Dart. Las pruebas Dart para 100 movimientos, reapertura local y reintento tras respuesta perdida existen, pero **no están ejecutadas**. No se generaron proyectos de plataforma, ni se hizo validación en dispositivos físicos Android o iOS. `git diff --check` se ejecutó; reporta solo advertencias de conversión de fin de línea CRLF en archivos de documentación.

Los requisitos de referencia son RF-052/CA-I1-02 para exactitud aritmética; RF-016 y RF-018 para consulta/registro y disponibilidad como cobertura parcial de UX; RNF-022 a RNF-025 para persistencia offline/sincronización; y RNF-020/RNF-021 para interfaz/accesibilidad. Sin ejecución Flutter y DB, la cobertura runtime de estos criterios queda pendiente. Los requisitos de autorización (CA-I1-07/11, CA-I2-06), conflictos concurrentes, seguridad cifrada, privacidad por usuario, sincronización en segundo plano, captura por plataforma, energía, rendimiento y prueba física no están cubiertos por la PoC.

**Recomendación:** continuar esta ruta para completar T-005: ejecutar tests Flutter y la integración con PostgreSQL, luego Android/iOS físicos. La evidencia disponible favorece construir sobre la preferencia informada, pues Nest compila con Node 22.15 y las pruebas unitarias de dominio pasan; no compara costo de equipo ni valida runtime/DB/móvil. Versiones fijadas son solo reproducibles para este prototipo, no productivas. DEC-004, validación técnica completa, MVP y decisiones productivas continúan pendientes. Sin autenticación, cifrado local o permisos; no usar datos reales.

