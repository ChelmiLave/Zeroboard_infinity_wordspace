using SQLite;
using ZeroBoard.Core;

namespace ZeroBoard.Data.Models;

[Table("Recurso")]
public class Recurso
{
    [PrimaryKey, AutoIncrement, Column("id_recurso")]
    public int IdRecurso { get; set; }

    [Column("id_proyecto")]
    public int IdProyecto { get; set; }

    [Column("tipo")]
    public TipoRecurso Tipo { get; set; } = TipoRecurso.Imagen;

    [Column("ruta_local")] // dentro de la carpeta privada de la app
    public string RutaLocal { get; set; } = string.Empty;

    [Column("ancho_px")] public int? AnchoPx { get; set; }
    [Column("alto_px")] public int? AltoPx { get; set; }
    [Column("tamano_bytes")] public long? TamanoBytes { get; set; }
}
