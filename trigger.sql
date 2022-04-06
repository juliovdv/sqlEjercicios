ALTER TABLE p5p2e4_procesamiento
    ADD CONSTRAINT CK_CANTIDAD_PROCESAMIENTOS
        CHECK ( NOT EXISTS(
                SELECT 1
                FROM p5p2e4_procesamiento
                GROUP BY id_paciente, id_imagen
                HAVING COUNT(*) > 5
            ))
;
-- B. Cada imagen de cada paciente no debe tener mÃ¡s de 5 procesamientos.
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

