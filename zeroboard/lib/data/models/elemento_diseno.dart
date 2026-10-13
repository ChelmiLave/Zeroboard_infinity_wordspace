import 'dart:convert';

class ElementoDiseno {
  final int? idElemento;
  final int idProyecto;
  final int? idArea; // null = flota libre en el lienzo
  final String tipoElemento; // TipoElemento.*
  final Map<String, dynamic> propiedades; // color, texto, grosor... (JSON)
  final int ordenCapa;
  // Caja delimitadora: sirve para pedir solo lo visible (culling).
  final double x;
  final double y;
  final double ancho;
  final double alto;
  final double rotacion;
  final bool bloqueado;
  final bool visible;

  ElementoDiseno({
    this.idElemento,
    required this.idProyecto,
    this.idArea,
    required this.tipoElemento,
    this.propiedades = const {},
    this.ordenCapa = 0,
    this.x = 0,
    this.y = 0,
    this.ancho = 0,
    this.alto = 0,
    this.rotacion = 0,
    this.bloqueado = false,
    this.visible = true,
  });

  Map<String, dynamic> toMap() => {
        'id_elemento': idElemento,
        'id_proyecto': idProyecto,
        'id_area': idArea,
        'tipo_elemento': tipoElemento,
        'propiedades_json': jsonEncode(propiedades), // Map -> texto JSON
        'orden_capa': ordenCapa,
        'x': x,
        'y': y,
        'ancho': ancho,
        'alto': alto,
        'rotacion': rotacion,
        'bloqueado': bloqueado ? 1 : 0, // SQLite no tiene bool
        'visible': visible ? 1 : 0,
      };

  factory ElementoDiseno.fromMap(Map<String, dynamic> m) => ElementoDiseno(
        idElemento: m['id_elemento'] as int?,
        idProyecto: m['id_proyecto'] as int,
        idArea: m['id_area'] as int?,
        tipoElemento: m['tipo_elemento'] as String,
        propiedades:
            jsonDecode(m['propiedades_json'] as String) as Map<String, dynamic>,
        ordenCapa: m['orden_capa'] as int,
        x: (m['x'] as num).toDouble(),
        y: (m['y'] as num).toDouble(),
        ancho: (m['ancho'] as num).toDouble(),
        alto: (m['alto'] as num).toDouble(),
        rotacion: (m['rotacion'] as num).toDouble(),
        bloqueado: (m['bloqueado'] as int) == 1,
        visible: (m['visible'] as int) == 1,
      );
}
