// GENERADO desde assets/sql/schema.sql — no editar a mano.
// Lista de sentencias que AppDatabase ejecuta al crear la base (onCreate).
const List<String> schemaV1 = [
  '''
CREATE TABLE Plantilla (
  id_plantilla INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre       TEXT NOT NULL,
  categoria    TEXT NOT NULL,
  tipo_diseno  TEXT NOT NULL CHECK (tipo_diseno IN ('presentacion','pizarra')),
  origen       TEXT NOT NULL DEFAULT 'incluida' CHECK (origen IN ('incluida','descargada')),
  ruta_recursos TEXT
)
  ''',
  '''
CREATE TABLE Proyecto (
  id_proyecto               INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo                    TEXT NOT NULL,
  tipo_diseno               TEXT NOT NULL CHECK (tipo_diseno IN ('presentacion','pizarra')),
  id_plantilla_origen       INTEGER,
  estado_guardado           TEXT NOT NULL DEFAULT 'guardado' CHECK (estado_guardado IN ('guardado','pendiente','error')),
  ruta_miniatura            TEXT,
  vista_x                   REAL NOT NULL DEFAULT 0,
  vista_y                   REAL NOT NULL DEFAULT 0,
  vista_zoom                REAL NOT NULL DEFAULT 1,
  fecha_creacion            TEXT NOT NULL DEFAULT (datetime('now')),
  fecha_ultima_modificacion TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (id_plantilla_origen) REFERENCES Plantilla(id_plantilla) ON DELETE SET NULL
)
  ''',
  '''
CREATE TABLE AreaTrabajo (
  id_area     INTEGER PRIMARY KEY AUTOINCREMENT,
  id_proyecto INTEGER NOT NULL,
  nombre      TEXT NOT NULL DEFAULT 'Sin nombre',
  orden       INTEGER NOT NULL DEFAULT 0,
  formato     TEXT NOT NULL DEFAULT '16_9' CHECK (formato IN ('16_9','4_3','a4','carta','libre')),
  ancho       REAL NOT NULL,
  alto        REAL NOT NULL,
  x           REAL NOT NULL DEFAULT 0,
  y           REAL NOT NULL DEFAULT 0,
  color_fondo TEXT NOT NULL DEFAULT '#FFFFFF',
  FOREIGN KEY (id_proyecto) REFERENCES Proyecto(id_proyecto) ON DELETE CASCADE
)
  ''',
  '''
CREATE TABLE ElementoDiseno (
  id_elemento      INTEGER PRIMARY KEY AUTOINCREMENT,
  id_proyecto      INTEGER NOT NULL,
  id_area          INTEGER,
  tipo_elemento    TEXT NOT NULL CHECK (tipo_elemento IN ('texto','forma','imagen','trazo','linea','nota')),
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
)
  ''',
  '''
CREATE TABLE Recurso (
  id_recurso   INTEGER PRIMARY KEY AUTOINCREMENT,
  id_proyecto  INTEGER NOT NULL,
  tipo         TEXT NOT NULL DEFAULT 'imagen' CHECK (tipo IN ('imagen')),
  ruta_local   TEXT NOT NULL,
  ancho_px     INTEGER,
  alto_px      INTEGER,
  tamano_bytes INTEGER,
  FOREIGN KEY (id_proyecto) REFERENCES Proyecto(id_proyecto) ON DELETE CASCADE
)
  ''',
  '''
CREATE TABLE Nota (
  id_nota            INTEGER PRIMARY KEY AUTOINCREMENT,
  id_proyecto        INTEGER,
  titulo             TEXT NOT NULL,
  contenido          TEXT NOT NULL DEFAULT '',
  fecha_recordatorio TEXT,
  id_notificacion    INTEGER,
  completada         INTEGER NOT NULL DEFAULT 0 CHECK (completada IN (0,1)),
  fecha_creacion     TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (id_proyecto) REFERENCES Proyecto(id_proyecto) ON DELETE CASCADE
)
  ''',
  '''
CREATE INDEX idx_area_proyecto      ON AreaTrabajo(id_proyecto, orden)
  ''',
  '''
CREATE INDEX idx_elemento_proyecto  ON ElementoDiseno(id_proyecto, orden_capa)
  ''',
  '''
CREATE INDEX idx_elemento_bbox      ON ElementoDiseno(id_proyecto, x, y)
  ''',
  '''
CREATE INDEX idx_recurso_proyecto   ON Recurso(id_proyecto)
  ''',
  '''
CREATE INDEX idx_nota_proyecto      ON Nota(id_proyecto)
  ''',
  '''
CREATE INDEX idx_proyecto_modificado ON Proyecto(fecha_ultima_modificacion DESC)
  ''',
];
