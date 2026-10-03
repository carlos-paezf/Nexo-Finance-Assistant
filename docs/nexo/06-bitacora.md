# 06 — Bitácora y fuentes

[Fuente en Notion](https://app.notion.com/p/3eeaf67c2e9281ae981bd4ca40c4e368?pvs=204)

## 3 de octubre de 2026 — Vista previa y commits por iteración
El usuario estableció dos reglas de trabajo: revisar una instancia visual de la
app mientras avanza y crear un commit después de cada iteración siguiendo
Conventional Commits 1.0.0. Se incorporan a AGENTS.md y al plan de seguimiento;
también se registran en Notion. Este incremento modifica documentación.

Se consultaron la especificación oficial de Conventional Commits y la guía de
Flutter Web. Los datos sintéticos y la plataforma de la demo deben identificarse;
la revisión visual web y la validación nativa conservan evidencia separada.
Este incremento documental no ejecuta una app. La PoC local mencionada en
Notion aún necesita publicación de código y ejecución verificable.
La conciliación de otras actualizaciones de Notion con las copias locales
permanece pendiente. No se aprueban requisitos adicionales del MVP.

Fuentes: [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/),
[Flutter Web](https://docs.flutter.dev/platform-integration/web/building).

## 2 de octubre de 2026 — Agentes y eficiencia
A solicitud del usuario, se añadió la política de agentes, selección de modelos y minimización del consumo total de tokens. Se verificaron los modelos y la configuración actual de Codex, la disponibilidad de Impeccable/Ponytail en esta sesión y la instalación de UI UX Pro Max documentada por su autor.
Se prepara el paquete v1.1 con configuración de proyecto y cuatro agentes especializados. La línea base del producto sigue en v0.2: 238 requisitos. No se han medido ahorros reales ni instalado los componentes en la instancia local del usuario. [Política detallada](https://app.notion.com/p/3eeaf67c2e92814ca552db8b0a3093be).
## 2 de octubre de 2026 — Apertura del proyecto
Se creó el proyecto Nexo en Notion con su documentación inicial, a solicitud del usuario.
## Línea base registrada
- v0.1: 144 RF y 66 RNF, según catálogo de la conversación.
- v0.2: incorporación de administración y soporte, RF-145 a RF-163 y RNF-067 a RNF-075.
- Total v0.2: 163 RF, 75 RNF, 238 requisitos; 16 módulos funcionales y 11 categorías no funcionales.
## Fuente primaria
Conversación de definición de Nexo aportada en esta sesión. No se dispone de un enlace público a la conversación; no se inventa uno. El catálogo conserva los códigos y prioridades propuestos, con redacción resumida y normalizada.
## Nivel de validación
El inventario es preliminar. No se ha aprobado el MVP, seleccionado tecnología, verificado tasas comerciales ni realizado una revisión jurídica. No se han implementado funcionalidades.
## Hallazgos
- Solapamiento entre RF-007 y RF-139.
- Cierre de tickets RF-152 propuesto P1 frente a soporte inicial P0; requiere decisión.
- Varios RNF requieren umbrales y condiciones de prueba.
- Restricciones por plataforma de SMS, notificaciones y correo requieren validación técnica.
## Cómo mantener la documentación
Actualizar catálogo y bitácora ante cambios acordados. Registrar decisiones con estado confirmado, propuesto o pendiente. Vincular historias y pruebas a los identificadores existentes. La actualización se realiza durante el trabajo solicitado; no hay sincronización automática de futuras conversaciones.
