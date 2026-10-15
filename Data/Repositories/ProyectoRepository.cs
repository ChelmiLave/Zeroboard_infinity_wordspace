using ZeroBoard.Core;
using ZeroBoard.Data.Database;
using ZeroBoard.Data.Models;

namespace ZeroBoard.Data.Repositories;

public class ProyectoRepository(ZeroBoardDatabase database)
{
    /// <summary>Crea el proyecto y su primera área en UNA transacción.</summary>
    public async Task<int> CrearAsync(string titulo, TipoDiseno tipo, int? idPlantillaOrigen = null)
    {
        var db = await database.ObtenerAsync();
        var proyecto = new Proyecto { Titulo = titulo, TipoDiseno = tipo, IdPlantillaOrigen = idPlantillaOrigen };

        await db.RunInTransactionAsync(conn =>
        {
            conn.Insert(proyecto); // Insert rellena proyecto.IdProyecto
            var formato = tipo == TipoDiseno.Presentacion ? FormatoArea.Panoramico16x9 : FormatoArea.Libre;
            conn.Insert(AreaTrabajo.DeFormato(proyecto.IdProyecto, formato));
        });
        return proyecto.IdProyecto;
    }

    /// <summary>Pantalla de inicio: lo más reciente primero.</summary>
    public async Task<List<Proyecto>> ListarAsync()
    {
        var db = await database.ObtenerAsync();
        return await db.Table<Proyecto>().OrderByDescending(p => p.FechaUltimaModificacion).ToListAsync();
    }

    public async Task<Proyecto?> ObtenerAsync(int id)
    {
        var db = await database.ObtenerAsync();
        return await db.FindAsync<Proyecto>(id); // null si no existe
    }

    /// <summary>Guarda posición/zoom del viewport y marca el estado de guardado.</summary>
    public async Task GuardarVistaAsync(int id, double x, double y, double zoom,
        EstadoGuardado estado = EstadoGuardado.Guardado)
    {
        var db = await database.ObtenerAsync();
        var p = await db.FindAsync<Proyecto>(id);
        if (p is null) return;
        p.VistaX = x; p.VistaY = y; p.VistaZoom = zoom;
        p.EstadoGuardado = estado;
        p.FechaUltimaModificacion = DateTime.Now;
        await db.UpdateAsync(p);
    }

    public async Task RenombrarAsync(int id, string titulo)
    {
        var db = await database.ObtenerAsync();
        var p = await db.FindAsync<Proyecto>(id);
        if (p is null) return;
        p.Titulo = titulo;
        p.FechaUltimaModificacion = DateTime.Now;
        await db.UpdateAsync(p);
    }

    /// <summary>ON DELETE CASCADE borra áreas, elementos, recursos y notas del proyecto.</summary>
    public async Task EliminarAsync(int id)
    {
        var db = await database.ObtenerAsync();
        await db.DeleteAsync<Proyecto>(id);
    }
}
