using SQLite;

namespace ZeroBoard.Data.Models;

[Table("Nota")]
public class Nota
{
    [PrimaryKey, AutoIncrement, Column("id_nota")]
    public int IdNota { get; set; }

    [Column("id_proyecto")] public int? IdProyecto { get; set; } // null = nota suelta
    [Column("titulo")] public string Titulo { get; set; } = string.Empty;
    [Column("contenido")] public string Contenido { get; set; } = string.Empty;
    [Column("fecha_recordatorio")] public DateTime? FechaRecordatorio { get; set; }
    [Column("id_notificacion")] public int? IdNotificacion { get; set; }
    [Column("completada")] public bool Completada { get; set; }
    [Column("fecha_creacion")] public DateTime FechaCreacion { get; set; } = DateTime.Now;
}
