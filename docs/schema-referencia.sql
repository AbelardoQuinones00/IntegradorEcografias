-- =====================================================================
-- SISTEMA DE GESTIÓN DE ECOGRAFÍAS
-- Script de creación de base de datos (modelo lógico normalizado 3FN)
-- Motor: MySQL 8.x
--
-- NOTA: este archivo es solo DOCUMENTACIÓN DE REFERENCIA para alinear
-- los campos de las 25 vistas Tailwind con el modelo de datos real.
-- No se ejecuta automáticamente (no está en src/main/resources) para
-- no chocar con Flyway/Hibernate ddl-auto cuando se configure la BD.
-- =====================================================================

DROP DATABASE IF EXISTS sistema_ecografias;
CREATE DATABASE sistema_ecografias
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE sistema_ecografias;

SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================================
-- A. SEGURIDAD Y PERSONAS
-- =====================================================================

CREATE TABLE persona (
    id_persona          BIGINT AUTO_INCREMENT PRIMARY KEY,
    documento           VARCHAR(20)  NOT NULL,
    nombres             VARCHAR(100) NOT NULL,
    apellido_paterno    VARCHAR(100) NOT NULL,
    apellido_materno    VARCHAR(100),
    fecha_nacimiento    DATE,
    sexo                VARCHAR(1),
    telefono            VARCHAR(20),
    correo              VARCHAR(150),
    CONSTRAINT uq_persona_documento UNIQUE (documento)
) ENGINE=InnoDB;

