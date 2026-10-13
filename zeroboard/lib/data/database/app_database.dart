import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'schema_v1.dart';

/// Abre (o crea) la base local. Patrón singleton: una sola conexión en toda la app.
class AppDatabase {
  AppDatabase._(); // constructor privado: nadie más puede crear instancias
  static final AppDatabase instance = AppDatabase._();
  static Database? _db;

  /// Si ya está abierta la reutiliza; si no, la abre.
  Future<Database> get database async => _db ??= await _abrir();

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), 'zeroboard.db');
    return openDatabase(
      ruta,
      version: 1, // sube este número cuando cambies el esquema y agrega onUpgrade
      onConfigure: (db) async {
        // SQLite trae las claves foráneas apagadas: se activan en CADA conexión.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // batch = todas las sentencias en una sola transacción (o todas o ninguna).
        final batch = db.batch();
        for (final sentencia in schemaV1) {
          batch.execute(sentencia);
        }
        await batch.commit(noResult: true);
      },
    );
  }
}
