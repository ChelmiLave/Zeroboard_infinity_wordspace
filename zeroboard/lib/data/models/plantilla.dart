import '../../core/constants/enums.dart';

class Plantilla {
  final int? idPlantilla;
  final String nombre;
  final String categoria;
  final String tipoDiseno; // TipoDiseno.*
  final String origen; // OrigenPlantilla.* (incluida en la app o descargada)
  final String? rutaRecursos;

  Plantilla({
    this.idPlantilla,
    required this.nombre,
    required this.categoria,
    required this.tipoDiseno,
    this.origen = OrigenPlantilla.incluida,
    this.rutaRecursos,
  });

  Map<String, dynamic> toMap() => {
        'id_plantilla': idPlantilla,
        'nombre': nombre,
        'categoria': categoria,
        'tipo_diseno': tipoDiseno,
        'origen': origen,
        'ruta_recursos': rutaRecursos,
      };

  factory Plantilla.fromMap(Map<String, dynamic> m) => Plantilla(
        idPlantilla: m['id_plantilla'] as int?,
        nombre: m['nombre'] as String,
        categoria: m['categoria'] as String,
        tipoDiseno: m['tipo_diseno'] as String,
        origen: m['origen'] as String,
        rutaRecursos: m['ruta_recursos'] as String?,
      );
}
