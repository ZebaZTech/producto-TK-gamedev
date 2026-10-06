-- =====================================================================
--  Gamedev.  |  Sistema de gestión de desarrollo de videojuegos
--  Motor: MySQL 8.0.16+ (necesario para CHECK y JSON_TABLE)
--  Módulos de la app Tkinter (NO renombrar): videogames, empleados,
--  tareas, usuarios
-- =====================================================================

CREATE DATABASE IF NOT EXISTS gamedev
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gamedev;

-- =====================================================================
-- 1. TABLAS CATÁLOGO (dominios que evitan dependencias transitivas)
-- =====================================================================
CREATE TABLE generos (
  id_genero INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre    VARCHAR(50)  NOT NULL,
  PRIMARY KEY (id_genero),
  UNIQUE KEY uq_generos_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE plataformas (            -- plataformas objetivo (hardware)
  id_plataforma INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(50)  NOT NULL,
  tipo          ENUM('PC','consola','movil') NOT NULL,
  PRIMARY KEY (id_plataforma),
  UNIQUE KEY uq_plataformas_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE clasificaciones (
  id_clasificacion INT UNSIGNED NOT NULL AUTO_INCREMENT,
  sistema      ENUM('ESRB','PEGI') NOT NULL,
  codigo       VARCHAR(10)  NOT NULL,
  descripcion  VARCHAR(100) NULL,
  PRIMARY KEY (id_clasificacion),
  UNIQUE KEY uq_clasificaciones (sistema, codigo)
) ENGINE=InnoDB;

CREATE TABLE motores_graficos (
  id_motor INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre   VARCHAR(60)  NOT NULL,
  PRIMARY KEY (id_motor),
  UNIQUE KEY uq_motores_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE especialidades (
  id_especialidad INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre          VARCHAR(50)  NOT NULL,
  PRIMARY KEY (id_especialidad),
  UNIQUE KEY uq_especialidades_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE habilidades (
  id_habilidad INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre       VARCHAR(80)  NOT NULL,
  PRIMARY KEY (id_habilidad),
  UNIQUE KEY uq_habilidades_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE roles_proyecto (
  id_rol INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(60)  NOT NULL,
  PRIMARY KEY (id_rol),
  UNIQUE KEY uq_roles_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE modulos_desarrollo (     -- jugabilidad, gráficos, sonido, IA
  id_modulo INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre    VARCHAR(50)  NOT NULL,
  PRIMARY KEY (id_modulo),
  UNIQUE KEY uq_modulos_desarrollo_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE lenguajes_programacion (
  id_lenguaje INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre      VARCHAR(50)  NOT NULL,
  PRIMARY KEY (id_lenguaje),
  UNIQUE KEY uq_lenguajes_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE tiendas_digitales (      -- Steam, Epic, App Store...
  id_tienda INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre    VARCHAR(60)  NOT NULL,
  PRIMARY KEY (id_tienda),
  UNIQUE KEY uq_tiendas_nombre (nombre)
) ENGINE=InnoDB;

-- =====================================================================
-- 2. MÓDULO videogames
-- =====================================================================
CREATE TABLE videogames (
  id_videogame     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo           VARCHAR(20)  NOT NULL,
  titulo           VARCHAR(150) NOT NULL,
  id_genero        INT UNSIGNED NOT NULL,
  id_clasificacion INT UNSIGNED NOT NULL,
  id_motor         INT UNSIGNED NULL,
  fecha_inicio     DATE NOT NULL,
  fecha_lanzamiento_prevista DATE NULL,
  presupuesto      DECIMAL(14,2) NOT NULL DEFAULT 0,
  estado           ENUM('planificacion','desarrollo','pruebas','lanzado','pausado','cancelado')
                   NOT NULL DEFAULT 'planificacion',
  PRIMARY KEY (id_videogame),
  UNIQUE KEY uq_videogames_codigo (codigo),
  KEY idx_videogames_titulo (titulo),
  KEY idx_videogames_estado (estado),
  CONSTRAINT chk_videogames_presupuesto CHECK (presupuesto >= 0),
  CONSTRAINT chk_videogames_fechas CHECK
    (fecha_lanzamiento_prevista IS NULL OR fecha_lanzamiento_prevista >= fecha_inicio),
  CONSTRAINT fk_videogames_genero FOREIGN KEY (id_genero)
    REFERENCES generos (id_genero) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_videogames_clasificacion FOREIGN KEY (id_clasificacion)
    REFERENCES clasificaciones (id_clasificacion) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_videogames_motor FOREIGN KEY (id_motor)
    REFERENCES motores_graficos (id_motor) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE videogame_plataformas (  -- N:M videogames <-> plataformas
  id_videogame  INT UNSIGNED NOT NULL,
  id_plataforma INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_videogame, id_plataforma),
  CONSTRAINT fk_vgp_videogame FOREIGN KEY (id_videogame)
    REFERENCES videogames (id_videogame) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_vgp_plataforma FOREIGN KEY (id_plataforma)
    REFERENCES plataformas (id_plataforma) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================================
-- 3. MÓDULO empleados
-- =====================================================================
CREATE TABLE empleados (
  id_empleado      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo_empleado  VARCHAR(20)  NOT NULL,
  nombres          VARCHAR(80)  NOT NULL,
  apellidos        VARCHAR(80)  NOT NULL,
  id_especialidad  INT UNSIGNED NOT NULL,
  anios_experiencia TINYINT UNSIGNED NOT NULL DEFAULT 0,
  experiencia_previa TEXT NULL,
  correo           VARCHAR(120) NULL,
  activo           TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_empleado),
  UNIQUE KEY uq_empleados_codigo (codigo_empleado),
  UNIQUE KEY uq_empleados_correo (correo),
  KEY idx_empleados_apellidos (apellidos, nombres),
  CONSTRAINT chk_empleados_activo CHECK (activo IN (0,1)),
  CONSTRAINT fk_empleados_especialidad FOREIGN KEY (id_especialidad)
    REFERENCES especialidades (id_especialidad) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE empleado_habilidades (   -- N:M empleados <-> habilidades
  id_empleado  INT UNSIGNED NOT NULL,
  id_habilidad INT UNSIGNED NOT NULL,
  nivel ENUM('basico','intermedio','avanzado','experto') NOT NULL DEFAULT 'intermedio',
  PRIMARY KEY (id_empleado, id_habilidad),
  CONSTRAINT fk_eh_empleado FOREIGN KEY (id_empleado)
    REFERENCES empleados (id_empleado) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_eh_habilidad FOREIGN KEY (id_habilidad)
    REFERENCES habilidades (id_habilidad) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE asignaciones_proyecto (  -- equipo de desarrollo (N:M con atributos)
  id_asignacion INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_videogame  INT UNSIGNED NOT NULL,
  id_empleado   INT UNSIGNED NOT NULL,
  id_rol        INT UNSIGNED NOT NULL,
  porcentaje_dedicacion DECIMAL(5,2) NOT NULL,
  fecha_asignacion DATE NOT NULL,
  fecha_fin     DATE NULL,
  PRIMARY KEY (id_asignacion),
  UNIQUE KEY uq_asignacion (id_videogame, id_empleado),
  KEY idx_asignacion_empleado (id_empleado),
  CONSTRAINT chk_asig_porcentaje CHECK (porcentaje_dedicacion > 0 AND porcentaje_dedicacion <= 100),
  CONSTRAINT chk_asig_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_asignacion),
  CONSTRAINT fk_asig_videogame FOREIGN KEY (id_videogame)
    REFERENCES videogames (id_videogame) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_asig_empleado FOREIGN KEY (id_empleado)
    REFERENCES empleados (id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_asig_rol FOREIGN KEY (id_rol)
    REFERENCES roles_proyecto (id_rol) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================================
-- 4. MÓDULO tareas
-- =====================================================================
CREATE TABLE tareas (
  id_tarea       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo         VARCHAR(20)  NOT NULL,
  id_videogame   INT UNSIGNED NOT NULL,
  id_modulo      INT UNSIGNED NOT NULL,
  descripcion    TEXT NOT NULL,
  prioridad      ENUM('baja','media','alta','critica') NOT NULL DEFAULT 'media',
  estado         ENUM('pendiente','en_proceso','revision','completada') NOT NULL DEFAULT 'pendiente',
  id_responsable INT UNSIGNED NULL,
  fecha_asignacion DATE NOT NULL,
  fecha_limite   DATE NOT NULL,
  porcentaje_avance DECIMAL(5,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_tarea),
  UNIQUE KEY uq_tareas_codigo (codigo),
  KEY idx_tareas_videogame_estado (id_videogame, estado),
  KEY idx_tareas_responsable (id_responsable),
  KEY idx_tareas_fecha_limite (fecha_limite),
  CONSTRAINT chk_tareas_avance CHECK (porcentaje_avance BETWEEN 0 AND 100),
  CONSTRAINT chk_tareas_fechas CHECK (fecha_limite >= fecha_asignacion),
  CONSTRAINT fk_tareas_videogame FOREIGN KEY (id_videogame)
    REFERENCES videogames (id_videogame) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_tareas_modulo FOREIGN KEY (id_modulo)
    REFERENCES modulos_desarrollo (id_modulo) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_tareas_responsable FOREIGN KEY (id_responsable)
    REFERENCES empleados (id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE tarea_dependencias (     -- N:M reflexiva tareas <-> tareas
  id_tarea             INT UNSIGNED NOT NULL,
  id_tarea_predecesora INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_tarea, id_tarea_predecesora),
  CONSTRAINT fk_td_tarea FOREIGN KEY (id_tarea)
    REFERENCES tareas (id_tarea) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_td_predecesora FOREIGN KEY (id_tarea_predecesora)
    REFERENCES tareas (id_tarea) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 5. ASSETS GRÁFICOS
-- =====================================================================
CREATE TABLE assets (
  id_asset     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo       VARCHAR(20)  NOT NULL,
  nombre       VARCHAR(100) NOT NULL,
  tipo         ENUM('personaje','escenario','objeto','interfaz') NOT NULL,
  descripcion  TEXT NULL,
  formato      VARCHAR(20)  NOT NULL,
  resolucion   VARCHAR(20)  NULL,
  id_videogame INT UNSIGNED NOT NULL,
  id_artista   INT UNSIGNED NULL,
  version_actual VARCHAR(20) NOT NULL DEFAULT '1.0',
  fecha_ultima_modificacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                            ON UPDATE CURRENT_TIMESTAMP,
  requisitos_tecnicos TEXT NULL,
  estado_aprobacion ENUM('pendiente','en_revision','aprobado','rechazado')
                    NOT NULL DEFAULT 'pendiente',
  PRIMARY KEY (id_asset),
  UNIQUE KEY uq_assets_codigo (codigo),
  KEY idx_assets_videogame_tipo (id_videogame, tipo),
  CONSTRAINT fk_assets_videogame FOREIGN KEY (id_videogame)
    REFERENCES videogames (id_videogame) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_assets_artista FOREIGN KEY (id_artista)
    REFERENCES empleados (id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================================
-- 6. CÓDIGO FUENTE
-- =====================================================================
CREATE TABLE modulos_codigo (
  id_modulo_codigo INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo       VARCHAR(20)  NOT NULL,
  nombre       VARCHAR(100) NOT NULL,
  id_videogame INT UNSIGNED NOT NULL,
  id_lenguaje  INT UNSIGNED NOT NULL,
  id_plataforma INT UNSIGNED NULL,
  funcionalidad_principal TEXT NULL,
  id_desarrollador INT UNSIGNED NULL,
  numero_lineas INT UNSIGNED NOT NULL DEFAULT 0,
  estado_compilacion ENUM('sin_compilar','compilando','exitosa','con_errores')
                     NOT NULL DEFAULT 'sin_compilar',
  PRIMARY KEY (id_modulo_codigo),
  UNIQUE KEY uq_modulos_codigo_codigo (codigo),
  UNIQUE KEY uq_modulos_codigo_nombre (id_videogame, nombre),
  CONSTRAINT fk_mc_videogame FOREIGN KEY (id_videogame)
    REFERENCES videogames (id_videogame) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_mc_lenguaje FOREIGN KEY (id_lenguaje)
    REFERENCES lenguajes_programacion (id_lenguaje) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_mc_plataforma FOREIGN KEY (id_plataforma)
    REFERENCES plataformas (id_plataforma) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_mc_desarrollador FOREIGN KEY (id_desarrollador)
    REFERENCES empleados (id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE modulos_codigo_dependencias (  -- N:M reflexiva
  id_modulo_codigo   INT UNSIGNED NOT NULL,
  id_modulo_requerido INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_modulo_codigo, id_modulo_requerido),
  CONSTRAINT fk_mcd_modulo FOREIGN KEY (id_modulo_codigo)
    REFERENCES modulos_codigo (id_modulo_codigo) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_mcd_requerido FOREIGN KEY (id_modulo_requerido)
    REFERENCES modulos_codigo (id_modulo_codigo) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE modulos_codigo_versiones (     -- historial de versiones
  id_historial     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_modulo_codigo INT UNSIGNED NOT NULL,
  numero_version   VARCHAR(20)  NOT NULL,
  fecha_cambio     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_autor         INT UNSIGNED NULL,
  descripcion_cambio TEXT NULL,
  hash_commit      VARCHAR(40) NULL,
  PRIMARY KEY (id_historial),
  UNIQUE KEY uq_mcv (id_modulo_codigo, numero_version),
  CONSTRAINT fk_mcv_modulo FOREIGN KEY (id_modulo_codigo)
    REFERENCES modulos_codigo (id_modulo_codigo) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_mcv_autor FOREIGN KEY (id_autor)
    REFERENCES empleados (id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================================
-- 7. VERSIONES DE PRUEBA, BUGS Y TESTEO
-- =====================================================================
CREATE TABLE versiones_prueba (
  id_version   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo       VARCHAR(20)  NOT NULL,
  id_videogame INT UNSIGNED NOT NULL,
  numero_version VARCHAR(20) NOT NULL,
  id_version_anterior INT UNSIGNED NULL,
  fecha_compilacion DATETIME NOT NULL,
  caracteristicas_implementadas TEXT NULL,
  cambios_respecto_anterior TEXT NULL,
  notas_testers TEXT NULL,
  PRIMARY KEY (id_version),
  UNIQUE KEY uq_versiones_codigo (codigo),
  UNIQUE KEY uq_versiones_numero (id_videogame, numero_version),
  CONSTRAINT fk_vp_videogame FOREIGN KEY (id_videogame)
    REFERENCES videogames (id_videogame) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_vp_anterior FOREIGN KEY (id_version_anterior)
    REFERENCES versiones_prueba (id_version) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE versiones_prueba_plataformas (
  id_version    INT UNSIGNED NOT NULL,
  id_plataforma INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_version, id_plataforma),
  CONSTRAINT fk_vpp_version FOREIGN KEY (id_version)
    REFERENCES versiones_prueba (id_version) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_vpp_plataforma FOREIGN KEY (id_plataforma)
    REFERENCES plataformas (id_plataforma) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE bugs (
  id_bug        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ticket        VARCHAR(20)  NOT NULL,
  id_version    INT UNSIGNED NOT NULL,
  fecha_reporte DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_modulo     INT UNSIGNED NOT NULL,
  descripcion   TEXT NOT NULL,
  pasos_reproducir TEXT NULL,
  severidad     ENUM('menor','moderado','mayor','critico') NOT NULL,
  prioridad     ENUM('baja','media','alta','urgente') NOT NULL DEFAULT 'media',
  id_tester     INT UNSIGNED NULL,
  id_desarrollador INT UNSIGNED NULL,
  estado_resolucion ENUM('abierto','asignado','en_correccion','resuelto','reabierto','cerrado')
                    NOT NULL DEFAULT 'abierto',
  verificado    TINYINT(1) NOT NULL DEFAULT 0,
  fecha_verificacion DATETIME NULL,
  PRIMARY KEY (id_bug),
  UNIQUE KEY uq_bugs_ticket (ticket),
  KEY idx_bugs_version_estado (id_version, estado_resolucion),
  KEY idx_bugs_severidad (severidad),
  CONSTRAINT chk_bugs_verificado CHECK (verificado IN (0,1)),
  CONSTRAINT fk_bugs_version FOREIGN KEY (id_version)
    REFERENCES versiones_prueba (id_version) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_bugs_modulo FOREIGN KEY (id_modulo)
    REFERENCES modulos_desarrollo (id_modulo) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_bugs_tester FOREIGN KEY (id_tester)
    REFERENCES empleados (id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_bugs_desarrollador FOREIGN KEY (id_desarrollador)
    REFERENCES empleados (id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE bug_adjuntos (
  id_adjunto INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_bug     INT UNSIGNED NOT NULL,
  tipo       ENUM('captura','video') NOT NULL,
  ruta_archivo VARCHAR(255) NOT NULL,
  fecha_subida DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_adjunto),
  KEY idx_bug_adjuntos_bug (id_bug),
  CONSTRAINT fk_ba_bug FOREIGN KEY (id_bug)
    REFERENCES bugs (id_bug) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE procesos_testeo (
  id_proceso  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo      VARCHAR(20)  NOT NULL,
  id_version  INT UNSIGNED NOT NULL,
  tipo_prueba ENUM('funcional','rendimiento','compatibilidad','jugabilidad') NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin   DATE NULL,
  cobertura   DECIMAL(5,2) NULL,
  resultado_final ENUM('pendiente','aprobado','aprobado_con_observaciones','rechazado')
                  NOT NULL DEFAULT 'pendiente',
  PRIMARY KEY (id_proceso),
  UNIQUE KEY uq_procesos_codigo (codigo),
  KEY idx_procesos_version (id_version),
  CONSTRAINT chk_procesos_cobertura CHECK (cobertura IS NULL OR cobertura BETWEEN 0 AND 100),
  CONSTRAINT chk_procesos_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
  CONSTRAINT fk_pt_version FOREIGN KEY (id_version)
    REFERENCES versiones_prueba (id_version) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE testeo_equipo (
  id_proceso  INT UNSIGNED NOT NULL,
  id_empleado INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_proceso, id_empleado),
  CONSTRAINT fk_te_proceso FOREIGN KEY (id_proceso)
    REFERENCES procesos_testeo (id_proceso) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_te_empleado FOREIGN KEY (id_empleado)
    REFERENCES empleados (id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE testeo_metricas (
  id_metrica INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_proceso INT UNSIGNED NOT NULL,
  nombre_metrica VARCHAR(60) NOT NULL,
  valor      DECIMAL(14,4) NOT NULL,
  unidad     VARCHAR(20) NULL,
  PRIMARY KEY (id_metrica),
  UNIQUE KEY uq_metrica (id_proceso, nombre_metrica),
  CONSTRAINT fk_tm_proceso FOREIGN KEY (id_proceso)
    REFERENCES procesos_testeo (id_proceso) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 8. DISTRIBUCIÓN DIGITAL
-- =====================================================================
CREATE TABLE distribuciones (
  id_distribucion INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo      VARCHAR(20) NOT NULL,
  id_tienda   INT UNSIGNED NOT NULL,
  id_version  INT UNSIGNED NOT NULL,
  fecha_publicacion DATE NOT NULL,
  tamano_gb   DECIMAL(8,2) NULL,
  requisitos_minimos TEXT NULL,
  requisitos_recomendados TEXT NULL,
  precio      DECIMAL(10,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_distribucion),
  UNIQUE KEY uq_distribuciones_codigo (codigo),
  UNIQUE KEY uq_distribuciones_tienda_version (id_tienda, id_version),
  CONSTRAINT chk_dist_precio CHECK (precio >= 0),
  CONSTRAINT chk_dist_tamano CHECK (tamano_gb IS NULL OR tamano_gb > 0),
  CONSTRAINT fk_dist_tienda FOREIGN KEY (id_tienda)
    REFERENCES tiendas_digitales (id_tienda) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_dist_version FOREIGN KEY (id_version)
    REFERENCES versiones_prueba (id_version) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE descuentos (
  id_descuento    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_distribucion INT UNSIGNED NOT NULL,
  descripcion     VARCHAR(100) NULL,
  porcentaje      DECIMAL(5,2) NOT NULL,
  fecha_inicio    DATE NOT NULL,
  fecha_fin       DATE NOT NULL,
  PRIMARY KEY (id_descuento),
  KEY idx_descuentos_dist (id_distribucion),
  CONSTRAINT chk_desc_porcentaje CHECK (porcentaje > 0 AND porcentaje <= 100),
  CONSTRAINT chk_desc_fechas CHECK (fecha_fin >= fecha_inicio),
  CONSTRAINT fk_desc_dist FOREIGN KEY (id_distribucion)
    REFERENCES distribuciones (id_distribucion) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 9. MÓDULO usuarios (usuarios registrados / jugadores)
-- =====================================================================
CREATE TABLE usuarios (
  id_usuario     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre_usuario VARCHAR(50)  NOT NULL,
  correo         VARCHAR(120) NOT NULL,
  password_hash  VARCHAR(255) NULL,          -- guardar SIEMPRE hash (bcrypt/argon2)
  fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado         ENUM('activo','inactivo','suspendido') NOT NULL DEFAULT 'activo',
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_usuarios_nombre (nombre_usuario),
  UNIQUE KEY uq_usuarios_correo (correo),
  KEY idx_usuarios_estado (estado)
) ENGINE=InnoDB;

CREATE TABLE usuario_plataformas (
  id_usuario    INT UNSIGNED NOT NULL,
  id_plataforma INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_usuario, id_plataforma),
  CONSTRAINT fk_up_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_up_plataforma FOREIGN KEY (id_plataforma)
    REFERENCES plataformas (id_plataforma) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE usuario_preferencias (
  id_preferencia INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_usuario INT UNSIGNED NOT NULL,
  clave      VARCHAR(50)  NOT NULL,
  valor      VARCHAR(255) NOT NULL,
  PRIMARY KEY (id_preferencia),
  UNIQUE KEY uq_pref (id_usuario, clave),
  CONSTRAINT fk_pref_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE adquisiciones (          -- compras = juegos adquiridos + tiempo de juego
  id_adquisicion  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_usuario      INT UNSIGNED NOT NULL,
  id_distribucion INT UNSIGNED NOT NULL,
  id_descuento    INT UNSIGNED NULL,
  fecha_compra    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  precio_pagado   DECIMAL(10,2) NOT NULL,
  minutos_jugados INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_adquisicion),
  UNIQUE KEY uq_adquisicion (id_usuario, id_distribucion),
  KEY idx_adq_distribucion (id_distribucion),
  CONSTRAINT chk_adq_precio CHECK (precio_pagado >= 0),
  CONSTRAINT fk_adq_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_adq_dist FOREIGN KEY (id_distribucion)
    REFERENCES distribuciones (id_distribucion) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_adq_desc FOREIGN KEY (id_descuento)
    REFERENCES descuentos (id_descuento) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE valoraciones (
  id_valoracion   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_usuario      INT UNSIGNED NOT NULL,
  id_distribucion INT UNSIGNED NOT NULL,
  puntuacion      TINYINT UNSIGNED NOT NULL,
  comentario      TEXT NULL,
  fecha           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_valoracion),
  UNIQUE KEY uq_valoracion (id_usuario, id_distribucion),
  CONSTRAINT chk_val_puntuacion CHECK (puntuacion BETWEEN 1 AND 5),
  CONSTRAINT fk_val_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_val_dist FOREIGN KEY (id_distribucion)
    REFERENCES distribuciones (id_distribucion) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE logros (
  id_logro     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_videogame INT UNSIGNED NOT NULL,
  nombre       VARCHAR(100) NOT NULL,
  descripcion  VARCHAR(255) NULL,
  puntos       INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (id_logro),
  UNIQUE KEY uq_logros (id_videogame, nombre),
  CONSTRAINT fk_logros_videogame FOREIGN KEY (id_videogame)
    REFERENCES videogames (id_videogame) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE usuario_logros (
  id_usuario INT UNSIGNED NOT NULL,
  id_logro   INT UNSIGNED NOT NULL,
  fecha_desbloqueo DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_usuario, id_logro),
  CONSTRAINT fk_ul_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ul_logro FOREIGN KEY (id_logro)
    REFERENCES logros (id_logro) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- 10. DATOS INICIALES DE CATÁLOGOS
-- =====================================================================
INSERT INTO generos (nombre) VALUES ('Acción'),('Aventura'),('Estrategia'),('Rol');
INSERT INTO plataformas (nombre, tipo) VALUES
  ('PC','PC'),('PlayStation 5','consola'),('Xbox Series X/S','consola'),
  ('Nintendo Switch','consola'),('Android','movil'),('iOS','movil');
INSERT INTO clasificaciones (sistema, codigo, descripcion) VALUES
  ('ESRB','E','Everyone'),('ESRB','E10+','Everyone 10+'),('ESRB','T','Teen'),
  ('ESRB','M','Mature 17+'),('ESRB','AO','Adults Only 18+'),
  ('PEGI','3','Apto para 3+'),('PEGI','7','Apto para 7+'),('PEGI','12','Apto para 12+'),
  ('PEGI','16','Apto para 16+'),('PEGI','18','Apto para 18+');
INSERT INTO motores_graficos (nombre) VALUES ('Unity'),('Unreal Engine'),('Godot'),('Motor propio');
INSERT INTO especialidades (nombre) VALUES ('Programación'),('Arte'),('Diseño'),('Música'),('Testing');
INSERT INTO roles_proyecto (nombre) VALUES
  ('Líder de proyecto'),('Desarrollador'),('Artista'),('Diseñador de niveles'),
  ('Compositor'),('Tester QA');
INSERT INTO modulos_desarrollo (nombre) VALUES ('Jugabilidad'),('Gráficos'),('Sonido'),('IA');
INSERT INTO lenguajes_programacion (nombre) VALUES ('C#'),('C++'),('Python'),('GDScript'),('Java'),('Kotlin'),('Swift');
INSERT INTO tiendas_digitales (nombre) VALUES ('Steam'),('Epic Games Store'),('App Store'),('Google Play');

-- =====================================================================
-- 11. TRIGGERS (reglas que CHECK no puede expresar)
-- =====================================================================
DELIMITER $$

-- El % de dedicación total activo de un empleado no puede superar 100
CREATE TRIGGER trg_asignacion_bi BEFORE INSERT ON asignaciones_proyecto
FOR EACH ROW
BEGIN
  DECLARE v_total DECIMAL(7,2);
  IF NEW.fecha_fin IS NULL OR NEW.fecha_fin >= CURDATE() THEN
    SELECT COALESCE(SUM(porcentaje_dedicacion),0) INTO v_total
      FROM asignaciones_proyecto
     WHERE id_empleado = NEW.id_empleado
       AND (fecha_fin IS NULL OR fecha_fin >= CURDATE());
    IF v_total + NEW.porcentaje_dedicacion > 100 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La dedicación total del empleado superaría el 100%';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_asignacion_bu BEFORE UPDATE ON asignaciones_proyecto
FOR EACH ROW
BEGIN
  DECLARE v_total DECIMAL(7,2);
  IF NEW.fecha_fin IS NULL OR NEW.fecha_fin >= CURDATE() THEN
    SELECT COALESCE(SUM(porcentaje_dedicacion),0) INTO v_total
      FROM asignaciones_proyecto
     WHERE id_empleado = NEW.id_empleado
       AND id_asignacion <> NEW.id_asignacion
       AND (fecha_fin IS NULL OR fecha_fin >= CURDATE());
    IF v_total + NEW.porcentaje_dedicacion > 100 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La dedicación total del empleado superaría el 100%';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_tarea_dep_bi BEFORE INSERT ON tarea_dependencias
FOR EACH ROW
BEGIN
  IF NEW.id_tarea = NEW.id_tarea_predecesora THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Una tarea no puede depender de sí misma';
  END IF;
END$$

CREATE TRIGGER trg_mcd_bi BEFORE INSERT ON modulos_codigo_dependencias
FOR EACH ROW
BEGIN
  IF NEW.id_modulo_codigo = NEW.id_modulo_requerido THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un módulo no puede depender de sí mismo';
  END IF;
END$$

DELIMITER ;

-- =====================================================================
-- 12. VISTAS (valores derivados: no se almacenan para respetar 3FN)
-- =====================================================================
CREATE OR REPLACE VIEW vw_distribuciones_resumen AS
SELECT d.id_distribucion, d.codigo, t.nombre AS tienda, v.titulo AS videogame,
       vp.numero_version, d.fecha_publicacion, d.tamano_gb, d.precio,
       (SELECT COUNT(*) FROM adquisiciones a WHERE a.id_distribucion = d.id_distribucion) AS num_descargas,
       (SELECT ROUND(AVG(val.puntuacion),2) FROM valoraciones val
         WHERE val.id_distribucion = d.id_distribucion) AS valoracion_promedio,
       (SELECT COUNT(*) FROM valoraciones val
         WHERE val.id_distribucion = d.id_distribucion) AS num_valoraciones
  FROM distribuciones d
  JOIN tiendas_digitales t ON t.id_tienda = d.id_tienda
  JOIN versiones_prueba vp ON vp.id_version = d.id_version
  JOIN videogames v ON v.id_videogame = vp.id_videogame;

CREATE OR REPLACE VIEW vw_bugs_conocidos_por_version AS
SELECT vp.id_version, vp.codigo AS codigo_version, vp.numero_version,
       b.ticket, b.severidad, b.prioridad, b.estado_resolucion, b.descripcion
  FROM bugs b
  JOIN versiones_prueba vp ON vp.id_version = b.id_version
 WHERE b.estado_resolucion NOT IN ('resuelto','cerrado');

-- =====================================================================
-- 13. STORED PROCEDURES
--     Convención: los parámetros JSON se envían como texto desde Python
--     con json.dumps(...). NULL = "no modificar" en los procedimientos
--     de actualización (solo para las listas N:M).
-- =====================================================================
DELIMITER $$

-- ---------- Auxiliares internos (sp_priv_*) ----------
CREATE PROCEDURE sp_priv_set_videogame_plataformas(
  IN p_id INT UNSIGNED, IN p_plataformas VARCHAR(500))   -- ej. '[1,2,5]'
BEGIN
  IF p_plataformas IS NOT NULL THEN
    DELETE FROM videogame_plataformas WHERE id_videogame = p_id;
    INSERT INTO videogame_plataformas (id_videogame, id_plataforma)
    SELECT DISTINCT p_id, jt.id_plataforma
      FROM JSON_TABLE(p_plataformas, '$[*]'
           COLUMNS (id_plataforma INT UNSIGNED PATH '$')) AS jt;
  END IF;
END$$

CREATE PROCEDURE sp_priv_set_empleado_habilidades(
  IN p_id INT UNSIGNED, IN p_habilidades VARCHAR(1000))
  -- ej. '[{"id":1,"nivel":"avanzado"},{"id":4,"nivel":"basico"}]'
BEGIN
  IF p_habilidades IS NOT NULL THEN
    DELETE FROM empleado_habilidades WHERE id_empleado = p_id;
    INSERT INTO empleado_habilidades (id_empleado, id_habilidad, nivel)
    SELECT p_id, jt.id_habilidad, COALESCE(jt.nivel,'intermedio')
      FROM JSON_TABLE(p_habilidades, '$[*]'
           COLUMNS (id_habilidad INT UNSIGNED PATH '$.id',
                    nivel VARCHAR(15) PATH '$.nivel')) AS jt;
  END IF;
END$$

CREATE PROCEDURE sp_priv_set_tarea_dependencias(
  IN p_id INT UNSIGNED, IN p_dependencias VARCHAR(500))  -- ej. '[3,7]'
BEGIN
  IF p_dependencias IS NOT NULL THEN
    DELETE FROM tarea_dependencias WHERE id_tarea = p_id;
    INSERT INTO tarea_dependencias (id_tarea, id_tarea_predecesora)
    SELECT DISTINCT p_id, jt.id_pred
      FROM JSON_TABLE(p_dependencias, '$[*]'
           COLUMNS (id_pred INT UNSIGNED PATH '$')) AS jt;
  END IF;
END$$

CREATE PROCEDURE sp_priv_set_usuario_plataformas(
  IN p_id INT UNSIGNED, IN p_plataformas VARCHAR(500))
BEGIN
  IF p_plataformas IS NOT NULL THEN
    DELETE FROM usuario_plataformas WHERE id_usuario = p_id;
    INSERT INTO usuario_plataformas (id_usuario, id_plataforma)
    SELECT DISTINCT p_id, jt.id_plataforma
      FROM JSON_TABLE(p_plataformas, '$[*]'
           COLUMNS (id_plataforma INT UNSIGNED PATH '$')) AS jt;
  END IF;
END$$

CREATE PROCEDURE sp_priv_set_usuario_preferencias(
  IN p_id INT UNSIGNED, IN p_preferencias VARCHAR(2000))
  -- ej. '[{"clave":"idioma","valor":"es"},{"clave":"tema","valor":"oscuro"}]'
BEGIN
  IF p_preferencias IS NOT NULL THEN
    DELETE FROM usuario_preferencias WHERE id_usuario = p_id;
    INSERT INTO usuario_preferencias (id_usuario, clave, valor)
    SELECT p_id, jt.clave, jt.valor
      FROM JSON_TABLE(p_preferencias, '$[*]'
           COLUMNS (clave VARCHAR(50) PATH '$.clave',
                    valor VARCHAR(255) PATH '$.valor')) AS jt;
  END IF;
END$$

-- =====================================================================
-- MÓDULO videogames
-- =====================================================================
CREATE PROCEDURE sp_insertar_videogame(
  IN  p_codigo VARCHAR(20), IN p_titulo VARCHAR(150),
  IN  p_id_genero INT UNSIGNED, IN p_id_clasificacion INT UNSIGNED,
  IN  p_id_motor INT UNSIGNED,
  IN  p_fecha_inicio DATE, IN p_fecha_lanzamiento DATE,
  IN  p_presupuesto DECIMAL(14,2), IN p_estado VARCHAR(20),
  IN  p_plataformas VARCHAR(500),
  OUT p_id_videogame INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;

  START TRANSACTION;
  INSERT INTO videogames (codigo, titulo, id_genero, id_clasificacion, id_motor,
                          fecha_inicio, fecha_lanzamiento_prevista, presupuesto, estado)
  VALUES (p_codigo, p_titulo, p_id_genero, p_id_clasificacion, p_id_motor,
          p_fecha_inicio, p_fecha_lanzamiento, COALESCE(p_presupuesto,0),
          COALESCE(p_estado,'planificacion'));
  SET p_id_videogame = LAST_INSERT_ID();
  CALL sp_priv_set_videogame_plataformas(p_id_videogame, p_plataformas);
  COMMIT;
END$$

CREATE PROCEDURE sp_actualizar_videogame(
  IN p_id_videogame INT UNSIGNED,
  IN p_codigo VARCHAR(20), IN p_titulo VARCHAR(150),
  IN p_id_genero INT UNSIGNED, IN p_id_clasificacion INT UNSIGNED,
  IN p_id_motor INT UNSIGNED,
  IN p_fecha_inicio DATE, IN p_fecha_lanzamiento DATE,
  IN p_presupuesto DECIMAL(14,2), IN p_estado VARCHAR(20),
  IN p_plataformas VARCHAR(500))
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;

  IF NOT EXISTS (SELECT 1 FROM videogames WHERE id_videogame = p_id_videogame) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El videogame no existe';
  END IF;

  START TRANSACTION;
  UPDATE videogames
     SET codigo = p_codigo, titulo = p_titulo, id_genero = p_id_genero,
         id_clasificacion = p_id_clasificacion, id_motor = p_id_motor,
         fecha_inicio = p_fecha_inicio,
         fecha_lanzamiento_prevista = p_fecha_lanzamiento,
         presupuesto = COALESCE(p_presupuesto,0),
         estado = COALESCE(p_estado,'planificacion')
   WHERE id_videogame = p_id_videogame;
  CALL sp_priv_set_videogame_plataformas(p_id_videogame, p_plataformas);
  COMMIT;
END$$

CREATE PROCEDURE sp_eliminar_videogame(IN p_id_videogame INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR 1451
    SELECT 'No se puede eliminar: el videogame tiene tareas, assets, versiones u otros registros asociados. Cambie su estado a "cancelado".' AS mensaje;

  DELETE FROM videogames WHERE id_videogame = p_id_videogame;
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El videogame no existe';
  END IF;
  SELECT 'Videogame eliminado correctamente' AS mensaje;
END$$

CREATE PROCEDURE sp_listar_videogames(
  IN p_estado VARCHAR(20), IN p_busqueda VARCHAR(100))   -- NULL = sin filtro
BEGIN
  SELECT v.id_videogame, v.codigo, v.titulo,
         g.nombre AS genero,
         CONCAT(c.sistema,' ',c.codigo) AS clasificacion,
         m.nombre AS motor_grafico,
         (SELECT GROUP_CONCAT(p.nombre ORDER BY p.nombre SEPARATOR ', ')
            FROM videogame_plataformas vp
            JOIN plataformas p ON p.id_plataforma = vp.id_plataforma
           WHERE vp.id_videogame = v.id_videogame) AS plataformas,
         v.fecha_inicio, v.fecha_lanzamiento_prevista, v.presupuesto, v.estado,
         (SELECT COUNT(*) FROM asignaciones_proyecto a
           WHERE a.id_videogame = v.id_videogame
             AND (a.fecha_fin IS NULL OR a.fecha_fin >= CURDATE())) AS miembros_equipo,
         v.id_genero, v.id_clasificacion, v.id_motor
    FROM videogames v
    JOIN generos g ON g.id_genero = v.id_genero
    JOIN clasificaciones c ON c.id_clasificacion = v.id_clasificacion
    LEFT JOIN motores_graficos m ON m.id_motor = v.id_motor
   WHERE (p_estado IS NULL OR p_estado = '' OR v.estado = p_estado)
     AND (p_busqueda IS NULL OR p_busqueda = ''
          OR v.codigo LIKE CONCAT('%',p_busqueda,'%')
          OR v.titulo LIKE CONCAT('%',p_busqueda,'%'))
   ORDER BY v.titulo;
END$$

-- =====================================================================
-- MÓDULO empleados
-- =====================================================================
CREATE PROCEDURE sp_insertar_empleado(
  IN  p_codigo_empleado VARCHAR(20), IN p_nombres VARCHAR(80), IN p_apellidos VARCHAR(80),
  IN  p_id_especialidad INT UNSIGNED, IN p_anios_experiencia TINYINT UNSIGNED,
  IN  p_experiencia_previa TEXT, IN p_correo VARCHAR(120),
  IN  p_habilidades VARCHAR(1000),
  OUT p_id_empleado INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;

  START TRANSACTION;
  INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad,
                         anios_experiencia, experiencia_previa, correo)
  VALUES (p_codigo_empleado, p_nombres, p_apellidos, p_id_especialidad,
          COALESCE(p_anios_experiencia,0), p_experiencia_previa, NULLIF(p_correo,''));
  SET p_id_empleado = LAST_INSERT_ID();
  CALL sp_priv_set_empleado_habilidades(p_id_empleado, p_habilidades);
  COMMIT;
END$$

CREATE PROCEDURE sp_actualizar_empleado(
  IN p_id_empleado INT UNSIGNED,
  IN p_codigo_empleado VARCHAR(20), IN p_nombres VARCHAR(80), IN p_apellidos VARCHAR(80),
  IN p_id_especialidad INT UNSIGNED, IN p_anios_experiencia TINYINT UNSIGNED,
  IN p_experiencia_previa TEXT, IN p_correo VARCHAR(120),
  IN p_activo TINYINT, IN p_habilidades VARCHAR(1000))
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;

  IF NOT EXISTS (SELECT 1 FROM empleados WHERE id_empleado = p_id_empleado) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado no existe';
  END IF;

  START TRANSACTION;
  UPDATE empleados
     SET codigo_empleado = p_codigo_empleado, nombres = p_nombres, apellidos = p_apellidos,
         id_especialidad = p_id_especialidad,
         anios_experiencia = COALESCE(p_anios_experiencia,0),
         experiencia_previa = p_experiencia_previa,
         correo = NULLIF(p_correo,''),
         activo = COALESCE(p_activo,1)
   WHERE id_empleado = p_id_empleado;
  CALL sp_priv_set_empleado_habilidades(p_id_empleado, p_habilidades);
  COMMIT;
END$$

-- Si el empleado tiene historial (tareas, asignaciones, bugs...), se desactiva
CREATE PROCEDURE sp_eliminar_empleado(IN p_id_empleado INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR 1451
  BEGIN
    UPDATE empleados SET activo = 0 WHERE id_empleado = p_id_empleado;
    SELECT 'El empleado tiene historial asociado: fue desactivado en lugar de eliminado' AS mensaje;
  END;

  DELETE FROM empleados WHERE id_empleado = p_id_empleado;
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado no existe';
  END IF;
  SELECT 'Empleado eliminado correctamente' AS mensaje;
END$$

CREATE PROCEDURE sp_listar_empleados(
  IN p_id_especialidad INT UNSIGNED, IN p_solo_activos TINYINT, IN p_busqueda VARCHAR(100))
BEGIN
  SELECT e.id_empleado, e.codigo_empleado, e.nombres, e.apellidos,
         es.nombre AS especialidad, e.anios_experiencia, e.experiencia_previa,
         e.correo, e.activo,
         (SELECT GROUP_CONCAT(CONCAT(h.nombre,' (',eh.nivel,')') ORDER BY h.nombre SEPARATOR ', ')
            FROM empleado_habilidades eh
            JOIN habilidades h ON h.id_habilidad = eh.id_habilidad
           WHERE eh.id_empleado = e.id_empleado) AS habilidades,
         (SELECT GROUP_CONCAT(CONCAT(v.titulo,' - ',r.nombre,' - ',a.porcentaje_dedicacion,'%')
                              ORDER BY v.titulo SEPARATOR '; ')
            FROM asignaciones_proyecto a
            JOIN videogames v ON v.id_videogame = a.id_videogame
            JOIN roles_proyecto r ON r.id_rol = a.id_rol
           WHERE a.id_empleado = e.id_empleado
             AND (a.fecha_fin IS NULL OR a.fecha_fin >= CURDATE())) AS proyectos_asignados,
         (SELECT COALESCE(SUM(a.porcentaje_dedicacion),0)
            FROM asignaciones_proyecto a
           WHERE a.id_empleado = e.id_empleado
             AND (a.fecha_fin IS NULL OR a.fecha_fin >= CURDATE())) AS dedicacion_total,
         e.id_especialidad
    FROM empleados e
    JOIN especialidades es ON es.id_especialidad = e.id_especialidad
   WHERE (p_id_especialidad IS NULL OR e.id_especialidad = p_id_especialidad)
     AND (p_solo_activos IS NULL OR p_solo_activos = 0 OR e.activo = 1)
     AND (p_busqueda IS NULL OR p_busqueda = ''
          OR CONCAT_WS(' ', e.codigo_empleado, e.nombres, e.apellidos)
             LIKE CONCAT('%',p_busqueda,'%'))
   ORDER BY e.apellidos, e.nombres;
END$$

-- Complementarios del módulo empleados: equipo de cada videogame
CREATE PROCEDURE sp_asignar_empleado_proyecto(
  IN  p_id_videogame INT UNSIGNED, IN p_id_empleado INT UNSIGNED,
  IN  p_id_rol INT UNSIGNED, IN p_porcentaje DECIMAL(5,2), IN p_fecha_asignacion DATE,
  OUT p_id_asignacion INT UNSIGNED)
BEGIN
  INSERT INTO asignaciones_proyecto
    (id_videogame, id_empleado, id_rol, porcentaje_dedicacion, fecha_asignacion)
  VALUES (p_id_videogame, p_id_empleado, p_id_rol, p_porcentaje,
          COALESCE(p_fecha_asignacion, CURDATE()));
  SET p_id_asignacion = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_desasignar_empleado_proyecto(
  IN p_id_videogame INT UNSIGNED, IN p_id_empleado INT UNSIGNED)
BEGIN
  DELETE FROM asignaciones_proyecto
   WHERE id_videogame = p_id_videogame AND id_empleado = p_id_empleado;
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La asignación no existe';
  END IF;
  SELECT 'Empleado desasignado del proyecto' AS mensaje;
END$$

-- =====================================================================
-- MÓDULO tareas
-- =====================================================================
CREATE PROCEDURE sp_insertar_tarea(
  IN  p_codigo VARCHAR(20), IN p_id_videogame INT UNSIGNED, IN p_id_modulo INT UNSIGNED,
  IN  p_descripcion TEXT, IN p_prioridad VARCHAR(10), IN p_estado VARCHAR(15),
  IN  p_id_responsable INT UNSIGNED,
  IN  p_fecha_asignacion DATE, IN p_fecha_limite DATE,
  IN  p_porcentaje_avance DECIMAL(5,2), IN p_dependencias VARCHAR(500),
  OUT p_id_tarea INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;

  IF p_id_responsable IS NOT NULL AND NOT EXISTS
     (SELECT 1 FROM asignaciones_proyecto
       WHERE id_videogame = p_id_videogame AND id_empleado = p_id_responsable) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El responsable no pertenece al equipo del videogame';
  END IF;
  IF p_estado = 'completada' THEN SET p_porcentaje_avance = 100; END IF;

  START TRANSACTION;
  INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado,
                      id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
  VALUES (p_codigo, p_id_videogame, p_id_modulo, p_descripcion,
          COALESCE(p_prioridad,'media'), COALESCE(p_estado,'pendiente'),
          p_id_responsable, COALESCE(p_fecha_asignacion, CURDATE()), p_fecha_limite,
          COALESCE(p_porcentaje_avance,0));
  SET p_id_tarea = LAST_INSERT_ID();
  CALL sp_priv_set_tarea_dependencias(p_id_tarea, p_dependencias);
  COMMIT;
END$$

CREATE PROCEDURE sp_actualizar_tarea(
  IN p_id_tarea INT UNSIGNED,
  IN p_codigo VARCHAR(20), IN p_id_videogame INT UNSIGNED, IN p_id_modulo INT UNSIGNED,
  IN p_descripcion TEXT, IN p_prioridad VARCHAR(10), IN p_estado VARCHAR(15),
  IN p_id_responsable INT UNSIGNED,
  IN p_fecha_asignacion DATE, IN p_fecha_limite DATE,
  IN p_porcentaje_avance DECIMAL(5,2), IN p_dependencias VARCHAR(500))
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;

  IF NOT EXISTS (SELECT 1 FROM tareas WHERE id_tarea = p_id_tarea) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La tarea no existe';
  END IF;
  IF p_id_responsable IS NOT NULL AND NOT EXISTS
     (SELECT 1 FROM asignaciones_proyecto
       WHERE id_videogame = p_id_videogame AND id_empleado = p_id_responsable) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El responsable no pertenece al equipo del videogame';
  END IF;
  IF p_estado = 'completada' THEN SET p_porcentaje_avance = 100; END IF;

  START TRANSACTION;
  UPDATE tareas
     SET codigo = p_codigo, id_videogame = p_id_videogame, id_modulo = p_id_modulo,
         descripcion = p_descripcion, prioridad = COALESCE(p_prioridad,'media'),
         estado = COALESCE(p_estado,'pendiente'), id_responsable = p_id_responsable,
         fecha_asignacion = COALESCE(p_fecha_asignacion, fecha_asignacion),
         fecha_limite = p_fecha_limite,
         porcentaje_avance = COALESCE(p_porcentaje_avance,0)
   WHERE id_tarea = p_id_tarea;
  CALL sp_priv_set_tarea_dependencias(p_id_tarea, p_dependencias);
  COMMIT;
END$$

CREATE PROCEDURE sp_eliminar_tarea(IN p_id_tarea INT UNSIGNED)
BEGIN
  DELETE FROM tareas WHERE id_tarea = p_id_tarea;   -- las dependencias se borran en cascada
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La tarea no existe';
  END IF;
  SELECT 'Tarea eliminada correctamente' AS mensaje;
END$$

CREATE PROCEDURE sp_listar_tareas(
  IN p_id_videogame INT UNSIGNED, IN p_estado VARCHAR(15), IN p_id_responsable INT UNSIGNED)
BEGIN
  SELECT t.id_tarea, t.codigo, v.titulo AS videogame, m.nombre AS modulo,
         t.descripcion, t.prioridad, t.estado,
         CONCAT(e.nombres,' ',e.apellidos) AS responsable,
         t.fecha_asignacion, t.fecha_limite, t.porcentaje_avance,
         (SELECT GROUP_CONCAT(tp.codigo ORDER BY tp.codigo SEPARATOR ', ')
            FROM tarea_dependencias d
            JOIN tareas tp ON tp.id_tarea = d.id_tarea_predecesora
           WHERE d.id_tarea = t.id_tarea) AS dependencias,
         (t.estado <> 'completada' AND t.fecha_limite < CURDATE()) AS vencida,
         t.id_videogame, t.id_modulo, t.id_responsable
    FROM tareas t
    JOIN videogames v ON v.id_videogame = t.id_videogame
    JOIN modulos_desarrollo m ON m.id_modulo = t.id_modulo
    LEFT JOIN empleados e ON e.id_empleado = t.id_responsable
   WHERE (p_id_videogame IS NULL OR t.id_videogame = p_id_videogame)
     AND (p_estado IS NULL OR p_estado = '' OR t.estado = p_estado)
     AND (p_id_responsable IS NULL OR t.id_responsable = p_id_responsable)
   ORDER BY t.fecha_limite, FIELD(t.prioridad,'critica','alta','media','baja');
END$$

-- =====================================================================
-- MÓDULO usuarios
-- =====================================================================
CREATE PROCEDURE sp_insertar_usuario(
  IN  p_nombre_usuario VARCHAR(50), IN p_correo VARCHAR(120),
  IN  p_password_hash VARCHAR(255), IN p_estado VARCHAR(15),
  IN  p_plataformas VARCHAR(500), IN p_preferencias VARCHAR(2000),
  OUT p_id_usuario INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;

  START TRANSACTION;
  INSERT INTO usuarios (nombre_usuario, correo, password_hash, estado)
  VALUES (p_nombre_usuario, p_correo, p_password_hash, COALESCE(p_estado,'activo'));
  SET p_id_usuario = LAST_INSERT_ID();
  CALL sp_priv_set_usuario_plataformas(p_id_usuario, p_plataformas);
  CALL sp_priv_set_usuario_preferencias(p_id_usuario, p_preferencias);
  COMMIT;
END$$

CREATE PROCEDURE sp_actualizar_usuario(
  IN p_id_usuario INT UNSIGNED,
  IN p_nombre_usuario VARCHAR(50), IN p_correo VARCHAR(120),
  IN p_password_hash VARCHAR(255),          -- NULL = conservar la actual
  IN p_estado VARCHAR(15),
  IN p_plataformas VARCHAR(500), IN p_preferencias VARCHAR(2000))
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;

  IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id_usuario = p_id_usuario) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe';
  END IF;

  START TRANSACTION;
  UPDATE usuarios
     SET nombre_usuario = p_nombre_usuario, correo = p_correo,
         password_hash = COALESCE(p_password_hash, password_hash),
         estado = COALESCE(p_estado,'activo')
   WHERE id_usuario = p_id_usuario;
  CALL sp_priv_set_usuario_plataformas(p_id_usuario, p_plataformas);
  CALL sp_priv_set_usuario_preferencias(p_id_usuario, p_preferencias);
  COMMIT;
END$$

-- Con compras registradas no se borra: se marca como inactivo
CREATE PROCEDURE sp_eliminar_usuario(IN p_id_usuario INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR 1451
  BEGIN
    UPDATE usuarios SET estado = 'inactivo' WHERE id_usuario = p_id_usuario;
    SELECT 'El usuario tiene compras registradas: fue marcado como inactivo en lugar de eliminado' AS mensaje;
  END;

  DELETE FROM usuarios WHERE id_usuario = p_id_usuario;
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe';
  END IF;
  SELECT 'Usuario eliminado correctamente' AS mensaje;
END$$

CREATE PROCEDURE sp_listar_usuarios(IN p_estado VARCHAR(15), IN p_busqueda VARCHAR(100))
BEGIN
  SELECT u.id_usuario, u.nombre_usuario, u.correo, u.fecha_registro, u.estado,
         (SELECT GROUP_CONCAT(p.nombre ORDER BY p.nombre SEPARATOR ', ')
            FROM usuario_plataformas up
            JOIN plataformas p ON p.id_plataforma = up.id_plataforma
           WHERE up.id_usuario = u.id_usuario) AS plataformas,
         (SELECT COUNT(*) FROM adquisiciones a WHERE a.id_usuario = u.id_usuario) AS juegos_adquiridos,
         (SELECT COALESCE(ROUND(SUM(a.minutos_jugados)/60,1),0)
            FROM adquisiciones a WHERE a.id_usuario = u.id_usuario) AS horas_jugadas,
         (SELECT COUNT(*) FROM usuario_logros ul WHERE ul.id_usuario = u.id_usuario) AS logros_desbloqueados,
         (SELECT COALESCE(SUM(a.precio_pagado),0)
            FROM adquisiciones a WHERE a.id_usuario = u.id_usuario) AS total_compras,
         (SELECT GROUP_CONCAT(CONCAT(pr.clave,'=',pr.valor) SEPARATOR ', ')
            FROM usuario_preferencias pr WHERE pr.id_usuario = u.id_usuario) AS preferencias
    FROM usuarios u
   WHERE (p_estado IS NULL OR p_estado = '' OR u.estado = p_estado)
     AND (p_busqueda IS NULL OR p_busqueda = ''
          OR u.nombre_usuario LIKE CONCAT('%',p_busqueda,'%')
          OR u.correo LIKE CONCAT('%',p_busqueda,'%'))
   ORDER BY u.nombre_usuario;
END$$

DELIMITER ;

-- =====================================================================
-- EJEMPLOS DE USO (desde MySQL Workbench)
-- =====================================================================
-- CALL sp_insertar_videogame('VG-001','Dragon Quest Lite',4,3,1,'2026-01-15','2027-03-01',
--                            250000.00,'desarrollo','[1,2]', @id);
-- SELECT @id;
-- CALL sp_listar_videogames(NULL, NULL);




-- =====================================================================
--  Gamedev. — SQL DE MODIFICACIÓN (Parte C)
--  Se aplica SOBRE la base de datos existente. NO crea la base,
--  NO elimina tablas, PK, FK, CHECK, triggers ni vistas.
--  Seguro para ejecutar más de una vez (idempotente).
-- =====================================================================
USE gamedev;

-- =====================================================================
-- 1. NUEVAS COLUMNAS PARA GESTIÓN DE IMÁGENES (Parte 8 de la rúbrica)
-- ---------------------------------------------------------------------
--  Se agrega SOLO la ruta del archivo (VARCHAR), nunca el binario:
--  más liviano, más simple de normalizar y compatible con Pillow,
--  que solo necesita una ruta para abrir la imagen con Image.open().
--  videogames.imagen_portada -> portada del juego (formularios de juego)
--  empleados.imagen_perfil   -> foto de perfil del empleado
--  Se agregan con IF NOT EXISTS (vía SQL dinámico) para que el script
--  pueda ejecutarse varias veces sin error.
-- =====================================================================

SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
   WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'videogames'
     AND COLUMN_NAME = 'imagen_portada');
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE videogames ADD COLUMN imagen_portada VARCHAR(255) NULL AFTER estado',
  'SELECT ''videogames.imagen_portada ya existe, no se modifica'' AS aviso');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
   WHERE TABLE_SCHEMA = DATABASE()
     AND TABLE_NAME = 'empleados'
     AND COLUMN_NAME = 'imagen_perfil');
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE empleados ADD COLUMN imagen_perfil VARCHAR(255) NULL AFTER activo',
  'SELECT ''empleados.imagen_perfil ya existe, no se modifica'' AS aviso');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- =====================================================================
-- 2. PROCEDIMIENTOS QUE DEBEN REEMPLAZARSE (y solo estos)
-- ---------------------------------------------------------------------
--  Motivo: necesitan un parámetro nuevo (ruta de imagen) que no existía.
--  MySQL no permite ALTER PROCEDURE sobre parámetros, así que se
--  recrean con DROP + CREATE. El resto de procedimientos (eliminar_*,
--  todos los de tareas y usuarios, y los sp_priv_* auxiliares) NO se
--  tocan porque no lo necesitan.
--
--  Cambios además del campo de imagen:
--  - sp_listar_videogames ahora acepta también un filtro opcional por
--    género (p_id_genero), pedido en la Parte 10 de la rúbrica.
-- =====================================================================
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_insertar_videogame$$
CREATE PROCEDURE sp_insertar_videogame(
  IN  p_codigo VARCHAR(20), IN p_titulo VARCHAR(150),
  IN  p_id_genero INT UNSIGNED, IN p_id_clasificacion INT UNSIGNED,
  IN  p_id_motor INT UNSIGNED,
  IN  p_fecha_inicio DATE, IN p_fecha_lanzamiento DATE,
  IN  p_presupuesto DECIMAL(14,2), IN p_estado VARCHAR(20),
  IN  p_plataformas VARCHAR(500),
  IN  p_imagen_portada VARCHAR(255),
  OUT p_id_videogame INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;

  START TRANSACTION;
  INSERT INTO videogames (codigo, titulo, id_genero, id_clasificacion, id_motor,
                          fecha_inicio, fecha_lanzamiento_prevista, presupuesto, estado,
                          imagen_portada)
  VALUES (p_codigo, p_titulo, p_id_genero, p_id_clasificacion, p_id_motor,
          p_fecha_inicio, p_fecha_lanzamiento, COALESCE(p_presupuesto,0),
          COALESCE(p_estado,'planificacion'), p_imagen_portada);
  SET p_id_videogame = LAST_INSERT_ID();
  CALL sp_priv_set_videogame_plataformas(p_id_videogame, p_plataformas);
  COMMIT;
END$$

DROP PROCEDURE IF EXISTS sp_actualizar_videogame$$
CREATE PROCEDURE sp_actualizar_videogame(
  IN p_id_videogame INT UNSIGNED,
  IN p_codigo VARCHAR(20), IN p_titulo VARCHAR(150),
  IN p_id_genero INT UNSIGNED, IN p_id_clasificacion INT UNSIGNED,
  IN p_id_motor INT UNSIGNED,
  IN p_fecha_inicio DATE, IN p_fecha_lanzamiento DATE,
  IN p_presupuesto DECIMAL(14,2), IN p_estado VARCHAR(20),
  IN p_plataformas VARCHAR(500),
  IN p_imagen_portada VARCHAR(255))     -- NULL = conservar la imagen actual
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;

  IF NOT EXISTS (SELECT 1 FROM videogames WHERE id_videogame = p_id_videogame) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El videogame no existe';
  END IF;

  START TRANSACTION;
  UPDATE videogames
     SET codigo = p_codigo, titulo = p_titulo, id_genero = p_id_genero,
         id_clasificacion = p_id_clasificacion, id_motor = p_id_motor,
         fecha_inicio = p_fecha_inicio,
         fecha_lanzamiento_prevista = p_fecha_lanzamiento,
         presupuesto = COALESCE(p_presupuesto,0),
         estado = COALESCE(p_estado,'planificacion'),
         imagen_portada = COALESCE(p_imagen_portada, imagen_portada)
   WHERE id_videogame = p_id_videogame;
  CALL sp_priv_set_videogame_plataformas(p_id_videogame, p_plataformas);
  COMMIT;
END$$

DROP PROCEDURE IF EXISTS sp_listar_videogames$$
CREATE PROCEDURE sp_listar_videogames(
  IN p_estado VARCHAR(20), IN p_busqueda VARCHAR(100),
  IN p_id_genero INT UNSIGNED)          -- NUEVO filtro opcional; NULL = sin filtro
BEGIN
  SELECT v.id_videogame, v.codigo, v.titulo,
         g.nombre AS genero,
         CONCAT(c.sistema,' ',c.codigo) AS clasificacion,
         m.nombre AS motor_grafico,
         (SELECT GROUP_CONCAT(p.nombre ORDER BY p.nombre SEPARATOR ', ')
            FROM videogame_plataformas vp
            JOIN plataformas p ON p.id_plataforma = vp.id_plataforma
           WHERE vp.id_videogame = v.id_videogame) AS plataformas,
         v.fecha_inicio, v.fecha_lanzamiento_prevista, v.presupuesto, v.estado,
         v.imagen_portada,
         (SELECT COUNT(*) FROM asignaciones_proyecto a
           WHERE a.id_videogame = v.id_videogame
             AND (a.fecha_fin IS NULL OR a.fecha_fin >= CURDATE())) AS miembros_equipo,
         v.id_genero, v.id_clasificacion, v.id_motor
    FROM videogames v
    JOIN generos g ON g.id_genero = v.id_genero
    JOIN clasificaciones c ON c.id_clasificacion = v.id_clasificacion
    LEFT JOIN motores_graficos m ON m.id_motor = v.id_motor
   WHERE (p_estado IS NULL OR p_estado = '' OR v.estado = p_estado)
     AND (p_busqueda IS NULL OR p_busqueda = ''
          OR v.codigo LIKE CONCAT('%',p_busqueda,'%')
          OR v.titulo LIKE CONCAT('%',p_busqueda,'%'))
     AND (p_id_genero IS NULL OR v.id_genero = p_id_genero)
   ORDER BY v.titulo;
END$$

DROP PROCEDURE IF EXISTS sp_insertar_empleado$$
CREATE PROCEDURE sp_insertar_empleado(
  IN  p_codigo_empleado VARCHAR(20), IN p_nombres VARCHAR(80), IN p_apellidos VARCHAR(80),
  IN  p_id_especialidad INT UNSIGNED, IN p_anios_experiencia TINYINT UNSIGNED,
  IN  p_experiencia_previa TEXT, IN p_correo VARCHAR(120),
  IN  p_habilidades VARCHAR(1000),
  IN  p_imagen_perfil VARCHAR(255),
  OUT p_id_empleado INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;

  START TRANSACTION;
  INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad,
                         anios_experiencia, experiencia_previa, correo, imagen_perfil)
  VALUES (p_codigo_empleado, p_nombres, p_apellidos, p_id_especialidad,
          COALESCE(p_anios_experiencia,0), p_experiencia_previa, NULLIF(p_correo,''),
          p_imagen_perfil);
  SET p_id_empleado = LAST_INSERT_ID();
  CALL sp_priv_set_empleado_habilidades(p_id_empleado, p_habilidades);
  COMMIT;
END$$

DROP PROCEDURE IF EXISTS sp_actualizar_empleado$$
CREATE PROCEDURE sp_actualizar_empleado(
  IN p_id_empleado INT UNSIGNED,
  IN p_codigo_empleado VARCHAR(20), IN p_nombres VARCHAR(80), IN p_apellidos VARCHAR(80),
  IN p_id_especialidad INT UNSIGNED, IN p_anios_experiencia TINYINT UNSIGNED,
  IN p_experiencia_previa TEXT, IN p_correo VARCHAR(120),
  IN p_activo TINYINT, IN p_habilidades VARCHAR(1000),
  IN p_imagen_perfil VARCHAR(255))       -- NULL = conservar la foto actual
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;

  IF NOT EXISTS (SELECT 1 FROM empleados WHERE id_empleado = p_id_empleado) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado no existe';
  END IF;

  START TRANSACTION;
  UPDATE empleados
     SET codigo_empleado = p_codigo_empleado, nombres = p_nombres, apellidos = p_apellidos,
         id_especialidad = p_id_especialidad,
         anios_experiencia = COALESCE(p_anios_experiencia,0),
         experiencia_previa = p_experiencia_previa,
         correo = NULLIF(p_correo,''),
         activo = COALESCE(p_activo,1),
         imagen_perfil = COALESCE(p_imagen_perfil, imagen_perfil)
   WHERE id_empleado = p_id_empleado;
  CALL sp_priv_set_empleado_habilidades(p_id_empleado, p_habilidades);
  COMMIT;
END$$

DROP PROCEDURE IF EXISTS sp_listar_empleados$$
CREATE PROCEDURE sp_listar_empleados(
  IN p_id_especialidad INT UNSIGNED, IN p_solo_activos TINYINT, IN p_busqueda VARCHAR(100))
BEGIN
  SELECT e.id_empleado, e.codigo_empleado, e.nombres, e.apellidos,
         es.nombre AS especialidad, e.anios_experiencia, e.experiencia_previa,
         e.correo, e.activo, e.imagen_perfil,
         (SELECT GROUP_CONCAT(CONCAT(h.nombre,' (',eh.nivel,')') ORDER BY h.nombre SEPARATOR ', ')
            FROM empleado_habilidades eh
            JOIN habilidades h ON h.id_habilidad = eh.id_habilidad
           WHERE eh.id_empleado = e.id_empleado) AS habilidades,
         (SELECT GROUP_CONCAT(CONCAT(v.titulo,' - ',r.nombre,' - ',a.porcentaje_dedicacion,'%')
                              ORDER BY v.titulo SEPARATOR '; ')
            FROM asignaciones_proyecto a
            JOIN videogames v ON v.id_videogame = a.id_videogame
            JOIN roles_proyecto r ON r.id_rol = a.id_rol
           WHERE a.id_empleado = e.id_empleado
             AND (a.fecha_fin IS NULL OR a.fecha_fin >= CURDATE())) AS proyectos_asignados,
         (SELECT COALESCE(SUM(a.porcentaje_dedicacion),0)
            FROM asignaciones_proyecto a
           WHERE a.id_empleado = e.id_empleado
             AND (a.fecha_fin IS NULL OR a.fecha_fin >= CURDATE())) AS dedicacion_total,
         e.id_especialidad
    FROM empleados e
    JOIN especialidades es ON es.id_especialidad = e.id_especialidad
   WHERE (p_id_especialidad IS NULL OR e.id_especialidad = p_id_especialidad)
     AND (p_solo_activos IS NULL OR p_solo_activos = 0 OR e.activo = 1)
     AND (p_busqueda IS NULL OR p_busqueda = ''
          OR CONCAT_WS(' ', e.codigo_empleado, e.nombres, e.apellidos)
             LIKE CONCAT('%',p_busqueda,'%'))
   ORDER BY e.apellidos, e.nombres;
END$$

DELIMITER ;

-- Nada más se modifica: sp_eliminar_videogame, sp_eliminar_empleado,
-- los 4 procedimientos de tareas, los 4 de usuarios, sp_asignar/desasignar_
-- empleado_proyecto y los sp_priv_* quedan exactamente igual que en el
-- archivo original.


 	-- =====================================================================
--  Gamedev. — SQL DE DATOS DE PRUEBA (Parte D)
--  Todos los INSERT están protegidos con NOT EXISTS: se puede ejecutar
--  este script varias veces sin generar duplicados. Los catálogos con
--  registros ya válidos se dejan intactos; solo se agrega lo que falta
--  para llegar a la cantidad objetivo.
-- =====================================================================
USE gamedev;

-- =====================================================================
-- PARTE 3 — CATÁLOGOS
-- =====================================================================

-- Géneros
-- Existentes: 4 (Acción, Aventura, Estrategia, Rol) | Objetivo: 5 | Se agregarán: 1
INSERT INTO generos (nombre)
SELECT 'Simulación' WHERE NOT EXISTS (SELECT 1 FROM generos WHERE nombre='Simulación');

-- Plataformas
-- Existentes: 6 (PC, PlayStation 5, Xbox Series X/S, Nintendo Switch, Android, iOS)
-- Objetivo: 5 | Se agregarán: 0 (ya se superó el objetivo, no se toca el catálogo)

-- Clasificaciones
-- Existentes: 10 (5 ESRB + 5 PEGI) | Objetivo: 5 | Se agregarán: 0

-- Motores gráficos
-- Existentes: 4 (Unity, Unreal Engine, Godot, Motor propio) | Objetivo: 5 | Se agregarán: 1
INSERT INTO motores_graficos (nombre)
SELECT 'CryEngine' WHERE NOT EXISTS (SELECT 1 FROM motores_graficos WHERE nombre='CryEngine');

-- Especialidades
-- Existentes: 5 (Programación, Arte, Diseño, Música, Testing) | Objetivo: 8 | Se agregarán: 3
INSERT INTO especialidades (nombre)
SELECT x.nombre FROM (
  SELECT 'Producción' AS nombre UNION ALL
  SELECT 'Guion y Narrativa' UNION ALL
  SELECT 'UI/UX'
) x
WHERE NOT EXISTS (SELECT 1 FROM especialidades e WHERE e.nombre = x.nombre);

-- Habilidades
-- Existentes: 0 (el script original no traía datos semilla) | Objetivo: 10 | Se agregarán: 10
INSERT INTO habilidades (nombre)
SELECT x.nombre FROM (
  SELECT 'C# avanzado' AS nombre UNION ALL
  SELECT 'Modelado 3D' UNION ALL
  SELECT 'Diseño de niveles' UNION ALL
  SELECT 'Composición musical' UNION ALL
  SELECT 'Automatización de pruebas (QA)' UNION ALL
  SELECT 'Shaders y VFX' UNION ALL
  SELECT 'Animación 2D' UNION ALL
  SELECT 'Diseño de sistemas de juego' UNION ALL
  SELECT 'Optimización de rendimiento' UNION ALL
  SELECT 'Scripting en Unity (C#)'
) x
WHERE NOT EXISTS (SELECT 1 FROM habilidades h WHERE h.nombre = x.nombre);

-- Roles de proyecto
-- Existentes: 6 (Líder de proyecto, Desarrollador, Artista, Diseñador de niveles,
-- Compositor, Tester QA) | Objetivo: 5 | Se agregarán: 0

-- Módulos de desarrollo
-- Existentes: 4 (Jugabilidad, Gráficos, Sonido, IA) | Objetivo: 5 | Se agregarán: 1
-- NOTA IMPORTANTE (léela antes de ejecutar): la rúbrica sugiere renombrar este
-- catálogo a fases de proceso (Preproducción, Diseño, Programación, Arte,
-- Pruebas). Como la regla obligatoria dice "NO eliminar/reemplazar registros
-- existentes", se conservan los 4 valores actuales (que son áreas técnicas del
-- juego, no fases de proceso) y se agrega solo 1 para llegar a 5. Se eligió
-- "Pruebas" porque es el que más falta hace: sin él no hay dónde clasificar
-- tareas de QA. Si prefieres alinear el catálogo 100% con el listado de la
-- rúbrica, es una decisión tuya (afecta el reporte de tu app) — al final de
-- este archivo dejo, comentado, el UPDATE para renombrarlos si decides usar
-- esa alternativa en lugar de esta.
INSERT INTO modulos_desarrollo (nombre)
SELECT 'Pruebas' WHERE NOT EXISTS (SELECT 1 FROM modulos_desarrollo WHERE nombre='Pruebas');

-- Lenguajes de programación
-- Existentes: 7 (C#, C++, Python, GDScript, Java, Kotlin, Swift) | Objetivo: 8 | Se agregarán: 1
INSERT INTO lenguajes_programacion (nombre)
SELECT 'TypeScript' WHERE NOT EXISTS (SELECT 1 FROM lenguajes_programacion WHERE nombre='TypeScript');

-- Tiendas digitales
-- Existentes: 4 (Steam, Epic Games Store, App Store, Google Play) | Objetivo: 5 | Se agregarán: 1
INSERT INTO tiendas_digitales (nombre)
SELECT 'GOG.com' WHERE NOT EXISTS (SELECT 1 FROM tiendas_digitales WHERE nombre='GOG.com');


-- =====================================================================
-- PARTE 4 — VIDEOJUEGOS
-- Existentes: 0 | Objetivo: 10 | Se agregarán: 10
-- =====================================================================
INSERT INTO videogames (codigo, titulo, id_genero, id_clasificacion, id_motor,
                        fecha_inicio, fecha_lanzamiento_prevista, presupuesto, estado)
SELECT * FROM (SELECT
  'VG-0001' AS codigo, 'Runa: Ecos del Bosque' AS titulo,
  (SELECT id_genero FROM generos WHERE nombre='Aventura') AS id_genero,
  (SELECT id_clasificacion FROM clasificaciones WHERE sistema='PEGI' AND codigo='12') AS id_clasificacion,
  (SELECT id_motor FROM motores_graficos WHERE nombre='Unity') AS id_motor,
  DATE'2024-02-01' AS fecha_inicio, DATE'2025-11-01' AS fecha_lanzamiento_prevista,
  180000.00 AS presupuesto, 'lanzado' AS estado
) t WHERE NOT EXISTS (SELECT 1 FROM videogames WHERE codigo='VG-0001');

INSERT INTO videogames (codigo, titulo, id_genero, id_clasificacion, id_motor,
                        fecha_inicio, fecha_lanzamiento_prevista, presupuesto, estado)
SELECT * FROM (SELECT
  'VG-0002', 'Forja de Acero',
  (SELECT id_genero FROM generos WHERE nombre='Acción'),
  (SELECT id_clasificacion FROM clasificaciones WHERE sistema='ESRB' AND codigo='M'),
  (SELECT id_motor FROM motores_graficos WHERE nombre='Unreal Engine'),
  DATE'2024-05-15', DATE'2026-06-01', 950000.00, 'desarrollo'
) t WHERE NOT EXISTS (SELECT 1 FROM videogames WHERE codigo='VG-0002');

INSERT INTO videogames (codigo, titulo, id_genero, id_clasificacion, id_motor,
                        fecha_inicio, fecha_lanzamiento_prevista, presupuesto, estado)
SELECT * FROM (SELECT
  'VG-0003', 'Imperios de Cristal',
  (SELECT id_genero FROM generos WHERE nombre='Estrategia'),
  (SELECT id_clasificacion FROM clasificaciones WHERE sistema='PEGI' AND codigo='7'),
  (SELECT id_motor FROM motores_graficos WHERE nombre='Motor propio'),
  DATE'2023-09-01', DATE'2025-01-15', 420000.00, 'lanzado'
) t WHERE NOT EXISTS (SELECT 1 FROM videogames WHERE codigo='VG-0003');

INSERT INTO videogames (codigo, titulo, id_genero, id_clasificacion, id_motor,
                        fecha_inicio, fecha_lanzamiento_prevista, presupuesto, estado)
SELECT * FROM (SELECT
  'VG-0004', 'Umbra: El Último Guardián',
  (SELECT id_genero FROM generos WHERE nombre='Rol'),
  (SELECT id_clasificacion FROM clasificaciones WHERE sistema='ESRB' AND codigo='T'),
  (SELECT id_motor FROM motores_graficos WHERE nombre='Unreal Engine'),
  DATE'2025-01-10', DATE'2027-02-01', 1200000.00, 'planificacion'
) t WHERE NOT EXISTS (SELECT 1 FROM videogames WHERE codigo='VG-0004');

INSERT INTO videogames (codigo, titulo, id_genero, id_clasificacion, id_motor,
                        fecha_inicio, fecha_lanzamiento_prevista, presupuesto, estado)
SELECT * FROM (SELECT
  'VG-0005', 'Granja Feliz 3D',
  (SELECT id_genero FROM generos WHERE nombre='Simulación'),
  (SELECT id_clasificacion FROM clasificaciones WHERE sistema='ESRB' AND codigo='E'),
  (SELECT id_motor FROM motores_graficos WHERE nombre='Unity'),
  DATE'2024-08-01', DATE'2025-12-01', 90000.00, 'pruebas'
) t WHERE NOT EXISTS (SELECT 1 FROM videogames WHERE codigo='VG-0005');

INSERT INTO videogames (codigo, titulo, id_genero, id_clasificacion, id_motor,
                        fecha_inicio, fecha_lanzamiento_prevista, presupuesto, estado)
SELECT * FROM (SELECT
  'VG-0006', 'Vórtice Neón',
  (SELECT id_genero FROM generos WHERE nombre='Acción'),
  (SELECT id_clasificacion FROM clasificaciones WHERE sistema='PEGI' AND codigo='16'),
  (SELECT id_motor FROM motores_graficos WHERE nombre='Godot'),
  DATE'2024-03-01', DATE'2025-09-01', 260000.00, 'lanzado'
) t WHERE NOT EXISTS (SELECT 1 FROM videogames WHERE codigo='VG-0006');

INSERT INTO videogames (codigo, titulo, id_genero, id_clasificacion, id_motor,
                        fecha_inicio, fecha_lanzamiento_prevista, presupuesto, estado)
SELECT * FROM (SELECT
  'VG-0007', 'Sendas de Eldrin',
  (SELECT id_genero FROM generos WHERE nombre='Rol'),
  (SELECT id_clasificacion FROM clasificaciones WHERE sistema='PEGI' AND codigo='12'),
  (SELECT id_motor FROM motores_graficos WHERE nombre='CryEngine'),
  DATE'2023-11-01', DATE'2026-10-01', 1500000.00, 'desarrollo'
) t WHERE NOT EXISTS (SELECT 1 FROM videogames WHERE codigo='VG-0007');

INSERT INTO videogames (codigo, titulo, id_genero, id_clasificacion, id_motor,
                        fecha_inicio, fecha_lanzamiento_prevista, presupuesto, estado)
SELECT * FROM (SELECT
  'VG-0008', 'Tácticas de Nébula',
  (SELECT id_genero FROM generos WHERE nombre='Estrategia'),
  (SELECT id_clasificacion FROM clasificaciones WHERE sistema='ESRB' AND codigo='E10+'),
  (SELECT id_motor FROM motores_graficos WHERE nombre='Godot'),
  DATE'2025-02-01', DATE'2026-03-01', 310000.00, 'planificacion'
) t WHERE NOT EXISTS (SELECT 1 FROM videogames WHERE codigo='VG-0008');

INSERT INTO videogames (codigo, titulo, id_genero, id_clasificacion, id_motor,
                        fecha_inicio, fecha_lanzamiento_prevista, presupuesto, estado)
SELECT * FROM (SELECT
  'VG-0009', 'Naufragio',
  (SELECT id_genero FROM generos WHERE nombre='Aventura'),
  (SELECT id_clasificacion FROM clasificaciones WHERE sistema='ESRB' AND codigo='M'),
  (SELECT id_motor FROM motores_graficos WHERE nombre='Unity'),
  DATE'2022-06-01', DATE'2023-12-01', 150000.00, 'pausado'
) t WHERE NOT EXISTS (SELECT 1 FROM videogames WHERE codigo='VG-0009');

INSERT INTO videogames (codigo, titulo, id_genero, id_clasificacion, id_motor,
                        fecha_inicio, fecha_lanzamiento_prevista, presupuesto, estado)
SELECT * FROM (SELECT
  'VG-0010', 'Proyecto Fénix',
  (SELECT id_genero FROM generos WHERE nombre='Acción'),
  (SELECT id_clasificacion FROM clasificaciones WHERE sistema='PEGI' AND codigo='18'),
  (SELECT id_motor FROM motores_graficos WHERE nombre='Unreal Engine'),
  DATE'2021-01-01', NULL, 75000.00, 'cancelado'
) t WHERE NOT EXISTS (SELECT 1 FROM videogames WHERE codigo='VG-0010');

-- Plataformas objetivo de cada videojuego (relación N:M)
INSERT INTO videogame_plataformas (id_videogame, id_plataforma)
SELECT v.id_videogame, p.id_plataforma FROM videogames v, plataformas p
WHERE v.codigo='VG-0001' AND p.nombre IN ('PC','Nintendo Switch')
  AND NOT EXISTS (SELECT 1 FROM videogame_plataformas x WHERE x.id_videogame=v.id_videogame AND x.id_plataforma=p.id_plataforma);
INSERT INTO videogame_plataformas (id_videogame, id_plataforma)
SELECT v.id_videogame, p.id_plataforma FROM videogames v, plataformas p
WHERE v.codigo='VG-0002' AND p.nombre IN ('PC','PlayStation 5','Xbox Series X/S')
  AND NOT EXISTS (SELECT 1 FROM videogame_plataformas x WHERE x.id_videogame=v.id_videogame AND x.id_plataforma=p.id_plataforma);
INSERT INTO videogame_plataformas (id_videogame, id_plataforma)
SELECT v.id_videogame, p.id_plataforma FROM videogames v, plataformas p
WHERE v.codigo='VG-0003' AND p.nombre IN ('PC')
  AND NOT EXISTS (SELECT 1 FROM videogame_plataformas x WHERE x.id_videogame=v.id_videogame AND x.id_plataforma=p.id_plataforma);
INSERT INTO videogame_plataformas (id_videogame, id_plataforma)
SELECT v.id_videogame, p.id_plataforma FROM videogames v, plataformas p
WHERE v.codigo='VG-0004' AND p.nombre IN ('PC','PlayStation 5')
  AND NOT EXISTS (SELECT 1 FROM videogame_plataformas x WHERE x.id_videogame=v.id_videogame AND x.id_plataforma=p.id_plataforma);
INSERT INTO videogame_plataformas (id_videogame, id_plataforma)
SELECT v.id_videogame, p.id_plataforma FROM videogames v, plataformas p
WHERE v.codigo='VG-0005' AND p.nombre IN ('Android','iOS')
  AND NOT EXISTS (SELECT 1 FROM videogame_plataformas x WHERE x.id_videogame=v.id_videogame AND x.id_plataforma=p.id_plataforma);
INSERT INTO videogame_plataformas (id_videogame, id_plataforma)
SELECT v.id_videogame, p.id_plataforma FROM videogames v, plataformas p
WHERE v.codigo='VG-0006' AND p.nombre IN ('PC','Nintendo Switch')
  AND NOT EXISTS (SELECT 1 FROM videogame_plataformas x WHERE x.id_videogame=v.id_videogame AND x.id_plataforma=p.id_plataforma);
INSERT INTO videogame_plataformas (id_videogame, id_plataforma)
SELECT v.id_videogame, p.id_plataforma FROM videogames v, plataformas p
WHERE v.codigo='VG-0007' AND p.nombre IN ('PC','PlayStation 5','Xbox Series X/S')
  AND NOT EXISTS (SELECT 1 FROM videogame_plataformas x WHERE x.id_videogame=v.id_videogame AND x.id_plataforma=p.id_plataforma);
INSERT INTO videogame_plataformas (id_videogame, id_plataforma)
SELECT v.id_videogame, p.id_plataforma FROM videogames v, plataformas p
WHERE v.codigo='VG-0008' AND p.nombre IN ('PC')
  AND NOT EXISTS (SELECT 1 FROM videogame_plataformas x WHERE x.id_videogame=v.id_videogame AND x.id_plataforma=p.id_plataforma);
INSERT INTO videogame_plataformas (id_videogame, id_plataforma)
SELECT v.id_videogame, p.id_plataforma FROM videogames v, plataformas p
WHERE v.codigo='VG-0009' AND p.nombre IN ('PC','Nintendo Switch')
  AND NOT EXISTS (SELECT 1 FROM videogame_plataformas x WHERE x.id_videogame=v.id_videogame AND x.id_plataforma=p.id_plataforma);
INSERT INTO videogame_plataformas (id_videogame, id_plataforma)
SELECT v.id_videogame, p.id_plataforma FROM videogames v, plataformas p
WHERE v.codigo='VG-0010' AND p.nombre IN ('PC')
  AND NOT EXISTS (SELECT 1 FROM videogame_plataformas x WHERE x.id_videogame=v.id_videogame AND x.id_plataforma=p.id_plataforma);


-- =====================================================================
-- PARTE 5 — EMPLEADOS
-- Existentes: 0 | Objetivo: 15 | Se agregarán: 15
-- =====================================================================
INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-001','Mariana','Torres',(SELECT id_especialidad FROM especialidades WHERE nombre='Programación'),6,'Motor de físicas en un estudio indie previo','mariana.torres@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-001');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-002','Andrés','Salazar',(SELECT id_especialidad FROM especialidades WHERE nombre='Programación'),9,'Backend de servicios online en una fintech','andres.salazar@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-002');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-003','Lucía','Fernández',(SELECT id_especialidad FROM especialidades WHERE nombre='Arte'),5,'Ilustración conceptual como freelance','lucia.fernandez@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-003');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-004','Javier','Morales',(SELECT id_especialidad FROM especialidades WHERE nombre='Arte'),8,'Modelado 3D en un estudio de animación','javier.morales@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-004');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-005','Camila','Rojas',(SELECT id_especialidad FROM especialidades WHERE nombre='Diseño'),4,'Diseño de niveles en modificaciones (mods) de otros juegos','camila.rojas@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-005');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-006','Diego','Herrera',(SELECT id_especialidad FROM especialidades WHERE nombre='Diseño'),7,'Game designer en un estudio de juegos móviles','diego.herrera@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-006');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-007','Valentina','Cruz',(SELECT id_especialidad FROM especialidades WHERE nombre='Música'),10,'Composición para cine independiente','valentina.cruz@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-007');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-008','Sebastián','Ibáñez',(SELECT id_especialidad FROM especialidades WHERE nombre='Testing'),3,'QA funcional en una empresa de software empresarial','sebastian.ibanez@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-008');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-009','Paula','Jiménez',(SELECT id_especialidad FROM especialidades WHERE nombre='Testing'),5,'Automatización de pruebas en una fintech','paula.jimenez@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-009');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-010','Felipe','Castillo',(SELECT id_especialidad FROM especialidades WHERE nombre='Producción'),11,'Gestión de proyectos ágiles en software','felipe.castillo@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-010');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-011','Daniela','Vargas',(SELECT id_especialidad FROM especialidades WHERE nombre='Guion y Narrativa'),6,'Guionista de novelas visuales','daniela.vargas@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-011');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-012','Tomás','Reyes',(SELECT id_especialidad FROM especialidades WHERE nombre='UI/UX'),4,'Diseño de interfaces para apps móviles','tomas.reyes@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-012');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-013','Isabela','Guzmán',(SELECT id_especialidad FROM especialidades WHERE nombre='Programación'),2,'Pasantía en desarrollo de videojuegos móviles','isabela.guzman@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-013');

INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-014','Nicolás','Peña',(SELECT id_especialidad FROM especialidades WHERE nombre='Arte'),6,'Ilustración de fondos para juegos de rol','nicolas.pena@gamedev.com',1) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-014');

-- Empleado inactivo, para poder demostrar el filtro "solo activos"
INSERT INTO empleados (codigo_empleado, nombres, apellidos, id_especialidad, anios_experiencia, experiencia_previa, correo, activo)
SELECT * FROM (SELECT 'EMP-015','Renata','Solís',(SELECT id_especialidad FROM especialidades WHERE nombre='Diseño'),9,'Balance de sistemas en juegos free-to-play','renata.solis@gamedev.com',0) t
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE codigo_empleado='EMP-015');

-- Habilidades por empleado
INSERT INTO empleado_habilidades (id_empleado, id_habilidad, nivel)
SELECT e.id_empleado, h.id_habilidad, x.nivel
FROM empleados e JOIN habilidades h ON 1=1
JOIN (
  SELECT 'EMP-001' cod,'C# avanzado' hab,'experto' nivel UNION ALL
  SELECT 'EMP-001','Optimización de rendimiento','avanzado' UNION ALL
  SELECT 'EMP-002','Scripting en Unity (C#)','avanzado' UNION ALL
  SELECT 'EMP-002','Optimización de rendimiento','intermedio' UNION ALL
  SELECT 'EMP-003','Modelado 3D','experto' UNION ALL
  SELECT 'EMP-003','Shaders y VFX','avanzado' UNION ALL
  SELECT 'EMP-004','Animación 2D','avanzado' UNION ALL
  SELECT 'EMP-004','Modelado 3D','intermedio' UNION ALL
  SELECT 'EMP-005','Diseño de niveles','experto' UNION ALL
  SELECT 'EMP-005','Diseño de sistemas de juego','avanzado' UNION ALL
  SELECT 'EMP-006','Diseño de sistemas de juego','experto' UNION ALL
  SELECT 'EMP-006','Diseño de niveles','avanzado' UNION ALL
  SELECT 'EMP-007','Composición musical','experto' UNION ALL
  SELECT 'EMP-008','Automatización de pruebas (QA)','avanzado' UNION ALL
  SELECT 'EMP-009','Automatización de pruebas (QA)','experto' UNION ALL
  SELECT 'EMP-010','Diseño de sistemas de juego','intermedio' UNION ALL
  SELECT 'EMP-011','Diseño de niveles','intermedio' UNION ALL
  SELECT 'EMP-012','Animación 2D','intermedio' UNION ALL
  SELECT 'EMP-013','C# avanzado','basico' UNION ALL
  SELECT 'EMP-013','Scripting en Unity (C#)','intermedio' UNION ALL
  SELECT 'EMP-014','Modelado 3D','avanzado' UNION ALL
  SELECT 'EMP-015','Diseño de niveles','basico'
) x ON x.cod = e.codigo_empleado AND x.hab = h.nombre
WHERE NOT EXISTS (SELECT 1 FROM empleado_habilidades eh WHERE eh.id_empleado=e.id_empleado AND eh.id_habilidad=h.id_habilidad);

-- Asignaciones a proyectos (equipo de desarrollo). Los juegos ya lanzados o
-- cancelados llevan fecha_fin en el pasado (no cuentan para el 100% actual).
INSERT INTO asignaciones_proyecto (id_videogame, id_empleado, id_rol, porcentaje_dedicacion, fecha_asignacion, fecha_fin)
SELECT v.id_videogame, e.id_empleado, r.id_rol, x.pct, x.f_ini, x.f_fin
FROM videogames v, empleados e, roles_proyecto r, (
  SELECT 'VG-0001' vg,'EMP-003' emp,'Artista' rol, 60 pct, DATE'2024-01-10' f_ini, DATE'2025-10-15' f_fin UNION ALL
  SELECT 'VG-0001','EMP-005','Diseñador de niveles',50, DATE'2024-01-10', DATE'2025-10-15' UNION ALL
  SELECT 'VG-0002','EMP-001','Desarrollador',70, DATE'2024-05-15', NULL UNION ALL
  SELECT 'VG-0002','EMP-004','Artista',60, DATE'2024-06-01', NULL UNION ALL
  SELECT 'VG-0002','EMP-008','Tester QA',40, DATE'2025-01-15', NULL UNION ALL
  SELECT 'VG-0003','EMP-010','Líder de proyecto',50, DATE'2023-09-01', DATE'2024-12-20' UNION ALL
  SELECT 'VG-0004','EMP-011','Diseñador de niveles',40, DATE'2025-01-10', NULL UNION ALL
  SELECT 'VG-0004','EMP-002','Desarrollador',30, DATE'2025-03-01', NULL UNION ALL
  SELECT 'VG-0005','EMP-009','Tester QA',60, DATE'2024-08-01', NULL UNION ALL
  SELECT 'VG-0005','EMP-012','Diseñador de niveles',50, DATE'2024-09-01', NULL UNION ALL
  SELECT 'VG-0006','EMP-014','Artista',40, DATE'2024-03-01', DATE'2025-08-20' UNION ALL
  SELECT 'VG-0007','EMP-002','Desarrollador',30, DATE'2023-11-01', NULL UNION ALL
  SELECT 'VG-0007','EMP-006','Diseñador de niveles',60, DATE'2023-11-01', NULL UNION ALL
  SELECT 'VG-0007','EMP-007','Compositor',30, DATE'2024-02-01', NULL UNION ALL
  SELECT 'VG-0008','EMP-013','Desarrollador',40, DATE'2025-02-01', NULL UNION ALL
  SELECT 'VG-0009','EMP-015','Diseñador de niveles',50, DATE'2022-06-01', DATE'2023-01-01' UNION ALL
  SELECT 'VG-0010','EMP-003','Artista',40, DATE'2021-01-01', DATE'2021-06-01'
) x
WHERE x.vg = v.codigo AND x.emp = e.codigo_empleado AND x.rol = r.nombre
  AND NOT EXISTS (SELECT 1 FROM asignaciones_proyecto a WHERE a.id_videogame=v.id_videogame AND a.id_empleado=e.id_empleado);


-- =====================================================================
-- PARTE 6 — TAREAS
-- Existentes: 0 | Objetivo: 20 | Se agregarán: 20
-- Distribución por módulo: Jugabilidad 7, Gráficos 5, IA 4, Pruebas 3, Sonido 1
-- (refleja el tamaño real de cada equipo: solo hay una compositora, por
--  ejemplo, así que solo hay una tarea de Sonido)
-- =====================================================================
-- Las tareas se insertan una por una para mantener claridad y trazabilidad
-- código-descripción; cada INSERT está protegido por su propio código único.

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-001', v.id_videogame, m.id_modulo, 'Balancear la mecánica de sigilo entre raíces','baja','completada', e.id_empleado, '2024-03-01','2024-04-15',100
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0001' AND m.nombre='Jugabilidad' AND e.codigo_empleado='EMP-005'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-001');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-002', v.id_videogame, m.id_modulo, 'Pulir animaciones de follaje en el bosque de niebla','media','completada', e.id_empleado, '2024-06-01','2024-08-01',100
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0001' AND m.nombre='Gráficos' AND e.codigo_empleado='EMP-003'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-002');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-003', v.id_videogame, m.id_modulo, 'Implementar sistema de combate cuerpo a cuerpo','alta','en_proceso', e.id_empleado, '2025-06-01','2026-01-15',65
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0002' AND m.nombre='Jugabilidad' AND e.codigo_empleado='EMP-001'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-003');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-004', v.id_videogame, m.id_modulo, 'Modelar armaduras de la facción imperial','media','en_proceso', e.id_empleado, '2025-07-01','2026-02-01',40
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0002' AND m.nombre='Gráficos' AND e.codigo_empleado='EMP-004'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-004');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-005', v.id_videogame, m.id_modulo, 'Ejecutar pruebas de estrés en combates masivos','alta','pendiente', e.id_empleado, '2026-09-01','2026-12-01',0
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0002' AND m.nombre='Pruebas' AND e.codigo_empleado='EMP-008'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-005');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-006', v.id_videogame, m.id_modulo, 'Diseñar el árbol tecnológico inicial','media','completada', e.id_empleado, '2023-09-15','2023-11-01',100
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0003' AND m.nombre='Jugabilidad' AND e.codigo_empleado='EMP-010'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-006');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-007', v.id_videogame, m.id_modulo, 'Redactar guion del primer acto','alta','en_proceso', e.id_empleado, '2025-01-15','2025-06-01',30
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0004' AND m.nombre='Jugabilidad' AND e.codigo_empleado='EMP-011'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-007');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-008', v.id_videogame, m.id_modulo, 'Prototipar sistema de combate por turnos','media','pendiente', e.id_empleado, '2025-09-01','2026-02-01',0
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0004' AND m.nombre='IA' AND e.codigo_empleado='EMP-002'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-008');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-009', v.id_videogame, m.id_modulo, 'Validar guardado de partida en múltiples dispositivos','alta','revision', e.id_empleado, '2025-10-01','2025-12-15',85
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0005' AND m.nombre='Pruebas' AND e.codigo_empleado='EMP-009'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-009');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-010', v.id_videogame, m.id_modulo, 'Ajustar interfaz de inventario de cultivos','media','en_proceso', e.id_empleado, '2025-09-01','2025-11-30',55
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0005' AND m.nombre='Gráficos' AND e.codigo_empleado='EMP-012'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-010');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-011', v.id_videogame, m.id_modulo, 'Retocar efectos de neón en el nivel final','baja','completada', e.id_empleado, '2025-05-01','2025-07-01',100
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0006' AND m.nombre='Gráficos' AND e.codigo_empleado='EMP-014'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-011');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-012', v.id_videogame, m.id_modulo, 'Implementar sistema de crafteo de pociones','alta','en_proceso', e.id_empleado, '2025-11-01','2026-05-01',45
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0007' AND m.nombre='Jugabilidad' AND e.codigo_empleado='EMP-002'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-012');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-013', v.id_videogame, m.id_modulo, 'Ajustar rutas de patrullaje de la guardia real','media','pendiente', e.id_empleado, '2026-06-01','2026-10-01',0
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0007' AND m.nombre='IA' AND e.codigo_empleado='EMP-006'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-013');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-014', v.id_videogame, m.id_modulo, 'Componer tema principal del reino de Eldrin','media','en_proceso', e.id_empleado, '2025-12-01','2026-04-01',60
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0007' AND m.nombre='Sonido' AND e.codigo_empleado='EMP-007'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-014');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-015', v.id_videogame, m.id_modulo, 'Revisar balance de dificultad en jefes finales','critica','pendiente', e.id_empleado, '2026-09-01','2026-12-15',0
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0007' AND m.nombre='Pruebas' AND e.codigo_empleado='EMP-002'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-015');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-016', v.id_videogame, m.id_modulo, 'Definir reglas base del sistema de turnos','alta','en_proceso', e.id_empleado, '2025-02-15','2025-08-01',20
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0008' AND m.nombre='Jugabilidad' AND e.codigo_empleado='EMP-013'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-016');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-017', v.id_videogame, m.id_modulo, 'Investigar algoritmos de IA para unidades enemigas','media','pendiente', e.id_empleado, '2025-09-01','2026-03-01',0
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0008' AND m.nombre='IA' AND e.codigo_empleado='EMP-013'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-017');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-018', v.id_videogame, m.id_modulo, 'Rediseñar el sistema de supervivencia en la isla','media','pendiente', e.id_empleado, '2022-07-01','2022-12-01',20
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0009' AND m.nombre='Jugabilidad' AND e.codigo_empleado='EMP-015'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-018');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-019', v.id_videogame, m.id_modulo, 'Bocetar los personajes principales','baja','completada', e.id_empleado, '2021-02-01','2021-04-01',100
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0010' AND m.nombre='Gráficos' AND e.codigo_empleado='EMP-003'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-019');

INSERT INTO tareas (codigo, id_videogame, id_modulo, descripcion, prioridad, estado, id_responsable, fecha_asignacion, fecha_limite, porcentaje_avance)
SELECT 'TSK-020', v.id_videogame, m.id_modulo, 'Evaluar la viabilidad técnica del modo multijugador','media','completada', e.id_empleado, '2021-03-01','2021-05-01',100
FROM videogames v, modulos_desarrollo m, empleados e
WHERE v.codigo='VG-0010' AND m.nombre='IA' AND e.codigo_empleado='EMP-003'
  AND NOT EXISTS (SELECT 1 FROM tareas WHERE codigo='TSK-020');

-- Dependencias entre tareas (sin ciclos, sin autodependencias)
-- TSK-005 (pruebas de estrés) depende de TSK-003 (combate implementado)
INSERT INTO tarea_dependencias (id_tarea, id_tarea_predecesora)
SELECT t1.id_tarea, t2.id_tarea FROM tareas t1, tareas t2
WHERE t1.codigo='TSK-005' AND t2.codigo='TSK-003'
  AND NOT EXISTS (SELECT 1 FROM tarea_dependencias d WHERE d.id_tarea=t1.id_tarea AND d.id_tarea_predecesora=t2.id_tarea);

-- TSK-015 (balance de jefes) depende de TSK-012 (crafteo de pociones implementado)
INSERT INTO tarea_dependencias (id_tarea, id_tarea_predecesora)
SELECT t1.id_tarea, t2.id_tarea FROM tareas t1, tareas t2
WHERE t1.codigo='TSK-015' AND t2.codigo='TSK-012'
  AND NOT EXISTS (SELECT 1 FROM tarea_dependencias d WHERE d.id_tarea=t1.id_tarea AND d.id_tarea_predecesora=t2.id_tarea);

-- TSK-009 (validar guardado) depende de TSK-010 (inventario de cultivos listo)
INSERT INTO tarea_dependencias (id_tarea, id_tarea_predecesora)
SELECT t1.id_tarea, t2.id_tarea FROM tareas t1, tareas t2
WHERE t1.codigo='TSK-009' AND t2.codigo='TSK-010'
  AND NOT EXISTS (SELECT 1 FROM tarea_dependencias d WHERE d.id_tarea=t1.id_tarea AND d.id_tarea_predecesora=t2.id_tarea);


-- =====================================================================
-- PARTE 7 — USUARIOS
-- Existentes: 0 | Objetivo: 10 | Se agregarán: 10
-- password_hash: valores de ejemplo (simulan un hash bcrypt); en la app
-- real reemplázalos por el hash real generado con bcrypt/argon2 desde Python.
-- =====================================================================
INSERT INTO usuarios (nombre_usuario, correo, password_hash, estado)
SELECT * FROM (SELECT 'nightfox92','nightfox92@mail.com','$2b$12$k3nQ1s0m3H4shV4lu30000000000000000000000000001','activo') t
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE nombre_usuario='nightfox92');

INSERT INTO usuarios (nombre_usuario, correo, password_hash, estado)
SELECT * FROM (SELECT 'valen_gamer','valen.gamer@mail.com','$2b$12$k3nQ1s0m3H4shV4lu30000000000000000000000000002','activo') t
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE nombre_usuario='valen_gamer');

INSERT INTO usuarios (nombre_usuario, correo, password_hash, estado)
SELECT * FROM (SELECT 'kai_plays','kai.plays@mail.com','$2b$12$k3nQ1s0m3H4shV4lu30000000000000000000000000003','activo') t
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE nombre_usuario='kai_plays');

INSERT INTO usuarios (nombre_usuario, correo, password_hash, estado)
SELECT * FROM (SELECT 'sofia.rpg','sofia.rpg@mail.com','$2b$12$k3nQ1s0m3H4shV4lu30000000000000000000000000004','activo') t
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE nombre_usuario='sofia.rpg');

INSERT INTO usuarios (nombre_usuario, correo, password_hash, estado)
SELECT * FROM (SELECT 'DarkWolf77','darkwolf77@mail.com','$2b$12$k3nQ1s0m3H4shV4lu30000000000000000000000000005','suspendido') t
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE nombre_usuario='DarkWolf77');

