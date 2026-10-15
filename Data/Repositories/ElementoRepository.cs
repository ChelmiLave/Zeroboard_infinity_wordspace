using ZeroBoard.Data.Database;
using ZeroBoard.Data.Models;

namespace ZeroBoard.Data.Repositories;

public class ElementoRepository(ZeroBoardDatabase database)
{
    public async Task<int> InsertarAsync(ElementoDiseno e)
    {
        var db = await database.ObtenerAsync();
        await db.InsertAsync(e); // rellena e.IdElemento
        return e.IdElemento;
    }

    public async Task ActualizarAsync(ElementoDiseno e)
    {
        var db = await database.ObtenerAsync();
        await db.UpdateAsync(e);
    }

    public async Task EliminarAsync(int idElemento)
    {
        var db = await database.ObtenerAsync();
        await db.DeleteAsync<ElementoDiseno>(idElemento);
    }

    /// <summary>Todos los elementos del proyecto, de atrás hacia adelante (orden de capa).</summary>
    public async Task<List<ElementoDiseno>> DeProyectoAsync(int idProyecto)
    {
        var db = await database.ObtenerAsync();
        return await db.Table<ElementoDiseno>()
            .Where(e => e.IdProyecto == idProyecto)
            .OrderBy(e => e.OrdenCapa)
            .ToListAsync();
    }

    /// <summary>
    /// CULLING: solo los elementos cuya caja toca el rectángulo visible.
    /// Dos rectángulos se intersectan si no están totalmente separados en X ni en Y.
    /// (No considera la rotación; añade un margen si rotas mucho.)
    /// </summary>
    public async Task<List<ElementoDiseno>> EnRegionAsync(
        int idProyecto, double izq, double arriba, double der, double abajo)
    {
        var db = await database.ObtenerAsync();
        return await db.QueryAsync<ElementoDiseno>(
            """
            SELECT * FROM ElementoDiseno
            WHERE id_proyecto = ? AND visible = 1
              AND x <= ? AND (x + ancho) >= ?
              AND y <= ? AND (y + alto) >= ?
            ORDER BY orden_capa
            """,
            idProyecto, der, izq, abajo, arriba);
    }
}
