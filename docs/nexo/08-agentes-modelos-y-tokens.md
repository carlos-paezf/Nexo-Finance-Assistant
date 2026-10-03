# ⚙️ 08 — Agentes, modelos y eficiencia de tokens

[Fuente en Notion](https://app.notion.com/p/3eeaf67c2e92814ca552db8b0a3093be?pvs=204)

## Objetivo y alcance
Política de trabajo v1.0, 2 de octubre de 2026 (America/Bogota). Minimizar el consumo total necesario para una tarea aceptada, conservando exactitud financiera, seguridad, accesibilidad y rendimiento de la app.
El principio de eficiencia y el uso de agentes y skills fueron solicitados por el usuario. El enrutamiento siguiente se aplica como configuración inicial ajustable por evidencia.
Esta política organiza el desarrollo en Codex; no selecciona el modelo del asistente financiero que tendrá Nexo.
## Modelos
La documentación actual de OpenAI identifica GPT-6 Luna como modelo eficiente para tareas enfocadas y GPT-6.1 Sol para tareas complejas. La disponibilidad efectiva debe comprobarse en la cuenta y el cliente del proyecto.
Modelo base: **gpt-6-luna**, razonamiento **high** como punto de partida documentado para Luna. Exploraciones sencillas pueden usar medium o low cuando un resultado conocido demuestre suficiente calidad.
Escalamiento: **gpt-6.1-sol**, medium para diseño de flujos y high para revisión crítica o razonamiento complejo.
Un modelo más económico no garantiza menos tokens. Tampoco reducir el razonamiento garantiza menor consumo total: puede aumentar los reintentos.
## Agentes bajo demanda


| Rol | Modelo inicial | Responsabilidad |
| --- | --- | --- |
| Principal | GPT-6 Luna · high | Clasificar y resolver tareas claras; integrar resultados y evidencias. |
| nexo_explorer | GPT-6 Luna · medium | Localizar archivos, dependencias y pruebas; solo lectura. |
| nexo_worker | GPT-6 Luna · high; escalable a Sol | Implementar un incremento definido y ejecutar sus pruebas. |
| nexo_ui | GPT-6.1 Sol · medium | Diseñar flujos o pantallas nuevas; aplicar Impeccable y el sistema visual. |
| nexo_reviewer | GPT-6.1 Sol · high | Revisar dinero, permisos, pérdida de datos y sincronización; no editar. |


La sesión principal coordina. Se permiten como máximo **dos subagentes abiertos simultáneamente, además del principal**. Este límite no obliga a usarlos.
El worker hereda el modelo por defecto; su archivo no fija uno para permitir que una petición explícita de lanzamiento lo escale a Sol.
## Reglas de delegación
1. Una tarea pequeña, clara y localizada se resuelve con el principal.
2. Delegar solo una subtarea con entrega propia que reduzca tiempo, consumo o riesgo. Registrar su motivo.
3. Ejecutar en paralelo únicamente tareas independientes con archivos de edición distintos o revisiones de solo lectura. Resolver antes los contratos compartidos.
4. Evitar que principal y subagente repitan la misma búsqueda, lectura completa o implementación.
5. Dar a cada agente objetivo, RF/RNF, archivos, criterios de aceptación y entrega concreta. Usar contexto mínimo cuando el cliente lo permita.
6. Reutilizar un agente si conserva contexto útil y cerrar el que haya terminado cuando el cliente lo soporte.
## Escalamiento verificable
Usar Sol desde el inicio para arquitectura transversal, cálculos y redondeo, permisos entre integrantes, autorización de soporte, concurrencia, sincronización o migraciones que puedan perder datos.
Escalar también cuando haya requisitos contradictorios que bloqueen el diseño o una falla reproducible después de un intento acotado de diagnóstico y corrección.
Una repetición de un comando fallido por sintaxis no obliga a escalar; corregir el comando y continuar. No inventar decisiones de producto ante requisitos faltantes.
El escalamiento es una decisión de trabajo, no una conmutación automática garantizada por el archivo TOML.
## Calidad que se conserva
- Exactitud monetaria, distribución que suma el total y registro compartido único.
- Autorización por recurso, separación privada/compartida y diagnóstico con consentimiento.
- Idempotencia, resolución de conflictos y prevención de pérdida de datos.
- Pruebas significativas y controles adecuados al cambio.
- Accesibilidad, errores comprensibles y límites de rendimiento ya definidos en los RNF.
- Revisión independiente antes de cerrar cambios críticos; el implementador aporta resultados de pruebas.
El reviewer trabaja en lectura: si una comprobación necesita generar archivos, la ejecuta el worker o principal y el reviewer evalúa su evidencia.
No disminuir estas exigencias para cumplir un presupuesto de tokens.
## Contexto y salidas
Leer primero el índice; abrir solo el módulo, regla o decisión que afecta la tarea. No cargar los 238 requisitos ni todos los [SKILL.md](http://SKILL.md) en cada ejecución.
Usar búsquedas y rangos acotados, resultados resumidos y reutilización de evidencia vigente.
El principal mantiene el estado de la tarea. Los agentes no reescriben documentación compartida en paralelo.
Las entregas de agentes contienen resultado, archivos, pruebas y pendientes. Objetivo orientativo: 200–400 tokens por resumen, ampliable cuando la evidencia lo exija; no es un límite duro del runtime.
Los logs y archivos grandes se conservan como evidencias con enlace; no se vuelcan completos al chat.
## Skills y plugins


| Capacidad | Estado verificado | Uso |
| --- | --- | --- |
| Ponytail | Disponible en esta sesión | Simplicidad en implementación y correcciones; conservar validación, seguridad, accesibilidad y pruebas necesarias. |
| Impeccable | Disponible en esta sesión | Flujos, interfaz y revisión visual; cargar solo el playbook aplicable y limitar las rondas de inspección. |
| UI UX Pro Max | Fuente e instalación para Codex verificadas; pendiente en el proyecto local | Complemento para referencias y sistema visual inicial; evitar repetir su generación en cada pantalla. |
| Notion | Conectado en esta sesión | Requisitos, decisiones y estado; leer y actualizar solo las páginas pertinentes. |
| OpenAI Docs | Disponible en esta sesión | Verificar configuración, modelos e integración OpenAI cuando la tarea lo necesite. |


Ponytail rige las decisiones de implementación. Impeccable rige la ejecución de UX/UI. UI UX Pro Max complementa la selección inicial de referencias; un sistema visual acordado prevalece sobre nuevas sugerencias genéricas.
Una modificación menor no activa una cadena completa de auditoría, rediseño y optimización. Seleccionar el flujo pertinente.
No añadir proveedores, plugins o dependencias solo por estar disponibles. Verificar compatibilidad con el stack elegido y beneficio concreto.
No se ha inspeccionado ni modificado el proyecto local del usuario. Disponibilidad en esta sesión no prueba instalación en otra instancia.
## Aplicación a Codex local
El paquete contiene un bloque de configuración de proyecto y cuatro archivos de agentes personalizados. Combinarlos con la configuración existente sin perder servidores MCP o instrucciones.
Codex actual utiliza archivos TOML independientes en `.codex/agents/`, con name, description y developer_instructions. La configuración de proyecto se carga en proyectos de confianza.
Si el cliente no admite agentes personalizados, conservar la misma política mediante instrucciones y roles explícitos en las tareas.
## UI UX Pro Max
El catálogo de plugins consultado no devolvió una coincidencia exacta. Se verificó el repositorio del autor y su instalador para Codex.
Instalación por proyecto, desde su raíz y con Node/npm y Python disponibles:
```bash
npx --yes ui-ux-pro-max-cli init --ai codex
```
Antes de instalar, comprobar si ya existe la skill y preservar personalizaciones. Registrar la versión realmente instalada; no se ha ejecutado este comando sobre el repositorio del usuario.
La instalación no requiere agregar el CLI como dependencia de producción de Nexo.
## Medición
Registrar por tarea comparable: tipo, RF/RNF, modelo y esfuerzo, agentes, tokens de entrada/salida si el cliente los expone, uso de razonamiento y caché según el proveedor, reintentos, duración, resultados de pruebas y defectos.
El total de una tarea suma las llamadas del principal y subagentes. Los tokens de caché y de razonamiento pueden ser subconjuntos: no sumarlos otra vez cuando estén incluidos en entrada/salida.
Si no hay contadores, marcar N/D; no inventar consumos ni porcentajes. Comparar varias tareas similares y considerar dificultad y diferencias de alcance.
La elección inicial no está acompañada de una promesa de ahorro o igualdad de calidad. Ajustar el enrutamiento solo después de observar consumo y aceptación del resultado.
## Fuentes verificadas
- [Modelos en Codex](https://learn.chatgpt.com/docs/models?surface=app)
- [Subagentes](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [Referencia de configuración](https://learn.chatgpt.com/docs/config-file/config-reference)
- [UI UX Pro Max — repositorio del autor](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill/blob/main/README.md)