INSERT INTO usuarios (nombre_usuario, correo, password_hash, estado)
SELECT * FROM (SELECT 'mateo_indie','mateo.indie@mail.com','$2b$12$k3nQ1s0m3H4shV4lu30000000000000000000000000006','activo') t
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE nombre_usuario='mateo_indie');

INSERT INTO usuarios (nombre_usuario, correo, password_hash, estado)
SELECT * FROM (SELECT 'camigamer','cami.gamer@mail.com','$2b$12$k3nQ1s0m3H4shV4lu30000000000000000000000000007','inactivo') t
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE nombre_usuario='camigamer');

INSERT INTO usuarios (nombre_usuario, correo, password_hash, estado)
SELECT * FROM (SELECT 'retro_lucas','retro.lucas@mail.com','$2b$12$k3nQ1s0m3H4shV4lu30000000000000000000000000008','activo') t
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE nombre_usuario='retro_lucas');

INSERT INTO usuarios (nombre_usuario, correo, password_hash, estado)
SELECT * FROM (SELECT 'elena_casual','elena.casual@mail.com','$2b$12$k3nQ1s0m3H4shV4lu30000000000000000000000000009','activo') t
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE nombre_usuario='elena_casual');

INSERT INTO usuarios (nombre_usuario, correo, password_hash, estado)
SELECT * FROM (SELECT 'thewanderer','thewanderer@mail.com','$2b$12$k3nQ1s0m3H4shV4lu30000000000000000000000000010','activo') t
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE nombre_usuario='thewanderer');

