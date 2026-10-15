using SQLite;
using ZeroBoard.Core;

namespace ZeroBoard.Data.Models;

[Table("Plantilla")]
public class Plantilla
{
    [PrimaryKey, AutoIncrement, Column("id_plantilla")]
    public int IdPlantilla { get; set; }

    [Column("nombre")] public string Nombre { get; set; } = string.Empty;
    [Column("categoria")] public string Categoria { get; set; } = string.Empty;
    [Column("tipo_diseno")] public TipoDiseno TipoDiseno { get; set; }
    [Column("origen")] public OrigenPlantilla Origen { get; set; } = OrigenPlantilla.Incluida;
    [Column("ruta_recursos")] public string? RutaRecursos { get; set; }
}
