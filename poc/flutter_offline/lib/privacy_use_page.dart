import 'package:flutter/material.dart';

/// Información sobre la PoC; no sustituye los documentos productivos pendientes.
const privacyUseSections = <(String, String)>[
  (
    'Política de privacidad y datos personales',
    'Usa solo datos inventados. El nombre de la cuenta, saldo inicial, '
        'descripciones, importes, fechas e identificadores se guardan en este '
        'dispositivo. Al pulsar Sincronizar con API, se envían a la API '
        'configurada y se almacenan en PostgreSQL. El archivo local no está '
        'cifrado y la API no tiene autenticación.\n\n'
        'La política para datos reales, el responsable, su contacto y los '
        'plazos de conservación están pendientes. Esta PoC no ofrece todavía '
        'exportación, rectificación ni eliminación desde la app.',
  ),
  (
    'Términos y condiciones de uso',
    'Este prototipo sirve para probar registro manual, saldo y sincronización '
        'con datos sintéticos. No realiza pagos, préstamos ni inversiones. '
        'El saldo local incluye movimientos pendientes; consulta el saldo '
        'confirmado tras sincronizar.\n\n'
        'Los términos del servicio productivo y su responsable aún no están '
        'definidos. Leer esta pantalla no registra aceptación ni autorización '
        'para tratar datos personales.',
  ),
  (
    'Propiedad intelectual',
    'El código, la marca, los textos y otros recursos necesitan una '
        'titularidad y condiciones de distribución documentadas. Esas '
        'decisiones están pendientes. No se atribuyen a Nexo derechos sobre '
        'materiales o marcas de terceros.',
  ),
  (
    'Permisos y accesos del dispositivo',
    'La PoC usa la carpeta de soporte de la app y la conexión a la API. '
        'No solicita acceso a SMS, correo, notificaciones de otras apps, '
        'contactos, cámara, micrófono ni ubicación.\n\n'
        'Antes de incorporar una captura opcional habrá que explicar su '
        'finalidad, pedir el permiso mínimo cuando se use y permitir '
        'rechazarlo sin impedir el registro manual.',
  ),
  (
    'Licencias y condiciones de uso de la app',
    'La licencia de distribución de Nexo y las condiciones de uso productivo '
        'están pendientes. Las dependencias mantienen sus propias licencias. '
        'El botón Licencias de componentes muestra los avisos registrados '
        'por Flutter en esta compilación; no cubre las dependencias del servidor.',
  ),
  (
    'Política de cookies',
    'Esta PoC de escritorio no utiliza cookies, WebView ni herramientas de '
        'analítica. El archivo que conserva la cuenta y la cola sin conexión '
        'es almacenamiento local de la app.\n\n'
        'Si se incorpora una web o un servicio de seguimiento, será necesario '
        'revisar sus cookies, finalidades, duración y controles de privacidad '
        'antes de activarlo.',
  ),
  (
    'Publicidad',
    'La PoC no incluye anuncios, identificadores publicitarios ni SDK de '
        'publicidad. Si se añaden patrocinios o referidos, deberán identificarse '
        'y explicar su efecto en las comparaciones. Los datos financieros '
        'no deben destinarse a publicidad sin una evaluación y autorización '
        'específicas cuando correspondan.',
  ),
  (
    'Derechos propios y de terceros',
    'Usa únicamente contenido propio o autorizado. No introduzcas datos '
        'personales reales de otras personas en esta PoC. Las licencias de '
        'dependencias no conceden derechos sobre marcas, datos o contenidos '
        'externos. El canal de reclamaciones del servicio futuro está pendiente.',
  ),
  (
    'Funcionalidades lícitas',
    'El flujo actual registra cuentas y movimientos inventados. No accede '
        'a bancos ni pide credenciales bancarias, CVV u OTP. Los conectores '
        'futuros deberán utilizar vías oficiales o expresamente autorizadas. '
        'La educación y las simulaciones financieras requerirán fuentes, '
        'supuestos y revisión del alcance regulado antes de ofrecerse.',
  ),
  (
    'Privacidad y geolocalización',
    'La PoC no obtiene ni almacena coordenadas y no solicita permisos de '
        'ubicación. Si una función futura necesita localización, deberá '
        'justificarla, informar su precisión y conservación, y permitir '
        'rechazarla o revocarla. El registro manual debe seguir disponible.',
  ),
  (
    'Markets y tiendas de aplicaciones',
    'Esta compilación de prueba no está publicada en Google Play ni App '
        'Store. Las declaraciones de datos, permisos, funciones financieras '
        'y condiciones de distribución deberán coincidir con el comportamiento '
        'real antes de publicarla.\n\n'
        'El explorador de productos financieros tampoco está implementado. '
        'Sus fuentes, fecha de consulta, costos, riesgos y relaciones '
        'comerciales deberán quedar claros.',
  ),
  (
    'Requisitos de accesibilidad',
    'Esta pantalla utiliza controles nativos de Flutter, títulos descriptivos '
        'y contenido desplazable. Mantiene el tamaño de texto configurado '
        'en el sistema.\n\n'
        'Las pruebas de teclado, contraste, ampliación de texto y lectores '
        'de pantalla siguen pendientes en las plataformas objetivo. '
        'WCAG 2.2 AA es la referencia del proyecto; no se declara conformidad.',
  ),
];

class PrivacyUsePage extends StatelessWidget {
  const PrivacyUsePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Privacidad y uso')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Información de la PoC',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Solo datos sintéticos. Estos textos describen el prototipo; '
                    'los documentos para producción siguen pendientes.',
                  ),
                  const SizedBox(height: 8),
                  const Text('Versión informativa: 5 de octubre de 2026'),
                  const SizedBox(height: 20),
                  for (final section in privacyUseSections)
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 20),
                      expandedAlignment: Alignment.centerLeft,
                      title: Semantics(
                        button: true,
                        child: Text(section.$1),
                      ),
                      children: [SelectableText(section.$2)],
                    ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: () => showLicensePage(
                        context: context,
                        applicationName: 'Nexo · PoC',
                        applicationVersion: '0.1.0',
                      ),
                      child: const Text('Licencias de componentes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
