using SQLite;

namespace ZeroBoard.Data.Database;

/// <summary>
/// Abre (o crea) la base local. Se registra como Singleton: una sola conexión en toda la app.
/// </summary>
public class ZeroBoardDatabase
{
    private const int VersionEsquema = 1;
    private SQLiteAsyncConnection? _db;

    public static string RutaBase =>
        Path.Combine(FileSystem.AppDataDirectory, "zeroboard.db3"); // carpeta privada de la app

    /// <summary>Devuelve la conexión lista para usar (la crea la primera vez).</summary>
    public async Task<SQLiteAsyncConnection> ObtenerAsync()
    {
        if (_db is not null) return _db;

        // storeDateTimeAsTicks:false -> los DateTime se guardan como texto ISO 8601 (legible).
        var db = new SQLiteAsyncConnection(
            RutaBase,
            SQLiteOpenFlags.ReadWrite | SQLiteOpenFlags.Create | SQLiteOpenFlags.SharedCache,
            storeDateTimeAsTicks: false);

        // SQLite trae las claves foráneas apagadas: hay que activarlas en cada conexión.
        await db.ExecuteAsync("PRAGMA foreign_keys = ON");

        var version = await db.ExecuteScalarAsync<int>("PRAGMA user_version");
        if (version < 1)
        {
            // Todas las sentencias en una transacción: o se crea todo o nada.
            await db.RunInTransactionAsync(conn =>
            {
                foreach (var sentencia in SchemaV1.Sentencias)
                    conn.Execute(sentencia);
            });
            await db.ExecuteAsync($"PRAGMA user_version = {VersionEsquema}");
        }
        // Futuro: if (version < 2) { ...migración... }

        _db = db;
        return _db;
    }
}
