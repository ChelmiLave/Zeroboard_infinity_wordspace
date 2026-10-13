class Recurso {
  final int? idRecurso;
  final int idProyecto;
  final String tipo; // por ahora solo 'imagen'
  final String rutaLocal; // dentro de la carpeta privada de la app
  final int? anchoPx;
  final int? altoPx;
  final int? tamanoBytes;

  Recurso({
    this.idRecurso,
    required this.idProyecto,
    this.tipo = 'imagen',
    required this.rutaLocal,
    this.anchoPx,
    this.altoPx,
    this.tamanoBytes,
  });

  Map<String, dynamic> toMap() => {
        'id_recurso': idRecurso,
        'id_proyecto': idProyecto,
        'tipo': tipo,
        'ruta_local': rutaLocal,
        'ancho_px': anchoPx,
        'alto_px': altoPx,
        'tamano_bytes': tamanoBytes,
      };

  factory Recurso.fromMap(Map<String, dynamic> m) => Recurso(
        idRecurso: m['id_recurso'] as int?,
        idProyecto: m['id_proyecto'] as int,
        tipo: m['tipo'] as String,
        rutaLocal: m['ruta_local'] as String,
        anchoPx: m['ancho_px'] as int?,
        altoPx: m['alto_px'] as int?,
        tamanoBytes: m['tamano_bytes'] as int?,
      );
}
