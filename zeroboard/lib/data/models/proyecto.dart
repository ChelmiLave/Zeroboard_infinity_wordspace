import '../../core/constants/enums.dart';

class Proyecto {
  final int? idProyecto; // null hasta que SQLite le asigne el id (AUTOINCREMENT)
  final String titulo;
  final String tipoDiseno; // TipoDiseno.*
  final int? idPlantillaOrigen;
  final String estadoGuardado; // EstadoGuardado.*
  final String? rutaMiniatura;
  final double vistaX; // posición del viewport al cerrar
  final double vistaY;
  final double vistaZoom;
  final DateTime fechaCreacion;
  final DateTime fechaUltimaModificacion;

  Proyecto({
    this.idProyecto,
    required this.titulo,
    required this.tipoDiseno,
    this.idPlantillaOrigen,
    this.estadoGuardado = EstadoGuardado.guardado,
    this.rutaMiniatura,
    this.vistaX = 0,
    this.vistaY = 0,
    this.vistaZoom = 1,
    DateTime? fechaCreacion,
    DateTime? fechaUltimaModificacion,
  })  : fechaCreacion = fechaCreacion ?? DateTime.now(),
        fechaUltimaModificacion = fechaUltimaModificacion ?? DateTime.now();

  /// Objeto -> Map (para insertar/actualizar en SQLite).
  Map<String, dynamic> toMap() => {
        'id_proyecto': idProyecto,
        'titulo': titulo,
        'tipo_diseno': tipoDiseno,
        'id_plantilla_origen': idPlantillaOrigen,
        'estado_guardado': estadoGuardado,
        'ruta_miniatura': rutaMiniatura,
        'vista_x': vistaX,
        'vista_y': vistaY,
        'vista_zoom': vistaZoom,
        'fecha_creacion': fechaCreacion.toIso8601String(),
        'fecha_ultima_modificacion': fechaUltimaModificacion.toIso8601String(),
      };

  /// Map (fila de SQLite) -> objeto.
  factory Proyecto.fromMap(Map<String, dynamic> m) => Proyecto(
        idProyecto: m['id_proyecto'] as int?,
        titulo: m['titulo'] as String,
        tipoDiseno: m['tipo_diseno'] as String,
        idPlantillaOrigen: m['id_plantilla_origen'] as int?,
        estadoGuardado: m['estado_guardado'] as String,
        rutaMiniatura: m['ruta_miniatura'] as String?,
        vistaX: (m['vista_x'] as num).toDouble(),
        vistaY: (m['vista_y'] as num).toDouble(),
        vistaZoom: (m['vista_zoom'] as num).toDouble(),
        fechaCreacion: DateTime.parse(m['fecha_creacion'] as String),
        fechaUltimaModificacion:
            DateTime.parse(m['fecha_ultima_modificacion'] as String),
      );
}
