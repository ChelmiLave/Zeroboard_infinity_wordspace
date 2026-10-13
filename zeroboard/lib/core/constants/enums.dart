// Valores permitidos de los enums. Deben coincidir con los CHECK del SQL.
class TipoDiseno {
  static const presentacion = 'presentacion';
  static const pizarra = 'pizarra';
}

class EstadoGuardado {
  static const guardado = 'guardado';
  static const pendiente = 'pendiente';
  static const error = 'error';
}

class FormatoArea {
  static const x16_9 = '16_9';
  static const x4_3 = '4_3';
  static const a4 = 'a4';
  static const carta = 'carta';
  static const libre = 'libre';

  /// Tamaño por defecto (ancho, alto) en unidades del lienzo.
  static (double, double) tamano(String formato) {
    switch (formato) {
      case x4_3:
        return (1024, 768);
      case a4:
        return (794, 1123);
      case carta:
        return (816, 1056);
      case x16_9:
      default:
        return (1280, 720);
    }
  }
}

class TipoElemento {
  static const texto = 'texto';
  static const forma = 'forma';
  static const imagen = 'imagen';
  static const trazo = 'trazo';
  static const linea = 'linea';
  static const nota = 'nota';
}

class OrigenPlantilla {
  static const incluida = 'incluida';
  static const descargada = 'descargada';
}
