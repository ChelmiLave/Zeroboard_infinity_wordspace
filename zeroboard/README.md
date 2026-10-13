# ZeroBoard · estructura y modelos (Flutter + SQLite)

1. Copia `lib/` y `assets/` dentro de tu proyecto Flutter (`flutter create zeroboard`).
2. Agrega las dependencias de `pubspec_dependencias.txt` y corre `flutter pub get`.
3. Antes de usar la base, llama una vez en `main()`:
   WidgetsFlutterBinding.ensureInitialized();
   await AppDatabase.instance.database;
4. `assets/sql/schema.sql` es la fuente del esquema; `schema_v1.dart` se generó de ahí.
   Si cambias el esquema: sube `version` en `app_database.dart` y agrega `onUpgrade`.
5. `assets/sql/schema_v2_sync.sql` (usuario/colaboración) NO se usa en la v1.
