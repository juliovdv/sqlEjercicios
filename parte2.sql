ALTER TABLE p5p2e4_procesamiento
    ADD CONSTRAINT CK_CANTIDAD_PROCESAMIENTOS
        CHECK ( NOT EXISTS(
                SELECT 1
                FROM p5p2e4_procesamiento
                GROUP BY id_paciente, id_imagen
                HAVING COUNT(*) > 5
            ))
;
-- B. Cada imagen de cada paciente no debe tener más de 5 procesamientos.
CREATE OR REPLACE FUNCTION FN_CANT_PROC_X_PACIENTE()
    RETURNS TRIGGER AS
$$
DECLARE
    nro_imagenes INTEGER;
BEGIN
    SELECT count(*)
    INTO nro_imagenes
    FROM p5p2e4_procesamiento p
    WHERE p.id_imagen = NEW.id_imagen
      AND p.id_paciente = NEW.id_paciente;

    IF nro_imagenes > 4 THEN
        RAISE EXCEPTION 'la imagen % del paciente % tiene muchos procesamientos', NEW.id_imagen, NEW.id_paciente;
    END IF;
    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER TR_CANT_PROC_X_PACIENTE
    BEFORE INSERT OR UPDATE OF id_imagen, id_paciente
    ON p5p2e4_procesamiento
    FOR EACH ROW
EXECUTE PROCEDURE FN_CANT_PROC_X_PACIENTE();

-- C. Agregue dos atributos de tipo fecha a las tablas Imagen_medica y Procesamiento,
-- una indica la fecha de la imagen y la otra la fecha de procesamiento de la imagen
-- y controle que la segunda no sea menor que la primera.
--TIPO GENERAL

/*
CREATE ASSERTION
   CHECK ( NOT EXISTS (
            select 1
            FROM p5p2e4_imagen_medica i JOIN p5p2e4_procesamiento p
            ON (i.id_paciente = p.id_paciente and i.id_imagen = p.id_imagen)
            WHERE fecha_proc < fecha_img )
   )
;
*/
/*
                            IMAGEN
*/
CREATE OR REPLACE FUNCTION FN_CTRL_FECHA_EN_IMG()
    RETURNS TRIGGER AS
$$
DECLARE

BEGIN
    IF (EXISTS(SELECT 1
            FROM P5P2E4_PROCESAMIENTO p
            WHERE (p.id_imagen = NEW.id_imagen AND p.id_paciente = NEW.id_paciente)
            AND p.fecha_procesamiento < NEW.fecha_imagen))
    THEN
        RAISE EXCEPTION 'fecha procesamiento menor que fecha imagen ';
    END IF;
    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';

--              ENCABEZADO
CREATE TRIGGER TR_CTRL_FECHA_EN_IMG
    BEFORE UPDATE OF fecha_imagen
    ON P5P2E4_IMAGEN_MEDICA
    FOR EACH ROW
EXECUTE PROCEDURE FN_CTRL_FECHA_EN_IMG();



/*
                            PROCESAMIENTO
*/
CREATE OR REPLACE FUNCTION FN_CTRL_FECHA_EN_PROC()
    RETURNS TRIGGER AS
$$
DECLARE

BEGIN

    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';

--              ENCABEZADO
CREATE TRIGGER TR_CTRL_FECHA_EN_PROC
    BEFORE INSERT OR UPDATE OF fecha_procesamiento, id_imagen, id_paciente
    ON P5P2E4_PROCESAMIENTO
    FOR EACH ROW
EXECUTE PROCEDURE FN_CTRL_FECHA_EN_PROC();

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-09-28 21:22:26.905

-- tables
-- Table: P5P2E4_ALGORITMO
CREATE TABLE P5P2E4_ALGORITMO
(
    id_algoritmo        int          NOT NULL,
    nombre_metadata     varchar(40)  NOT NULL,
    descripcion         varchar(256) NOT NULL,
    costo_computacional varchar(15)  NOT NULL,
    CONSTRAINT PK_P5P2E4_ALGORITMO PRIMARY KEY (id_algoritmo)
);

-- Table: P5P2E4_IMAGEN_MEDICA
CREATE TABLE P5P2E4_IMAGEN_MEDICA
(
    id_paciente       int          NOT NULL,
    id_imagen         int          NOT NULL,
    modalidad         varchar(80)  NOT NULL,
    descripcion       varchar(180) NOT NULL,
    descripcion_breve varchar(80)  NULL,
    CONSTRAINT PK_P5P2E4_IMAGEN_MEDICA PRIMARY KEY (id_paciente, id_imagen)
);

-- Table: P5P2E4_PACIENTE
CREATE TABLE P5P2E4_PACIENTE
(
    id_paciente      int          NOT NULL,
    apellido         varchar(80)  NOT NULL,
    nombre           varchar(80)  NOT NULL,
    domicilio        varchar(120) NOT NULL,
    fecha_nacimiento date         NOT NULL,
    CONSTRAINT PK_P5P2E4_PACIENTE PRIMARY KEY (id_paciente)
);

-- Table: P5P2E4_PROCESAMIENTO
CREATE TABLE P5P2E4_PROCESAMIENTO
(
    id_algoritmo  int            NOT NULL,
    id_paciente   int            NOT NULL,
    id_imagen     int            NOT NULL,
    nro_secuencia int            NOT NULL,
    parametro     decimal(15, 3) NOT NULL,
    CONSTRAINT PK_P5P2E4_PROCESAMIENTO PRIMARY KEY (id_algoritmo, id_paciente, id_imagen, nro_secuencia)
);

-- foreign keys
-- Reference: FK_P5P2E4_IMAGEN_MEDICA_PACIENTE (table: P5P2E4_IMAGEN_MEDICA)
ALTER TABLE P5P2E4_IMAGEN_MEDICA
    ADD CONSTRAINT FK_P5P2E4_IMAGEN_MEDICA_PACIENTE
        FOREIGN KEY (id_paciente)
            REFERENCES P5P2E4_PACIENTE (id_paciente)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

ALTER TABLE P5P2E4_PROCESAMIENTO
    ADD COLUMN fecha_procesamiento Date;

-- Reference: FK_P5P2E4_PROCESAMIENTO_ALGORITMO (table: P5P2E4_PROCESAMIENTO)
ALTER TABLE P5P2E4_PROCESAMIENTO
    ADD CONSTRAINT FK_P5P2E4_PROCESAMIENTO_ALGORITMO
        FOREIGN KEY (id_algoritmo)
            REFERENCES P5P2E4_ALGORITMO (id_algoritmo)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

-- Reference: FK_P5P2E4_PROCESAMIENTO_IMAGEN_MEDICA (table: P5P2E4_PROCESAMIENTO)
ALTER TABLE P5P2E4_PROCESAMIENTO
    ADD CONSTRAINT FK_P5P2E4_PROCESAMIENTO_IMAGEN_MEDICA
        FOREIGN KEY (id_paciente, id_imagen)
            REFERENCES P5P2E4_IMAGEN_MEDICA (id_paciente, id_imagen)
            NOT DEFERRABLE
                INITIALLY IMMEDIATE
;

-- End of file.