-- Plataformas que usa cada usuario
INSERT INTO usuario_plataformas (id_usuario, id_plataforma)
SELECT u.id_usuario, p.id_plataforma FROM usuarios u, plataformas p
WHERE u.nombre_usuario='nightfox92' AND p.nombre IN ('PC','PlayStation 5')
  AND NOT EXISTS (SELECT 1 FROM usuario_plataformas x WHERE x.id_usuario=u.id_usuario AND x.id_plataforma=p.id_plataforma);
INSERT INTO usuario_plataformas (id_usuario, id_plataforma)
SELECT u.id_usuario, p.id_plataforma FROM usuarios u, plataformas p
WHERE u.nombre_usuario='valen_gamer' AND p.nombre IN ('Nintendo Switch')
  AND NOT EXISTS (SELECT 1 FROM usuario_plataformas x WHERE x.id_usuario=u.id_usuario AND x.id_plataforma=p.id_plataforma);
INSERT INTO usuario_plataformas (id_usuario, id_plataforma)
SELECT u.id_usuario, p.id_plataforma FROM usuarios u, plataformas p
WHERE u.nombre_usuario='kai_plays' AND p.nombre IN ('PC','Xbox Series X/S')
  AND NOT EXISTS (SELECT 1 FROM usuario_plataformas x WHERE x.id_usuario=u.id_usuario AND x.id_plataforma=p.id_plataforma);
