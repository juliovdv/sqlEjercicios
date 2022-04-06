-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2021-06-30 20:02:38.072

-- tables
-- Table: GR02_GRUPO
CREATE TABLE GR02_GRUPO (
    nro_grupo int  NOT NULL,
    nombre_grupo varchar(40)  NOT NULL,
    limite_integrantes int  NOT NULL,
    tipo_gr char(1)  NOT NULL,
    CONSTRAINT PK_GR02_GRUPO PRIMARY KEY (nro_grupo)
);

-- Table: GR02_GR_COMUN
CREATE TABLE GR02_GR_COMUN (
    nro_grupo int  NOT NULL,
    caracteristica varchar(30)  NOT NULL,
    CONSTRAINT PK_GR02_GR_COMUN PRIMARY KEY (nro_grupo)
);

-- Table: GR02_GR_EXCLUSIVO
CREATE TABLE GR02_GR_EXCLUSIVO (
    nro_grupo int  NOT NULL,
    perfil varchar(30)  NOT NULL,
    CONSTRAINT PK_GR02_GR_EXCLUSIVO PRIMARY KEY (nro_grupo)
);

-- Table: GR02_INTEGRA
CREATE TABLE GR02_INTEGRA (
    tipo_usuario char(3)  NOT NULL,
    cod_usuario int  NOT NULL,
    nro_grupo int  NOT NULL,
    fecha date  NOT NULL,
    CONSTRAINT PK_GR02_INTEGRA PRIMARY KEY (tipo_usuario,cod_usuario,nro_grupo)
);

-- Table: GR02_USUARIO
CREATE TABLE GR02_USUARIO (
    tipo_usuario char(3)  NOT NULL,
    cod_usuario int  NOT NULL,
    apellido varchar(30)  NOT NULL,
    nombre varchar(30)  NOT NULL,
    nick varchar(15)  NULL,
    CONSTRAINT PK_GR02_USUARIO PRIMARY KEY (tipo_usuario,cod_usuario)
);

-- foreign keys
-- Reference: FK_GR02_GR_COMUN_GRUPO (table: GR02_GR_COMUN)
ALTER TABLE GR02_GR_COMUN ADD CONSTRAINT FK_GR02_GR_COMUN_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GR02_GRUPO (nro_grupo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_GR02_GR_EXCLUSIVO_GRUPO (table: GR02_GR_EXCLUSIVO)
ALTER TABLE GR02_GR_EXCLUSIVO ADD CONSTRAINT FK_GR02_GR_EXCLUSIVO_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GR02_GRUPO (nro_grupo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_GR02_INTEGRA_GRUPO (table: GR02_INTEGRA)
ALTER TABLE GR02_INTEGRA ADD CONSTRAINT FK_GR02_INTEGRA_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GR02_GRUPO (nro_grupo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_GR02_INTEGRA_USUARIO (table: GR02_INTEGRA)
ALTER TABLE GR02_INTEGRA ADD CONSTRAINT FK_GR02_INTEGRA_USUARIO
    FOREIGN KEY (tipo_usuario, cod_usuario)
    REFERENCES GR02_USUARIO (tipo_usuario, cod_usuario)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- End of file.