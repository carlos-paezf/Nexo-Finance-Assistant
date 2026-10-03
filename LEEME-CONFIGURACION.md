# Configuración inicial de Nexo en Codex

Preparado el 2026-10-02 (America/Bogota). Contiene reglas de trabajo y una copia de
la documentación de Notion. No configura automáticamente tu aplicación o repositorio.

## Instalar en una carpeta local
1. Extrae el contenido del ZIP en la raíz de la carpeta del proyecto. AGENTS.md debe
   quedar junto a los archivos principales del repositorio, no dentro de docs/.
   Si ya existen AGENTS.md o documentos con esos nombres, combina el contenido
   conservando tus cambios.
2. En la app de escritorio, abre el menú del proyecto y selecciona Edit project /
   Editar proyecto. Añade la carpeta del repositorio y márcala como Make primary /
   principal si hay varias.
   En CLI, inicia codex desde esa carpeta; en el IDE, abre esa carpeta o raíz.
3. Abre un nuevo chat dentro del proyecto y pega el texto de INICIO-CODEX.md.
4. Comprueba que Codex identifica AGENTS.md y la línea base v0.2 antes de planificar.
5. Si usas Git, incluye AGENTS.md y docs/nexo/ en el repositorio para que las nuevas
   sesiones y los worktrees dispongan del mismo contexto.

## Si usas un proyecto de chats sin carpeta
Añade los archivos de docs/nexo/ como fuentes del proyecto y copia el contenido de
AGENTS.md en las instrucciones del proyecto, adaptando los nombres de rutas a los
archivos adjuntos. Inicia el chat desde ese proyecto. Adjuntar un archivo llamado
AGENTS.md no implica la misma detección automática de una carpeta local.

## Acceso a Notion
Proyecto de referencia:
https://app.notion.com/p/3eeaf67c2e928135b4c6dd1d41f06290

Instala o habilita el conector/plugin de Notion en el entorno donde ejecutarás
Codex y autentica la cuenta que tiene acceso al proyecto. Si ese entorno usa
servidores MCP locales, se administran desde Settings > MCP servers; requiere
los datos del servidor oficial de Notion y su autenticación.

Verifica el acceso pidiendo que lea la página principal y liste sus páginas hijas.
La conexión de esta conversación no configura automáticamente otra instalación.

Los archivos incluidos son una copia del estado consultado, no una sincronización
automática. Para mantenerlos actualizados, pide a Codex que compare las páginas
relevantes, preserve decisiones aprobadas y registre los cambios con fecha y fuente.
Ante falta de acceso, puede preparar los cambios localmente e informar del pendiente.

## Qué incluye
- AGENTS.md: expectativas de trabajo, contexto, privacidad, cálculo y trazabilidad.
- INICIO-CODEX.md: primera tarea de planificación lista para pegar.
- docs/nexo/: índice y ocho documentos extraídos de Notion.
- MANIFIESTO.json: fuentes, última edición y fecha de extracción.

El paquete conserva el alcance preliminar. No contiene una app implementada,
tecnologías elegidas ni un MVP aprobado.

## Fuentes oficiales de configuración
- [Instrucciones AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [Proyectos y chats](https://learn.chatgpt.com/docs/projects?surface=app)
- [Conexiones MCP](https://learn.chatgpt.com/docs/extend/mcp?surface=cli)

## Actualización v1.1 — Agentes y tokens
Combina también la carpeta .codex/ con la configuración existente. Modelo base Luna high; hasta dos subagentes simultáneos además del principal. Sol para diseño complejo/revisión crítica y trabajo financiero o de permisos. Consulta docs/nexo/08-agentes-modelos-y-tokens.md y 09-skills-y-verificacion.md.

La instancia local del usuario todavía debe aplicar y verificar los archivos. No se ejecutó el instalador UI UX Pro Max sobre ella.