INSERT INTO usuario_plataformas (id_usuario, id_plataforma)
SELECT u.id_usuario, p.id_plataforma FROM usuarios u, plataformas p
WHERE u.nombre_usuario='sofia.rpg' AND p.nombre IN ('PC')
  AND NOT EXISTS (SELECT 1 FROM usuario_plataformas x WHERE x.id_usuario=u.id_usuario AND x.id_plataforma=p.id_plataforma);
INSERT INTO usuario_plataformas (id_usuario, id_plataforma)
SELECT u.id_usuario, p.id_plataforma FROM usuarios u, plataformas p
WHERE u.nombre_usuario='DarkWolf77' AND p.nombre IN ('PlayStation 5')
  AND NOT EXISTS (SELECT 1 FROM usuario_plataformas x WHERE x.id_usuario=u.id_usuario AND x.id_plataforma=p.id_plataforma);
INSERT INTO usuario_plataformas (id_usuario, id_plataforma)
SELECT u.id_usuario, p.id_plataforma FROM usuarios u, plataformas p
WHERE u.nombre_usuario='mateo_indie' AND p.nombre IN ('PC','Android')
  AND NOT EXISTS (SELECT 1 FROM usuario_plataformas x WHERE x.id_usuario=u.id_usuario AND x.id_plataforma=p.id_plataforma);
