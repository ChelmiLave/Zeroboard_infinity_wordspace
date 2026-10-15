-- ZeroBoard · Migración FUTURA (v2): cuenta opcional y colaboración.
-- NO se ejecuta en la versión 1. Viene del ERD original.

CREATE TABLE Usuario (
  id_usuario        INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre_completo   TEXT NOT NULL,
  correo            TEXT NOT NULL UNIQUE,
  token_sesion      TEXT,
  fecha_ultimo_sync TEXT
);

ALTER TABLE Proyecto ADD COLUMN id_usuario_creador INTEGER REFERENCES Usuario(id_usuario);
ALTER TABLE Proyecto ADD COLUMN estado_sincronizacion INTEGER NOT NULL DEFAULT 0
  CHECK (estado_sincronizacion IN (0,1,2)); -- 0 Pendiente, 1 Sincronizado, 2 Conflicto

CREATE TABLE Colaboracion (
  id_proyecto         INTEGER NOT NULL,
  id_usuario_invitado INTEGER NOT NULL,
  rol_permiso         INTEGER NOT NULL DEFAULT 1 CHECK (rol_permiso IN (0,1)), -- 0 Editor, 1 Lector
  PRIMARY KEY (id_proyecto, id_usuario_invitado),
  FOREIGN KEY (id_proyecto) REFERENCES Proyecto(id_proyecto) ON DELETE CASCADE,
  FOREIGN KEY (id_usuario_invitado) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);
