# 11 — Legal, privacidad y accesibilidad

[Seguimiento en Notion](https://app.notion.com/p/3f0af67c2e9281cf9f2ed4e6fe3b7bdb)

Fecha de revisión: **5 de octubre de 2026**. Ámbito de referencia: Colombia,
Flutter Windows de PoC y futura evaluación Android/iOS. Base inspeccionada:
`f1ada910bb6b4912201a9e2d0941f01b0283dc43`.

El usuario pidió incorporar los doce temas siguientes. Este documento añade
controles de seguimiento **C-01 a C-12**; conserva la línea base de 163 RF y
75 RNF, sus ID y el alcance del MVP pendiente. Los controles no se cuentan como
doce funcionalidades implementadas. T-009 y el nuevo T-011 permanecen abiertos.

## Resultado de la auditoría

"Presente" significa cobertura documental previa, no cumplimiento del producto.
Los faltantes se incorporan aquí y en la pantalla informativa de la PoC. Los
borradores productivos siguen sujetos a completar datos y revisión jurídica.

| Control / tema | Evidencia previa | Aplicación en esta iteración | Pendiente para producción |
| --- | --- | --- | --- |
| C-01 Privacidad y datos personales | RF-131 a RF-138; RNF-009 a RNF-015 | Inventario, borrador de política y aviso factual en la app | Responsable/contacto; autorización verificable; derechos; retención; cifrado y acceso |
| C-02 Términos y condiciones | Sin texto explícito | Condiciones de prueba y borrador de términos | Operador, elegibilidad, oferta, vigencia, soporte y aceptación versionada |
| C-03 Propiedad intelectual | Sin inventario ni titularidad explícitos | Procedimiento para código, marca, textos y recursos | Titulares, contratos/cesiones y uso permitido de marca |
| C-04 Permisos y accesos | RF-037, RF-138; RNF-005, RNF-008, RNF-011, RNF-059, RNF-061 | Matriz de accesos actuales y reglas para captura futura | Pruebas de rechazo/revocación por plataforma; autorización distinta del permiso del SO |
| C-05 Licencias y condiciones de la app | Lockfiles; sin LICENSE de Nexo | Visor nativo de licencias de componentes y revisión de metadatos backend | Licencia de Nexo/EULA y avisos de todas las piezas distribuidas |
| C-06 Cookies | Sin política explícita; no cookies en la PoC | Política aplicable al prototipo y condición de revisión para web/SDK | Inventario y preferencias si se incorpora seguimiento |
| C-07 Publicidad | RNF-065; RB-012 | Política sin anuncios en PoC; identificación de patrocinios futuros | Modelo comercial, SDK, autorizaciones y declaraciones en tiendas |
| C-08 Derechos propios y de terceros | Integraciones autorizadas RNF-059 | Procedencia de recursos, respeto de datos ajenos y canal previsto | Evidencia de permisos y canal real de reclamación |
| C-09 Funcionalidades lícitas | RNF-005, RNF-049, RNF-059 | Límite del prototipo y criterio de revisión de conectores/servicios | Evaluación jurídica según funciones efectivamente ofrecidas |
| C-10 Privacidad y geolocalización | Privacidad/minimización genéricas; ubicación no especificada | Ubicación no recolectada; reglas de finalidad y mínima precisión | Justificación, permisos, conservación y pruebas si se propone ubicación |
| C-11 Markets | RF-094 a RF-103 cubren productos financieros; RNF-057 cubre plataformas | Criterios para tiendas y explorador financiero | Mercados/países, declaraciones, publicación y evaluación financiera |
| C-12 Accesibilidad | RNF-028 a RNF-035; WCAG 2.2 AA como referencia | Pantalla desplazable, controles Material y pruebas widget escritas | Ejecutarlas; auditoría de toda la app, teclado y lectores en dispositivos |

## C-01 — Política de privacidad y tratamiento de datos

### Información vigente del prototipo

La finalidad actual es experimentar registro manual, persistencia y
sincronización con **información inventada**. El usuario conserva una copia en
la carpeta de soporte de Flutter; al accionar sincronización se envían datos a
la API configurada, que escribe en PostgreSQL. No hay proveedor IA, publicidad,
analítica, geolocalización ni conectores bancarios en el flujo inspeccionado.

| Información | Destino actual | Finalidad / conservación actual |
| --- | --- | --- |
| Nombre e ID de cuenta; saldo inicial | Archivo local y PostgreSQL tras sincronización | Crear cuenta sintética y calcular saldo; sin caducidad automática |
| ID de movimiento/cuenta, descripción, ingreso/gasto, centavos y fecha | Archivo local y PostgreSQL tras sincronización | Registro, saldo y replay idempotente; sin caducidad automática |
| Estado de sincronización, saldo confirmado y versión del archivo | Archivo local | Recuperar cola y distinguir saldos; sin caducidad automática |
| Huella de solicitud y fechas técnicas | PostgreSQL | Idempotencia y orden; sin caducidad automática |
| Registros técnicos del entorno | Consola/configuración local | Deben inspeccionarse antes de definir una política productiva de logs |

El archivo local **no está cifrado**; no hay usuarios ni autorización por
recurso. La API utiliza HTTP y el código base escucha en `0.0.0.0`; no asumir
que queda aislada por usar localhost en el cliente. Mantener pruebas en un
entorno restringido y con datos sintéticos. Estos límites no se corrigen con
un aviso legal. No hay exportación, rectificación, eliminación de cuenta ni
plazo automático implementados. Borrar el archivo local no borra PostgreSQL.

### Borrador productivo — no vigente para datos reales

Completar y revisar antes de recolectar información personal:

- **Responsable:** [PENDIENTE: nombre/razón social, identificación aplicable,
  domicilio, teléfono, correo y área de protección de datos]. No usar el nombre
  de usuario de GitHub como identificación jurídica.
- **Finalidades:** administrar cuenta y registros; calcular saldos; sincronizar
  y dar soporte dentro del alcance autorizado. Separar finalidades opcionales
  de conectores, IA, marketing y ubicación; no inferirlas del uso del núcleo.
- **Derechos y trámite:** conocer, actualizar y rectificar; solicitar prueba de
  autorización e información de uso; acceso gratuito en los términos legales;
  revocación/supresión cuando procedan y reclamación ante SIC tras agotar el
  trámite aplicable. Canal [PENDIENTE]. Consultas: 10 días hábiles, ampliación
  máxima de 5 con aviso; reclamos: 15, ampliación máxima de 8 con aviso.
- **Proveedores/destinos:** [PENDIENTE: encargados, países, contratos,
  transferencias/transmisiones y propósitos]. Declarar el tratamiento real,
  incluidos SDK y datos de diagnóstico; no prometer ausencia de terceros por
  tener una base propia.
- **Conservación y seguridad:** [PENDIENTE: plazo por categoría, fundamentos de
  excepciones, eliminación de réplicas/backups, cifrado, TLS, autenticación,
  autorización y controles operacionales]. Una obligación de conservación se
  explica; no se promete borrado inmediato universal.
- **Vigencia y cambios:** [PENDIENTE: fecha de entrada en vigor, duración de la
  base y política, versiones]. Informar cambios sustanciales antes de aplicarlos
  y obtener nueva autorización cuando corresponda.

La pantalla informativa no registra consentimiento. El producto deberá ofrecer
el texto antes de recolectar datos, evidencia de autorización por finalidad y
versión cuando se requiera, y mecanismos para ejercer derechos. No usar casillas
premarcadas ni unir permisos del dispositivo a autorización de tratamiento.

Referencias: [Ley 1581, arts. 8–9, 12, 14–17 y 26](https://www.alcaldiabogota.gov.co/sisjur/normas/Norma1.jsp?i=49981)
y [Decreto 1074, sección 2.2.2.25](https://normograma.sena.edu.co/compilacion/docs/decreto_1074_2015_pr027.htm).

## C-02 — Términos y condiciones de uso

**Condiciones informativas de la PoC:** prueba con datos sintéticos de cuenta,
ingresos/gastos, saldo y sincronización manual. El saldo local incluye
pendientes; el confirmado corresponde a la consulta de API. No se realizan
pagos, préstamos, inversiones ni conexión bancaria. No hay oferta comercial,
suscripción o compromiso de disponibilidad. Los límites técnicos se muestran
de forma expresa; no se incluye una renuncia general a derechos del usuario.

**Borrador del servicio futuro:** identificar operador y contacto; alcance
efectivamente habilitado; requisitos de acceso y tratamiento de menores;
responsabilidades de uso; proceso de aceptación por versión; soporte y
reclamaciones; suspensión justificada, cierre y recuperación/exportación de
datos; vigencia, cambios y régimen aplicable. Si se cobran servicios, concretar
precio total, impuestos, renovación, cancelación y derechos del consumidor
aplicables antes de contratar. Datos y decisiones comerciales: **pendientes**.
No redactar limitaciones que supriman derechos irrenunciables.

Referencia según oferta real: [Ley 1480, información, publicidad, contratos y
comercio electrónico](https://normograma.invima.gov.co/compilacion/docs/ley_1480_2011.htm).

## C-03 / C-08 — Propiedad intelectual y derechos

Mantener por recurso autor/titular, procedencia, permiso o contrato, licencia,
restricciones y avisos. Comprende código propio/aportado, marca Nexo, logo,
iconos, fuentes, textos, imágenes, tasas y contenido externo. Conservar evidencia
de cesiones o autorizaciones cuando corresponda. El acceso al repositorio no
resuelve la titularidad ni las condiciones de distribución.

No reutilizar logos bancarios, contenido, datos o API por el solo hecho de ser
visibles en internet. Revisar las condiciones de la fuente antes de importar,
mostrar o redistribuir información. Las licencias de componentes no transfieren
derechos sobre marcas o datos ajenos. Definir un canal [PENDIENTE] para reclamos
de titularidad/contenido, recepción de evidencia, revisión y respuesta. No
atribuir a Nexo propiedad sobre información aportada por una persona.

Referencia de documentación de autor/titular y transferencias:
[DNDA — registro de software](https://www.derechodeautor.gov.co/es/registro-de-software).
La auditoría no afirma que exista un registro de Nexo ni exige registrarlo para
continuar la PoC.

## C-04 / C-10 — Permisos, accesos y geolocalización

| Acceso | PoC actual | Regla para futura incorporación |
| --- | --- | --- |
| Carpeta privada de soporte | `path_provider`; lectura/escritura de JSON | Mantener alcance de app; cifrar datos reales y comprobar aislamiento |
| Red / API | HTTP mediante `dart:io`; endpoint configurable | TLS y control de acceso productivos; inventario de destinos |
| SMS y notificaciones ajenas | No implementados ni solicitados | Vía permitida por SO/tienda; finalidad y alcance mínimos; exclusión de OTP |
| Correo | No implementado | OAuth/alcances mínimos, autorización específica y revocación |
| Cámara, archivos externos, contactos, micrófono | No implementados ni solicitados | Justificar cada acceso antes de añadirlo; selector del SO cuando baste |
| Ubicación precisa/aproximada y segundo plano | No recolectada ni solicitada | Por defecto desactivada; sin solicitud preventiva |

El producto debe explicar el beneficio y destino de los datos antes de pedir
un acceso opcional, solicitarlo al usar la función y conservar el registro
manual si se deniega. Probar rechazo, revocación desde ajustes, expiración y
reinicio; detener la captura futura al perder autorización. Un permiso del SO
no habilita lectura ilimitada ni legitima una integración prohibida.

Para ubicación futura: justificar necesidad, preferir aproximada/solo durante
uso si basta, declarar conservación y compartición y separar segundo plano.
No inferir ubicación para publicidad a partir de los datos financieros. No hay
manifiestos Android/iOS generados en la base; verificarlos junto con cada plugin
y SDK antes de afirmar sus permisos efectivos.

## C-05 — Licencias y condiciones de uso de la app

No se encontró una licencia de distribución de Nexo en la base. Decidir licencia
del código y condiciones de uso de la app por separado; revisar su compatibilidad
con aportaciones y dependencias. No añadir MIT, una EULA o una declaración de
titularidad sin esa decisión.

La pantalla nueva usa `showLicensePage`, el visor del SDK, sin dependencias
nuevas. Presenta licencias **registradas por los componentes Flutter** en la
compilación; no acredita exhaustividad ni incluye el servidor o PostgreSQL.

Revisión de metadatos del `package-lock.json` fijado, sin evaluación jurídica de
compatibilidad ni extracción de todos los textos:

| Dependencia directa backend | Versión fijada | Licencia declarada en el lockfile |
| --- | --- | --- |
| @nestjs/common, @nestjs/core, @nestjs/platform-express | 12.1.2 | MIT |
| @prisma/adapter-pg, @prisma/client | 7.10.0 | Apache-2.0 |
| dotenv | 16.6.1 | BSD-2-Clause |
| pg | 8.23.1 | MIT |
| reflect-metadata | 0.2.2 | Apache-2.0 |
| rxjs | 7.8.2 | Apache-2.0 |

Las transitivas incluyen otras licencias; `busboy` 1.6.0 y `streamsearch` 1.1.0
no tienen el campo de licencia en este lockfile. Eso no significa que carezcan
de licencia. Pendiente inspeccionar LICENSE/NOTICE de los paquetes reales,
SDK Flutter/Dart, plugins, artefactos nativos, PostgreSQL y herramientas
efectivamente distribuidas; conservar los avisos y resolver obligaciones antes
de distribuir cada artefacto. El auditor de vulnerabilidades no valida licencias.

## C-06 — Política de cookies

La PoC Windows inspeccionada no usa cookies, WebView, analítica ni SDK de
seguimiento. Su JSON de recuperación local no es una cookie y no requiere añadir
un banner de cookies al flujo nativo actual.

Antes de incorporar una web, WebView o SDK: inventariar cookie/identificador,
proveedor, propósito, duración y datos/destinos; determinar si es necesario u
opcional. Informar el almacenamiento necesario. Mantener seguimiento opcional
desactivado hasta la autorización que resulte aplicable; permitir rechazar y
cambiar preferencias de forma accesible. Una política web no cubre por sí sola
todos los identificadores de una app nativa. Revisar por país objetivo.

## C-07 — Publicidad

La PoC no integra anuncios, identificadores publicitarios, SDK ni seguimiento.
Si se proponen anuncios, afiliados o referidos: identificar el patrocinador y la
relación comercial, separar resultado patrocinado de comparación independiente
y explicar criterios. Evitar promesas de rendimiento o publicidad engañosa.
La incorporación exige revisar datos compartidos, consentimiento aplicable,
políticas de SDK y declaraciones de las tiendas. No destinar por defecto datos
financieros a segmentación comercial. RNF-065 y RB-012 siguen vigentes.

Referencia: [Ley 1480, arts. 29–30](https://normograma.invima.gov.co/compilacion/docs/ley_1480_2011.htm).

## C-09 — Funcionalidades lícitas

La prueba actual solo registra información sintética; no intermedia operaciones.
No solicitar credenciales bancarias, CVV ni OTP. Cada conector requiere una vía
oficial o autorización expresa y cumplimiento del SO/tienda; un permiso técnico
no sustituye esos requisitos. El acceso a SMS o notificaciones no se añade en
esta iteración.

El explorador, IA, educación, simulaciones y recomendaciones están pendientes;
documentar finalidad, fuentes, supuestos y límites. Si una función real implica
asesoría, intermediación, préstamos, pagos, captación u otra actividad regulada,
evaluar su régimen y habilitaciones antes de ofrecerla. Una frase de exención
en términos no convierte una función regulada en no regulada. RNF-049.

## C-11 — Markets: tiendas y productos financieros

"Markets" se cubre en ambos sentidos hasta concretar los canales de lanzamiento.
No publicar esta PoC de datos sintéticos como app productiva.

Para **Google Play**: política de privacidad pública y dentro de la app,
declaración de seguridad de datos coherente con código/SDK y declaración de
funciones financieras; revisar permisos/captura y requisitos de eliminación
si se ofrece crear cuentas de usuario. Para **App Store**: política accesible,
declaraciones de datos y SDK, permisos justificados, eliminación de cuentas
cuando aplique, derechos de distribución y condiciones de licencia. Si se
incorpora seguimiento sujeto a ATT, evaluar y solicitar autorización antes.
No confundir la cuenta contable de la PoC con una cuenta autenticada de usuario.

Definir países, público/edad, canales, responsable y modelo comercial antes de
completar declaraciones. Revisar las políticas vigentes con la compilación
real; no declarar "no recopila datos" porque exista almacenamiento local,
pues también hay envío a API. No se enviaron formularios ni se publicó en tiendas.

Para el **explorador de productos financieros**: conservar RF-094 a RF-103,
RB-010/RB-012 y RNF-049/RNF-062 a RNF-066. Fuente y derechos de uso, fecha,
costos, impuestos, riesgos, capitalización, vigencia y patrocinios deben ser
visibles; no presentar tasas de ejemplo como oferta verificada ni ejecutar
operaciones automáticamente. El módulo permanece sin implementar.

Fuentes: [Google Play — User Data](https://support.google.com/googleplay/android-developer/answer/10144311),
[declaración financiera](https://support.google.com/googleplay/android-developer/answer/13849271),
[Financial Services](https://support.google.com/googleplay/android-developer/answer/9876821)
y [Apple — App Review](https://developer.apple.com/app-store/review/guidelines/).

## C-12 — Accesibilidad y aceptación

Mantener RNF-028 a RNF-035. WCAG 2.2 AA es referencia aplicable; no hay auditoría
integral ni certificación de la PoC. La extensión conserva Material 3, paleta
existente, ancho máximo 680, texto adaptable, títulos legibles, desplazamiento
y controles con nombres accesibles; no introduce estados dependientes del color.

| Comprobación | Criterio de aceptación | Evidencia actual |
| --- | --- | --- |
| Lectura sin cuenta/red | Abrir información incluso ante fallo del almacenamiento | Test widget ejecutado; pasa con fallo simulado de almacenamiento |
| Texto ampliado | 200% en ancho 360 px; texto/control completo y desplazable | Test widget ejecutado; llega al apartado de accesibilidad y al visor de licencias |
| Controles nombrados | Etiquetas, estado expandido y visor de licencias accesibles | Guías del SDK ejecutadas al 100%/200%; pasan en contenido y licencia |
| Contraste | Texto normal 4,5:1; grande/UI relevantes 3:1 según criterio | `textContrastGuideline` pasa en los árboles comprobados al 100%/200% |
| Teclado | Tab/Shift+Tab, foco visible/no oculto, Enter/Espacio, volver sin atrapamiento | Test widget desde `NexoPocApp`; abre, expande/contrae, consulta licencias y vuelve |
| Puntero/táctil | Mínimo WCAG aplicable; verificar guía nativa de 48 dp Android/44 pt iOS | `labeledTapTargetGuideline`, Android e iOS pasan en el alcance automatizado; sin dispositivo físico |
| Lectores | Orden/nombre/rol/estado con Narrator, TalkBack y VoiceOver | Windows UIA parcial: Narrator activo; 12 nombres/roles Button e InvokePattern en orden; licencia y retorno verificados. Audio no capturado; UIA no expone cuerpo ni estado expandido. Narrator completo y lectores móviles pendientes. |
| Flujos financieros | Errores claros, saldo/estado textual, contraste y foco sin perder contexto | Auditar app completa en la iteración local |

Fuentes: [WCAG 2.2](https://www.w3.org/TR/WCAG22/) y
[Flutter — accesibilidad](https://docs.flutter.dev/ui/accessibility).

## Ejecución y cierre de esta iteración

La pantalla **Privacidad y uso** se abre desde el icono de privacidad de la
barra superior; funciona con textos locales y permite consultar las licencias.
No registra aceptación ni cambia cuentas, cola, API o base de datos.

Validación automatizada realizada en Windows con Flutter local. `flutter analyze`
no reportó issues y `flutter test` pasó 14/14. Los tests de teclado y guías se
ejecutaron por separado durante su iteración. El viewport de guía es 360×800 a
escalas 100% y 200%; el test de
teclado recorre controles enfocados y su centro permanece visible (la caja del
botón de licencias admite hasta 4 px de desborde inferior en el viewport de
test). Esto es evidencia de Flutter Test, no prueba nativa Android/iOS ni una
medición/certificación integral WCAG.

La instancia visual Windows ya abierta permanece disponible y no se relanzó:
esta iteración solo modifica pruebas. Comando para iniciar una nueva instancia
con datos sintéticos aislados:

```powershell
Set-Location D:\Nexus\poc\flutter_offline
& 'D:\Nexus\poc\.runtime\flutter\bin\flutter.bat' analyze
& 'D:\Nexus\poc\.runtime\flutter\bin\flutter.bat' test
& 'D:\Nexus\poc\.runtime\flutter\bin\flutter.bat' run -d windows --dart-define=NEXO_API_URL=http://127.0.0.1:3000
```

Quedan pendientes la evaluación completa de todos los flujos, Narrator/TalkBack/
VoiceOver, pruebas en dispositivos Android/iOS, mediciones nativas de objetivos
táctiles y auditoría de conformidad. T-005 sigue en progreso; no se declara
cumplimiento productivo. Consumo de tokens atribuible: N/D.

Código y documentos: commit [`d8126d9`](https://github.com/carlos-paezf/Nexo-Finance-Assistant/commit/d8126d9b2a56281a03dfecc017c28e0f048c7562)
— `feat(poc): add privacy and usage information`, [PR #2 en borrador](https://github.com/carlos-paezf/Nexo-Finance-Assistant/pull/2),
base `feat/t005-runtime-validation`. Integración con la iteración local pendiente;
no se fusionó la rama ni se publicó una app.

## Puerta de publicación

La revisión queda abierta hasta completar el responsable/contacto, los textos
productivos, titularidad/licencia, inventario de SDK/proveedores, derechos y
retención operables, seguridad para datos reales, declaraciones de tienda y
evidencia de accesibilidad por plataforma. Registrar responsable de cada punto
y revisión técnica/jurídica; no marcar cumplimiento por existir esta pantalla.

## Evidencia vigente — integración en T-005 — 5 de octubre de 2026

### Actualización — cobertura completa y lectores de pantalla

En la iteración del 5 de octubre de 2026, la prueba de escala y guías obtiene
el `ThemeData` de `NexoPocApp`; no mantiene una paleta duplicada. Con viewport
360×800, ejecuta la vista inicial, cada una de las 12 secciones expandida de
forma aislada y el botón de licencias, a 100% y 200%. Recorre el contenido
visible y aplica en cada estado `textContrastGuideline`,
`labeledTapTargetGuideline`, `androidTapTargetGuideline` e
`iOSTapTargetGuideline`. Resultado: prueba widget aprobada. `flutter analyze`
sin issues y `flutter test` 14/14. Esto no equivale a validación en un lector de
pantalla nativo, dispositivos móviles o conformidad WCAG integral.

Narrator queda pendiente: al comprobar el entorno, el proceso Narrator no
estaba activo y tampoco estaba ejecutándose la instancia Windows de la PoC
(incluido el PID previamente documentado 24124); por eso no se pudieron
observar anuncios hablados, árbol UI Automation ni navegación con Narrator.
Procedimiento manual: ejecutar el comando de instancia Release registrado
abajo; iniciar Narrator con Win+Ctrl+Enter; recorrer con Tab y flechas desde el
título; confirmar nombre/rol/estado expandido y orden de las 12 secciones;
abrir “Licencias de componentes” con Enter y volver con Alt+Left o el control
de retorno; anotar anuncios reales. La ausencia del lector activo es un
bloqueo concreto, no un resultado aprobado.

En `feat/t005-runtime-validation` se integró esta pantalla desde el AppBar de
la PoC. La prueba automatizada ejecutada pasó apertura sin cuenta ante una
excepción de almacenamiento, escala de texto 200% con ancho 360 px, guía de
objetivos táctiles y apertura del visor nativo de licencias. `flutter analyze`
no reportó issues; `flutter test` pasó 12/12. También se compiló y abrió el
ejecutable Windows Release con una carpeta independiente de datos sintéticos;
se comprobó visualmente la pantalla desde el AppBar. Captura y log locales
(no versionados): `poc/.runtime/privacy-use-window.png` y
`poc/.runtime/privacy-use-windows-validation.log`.

Para reabrir la instancia Release actual:

```powershell
$env:NEXO_DATA_DIRECTORY = 'D:\Nexus\poc\.runtime\privacy-use-b6cb9cb59e624046b3789d99f3b9a71d'
& 'D:\Nexus\poc\flutter_offline\build\windows\x64\runner\Release\nexo_offline_poc.exe'
```

Esta evidencia cubre escritorio y pruebas widget; no valida Android ni iOS
físicos, accesibilidad de toda la app ni conformidad legal. T-005 y el
cumplimiento productivo continúan pendientes.

### Actualización C-12 — UI Automation con Narrator activo — 5 de octubre de 2026

Se abrió Release Windows con el directorio de datos sintéticos independiente
documentado arriba (PID PoC 44128); Narrator quedó activo (PID 81976). UIA
encontró los 12 nombres de sección en el orden de `privacyUseSections`. La
inspección inicial presentaba los encabezados como texto estático; se añadió
`Semantics(button: true)` al título del `ExpansionTile` y se reconstruyó
Release. UIA posterior muestra los 12 como `ControlType.Button` con
`InvokePattern`. Al invocar la primera sección se comprobó visualmente el
cuerpo; se verificó la vuelta desde la vista `Licenses` mediante el botón
`Back`.

Límite observado: los nodos de botón aparecen no enfocables para UIA y sin
`HelpText` ni patrón `ExpandCollapse`; UIA tampoco expone el texto del cuerpo
expandido. Flutter Test sí verifica los hints localizados y estados expandido/
contraído y cuerpo visible/oculto. Las herramientas de esta sesión no permiten
escuchar ni capturar la voz de Narrator, por lo que quedan pendientes anuncios,
foco y navegación de lector validados por una persona. TalkBack/VoiceOver y
validación móvil también quedan pendientes. Captura Windows expandida
(local, no versionada): `poc/.runtime/t005-narrator-expanded.png`.
