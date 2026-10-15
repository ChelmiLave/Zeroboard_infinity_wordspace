namespace ZeroBoard.Core;

// Se guardan en SQLite como INTEGER: el número de cada valor debe coincidir con los CHECK del schema.sql.
// No cambies el orden ni los números de los valores existentes (solo agrega al final).

public enum TipoDiseno { Presentacion = 0, Pizarra = 1 }

public enum EstadoGuardado { Guardado = 0, Pendiente = 1, Error = 2 }

public enum FormatoArea { Panoramico16x9 = 0, Estandar4x3 = 1, A4 = 2, Carta = 3, Libre = 4 }

public enum TipoElemento { Texto = 0, Forma = 1, Imagen = 2, Trazo = 3, Linea = 4, NotaAdhesiva = 5 }

public enum OrigenPlantilla { Incluida = 0, Descargada = 1 }

public enum TipoRecurso { Imagen = 0 }

public static class FormatoAreaExtensions
{
    /// <summary>Tamaño por defecto (ancho, alto) en unidades del lienzo.</summary>
    public static (double Ancho, double Alto) Tamano(this FormatoArea formato) => formato switch
    {
        FormatoArea.Estandar4x3 => (1024, 768),
        FormatoArea.A4 => (794, 1123),
        FormatoArea.Carta => (816, 1056),
        _ => (1280, 720),
    };
}
