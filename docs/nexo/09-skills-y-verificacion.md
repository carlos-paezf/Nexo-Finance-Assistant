# Skills, aplicación y verificación

Configuración de trabajo v1.0; paquete v1.1. No altera la línea base de 238 requisitos.

## Aplicar
1. Combina AGENTS.md, docs/nexo/, .codex/config.toml y .codex/agents/ con tu proyecto.
   Conserva servidores MCP, reglas y personalizaciones existentes.
2. Abre una sesión nueva en la carpeta principal y verifica los archivos cargados.
   La configuración del proyecto requiere que ese proyecto sea de confianza.
3. Comprueba acceso a gpt-6-luna y gpt-6.1-sol. El archivo no concede acceso.
4. Pega INICIO-CODEX.md. Codex decide delegar por las reglas; la existencia de
   agentes personalizados no los ejecuta en cada tarea.

## Skills
Ponytail e Impeccable están disponibles en la sesión que preparó este paquete.
En tu instalación, habilita los plugins correspondientes o sus skills y
comprueba que Codex los enumera. No se copian sus binarios ni paquetes en este ZIP.

UI UX Pro Max no apareció como coincidencia exacta del catálogo de plugins
consultado. Su autor documenta compatibilidad y un instalador para Codex.

Desde la raíz del proyecto, con Node/npm y Python disponibles:

```bash
npx --yes ui-ux-pro-max-cli init --ai codex
```

Comprueba primero si ya existe. Registra la versión instalada y preserva cambios
locales; el comando no se ejecutó en el repositorio del usuario. El instalador
es herramienta de desarrollo, no dependencia de producción de Nexo.
Fuente: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill/blob/main/README.md

Usa Impeccable para el trabajo UI del momento y Ponytail para simplificar
implementación. UI UX Pro Max aporta referencias al sistema visual inicial;
un sistema aprobado prevalece sobre sugerencias posteriores. No actives todos
los flujos por cada cambio.

## Comprobación en Codex
Solicita: “Indica la carpeta de trabajo, las instrucciones y cuatro agentes
Nexo cargados, los modelos disponibles y el estado de las tres skills”.
Prueba después una tarea conocida y acotada con Luna. Revisa criterios y
evidencia; para dinero/permisos/sincronización utiliza la revisión Sol.
No uses tareas distintas para atribuir un porcentaje de ahorro.

## Registro por tarea
Anota ID, dificultad/alcance, RF/RNF, modelo/esfuerzo, agentes, llamadas, tokens
disponibles, reintentos, duración, pruebas y defectos. Si faltan contadores: N/D.
Cuenta el total de principal y agentes. Caché y razonamiento pueden estar
incluidos en entrada/salida; evita sumar subconjuntos dos veces.
No cambies la aceptación para reducir la cifra.

## Validación del paquete
Se comprobó sintaxis TOML con Python tomllib, campos documentados, roles/modelos,
límite de dos subagentes, integridad del ZIP y conservación de 163 RF y 75 RNF.
La prueba completa de carga, acceso a modelos e instalación de skills se realiza
en tu cliente: Codex CLI no está disponible en el entorno que generó el paquete.

Fuentes:
- https://learn.chatgpt.com/docs/models?surface=app
- https://learn.chatgpt.com/docs/agent-configuration/subagents
- https://learn.chatgpt.com/docs/config-file/config-reference
