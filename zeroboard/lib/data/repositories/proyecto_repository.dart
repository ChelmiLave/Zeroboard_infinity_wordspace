import 'package:sqflite/sqflite.dart';

import '../../core/constants/enums.dart';
import '../database/app_database.dart';
import '../models/area_trabajo.dart';
import '../models/proyecto.dart';

class ProyectoRepository {
  Future<Database> get _db => AppDatabase.instance.database;

  /// Crea el proyecto y su primera área en UNA transacción (o se guardan ambos o ninguno).
  Future<int> crear({
    required String titulo,
    required String tipoDiseno,
    int? idPlantillaOrigen,
  }) async {
    final db = await _db;
    return db.transaction((txn) async {
      final id = await txn.insert(
        'Proyecto',
        Proyecto(
          titulo: titulo,
          tipoDiseno: tipoDiseno,
          idPlantillaOrigen: idPlantillaOrigen,
        ).toMap()
          ..remove('id_proyecto'), // que SQLite asigne el id
      );
      final area = AreaTrabajo.deFormato(
        idProyecto: id,
        formato: tipoDiseno == TipoDiseno.presentacion
            ? FormatoArea.x16_9
            : FormatoArea.libre,
      );
      await txn.insert('AreaTrabajo', area.toMap()..remove('id_area'));
      return id;
    });
  }

  /// Lista para la pantalla de inicio: lo más reciente primero.
  Future<List<Proyecto>> listar() async {
    final db = await _db;
    final filas =
        await db.query('Proyecto', orderBy: 'fecha_ultima_modificacion DESC');
    return filas.map(Proyecto.fromMap).toList();
  }

  Future<Proyecto?> obtener(int id) async {
    final db = await _db;
    final filas =
        await db.query('Proyecto', where: 'id_proyecto = ?', whereArgs: [id]);
    return filas.isEmpty ? null : Proyecto.fromMap(filas.first);
  }

  /// Guarda posición/zoom del viewport y marca el estado de guardado.
  Future<void> guardarVista(int id,
      {required double x,
      required double y,
      required double zoom,
      String estado = EstadoGuardado.guardado}) async {
    final db = await _db;
    await db.update(
      'Proyecto',
      {
        'vista_x': x,
        'vista_y': y,
        'vista_zoom': zoom,
        'estado_guardado': estado,
        'fecha_ultima_modificacion': DateTime.now().toIso8601String(),
      },
      where: 'id_proyecto = ?',
      whereArgs: [id],
    );
  }

  Future<void> renombrar(int id, String titulo) async {
    final db = await _db;
    await db.update(
      'Proyecto',
      {
        'titulo': titulo,
        'fecha_ultima_modificacion': DateTime.now().toIso8601String(),
      },
      where: 'id_proyecto = ?',
      whereArgs: [id],
    );
  }

  /// ON DELETE CASCADE borra áreas, elementos, recursos y notas del proyecto.
  Future<void> eliminar(int id) async {
    final db = await _db;
    await db.delete('Proyecto', where: 'id_proyecto = ?', whereArgs: [id]);
  }
}