CREATE TABLE paciente (
    id_paciente         BIGINT PRIMARY KEY,
    direccion           VARCHAR(200),
    estado              BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_paciente_persona FOREIGN KEY (id_paciente)
        REFERENCES persona(id_persona)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE empleado (
    id_empleado         BIGINT PRIMARY KEY,
    codigo_empleado     VARCHAR(20) NOT NULL,
    fecha_ingreso       DATE NOT NULL,
    estado              BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_empleado_codigo UNIQUE (codigo_empleado),
    CONSTRAINT fk_empleado_persona FOREIGN KEY (id_empleado)
        REFERENCES persona(id_persona)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE especialista (
    id_especialista     BIGINT PRIMARY KEY,
    especialidad        VARCHAR(100) NOT NULL,
    colegiatura         VARCHAR(30) NOT NULL,
    CONSTRAINT uq_especialista_colegiatura UNIQUE (colegiatura),
    CONSTRAINT fk_especialista_empleado FOREIGN KEY (id_especialista)
        REFERENCES empleado(id_empleado)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE rol (
    id_rol              BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(50) NOT NULL,
    descripcion         VARCHAR(200),
    estado              BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_rol_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE permiso (
    id_permiso          BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(50) NOT NULL,
    descripcion         VARCHAR(200),
    modulo              VARCHAR(50) NOT NULL,
    CONSTRAINT uq_permiso_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE rol_permiso (
    id_rol              BIGINT NOT NULL,
    id_permiso          BIGINT NOT NULL,
    PRIMARY KEY (id_rol, id_permiso),
    CONSTRAINT fk_rolpermiso_rol FOREIGN KEY (id_rol)
        REFERENCES rol(id_rol)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_rolpermiso_permiso FOREIGN KEY (id_permiso)
        REFERENCES permiso(id_permiso)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE usuario (
    id_usuario          BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_persona          BIGINT NOT NULL,
    id_rol              BIGINT NOT NULL,
    username            VARCHAR(50) NOT NULL,
    password            VARCHAR(255) NOT NULL,
    estado              BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_usuario_persona UNIQUE (id_persona),
    CONSTRAINT uq_usuario_username UNIQUE (username),
    CONSTRAINT fk_usuario_persona FOREIGN KEY (id_persona)
        REFERENCES persona(id_persona)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol)
        REFERENCES rol(id_rol)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE notificacion (
    id_notificacion     BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_usuario          BIGINT NOT NULL,
    titulo              VARCHAR(100) NOT NULL,
    mensaje             VARCHAR(500) NOT NULL,
    fecha               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo                VARCHAR(30),
    leida               BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_notificacion_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE horario_empleado (
    id_horario              BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_empleado             BIGINT NOT NULL,
    dia_semana              VARCHAR(10) NOT NULL,
    hora_inicio              TIME NOT NULL,
    hora_fin                 TIME NOT NULL,
    fecha_inicio_vigencia    DATE NOT NULL,
    fecha_fin_vigencia       DATE,
    estado                   BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_horario_empleado FOREIGN KEY (id_empleado)
        REFERENCES empleado(id_empleado)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_horario_rango CHECK (hora_fin > hora_inicio)
) ENGINE=InnoDB;

-- =====================================================================
-- B. PACIENTES Y SERVICIOS
-- =====================================================================

CREATE TABLE servicio_ecografia (
    id_servicio         BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    descripcion         VARCHAR(300),
    duracion_estimada   DECIMAL(5,2) NOT NULL,
    tarifa              DECIMAL(10,2) NOT NULL,
    estado              BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE solicitud_servicio (
    id_solicitud        BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_paciente         BIGINT NOT NULL,
    id_servicio         BIGINT NOT NULL,
    fecha_solicitud     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado              VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    observaciones       VARCHAR(300),
    CONSTRAINT fk_solicitud_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente(id_paciente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_solicitud_servicio FOREIGN KEY (id_servicio)
        REFERENCES servicio_ecografia(id_servicio)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================================
-- GESTIÓN DE CITAS
-- =====================================================================

CREATE TABLE estado_cita (
    id_estado_cita      BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(30) NOT NULL,
    descripcion         VARCHAR(200),
    CONSTRAINT uq_estadocita_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE sala (
    id_sala             BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(50) NOT NULL,
    ubicacion           VARCHAR(100),
    capacidad           INT,
    estado              VARCHAR(20) NOT NULL DEFAULT 'DISPONIBLE'
) ENGINE=InnoDB;

CREATE TABLE cita (
    id_cita             BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_solicitud        BIGINT,
    id_paciente         BIGINT NOT NULL,
    id_servicio         BIGINT NOT NULL,
    id_especialista     BIGINT NOT NULL,
    id_sala             BIGINT NOT NULL,
    id_estado_cita      BIGINT NOT NULL,
    fecha               DATE NOT NULL,
    hora_inicio         TIME NOT NULL,
    hora_fin            TIME NOT NULL,
    observaciones       VARCHAR(300),
    fecha_registro      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_cita_solicitud UNIQUE (id_solicitud),
    CONSTRAINT fk_cita_solicitud FOREIGN KEY (id_solicitud)
        REFERENCES solicitud_servicio(id_solicitud)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_cita_paciente FOREIGN KEY (id_paciente)
        REFERENCES paciente(id_paciente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cita_servicio FOREIGN KEY (id_servicio)
        REFERENCES servicio_ecografia(id_servicio)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cita_especialista FOREIGN KEY (id_especialista)
        REFERENCES especialista(id_especialista)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cita_sala FOREIGN KEY (id_sala)
        REFERENCES sala(id_sala)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cita_estado FOREIGN KEY (id_estado_cita)
        REFERENCES estado_cita(id_estado_cita)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_cita_horas CHECK (hora_fin > hora_inicio)
) ENGINE=InnoDB;

-- =====================================================================
-- C. ESPECIALISTAS
-- =====================================================================

CREATE TABLE asignacion_servicio_especialista (
    id_asignacion       BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_especialista     BIGINT NOT NULL,
    id_servicio         BIGINT NOT NULL,
    fecha_asignacion    DATE NOT NULL DEFAULT (CURRENT_DATE),
    estado              BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_asignacion_especialista_servicio UNIQUE (id_especialista, id_servicio),
    CONSTRAINT fk_asignacion_especialista FOREIGN KEY (id_especialista)
        REFERENCES especialista(id_especialista)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_asignacion_servicio FOREIGN KEY (id_servicio)
        REFERENCES servicio_ecografia(id_servicio)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- D. SALAS Y EQUIPOS
-- =====================================================================

CREATE TABLE estado_equipo (
    id_estado_equipo    BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(30) NOT NULL,
    descripcion         VARCHAR(200),
    CONSTRAINT uq_estadoequipo_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE equipo (
    id_equipo           BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_estado_equipo    BIGINT NOT NULL,
    codigo              VARCHAR(30) NOT NULL,
    nombre              VARCHAR(100) NOT NULL,
    tipo                VARCHAR(50),
    marca               VARCHAR(50),
    modelo              VARCHAR(50),
    numero_serie        VARCHAR(50),
    ubicacion           VARCHAR(100),
    fecha_adquisicion   DATE,
    CONSTRAINT uq_equipo_codigo UNIQUE (codigo),
    CONSTRAINT uq_equipo_serie UNIQUE (numero_serie),
    CONSTRAINT fk_equipo_estado FOREIGN KEY (id_estado_equipo)
        REFERENCES estado_equipo(id_estado_equipo)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE cita_equipo (
    id_cita             BIGINT NOT NULL,
    id_equipo           BIGINT NOT NULL,
    PRIMARY KEY (id_cita, id_equipo),
    CONSTRAINT fk_citaequipo_cita FOREIGN KEY (id_cita)
        REFERENCES cita(id_cita)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_citaequipo_equipo FOREIGN KEY (id_equipo)
        REFERENCES equipo(id_equipo)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE mantenimiento_equipo (
    id_mantenimiento    BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_equipo           BIGINT NOT NULL,
    tipo                VARCHAR(30) NOT NULL,
    fecha_programada    DATE,
    fecha_realizada     DATE,
    descripcion         VARCHAR(300),
    observaciones       VARCHAR(300),
    costo               DECIMAL(10,2),
    estado              VARCHAR(20) NOT NULL DEFAULT 'PROGRAMADO',
    CONSTRAINT fk_mantenimiento_equipo FOREIGN KEY (id_equipo)
        REFERENCES equipo(id_equipo)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- E. ATENCIÓN Y RESULTADOS
-- =====================================================================

CREATE TABLE estado_atencion (
    id_estado_atencion  BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(30) NOT NULL,
    descripcion         VARCHAR(200),
    CONSTRAINT uq_estadoatencion_nombre UNIQUE (nombre)
) ENGINE=InnoDB;

CREATE TABLE atencion (
    id_atencion             BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_cita                 BIGINT NOT NULL,
    id_estado_atencion      BIGINT NOT NULL,
    fecha_inicio             DATETIME,
    fecha_fin                DATETIME,
    observaciones_generales  VARCHAR(300),
    CONSTRAINT uq_atencion_cita UNIQUE (id_cita),
    CONSTRAINT fk_atencion_cita FOREIGN KEY (id_cita)
        REFERENCES cita(id_cita)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_atencion_estado FOREIGN KEY (id_estado_atencion)
        REFERENCES estado_atencion(id_estado_atencion)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE observacion_atencion (
    id_observacion      BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_atencion         BIGINT NOT NULL,
    descripcion         VARCHAR(300) NOT NULL,
    fecha_registro      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_observacion_atencion FOREIGN KEY (id_atencion)
        REFERENCES atencion(id_atencion)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE resultado_ecografia (
    id_resultado        BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_atencion         BIGINT NOT NULL,
    descripcion         VARCHAR(500),
    hallazgos           TEXT,
    conclusiones        TEXT,
    fecha_registro      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_resultado_atencion UNIQUE (id_atencion),
    CONSTRAINT fk_resultado_atencion FOREIGN KEY (id_atencion)
        REFERENCES atencion(id_atencion)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE informe_ecografia (
    id_informe               BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_atencion               BIGINT NOT NULL,
    fecha_elaboracion         DATETIME,
    fecha_finalizacion        DATETIME,
    estado                    VARCHAR(20) NOT NULL DEFAULT 'EN_ELABORACION',
    nombre_archivo             VARCHAR(150),
    tipo_archivo               VARCHAR(20),
    ruta_archivo               VARCHAR(300),
    fecha_entrega              DATETIME,
    CONSTRAINT uq_informe_atencion UNIQUE (id_atencion),
    CONSTRAINT fk_informe_atencion FOREIGN KEY (id_atencion)
        REFERENCES atencion(id_atencion)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- INVENTARIO
-- =====================================================================

CREATE TABLE insumo (
    id_insumo           BIGINT AUTO_INCREMENT PRIMARY KEY,
    codigo               VARCHAR(30) NOT NULL,
    nombre               VARCHAR(100) NOT NULL,
    descripcion          VARCHAR(300),
    unidad_medida        VARCHAR(20) NOT NULL,
    stock_actual         DECIMAL(10,2) NOT NULL DEFAULT 0,   -- mantenido por trigger
    stock_minimo         DECIMAL(10,2) NOT NULL DEFAULT 0,
    estado               BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_insumo_codigo UNIQUE (codigo)
) ENGINE=InnoDB;

CREATE TABLE movimiento_inventario (
    id_movimiento        BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_insumo            BIGINT NOT NULL,
    id_usuario            BIGINT NOT NULL,
    tipo                  VARCHAR(20) NOT NULL,
    cantidad              DECIMAL(10,2) NOT NULL,
    fecha                 DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo                VARCHAR(100),
    observaciones         VARCHAR(300),
    CONSTRAINT fk_movimiento_insumo FOREIGN KEY (id_insumo)
        REFERENCES insumo(id_insumo)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimiento_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_movimiento_tipo CHECK (tipo IN ('ENTRADA','SALIDA','CONSUMO','AJUSTE'))
) ENGINE=InnoDB;

-- =====================================================================
-- PROVEEDORES Y COMPRAS
-- =====================================================================

CREATE TABLE proveedor (
    id_proveedor        BIGINT AUTO_INCREMENT PRIMARY KEY,
    tipo_documento       VARCHAR(10) NOT NULL,
    documento            VARCHAR(20) NOT NULL,
    razon_social         VARCHAR(150) NOT NULL,
    contacto             VARCHAR(100),
    telefono             VARCHAR(20),
    correo               VARCHAR(150),
    direccion            VARCHAR(200),
    estado               BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_proveedor_documento UNIQUE (documento)
) ENGINE=InnoDB;

CREATE TABLE compra (
    id_compra            BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_proveedor          BIGINT NOT NULL,
    numero_compra          VARCHAR(30) NOT NULL,
    fecha_compra           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total                  DECIMAL(10,2) NOT NULL DEFAULT 0,   -- mantenido por trigger
    estado                 VARCHAR(20) NOT NULL DEFAULT 'REGISTRADA',
    CONSTRAINT uq_compra_numero UNIQUE (numero_compra),
    CONSTRAINT fk_compra_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES proveedor(id_proveedor)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE detalle_compra (
    id_detalle             BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_compra               BIGINT NOT NULL,
    id_insumo                BIGINT NOT NULL,
    cantidad                 DECIMAL(10,2) NOT NULL,
    precio_unitario           DECIMAL(10,2) NOT NULL,
    subtotal                  DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    CONSTRAINT fk_detalle_compra FOREIGN KEY (id_compra)
        REFERENCES compra(id_compra)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_insumo FOREIGN KEY (id_insumo)
        REFERENCES insumo(id_insumo)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================================
-- VENTAS / PAGOS
-- =====================================================================

CREATE TABLE comprobante_pago (
    id_comprobante         BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_cita                 BIGINT NOT NULL,
    tipo_comprobante         VARCHAR(20) NOT NULL,
    serie                    VARCHAR(10),
    numero                   VARCHAR(20),
    fecha_emision             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    concepto                  VARCHAR(200),
    subtotal                  DECIMAL(10,2) NOT NULL,
    descuento                 DECIMAL(10,2) NOT NULL DEFAULT 0,
    total                     DECIMAL(10,2) GENERATED ALWAYS AS (subtotal - descuento) STORED,
    estado                    VARCHAR(20) NOT NULL DEFAULT 'EMITIDO',
    CONSTRAINT uq_comprobante_cita UNIQUE (id_cita),
    CONSTRAINT fk_comprobante_cita FOREIGN KEY (id_cita)
        REFERENCES cita(id_cita)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =====================================================================
-- MARKETING
-- =====================================================================

CREATE TABLE promocion (
    id_promocion         BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre                 VARCHAR(100) NOT NULL,
    descripcion             VARCHAR(300),
    tipo_descuento           VARCHAR(20) NOT NULL,
    valor_descuento          DECIMAL(10,2) NOT NULL,
    fecha_inicio             DATE NOT NULL,
    fecha_fin                DATE NOT NULL,
    estado                   BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_promocion_tipo CHECK (tipo_descuento IN ('PORCENTAJE','MONTO_FIJO')),
    CONSTRAINT chk_promocion_fechas CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

CREATE TABLE promocion_servicio (
    id_promocion         BIGINT NOT NULL,
    id_servicio           BIGINT NOT NULL,
    PRIMARY KEY (id_promocion, id_servicio),
    CONSTRAINT fk_promoservicio_promocion FOREIGN KEY (id_promocion)
        REFERENCES promocion(id_promocion)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_promoservicio_servicio FOREIGN KEY (id_servicio)
        REFERENCES servicio_ecografia(id_servicio)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- Triggers de sincronizacion (compra.total, insumo.stock_actual) y
-- catalogos iniciales (estado_cita, estado_equipo, estado_atencion):
-- ver el script completo entregado por el usuario.
