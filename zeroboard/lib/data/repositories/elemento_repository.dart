import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/elemento_diseno.dart';

class ElementoRepository {
  Future<Database> get _db => AppDatabase.instance.database;

  Future<int> insertar(ElementoDiseno e) async {
    final db = await _db;
    return db.insert('ElementoDiseno', e.toMap()..remove('id_elemento'));
  }

  Future<void> actualizar(ElementoDiseno e) async {
    final db = await _db;
    await db.update('ElementoDiseno', e.toMap(),
        where: 'id_elemento = ?', whereArgs: [e.idElemento]);
  }

  Future<void> eliminar(int idElemento) async {
    final db = await _db;
    await db.delete('ElementoDiseno',
        where: 'id_elemento = ?', whereArgs: [idElemento]);
  }

  /// Todos los elementos del proyecto, de atrás hacia adelante (orden de capa).
  Future<List<ElementoDiseno>> deProyecto(int idProyecto) async {
    final db = await _db;
    final filas = await db.query('ElementoDiseno',
        where: 'id_proyecto = ?', whereArgs: [idProyecto], orderBy: 'orden_capa');
    return filas.map(ElementoDiseno.fromMap).toList();
  }

  /// CULLING: solo los elementos cuya caja toca el rectángulo visible.
  /// Dos rectángulos se intersectan si no están totalmente separados en X ni en Y.
  /// (No considera la rotación; añade un margen si rotas mucho.)
  Future<List<ElementoDiseno>> enRegion(
    int idProyecto, {
    required double izq,
    required double arriba,
    required double der,
    required double abajo,
  }) async {
    final db = await _db;
    final filas = await db.query(
      'ElementoDiseno',
      where: 'id_proyecto = ? AND visible = 1 '
          'AND x <= ? AND (x + ancho) >= ? '
          'AND y <= ? AND (y + alto) >= ?',
      whereArgs: [idProyecto, der, izq, abajo, arriba],
      orderBy: 'orden_capa',
    );
    return filas.map(ElementoDiseno.fromMap).toList();
  }
}
