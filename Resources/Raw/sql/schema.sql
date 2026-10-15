-- ZeroBoard · Esquema SQLite v1 (100% local, sin cuenta)
-- Enums: INTEGER (coinciden con los enum de C#). Booleanos: 0/1.
-- Fechas: texto ISO 8601 (DateTime en C#). Colores: INTEGER ARGB (0xAARRGGBB).

CREATE TABLE Plantilla (
  id_plantilla  INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre        TEXT NOT NULL,
  categoria     TEXT NOT NULL,
  tipo_diseno   INTEGER NOT NULL CHECK (tipo_diseno IN (0,1)),      -- 0 Presentacion, 1 Pizarra
  origen        INTEGER NOT NULL DEFAULT 0 CHECK (origen IN (0,1)), -- 0 Incluida, 1 Descargada
  ruta_recursos TEXT
);

CREATE TABLE Proyecto (
  id_proyecto               INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo                    TEXT NOT NULL,
  tipo_diseno               INTEGER NOT NULL CHECK (tipo_diseno IN (0,1)),
  id_plantilla_origen       INTEGER,
  estado_guardado           INTEGER NOT NULL DEFAULT 0 CHECK (estado_guardado IN (0,1,2)), -- 0 Guardado, 1 Pendiente, 2 Error
  ruta_miniatura            TEXT,
  vista_x                   REAL NOT NULL DEFAULT 0,
  vista_y                   REAL NOT NULL DEFAULT 0,
  vista_zoom                REAL NOT NULL DEFAULT 1,
  fecha_creacion            TEXT NOT NULL,
  fecha_ultima_modificacion TEXT NOT NULL,
  FOREIGN KEY (id_plantilla_origen) REFERENCES Plantilla(id_plantilla) ON DELETE SET NULL
);

CREATE TABLE AreaTrabajo (
  id_area     INTEGER PRIMARY KEY AUTOINCREMENT,
  id_proyecto INTEGER NOT NULL,
  nombre      TEXT NOT NULL DEFAULT 'Sin nombre',
  orden       INTEGER NOT NULL DEFAULT 0,
  formato     INTEGER NOT NULL DEFAULT 0 CHECK (formato IN (0,1,2,3,4)), -- 0 16:9, 1 4:3, 2 A4, 3 Carta, 4 Libre
  ancho       REAL NOT NULL,
  alto        REAL NOT NULL,
  x           REAL NOT NULL DEFAULT 0,
  y           REAL NOT NULL DEFAULT 0,
  color_fondo INTEGER NOT NULL DEFAULT -1,  -- -1 = 0xFFFFFFFF (blanco opaco)
  FOREIGN KEY (id_proyecto) REFERENCES Proyecto(id_proyecto) ON DELETE CASCADE
);

CREATE TABLE ElementoDiseno (
  id_elemento      INTEGER PRIMARY KEY AUTOINCREMENT,
  id_proyecto      INTEGER NOT NULL,
  id_area          INTEGER,
  tipo_elemento    INTEGER NOT NULL CHECK (tipo_elemento IN (0,1,2,3,4,5)), -- 0 Texto,1 Forma,2 Imagen,3 Trazo,4 Linea,5 NotaAdhesiva
  propiedades_json TEXT NOT NULL DEFAULT '{}',
  orden_capa       INTEGER NOT NULL DEFAULT 0,
  x                REAL NOT NULL DEFAULT 0,
  y                REAL NOT NULL DEFAULT 0,
  ancho            REAL NOT NULL DEFAULT 0,
  alto             REAL NOT NULL DEFAULT 0,
  rotacion         REAL NOT NULL DEFAULT 0,
  bloqueado        INTEGER NOT NULL DEFAULT 0 CHECK (bloqueado IN (0,1)),
  visible          INTEGER NOT NULL DEFAULT 1 CHECK (visible IN (0,1)),
  FOREIGN KEY (id_proyecto) REFERENCES Proyecto(id_proyecto) ON DELETE CASCADE,
  FOREIGN KEY (id_area) REFERENCES AreaTrabajo(id_area) ON DELETE CASCADE
);

CREATE TABLE Recurso (
  id_recurso   INTEGER PRIMARY KEY AUTOINCREMENT,
  id_proyecto  INTEGER NOT NULL,
  tipo         INTEGER NOT NULL DEFAULT 0 CHECK (tipo IN (0)), -- 0 Imagen
  ruta_local   TEXT NOT NULL,
  ancho_px     INTEGER,
  alto_px      INTEGER,
  tamano_bytes INTEGER,
  FOREIGN KEY (id_proyecto) REFERENCES Proyecto(id_proyecto) ON DELETE CASCADE
);

CREATE TABLE Nota (
  id_nota            INTEGER PRIMARY KEY AUTOINCREMENT,
  id_proyecto        INTEGER,
  titulo             TEXT NOT NULL,
  contenido          TEXT NOT NULL DEFAULT '',
  fecha_recordatorio TEXT,
  id_notificacion    INTEGER,
  completada         INTEGER NOT NULL DEFAULT 0 CHECK (completada IN (0,1)),
  fecha_creacion     TEXT NOT NULL,
  FOREIGN KEY (id_proyecto) REFERENCES Proyecto(id_proyecto) ON DELETE CASCADE
);

CREATE INDEX idx_area_proyecto       ON AreaTrabajo(id_proyecto, orden);
CREATE INDEX idx_elemento_proyecto   ON ElementoDiseno(id_proyecto, orden_capa);
CREATE INDEX idx_elemento_bbox       ON ElementoDiseno(id_proyecto, x, y);
CREATE INDEX idx_recurso_proyecto    ON Recurso(id_proyecto);
CREATE INDEX idx_nota_proyecto       ON Nota(id_proyecto);
CREATE INDEX idx_proyecto_modificado ON Proyecto(fecha_ultima_modificacion DESC)
