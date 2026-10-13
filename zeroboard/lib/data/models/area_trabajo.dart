import '../../core/constants/enums.dart';

/// Área con dimensiones definidas sobre el lienzo (una diapositiva, una hoja A4...).
class AreaTrabajo {
  final int? idArea;
  final int idProyecto;
  final String nombre;
  final int orden; // orden de la diapositiva en una presentación
  final String formato; // FormatoArea.*
  final double ancho;
  final double alto;
  final double x; // posición en el lienzo
  final double y;
  final String colorFondo; // '#RRGGBB'

  AreaTrabajo({
    this.idArea,
    required this.idProyecto,
    this.nombre = 'Sin nombre',
    this.orden = 0,
    this.formato = FormatoArea.x16_9,
    required this.ancho,
    required this.alto,
    this.x = 0,
    this.y = 0,
    this.colorFondo = '#FFFFFF',
  });

  /// Crea un área con el tamaño por defecto de su formato.
  factory AreaTrabajo.deFormato({
    required int idProyecto,
    String formato = FormatoArea.x16_9,
    int orden = 0,
  }) {
    final (w, h) = FormatoArea.tamano(formato);
    return AreaTrabajo(
        idProyecto: idProyecto, formato: formato, ancho: w, alto: h, orden: orden);
  }

  Map<String, dynamic> toMap() => {
        'id_area': idArea,
        'id_proyecto': idProyecto,
        'nombre': nombre,
        'orden': orden,
        'formato': formato,
        'ancho': ancho,
        'alto': alto,
        'x': x,
        'y': y,
        'color_fondo': colorFondo,
      };

  factory AreaTrabajo.fromMap(Map<String, dynamic> m) => AreaTrabajo(
        idArea: m['id_area'] as int?,
        idProyecto: m['id_proyecto'] as int,
        nombre: m['nombre'] as String,
        orden: m['orden'] as int,
        formato: m['formato'] as String,
        ancho: (m['ancho'] as num).toDouble(),
        alto: (m['alto'] as num).toDouble(),
        x: (m['x'] as num).toDouble(),
        y: (m['y'] as num).toDouble(),
        colorFondo: m['color_fondo'] as String,
      );
}