INSERT INTO usuario_plataformas (id_usuario, id_plataforma)
SELECT u.id_usuario, p.id_plataforma FROM usuarios u, plataformas p
WHERE u.nombre_usuario='camigamer' AND p.nombre IN ('iOS')
  AND NOT EXISTS (SELECT 1 FROM usuario_plataformas x WHERE x.id_usuario=u.id_usuario AND x.id_plataforma=p.id_plataforma);
INSERT INTO usuario_plataformas (id_usuario, id_plataforma)
SELECT u.id_usuario, p.id_plataforma FROM usuarios u, plataformas p
WHERE u.nombre_usuario='retro_lucas' AND p.nombre IN ('Nintendo Switch','PC')
  AND NOT EXISTS (SELECT 1 FROM usuario_plataformas x WHERE x.id_usuario=u.id_usuario AND x.id_plataforma=p.id_plataforma);
INSERT INTO usuario_plataformas (id_usuario, id_plataforma)
SELECT u.id_usuario, p.id_plataforma FROM usuarios u, plataformas p
WHERE u.nombre_usuario='elena_casual' AND p.nombre IN ('Android','iOS')
  AND NOT EXISTS (SELECT 1 FROM usuario_plataformas x WHERE x.id_usuario=u.id_usuario AND x.id_plataforma=p.id_plataforma);
