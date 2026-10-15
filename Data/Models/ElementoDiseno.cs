using System.Text.Json;
using SQLite;
using ZeroBoard.Core;

namespace ZeroBoard.Data.Models;

[Table("ElementoDiseno")]
public class ElementoDiseno
{
    [PrimaryKey, AutoIncrement, Column("id_elemento")]
    public int IdElemento { get; set; }

    [Column("id_proyecto")]
    public int IdProyecto { get; set; }

    [Column("id_area")]
    public int? IdArea { get; set; } // null = flota libre en el lienzo

    [Column("tipo_elemento")]
    public TipoElemento TipoElemento { get; set; }

    /// <summary>Texto JSON tal como se guarda en la base. Usa <see cref="Propiedades"/> para leer/escribir.</summary>
    [Column("propiedades_json")]
    public string PropiedadesJson { get; set; } = "{}";

    [Column("orden_capa")]
    public int OrdenCapa { get; set; }

    // Caja delimitadora: permite pedir solo lo visible (culling).
    [Column("x")] public double X { get; set; }
    [Column("y")] public double Y { get; set; }
    [Column("ancho")] public double Ancho { get; set; }
    [Column("alto")] public double Alto { get; set; }
    [Column("rotacion")] public double Rotacion { get; set; }

    [Column("bloqueado")] public bool Bloqueado { get; set; } // bool -> INTEGER 0/1
    [Column("visible")] public bool Visible { get; set; } = true;

    /// <summary>Propiedades como diccionario (color, texto, grosor...). [Ignore] = no es columna.</summary>
    [Ignore]
    public Dictionary<string, JsonElement> Propiedades
    {
        get => JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(PropiedadesJson) ?? new();
        set => PropiedadesJson = JsonSerializer.Serialize(value);
    }
}
