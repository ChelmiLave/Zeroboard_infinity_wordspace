using SQLite;
using ZeroBoard.Core;

namespace ZeroBoard.Data.Models;

[Table("Proyecto")] // nombre de la tabla en SQLite
public class Proyecto
{
    [PrimaryKey, AutoIncrement, Column("id_proyecto")]
    public int IdProyecto { get; set; } // 0 hasta que SQLite asigne el id

    [Column("titulo")]
    public string Titulo { get; set; } = string.Empty;

    [Column("tipo_diseno")]
    public TipoDiseno TipoDiseno { get; set; } // enum -> INTEGER

    [Column("id_plantilla_origen")]
    public int? IdPlantillaOrigen { get; set; } // int? = acepta NULL

    [Column("estado_guardado")]
    public EstadoGuardado EstadoGuardado { get; set; } = EstadoGuardado.Guardado;

    [Column("ruta_miniatura")]
    public string? RutaMiniatura { get; set; }

    [Column("vista_x")]
    public double VistaX { get; set; }

    [Column("vista_y")]
    public double VistaY { get; set; }

    [Column("vista_zoom")]
    public double VistaZoom { get; set; } = 1;

    [Column("fecha_creacion")]
    public DateTime FechaCreacion { get; set; } = DateTime.Now;

    [Column("fecha_ultima_modificacion")]
    public DateTime FechaUltimaModificacion { get; set; } = DateTime.Now;
}