INSERT INTO usuario_plataformas (id_usuario, id_plataforma)
SELECT u.id_usuario, p.id_plataforma FROM usuarios u, plataformas p
WHERE u.nombre_usuario='thewanderer' AND p.nombre IN ('PC','Xbox Series X/S','PlayStation 5')
  AND NOT EXISTS (SELECT 1 FROM usuario_plataformas x WHERE x.id_usuario=u.id_usuario AND x.id_plataforma=p.id_plataforma);

-- Preferencias de usuario
INSERT INTO usuario_preferencias (id_usuario, clave, valor)
SELECT u.id_usuario, x.clave, x.valor FROM usuarios u
JOIN (
  SELECT 'nightfox92' usr,'idioma' clave,'es' valor UNION ALL
  SELECT 'nightfox92','tema','oscuro' UNION ALL
  SELECT 'valen_gamer','idioma','es' UNION ALL
  SELECT 'kai_plays','notificaciones','activadas' UNION ALL
  SELECT 'sofia.rpg','idioma','en' UNION ALL
  SELECT 'DarkWolf77','tema','claro' UNION ALL
  SELECT 'mateo_indie','idioma','es' UNION ALL
  SELECT 'retro_lucas','tema','oscuro' UNION ALL
  SELECT 'elena_casual','idioma','es' UNION ALL
  SELECT 'thewanderer','idioma','en' UNION ALL
  SELECT 'thewanderer','tema','oscuro'
) x ON x.usr = u.nombre_usuario
WHERE NOT EXISTS (SELECT 1 FROM usuario_preferencias p WHERE p.id_usuario=u.id_usuario AND p.clave=x.clave);


