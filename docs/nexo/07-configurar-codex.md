# 🛠️ 07 — Configurar Codex para Nexo

[Fuente en Notion](https://app.notion.com/p/3eeaf67c2e9281a69455e5410c500fb1?pvs=204)

## Objetivo
Configurar el proyecto de desarrollo para trabajar con la línea base v0.2: 163 RF y 75 RNF, conservando trazabilidad, privacidad y decisiones pendientes.
## Fecha
2 de octubre de 2026, America/Bogota.
## Configuración para carpeta o repositorio
1. Colocar `AGENTS.md` en la raíz del proyecto y los documentos en **docs/nexo/**. Si esos archivos ya existen, combinar el contenido preservando cambios.
2. En el menú del proyecto de la app, seleccionar **Edit project**, añadir la carpeta y marcarla como **Make primary** cuando haya varias. En CLI, iniciar Codex desde esa carpeta; en el IDE, abrir la raíz correspondiente.
3. Abrir un nuevo chat desde el proyecto y verificar que Codex puede leer `AGENTS.md` y el índice.
4. Si se usa Git, incluir instrucciones y documentación en el repositorio para compartir el contexto entre sesiones y worktrees.
## Notion como fuente
Habilitar el conector o plugin de Notion en el entorno donde se ejecuta Codex y autenticar la cuenta con acceso al proyecto. Para clientes que usan MCP local, administrarlo desde Settings → MCP servers y completar la autenticación del servidor oficial.
Verificar el acceso pidiendo la lectura de la página principal y el listado de páginas hijas. La conexión de una conversación no configura automáticamente otra instalación.
## Copia local
El paquete de configuración contiene `AGENTS.md`, mensaje inicial, guía de instalación y seis documentos extraídos de Notion con su índice y metadatos. Es una copia del estado consultado, sin sincronización automática.
Comparar y actualizar las páginas relevantes durante cada tarea. Si Notion no está disponible, trabajar con la copia e informar de la actualización pendiente.
## Reglas del archivo de instrucciones
- Trabajar en español y por incrementos verificables.
- Vincular cambios con RF/RNF y criterios de aceptación.
- Mantener las tecnologías y el MVP en estado propuesto hasta decidirlos.
- Conservar exactitud financiera, registro único compartido y permisos por recurso.
- Probar cálculos, privacidad, deduplicación y sincronización según el cambio.
- Actualizar plan y bitácora, e informar resultados y pendientes con evidencia.
## Primera tarea propuesta
Lee `AGENTS.md` y `docs/nexo/00-indice.md`. Verifica las fuentes disponibles y, si tienes acceso, contrasta Notion. Empieza por T-001 y T-002: prepara la propuesta de MVP y resuelve documentalmente los solapamientos como propuestas. Entrega requisitos incluidos y diferidos, criterios de aceptación del primer incremento, recomendación de tecnología móvil y decisiones pendientes. Esta tarea es de planificación.
## Proyecto de chats sin carpeta
Añadir los documentos como fuentes del proyecto y el contenido de `AGENTS.md` como instrucciones del proyecto. La detección automática de `AGENTS.md` corresponde al trabajo sobre una carpeta; un adjunto requiere referencia explícita.
## Fuentes oficiales consultadas
- [Instrucciones AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [Proyectos y chats](https://learn.chatgpt.com/docs/projects?surface=app)
- [MCP](https://learn.chatgpt.com/docs/extend/mcp?surface=cli)
## Agentes y consumo de tokens
El paquete v1.1 añade `.codex/config.toml`, cuatro agentes en `.codex/agents/` y las reglas de [modelos, skills y eficiencia](https://app.notion.com/p/3eeaf67c2e92814ca552db8b0a3093be). Combinar estos archivos con la configuración existente y abrir una nueva sesión. Comprobar que Luna y Sol están disponibles para la cuenta; no asumirlo por su presencia en el archivo.
## Estado
Paquete preparado y catálogo completo verificado. La configuración de la nueva instalación del usuario todavía debe aplicarse y verificarse; no se ha inspeccionado ni modificado su repositorio.
