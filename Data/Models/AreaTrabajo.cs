using SQLite;
using ZeroBoard.Core;

namespace ZeroBoard.Data.Models;

/// <summary>Área con dimensiones definidas sobre el lienzo (diapositiva, hoja A4...).</summary>
[Table("AreaTrabajo")]
public class AreaTrabajo
{
    [PrimaryKey, AutoIncrement, Column("id_area")]
    public int IdArea { get; set; }

    [Column("id_proyecto")]
    public int IdProyecto { get; set; }

    [Column("nombre")]
    public string Nombre { get; set; } = "Sin nombre";

    [Column("orden")]
    public int Orden { get; set; }

    [Column("formato")]
    public FormatoArea Formato { get; set; } = FormatoArea.Panoramico16x9;

    [Column("ancho")]
    public double Ancho { get; set; }

    [Column("alto")]
    public double Alto { get; set; }

    [Column("x")]
    public double X { get; set; }

    [Column("y")]
    public double Y { get; set; }

    /// <summary>Color en INTEGER ARGB. -1 equivale a 0xFFFFFFFF (blanco).</summary>
    [Column("color_fondo")]
    public int ColorFondoArgb { get; set; } = -1;

    /// <summary>Crea un área con el tamaño por defecto de su formato.</summary>
    public static AreaTrabajo DeFormato(int idProyecto, FormatoArea formato, int orden = 0)
    {
        var (ancho, alto) = formato.Tamano();
        return new AreaTrabajo { IdProyecto = idProyecto, Formato = formato, Ancho = ancho, Alto = alto, Orden = orden };
    }
}