-- =====================================================================
-- OPCIONAL: ejemplos de ruta de imagen (Parte 8), solo si ya ejecutaste
-- gamedev_alter_estructura.sql. Ajusta las rutas a donde Tkinter guarde
-- realmente los archivos.
-- =====================================================================
-- UPDATE videogames SET imagen_portada = 'assets/portadas/vg_0001.png' WHERE codigo='VG-0001';
-- UPDATE empleados  SET imagen_perfil  = 'assets/perfiles/emp_001.jpg'  WHERE codigo_empleado='EMP-001';

-- =====================================================================
-- ALTERNATIVA OPCIONAL para modulosvideogamesvideogames_desarrollo (NO se ejecuta por defecto):
-- si prefieres que el catálogo use exactamente los 5 nombres de la rúbrica
-- en vez de conservar los 4 originales + Pruebas, podrías correr en su
-- lugar (bajo tu propio criterio, ya que renombra datos existentes):
-- UPDATE modulos_desarrollo SET nombre='Programación' WHERE nombre='Jugabilidad';
-- UPDATE modulos_desarrollo SET nombre='Arte'         WHERE nombre='Gráficos';
-- UPDATE modulos_desarrollo SET nombre='Diseño'       WHERE nombre='Sonido';
-- UPDATE modulos_desarrollo SET nombre='Preproducción' WHERE nombre='IA';
-- (y ya tendrías 'Pruebas' de este script) -- pero esto invalida los
-- nombres usados en las tareas de ejemplo de arriba, revísalas si lo haces.


