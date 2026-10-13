class Nota {
  final int? idNota;
  final int? idProyecto; // null = nota suelta, sin proyecto
  final String titulo;
  final String contenido;
  final DateTime? fechaRecordatorio;
  final int? idNotificacion; // id usado al programar la notificación local
  final bool completada;
  final DateTime fechaCreacion;

  Nota({
    this.idNota,
    this.idProyecto,
    required this.titulo,
    this.contenido = '',
    this.fechaRecordatorio,
    this.idNotificacion,
    this.completada = false,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id_nota': idNota,
        'id_proyecto': idProyecto,
        'titulo': titulo,
        'contenido': contenido,
        'fecha_recordatorio': fechaRecordatorio?.toIso8601String(),
        'id_notificacion': idNotificacion,
        'completada': completada ? 1 : 0,
        'fecha_creacion': fechaCreacion.toIso8601String(),
      };

  factory Nota.fromMap(Map<String, dynamic> m) => Nota(
        idNota: m['id_nota'] as int?,
        idProyecto: m['id_proyecto'] as int?,
        titulo: m['titulo'] as String,
        contenido: m['contenido'] as String,
        fechaRecordatorio: m['fecha_recordatorio'] == null
            ? null
            : DateTime.parse(m['fecha_recordatorio'] as String),
        idNotificacion: m['id_notificacion'] as int?,
        completada: (m['completada'] as int) == 1,
        fechaCreacion: DateTime.parse(m['fecha_creacion'] as String),
      );
}
