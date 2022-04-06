/*
                EJERCICIO 1
*/
-- Cada palabra clave puede aparecer como máximo en 5 artículos.

CREATE OR REPLACE FUNCTION FN_CANT_PALABRA_EN_ARTICULO()
    RETURNS TRIGGER AS
$$
DECLARE
    nro_palabras INTEGER;
BEGIN
    SELECT count(*)
    INTO nro_palabras
    FROM p5p1e1_contiene c
    WHERE c.cod_palabra = NEW.cod_palabra
      AND c.idioma = NEW.idioma;

    IF nro_palabras > 4 THEN
        RAISE EXCEPTION 'la palabra ya esta en 5 articulos';
    END IF;
    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER TR_CANT_PALABRA_EN_ARTICULO
    BEFORE INSERT OR UPDATE OF cod_palabra, idioma
    ON p5p1e1_contiene
    FOR EACH ROW
EXECUTE PROCEDURE FN_CANT_PALABRA_EN_ARTICULO();

--Sólo los autores argentinos pueden publicar artículos que contengan más de 10 palabras
--claves, pero con un tope de 15 palabras, el resto de los autores sólo pueden publicar
--artículos que contengan hasta 10 palabras claves.

CREATE OR REPLACE FUNCTION FN_MAX_PALABRAS_ARTICULO_NACIONALIDAD()
    RETURNS TRIGGER AS
$$
DECLARE
    nro_palabras INTEGER;
    nacionalidad TEXT;
BEGIN

    SELECT nacionalidad
    INTO nacionalidad
    FROM p5p1e1_articulo a
    WHERE a.id_articulo = NEW.id_articulo;

    SELECT count(*)
    INTO nro_palabras
    FROM p5p1e1_contiene
    WHERE id_articulo = NEW.id_articulo;

    IF (nacionalidad != 'Argentino' AND nro_palabras > 9) OR
       (nacionalidad = 'Argentino' AND nro_palabras > 14)
    THEN
        RAISE EXCEPTION 'el articulo ya alcanzo su maximo de palabras';
    END IF;

    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';


CREATE TRIGGER TR_MAX_PALABRAS_ARTICULO_NACIONALIDAD
    BEFORE INSERT OR UPDATE OF id_articulo
    ON p5p1e1_contiene
    FOR EACH ROW
EXECUTE PROCEDURE FN_MAX_PALABRAS_ARTICULO_NACIONALIDAD();


CREATE OR REPLACE FUNCTION FN_NACIONALIDAD_ARTICULO()
    RETURNS TRIGGER AS
$$
DECLARE
    nro_palabras INTEGER;
BEGIN

    SELECT count(*)
    INTO nro_palabras
    FROM p5p1e1_contiene
    WHERE id_articulo = NEW.id_articulo;

    IF nro_palabras > 10 AND NEW.nacionalidad != 'Argentino' THEN
        RAISE EXCEPTION 'este articulo tiene mas palabras de lo permitido';
    END IF;

    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';


CREATE TRIGGER TR_NACIONALIDAD_ARTICULO
    BEFORE UPDATE OF nacionalidad
    ON p5p1e1_articulo
    FOR EACH ROW
EXECUTE PROCEDURE FN_NACIONALIDAD_ARTICULO();




/*
                EJERCICIO 2
*/
-- 4.B. Cada imagen de cada paciente no debe tener más de 5 procesamientos.
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
        RAISE EXCEPTION 'la imagen % del paciente % ya tiene 5 procesamientos', NEW.id_imagen, NEW.id_paciente;
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

-- 4.C. Agregue dos atributos de tipo fecha a las tablas Imagen_medica y Procesamiento,
-- una indica la fecha de la imagen y la otra la fecha de procesamiento de la imagen
-- y controle que la segunda no sea menor que la primera.
--     TIPO GENERAL

/*
                            IMAGEN
*/
CREATE OR REPLACE FUNCTION FN_CTRL_FECHA_EN_IMG()
    RETURNS TRIGGER AS
$$
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


------------------------------------------------------------
CREATE OR REPLACE FUNCTION ...
    RETURNS TRIGGER AS
$$
DECLARE

BEGIN

END






$$
    LANGUAGE 'plpgsql';



CREATE TRIGGER ...
    BEFORE
INSERT OR
UPDATE OF ...
    ON ...
    FOR EACH ROW
EXECUTE PROCEDURE ...;