-- =====================================================================
--  Gamedev. — CONSULTAS DE VERIFICACIÓN (Parte E)
--  Y PROCEDIMIENTOS DE PRUEBA (Parte F)
--  Ejecutar DESPUÉS de gamedev_alter_estructura.sql y gamedev_datos_prueba.sql
-- =====================================================================
USE gamedev;

-- =====================================================================
-- E.1 — Cantidad de registros por tabla clave
-- =====================================================================
SELECT 'generos' t, COUNT(*) n FROM generos
UNION ALL SELECT 'plataformas', COUNT(*) FROM plataformas
UNION ALL SELECT 'clasificaciones', COUNT(*) FROM clasificaciones
UNION ALL SELECT 'motores_graficos', COUNT(*) FROM motores_graficos
UNION ALL SELECT 'especialidades', COUNT(*) FROM especialidades
UNION ALL SELECT 'habilidades', COUNT(*) FROM habilidades
UNION ALL SELECT 'roles_proyecto', COUNT(*) FROM roles_proyecto
UNION ALL SELECT 'modulos_desarrollo', COUNT(*) FROM modulos_desarrollo
UNION ALL SELECT 'lenguajes_programacion', COUNT(*) FROM lenguajes_programacion
UNION ALL SELECT 'tiendas_digitales', COUNT(*) FROM tiendas_digitales
UNION ALL SELECT 'videogames', COUNT(*) FROM videogames
UNION ALL SELECT 'empleados', COUNT(*) FROM empleados
UNION ALL SELECT 'tareas', COUNT(*) FROM tareas
UNION ALL SELECT 'usuarios', COUNT(*) FROM usuarios
UNION ALL SELECT 'videogame_plataformas', COUNT(*) FROM videogame_plataformas
UNION ALL SELECT 'empleado_habilidades', COUNT(*) FROM empleado_habilidades
UNION ALL SELECT 'asignaciones_proyecto', COUNT(*) FROM asignaciones_proyecto
UNION ALL SELECT 'tarea_dependencias', COUNT(*) FROM tarea_dependencias
UNION ALL SELECT 'usuario_plataformas', COUNT(*) FROM usuario_plataformas
UNION ALL SELECT 'usuario_preferencias', COUNT(*) FROM usuario_preferencias;

-- =====================================================================
-- E.2 — Confirmar que las columnas de imagen existen
-- =====================================================================
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
  FROM information_schema.COLUMNS
 WHERE TABLE_SCHEMA = DATABASE()
   AND ((TABLE_NAME='videogames' AND COLUMN_NAME='imagen_portada')
     OR (TABLE_NAME='empleados'  AND COLUMN_NAME='imagen_perfil'));

-- =====================================================================
-- E.3 — Videojuegos: estados, género, plataformas
-- =====================================================================
SELECT v.codigo, v.titulo, g.nombre AS genero, v.estado,
       v.fecha_inicio, v.fecha_lanzamiento_prevista, v.presupuesto,
       (SELECT GROUP_CONCAT(p.nombre ORDER BY p.nombre SEPARATOR ', ')
          FROM videogame_plataformas vp JOIN plataformas p ON p.id_plataforma=vp.id_plataforma
         WHERE vp.id_videogame=v.id_videogame) AS plataformas
  FROM videogames v JOIN generos g ON g.id_genero=v.id_genero
 ORDER BY v.codigo;

-- Videojuegos por estado (para confirmar variedad de estados)
SELECT estado, COUNT(*) AS cantidad FROM videogames GROUP BY estado;

-- =====================================================================
-- E.4 — Empleados: especialidad, habilidades, equipo
-- =====================================================================
SELECT e.codigo_empleado, e.nombres, e.apellidos, es.nombre AS especialidad,
       e.activo,
       (SELECT GROUP_CONCAT(h.nombre SEPARATOR ', ')
          FROM empleado_habilidades eh JOIN habilidades h ON h.id_habilidad=eh.id_habilidad
         WHERE eh.id_empleado=e.id_empleado) AS habilidades
  FROM empleados e JOIN especialidades es ON es.id_especialidad=e.id_especialidad
 ORDER BY e.codigo_empleado;

-- Dedicación total activa por empleado (debe ser <= 100 en todos los casos)
SELECT e.codigo_empleado, CONCAT(e.nombres,' ',e.apellidos) AS empleado,
       COALESCE(SUM(a.porcentaje_dedicacion),0) AS dedicacion_activa
  FROM empleados e
  LEFT JOIN asignaciones_proyecto a
    ON a.id_empleado = e.id_empleado AND (a.fecha_fin IS NULL OR a.fecha_fin >= CURDATE())
 GROUP BY e.id_empleado, e.codigo_empleado, e.nombres, e.apellidos
 ORDER BY dedicacion_activa DESC;

-- =====================================================================
-- E.5 — Tareas: distribución por módulo de desarrollo y por estado
-- =====================================================================
SELECT m.nombre AS modulo, COUNT(*) AS cantidad_tareas
  FROM tareas t JOIN modulos_desarrollo m ON m.id_modulo=t.id_modulo
 GROUP BY m.nombre ORDER BY cantidad_tareas DESC;

SELECT t.estado, COUNT(*) AS cantidad FROM tareas t GROUP BY t.estado;

-- Tareas con su videojuego, módulo, responsable y dependencias
SELECT t.codigo, v.titulo AS videogame, m.nombre AS modulo, t.prioridad, t.estado,
       CONCAT(e.nombres,' ',e.apellidos) AS responsable, t.porcentaje_avance,
       (SELECT GROUP_CONCAT(tp.codigo SEPARATOR ', ')
          FROM tarea_dependencias d JOIN tareas tp ON tp.id_tarea=d.id_tarea_predecesora
         WHERE d.id_tarea=t.id_tarea) AS depende_de
  FROM tareas t
  JOIN videogames v ON v.id_videogame=t.id_videogame
  JOIN modulos_desarrollo m ON m.id_modulo=t.id_modulo
  LEFT JOIN empleados e ON e.id_empleado=t.id_responsable
 ORDER BY t.codigo;

-- Integridad: fecha_limite >= fecha_asignacion (debe devolver 0 filas)
SELECT * FROM tareas WHERE fecha_limite < fecha_asignacion;

-- Integridad: dependencias circulares directas t1->t2->t1 (debe devolver 0 filas)
SELECT d1.id_tarea, d1.id_tarea_predecesora
  FROM tarea_dependencias d1
  JOIN tarea_dependencias d2
    ON d2.id_tarea = d1.id_tarea_predecesora AND d2.id_tarea_predecesora = d1.id_tarea;

-- =====================================================================
-- E.6 — Usuarios: plataformas y preferencias
-- =====================================================================
SELECT u.nombre_usuario, u.correo, u.estado,
       (SELECT GROUP_CONCAT(p.nombre SEPARATOR ', ')
          FROM usuario_plataformas up JOIN plataformas p ON p.id_plataforma=up.id_plataforma
         WHERE up.id_usuario=u.id_usuario) AS plataformas,
       (SELECT GROUP_CONCAT(CONCAT(pr.clave,'=',pr.valor) SEPARATOR ', ')
          FROM usuario_preferencias pr WHERE pr.id_usuario=u.id_usuario) AS preferencias
  FROM usuarios u
 ORDER BY u.nombre_usuario;

-- =====================================================================
-- E.7 — Módulos de desarrollo disponibles (para poblar el combobox de tareas)
-- =====================================================================
SELECT id_modulo, nombre FROM modulos_desarrollo ORDER BY id_modulo;


-- =====================================================================
-- F. PROCEDIMIENTOS DE PRUEBA (ejemplos seguros con CALL)
--    Cada ejemplo usa datos nuevos/de prueba y no toca los ya sembrados.
-- =====================================================================

-- F.1 Insertar un videojuego nuevo (usa el parámetro de imagen agregado)
CALL sp_insertar_videogame(
  'VG-0011','Ecos de Kaeru',
  (SELECT id_genero FROM generos WHERE nombre='Aventura'),
  (SELECT id_clasificacion FROM clasificaciones WHERE sistema='PEGI' AND codigo='12'),
  (SELECT id_motor FROM motores_graficos WHERE nombre='Godot'),
  '2026-01-10', '2027-05-01', 220000.00, 'planificacion',
  JSON_ARRAY((SELECT id_plataforma FROM plataformas WHERE nombre='PC')),
  'assets/portadas/vg_0011.png',
  @nuevo_id_videogame
);
SELECT @nuevo_id_videogame AS id_videogame_creado;

-- F.2 Listar videojuegos filtrando por estado y por género (nuevo filtro)
CALL sp_listar_videogames('planificacion', NULL, NULL);
CALL sp_listar_videogames(NULL, NULL, (SELECT id_genero FROM generos WHERE nombre='Rol'));

-- F.3 Actualizar el videojuego recién creado (conservando la imagen: se pasa NULL)
CALL sp_actualizar_videogame(
  @nuevo_id_videogame, 'VG-0011','Ecos de Kaeru: Edición Revisada',
  (SELECT id_genero FROM generos WHERE nombre='Aventura'),
  (SELECT id_clasificacion FROM clasificaciones WHERE sistema='PEGI' AND codigo='12'),
  (SELECT id_motor FROM motores_graficos WHERE nombre='Godot'),
  '2026-01-10', '2027-06-01', 240000.00, 'desarrollo',
  JSON_ARRAY((SELECT id_plataforma FROM plataformas WHERE nombre='PC'),
             (SELECT id_plataforma FROM plataformas WHERE nombre='Nintendo Switch')),
  NULL
);
CALL sp_listar_videogames(NULL, 'Ecos de Kaeru', NULL);

-- F.4 Insertar un empleado nuevo (usa el parámetro de imagen agregado)
CALL sp_insertar_empleado(
  'EMP-016','Rocío','Delgado',
  (SELECT id_especialidad FROM especialidades WHERE nombre='UI/UX'),
  3,'Diseño de interfaces para e-commerce','rocio.delgado@gamedev.com',
  JSON_ARRAY(JSON_OBJECT('id',(SELECT id_habilidad FROM habilidades WHERE nombre='Animación 2D'),'nivel','intermedio')),
  'assets/perfiles/emp_016.jpg',
  @nuevo_id_empleado
);
SELECT @nuevo_id_empleado AS id_empleado_creado;

-- F.5 Listar empleados de una especialidad, solo activos
CALL sp_listar_empleados((SELECT id_especialidad FROM especialidades WHERE nombre='Programación'), 1, NULL);

-- F.6 Asignar al empleado nuevo a un proyecto y luego crear una tarea para él
CALL sp_asignar_empleado_proyecto(
  (SELECT id_videogame FROM videogames WHERE codigo='VG-0011'),
  @nuevo_id_empleado,
  (SELECT id_rol FROM roles_proyecto WHERE nombre='Diseñador de niveles'),
  50.00, CURDATE(), @nueva_asignacion
);

CALL sp_insertar_tarea(
  'TSK-021',
  (SELECT id_videogame FROM videogames WHERE codigo='VG-0011'),
  (SELECT id_modulo FROM modulos_desarrollo WHERE nombre='Gráficos'),
  'Diseñar pantalla de menú principal', 'media', 'pendiente',
  @nuevo_id_empleado, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 0,
  NULL, @nueva_tarea
);
CALL sp_listar_tareas((SELECT id_videogame FROM videogames WHERE codigo='VG-0011'), NULL, NULL);

-- F.7 Insertar un usuario nuevo
CALL sp_insertar_usuario(
  'nuevo_tester', 'nuevo.tester@mail.com', '$2b$12$HashDePruebaSoloParaDemo00000000',
  'activo',
  JSON_ARRAY((SELECT id_plataforma FROM plataformas WHERE nombre='PC')),
  JSON_ARRAY(JSON_OBJECT('clave','idioma','valor','es')),
  @nuevo_id_usuario
);
CALL sp_listar_usuarios('activo', 'nuevo_tester');

-- F.8 Actualizar y luego eliminar la tarea de prueba (limpieza)
CALL sp_actualizar_tarea(
  @nueva_tarea, 'TSK-021',
  (SELECT id_videogame FROM videogames WHERE codigo='VG-0011'),
  (SELECT id_modulo FROM modulos_desarrollo WHERE nombre='Gráficos'),
  'Diseñar pantalla de menú principal (revisada)', 'alta', 'en_proceso',
  @nuevo_id_empleado, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 35, NULL
);
CALL sp_eliminar_tarea(@nueva_tarea);

-- F.9 Probar el rechazo de dedicación > 100% (debe fallar con un error controlado)
-- Descomenta para probar manualmente:
-- CALL sp_asignar_empleado_proyecto(
--   (SELECT id_videogame FROM videogames WHERE codigo='VG-0002'),
--   (SELECT id_empleado FROM empleados WHERE codigo_empleado='EMP-001'), -- ya tiene 70% activo
--   (SELECT id_rol FROM roles_proyecto WHERE nombre='Desarrollador'),
--   40.00, CURDATE(), @falla
-- ); -- Error esperado: "La dedicación total del empleado superaría el 100%"

-- F.10 Limpieza final de los datos de prueba de esta sección F (opcional)
-- CALL sp_eliminar_usuario(@nuevo_id_usuario);
-- CALL sp_desasignar_empleado_proyecto((SELECT id_videogame FROM videogames WHERE codigo='VG-0011'), @nuevo_id_empleado);
-- CALL sp_eliminar_empleado(@nuevo_id_empleado);
-- CALL sp_eliminar_videogame((SELECT id_videogame FROM videogames WHERE codigo='VG-0011'));

