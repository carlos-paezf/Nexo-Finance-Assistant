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
consultado. El 3 de octubre se encontró instalada globalmente en
`C:\Users\cpaez\.agents\skills\ui-ux-pro-max`, con SKILL.md, datos y scripts; además
aparece entre las skills disponibles en esta sesión. No está copiada en el
proyecto, pero no falta ni se repitió el instalador.

Desde la raíz del proyecto, con Node/npm y Python disponibles:

```bash
npx --yes ui-ux-pro-max-cli init --ai codex
```

Solo si falta en el perfil y en el proyecto, comprueba primero si existe una
instalación personalizada y usa el instalador por proyecto. Para esta sesión no
hizo falta ejecutar el comando ni registrar otra versión; se conservó la
instalación global. El instalador es herramienta de desarrollo, no dependencia
de producción de Nexo.
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

### Resultado de comprobación local — 3 de octubre de 2026
`.codex/config.toml` y cuatro archivos `.codex/agents/*.toml` están presentes;
Python `tomllib` validó sintaxis y modelos configurados. El cliente de esta tarea
ejecutó una revisión independiente con `gpt-6-sol`; la documentación oficial y
el plan Plus indican disponibilidad de Luna/Sol, aunque no prueban acceso desde
otro perfil local.

`codex doctor` corrió con CLI 0.142.0 en el perfil aislado
`C:\Users\CodexSandboxOffline\.codex`, informó falta de credenciales y problemas
de conexión. No confirma si ese CLI cargó los agentes del proyecto. La carga de
configuración y agentes en una sesión nueva del perfil principal queda por
confirmar allí; la limitación se debe al entorno aislado observado, no a TOML
inválido. No se alteró ni actualizó ese perfil.

La skill UI UX Pro Max ya estaba instalada globalmente en el perfil del usuario;
no se creó copia local ni se reemplazó ninguna personalización. El panel de uso
muestra porcentajes agregados, no tokens de esta tarea. Consumo atribuible: N/D.

## Validación del paquete
Se comprobó sintaxis TOML con Python tomllib, campos documentados, roles/modelos,
límite de dos subagentes, integridad del ZIP y conservación de 163 RF y 75 RNF.
El 3 de octubre se comprobó el CLI 0.142.0 en un perfil aislado sin credenciales
ni conectividad. Su catálogo local no incluye GPT-6 Luna/Sol y no confirma la
carga de estos agentes desde el perfil principal. La revisión `gpt-6-sol` y las
skills disponibles se verificaron en la sesión Codex actual; la carga del `.codex`
local debe confirmarse en una nueva sesión principal autenticada.

Fuentes:
- https://learn.chatgpt.com/docs/models?surface=app
- https://learn.chatgpt.com/docs/agent-configuration/subagents
- https://learn.chatgpt.com/docs/config-file/config-reference
