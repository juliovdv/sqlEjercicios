-----------------------TRABAJO PRACTICO ESPECIAL

---- A. TRIGGERS y SERVICIOS
---- 1.

ALTER TABLE gr02_usuario ADD COLUMN cantidad_grupos_comun int;
ALTER TABLE gr02_usuario ADD COLUMN cantidad_grupos_exclusivo int;
ALTER TABLE gr02_integra ADD COLUMN integra boolean;

UPDATE gr02_usuario SET cantidad_grupos_comun = 0, cantidad_grupos_exclusivo = 0;


CREATE OR REPLACE FUNCTION FN_GR02_GRUPOS_QUE_INTEGRA()
    RETURNS TRIGGER AS
$$
DECLARE
    usuario_grupo record;
BEGIN

    IF (TG_OP = 'INSERT') THEN
        FOR usuario_grupo IN
            SELECT nt.tipo_usuario, nt.cod_usuario, nt.nro_grupo, g02g.tipo_gr
            FROM new_table nt
                     JOIN gr02_grupo g02g ON nt.nro_grupo = g02g.nro_grupo
            WHERE nt.integra = TRUE
            LOOP
                IF usuario_grupo.tipo_gr = 'C' THEN
                    UPDATE gr02_usuario
                    SET cantidad_grupos_comun = cantidad_grupos_comun + 1
                    WHERE tipo_usuario = usuario_grupo.tipo_usuario
                      AND cod_usuario = usuario_grupo.cod_usuario;
                ELSE
                    UPDATE gr02_usuario
                    SET cantidad_grupos_exclusivos = gr02_usuario.cantidad_grupos_exclusivos + 1
                    WHERE tipo_usuario = usuario_grupo.tipo_usuario
                      AND cod_usuario = usuario_grupo.cod_usuario;
                END IF;
            END LOOP;
    ELSEIF (TG_OP = 'UPDATE') THEN
        FOR usuario_grupo IN
            SELECT nt.tipo_usuario, nt.cod_usuario, nt.nro_grupo, g02g.tipo_gr
            FROM new_table nt
                     JOIN gr02_grupo g02g ON nt.nro_grupo = g02g.nro_grupo
            WHERE nt.integra = TRUE
            LOOP
                IF usuario_grupo.tipo_gr = 'C' THEN
                    UPDATE gr02_usuario
                    SET cantidad_grupos_comun = cantidad_grupos_comun + 1
                    WHERE tipo_usuario = usuario_grupo.tipo_usuario
                      AND cod_usuario = usuario_grupo.cod_usuario;
                ELSE
                    UPDATE gr02_usuario
                    SET cantidad_grupos_exclusivos = gr02_usuario.cantidad_grupos_exclusivos + 1
                    WHERE tipo_usuario = usuario_grupo.tipo_usuario
                      AND cod_usuario = usuario_grupo.cod_usuario;
                END IF;
            END LOOP;
        FOR usuario_grupo IN
            SELECT ot.tipo_usuario, ot.cod_usuario, ot.nro_grupo, g02g.tipo_gr
            FROM old_table ot
                     JOIN gr02_grupo g02g ON ot.nro_grupo = g02g.nro_grupo
            WHERE ot.integra = TRUE
            LOOP
                IF usuario_grupo.tipo_gr = 'C' THEN
                    UPDATE gr02_usuario
                    SET cantidad_grupos_comun = cantidad_grupos_comun - 1
                    WHERE tipo_usuario = usuario_grupo.tipo_usuario
                      AND cod_usuario = usuario_grupo.cod_usuario;
                ELSE
                    UPDATE gr02_usuario
                    SET cantidad_grupos_exclusivos = gr02_usuario.cantidad_grupos_exclusivos - 1
                    WHERE tipo_usuario = usuario_grupo.tipo_usuario
                      AND cod_usuario = usuario_grupo.cod_usuario;
                END IF;
            END LOOP;
    ELSEIF (TG_OP = 'DELETE') THEN
        FOR usuario_grupo IN
            SELECT ot.tipo_usuario, ot.cod_usuario, ot.nro_grupo, g02g.tipo_gr
            FROM old_table ot
                     JOIN gr02_grupo g02g ON ot.nro_grupo = g02g.nro_grupo
            WHERE ot.integra = TRUE
            LOOP
                IF usuario_grupo.tipo_gr = 'C' THEN
                    UPDATE gr02_usuario
                    SET cantidad_grupos_comun = cantidad_grupos_comun - 1
                    WHERE tipo_usuario = usuario_grupo.tipo_usuario
                      AND cod_usuario = usuario_grupo.cod_usuario;
                ELSE
                    UPDATE gr02_usuario
                    SET cantidad_grupos_exclusivos = gr02_usuario.cantidad_grupos_exclusivos - 1
                    WHERE tipo_usuario = usuario_grupo.tipo_usuario
                      AND cod_usuario = usuario_grupo.cod_usuario;
                END IF;
            END LOOP;

    END IF;
    RETURN NEW;
END ;
$$
    LANGUAGE 'plpgsql';


CREATE TRIGGER TR_GR02_GRUPOS_QUE_INTEGRA_INS
    AFTER INSERT
    ON gr02_integra
    REFERENCING NEW TABLE AS new_table
    FOR EACH STATEMENT
EXECUTE PROCEDURE FN_GR02_GRUPOS_QUE_INTEGRA();

CREATE TRIGGER TR_GR02_GRUPOS_QUE_INTEGRA_DEL
    AFTER DELETE
    ON gr02_integra
    REFERENCING OLD TABLE AS old_table
    FOR EACH STATEMENT
EXECUTE PROCEDURE FN_GR02_GRUPOS_QUE_INTEGRA();

CREATE TRIGGER TR_GR02_GRUPOS_QUE_INTEGRA_UPD
    AFTER UPDATE
    ON gr02_integra
    REFERENCING NEW TABLE AS new_table
        OLD TABLE AS old_table
    FOR EACH STATEMENT
EXECUTE PROCEDURE FN_GR02_GRUPOS_QUE_INTEGRA();


INSERT INTO gr02_integra (tipo_usuario, cod_usuario, nro_grupo, fecha, integra)
VALUES ('B', 1, 4, '2021-06-17', 'True'),
       ('B', 1, 3, '2021-06-17', 'True'),
       ('B', 1, 1, '2021-06-17', 'True')
       ;
DELETE FROM gr02_integra WHERE tipo_usuario = 'B' AND cod_usuario = 1;
---- 2.


------ CREACION DE VISTAS
CREATE VIEW GR02_V_GRUPO_COMUN
AS
SELECT g02g.nro_grupo, nombre_grupo, limite_integrantes, tipo_gr, caracteristica
FROM gr02_gr_comun g02gc JOIN gr02_grupo g02g on g02g.nro_grupo = g02gc.nro_grupo;

CREATE VIEW GR02_V_GRUPO_EXCLUSIVO
AS
SELECT g02g.nro_grupo, nombre_grupo, limite_integrantes, tipo_gr, perfil
FROM gr02_gr_exclusivo g02ge  JOIN gr02_grupo g02g on g02g.nro_grupo = g02ge.nro_grupo;


------ FUNCIONES
CREATE OR REPLACE FUNCTION FN_GR02_V_GRUPO_COMUN()
    RETURNS TRIGGER AS
$$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO gr02_grupo (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr)
        VALUES (NEW.nro_grupo, NEW.nombre_grupo, NEW.limite_integrantes, 'C');
        INSERT INTO gr02_gr_comun (nro_grupo, caracteristica)
        VALUES (NEW.nro_grupo, NEW.caracteristica);
    ELSEIF (tg_op = 'UPDATE') THEN
        IF new.tipo_gr = (SELECT tipo_gr FROM gr02_grupo WHERE nro_grupo = NEW.nro_grupo) THEN
            UPDATE gr02_grupo
            SET nro_grupo          = NEW.nro_grupo,
                nombre_grupo       = NEW.nombre_grupo,
                limite_integrantes = NEW.limite_integrantes
            WHERE nro_grupo = NEW.nro_grupo;
            UPDATE gr02_gr_comun
            SET nro_grupo      = NEW.nro_grupo,
                caracteristica = NEW.caracteristica
            WHERE nro_grupo = NEW.nro_grupo;
        ELSE
            DELETE FROM gr02_gr_comun WHERE nro_grupo = NEW.nro_grupo;
            UPDATE gr02_grupo
            SET nro_grupo          = NEW.nro_grupo,
                nombre_grupo       = NEW.nombre_grupo,
                limite_integrantes = NEW.limite_integrantes,
                tipo_gr = NEW.tipo_gr
            WHERE nro_grupo = NEW.nro_grupo;
            INSERT INTO gr02_gr_exclusivo (nro_grupo, perfil)
        VALUES (NEW.nro_grupo, NEW.caracteristica);

        END IF;
    ELSEIF (tg_op = 'DELETE') THEN
        DELETE FROM gr02_gr_comun WHERE nro_grupo = OLD.nro_grupo;
        DELETE FROM gr02_grupo WHERE nro_grupo = OLD.nro_grupo;
    END IF;
    RETURN NULL;
END;
$$
    LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION FN_GR02_V_GRUPO_EXCLUSIVO()
    RETURNS TRIGGER AS
$$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO gr02_grupo (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr)
        VALUES (NEW.nro_grupo, NEW.nombre_grupo, NEW.limite_integrantes, 'E');
        INSERT INTO gr02_gr_exclusivo (nro_grupo, perfil)
        VALUES (NEW.nro_grupo, NEW.perfil);
    ELSEIF (tg_op = 'UPDATE') THEN
        IF new.tipo_gr = (SELECT tipo_gr FROM gr02_grupo WHERE nro_grupo = NEW.nro_grupo) THEN
            UPDATE gr02_grupo
            SET nro_grupo          = NEW.nro_grupo,
                nombre_grupo       = NEW.nombre_grupo,
                limite_integrantes = NEW.limite_integrantes
            WHERE nro_grupo = NEW.nro_grupo;
            UPDATE gr02_gr_exclusivo
            SET nro_grupo      = NEW.nro_grupo,
                perfil = NEW.perfil
            WHERE nro_grupo = NEW.nro_grupo;
        ELSE
            DELETE FROM gr02_gr_exclusivo WHERE nro_grupo = NEW.nro_grupo;
            UPDATE gr02_grupo
            SET nro_grupo          = NEW.nro_grupo,
                nombre_grupo       = NEW.nombre_grupo,
                limite_integrantes = NEW.limite_integrantes,
                tipo_gr = NEW.tipo_gr
            WHERE nro_grupo = NEW.nro_grupo;
            INSERT INTO gr02_gr_comun (nro_grupo, caracteristica)
        VALUES (NEW.nro_grupo, NEW.perfil);

        END IF;
    ELSEIF (tg_op = 'DELETE') THEN
        DELETE FROM gr02_gr_exclusivo WHERE nro_grupo = OLD.nro_grupo;
        DELETE FROM gr02_grupo WHERE nro_grupo = OLD.nro_grupo;
    END IF;
    RETURN NULL;
END;
$$
    LANGUAGE 'plpgsql';


-----TRIGGERS

CREATE TRIGGER TR_GR02_V_GRUPO_COMUN
    INSTEAD OF INSERT OR UPDATE OR DELETE
    ON GR02_V_GRUPO_COMUN
    FOR EACH ROW
    EXECUTE PROCEDURE FN_GR02_V_GRUPO_COMUN();

CREATE TRIGGER TR_GR02_V_GRUPO_EXCLUSIVO
    INSTEAD OF INSERT OR UPDATE
    ON GR02_V_GRUPO_EXCLUSIVO
    FOR EACH ROW
    EXECUTE PROCEDURE FN_GR02_V_GRUPO_EXCLUSIVO();


-----SENTENCIAS DE PRUEBA A.2

INSERT INTO GR02_V_GRUPO_COMUN (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr, caracteristica)
VALUES (4, 'DDD', 15, 'C', 'Comun');

DELETE FROM GR02_V_GRUPO_COMUN WHERE nro_grupo = 3;

UPDATE GR02_V_GRUPO_COMUN
SET nro_grupo          = 1,
    nombre_grupo       = 'ZZZ',
    limite_integrantes = 8,
    tipo_gr            = 'E',
    caracteristica     = 'Modificado'
WHERE nro_grupo = 1;

INSERT INTO GR02_V_GRUPO_EXCLUSIVO (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr, perfil)
VALUES (5, 'DDD', 15, 'E', 'Exclusivo');

DELETE FROM GR02_V_GRUPO_EXCLUSIVO WHERE nro_grupo = 3;

UPDATE GR02_V_GRUPO_EXCLUSIVO
SET nro_grupo          = 1,
    nombre_grupo       = 'ZZZ',
    limite_integrantes = 8,
    tipo_gr            = 'C',
    perfil     = 'Modificado'
WHERE nro_grupo = 1;

SELECT *
FROM GR02_V_GRUPO_COMUN;
SELECT *
FROM GR02_V_GRUPO_EXCLUSIVO;
SELECT *
FROM gr02_gr_comun;
SELECT *
FROM GR02_GRUPO;
SELECT *
FROM gr02_gr_exclusivo;



---- B. VISTAS
---- 1.
CREATE VIEW GR02_V_GRUPOS_COMP
AS
SELECT *
FROM GR02_GRUPO
WHERE nro_grupo IN (
    SELECT nro_grupo
    FROM GR02_INTEGRA
    GROUP BY nro_grupo
    HAVING count(*) = (
        SELECT count(*)
        FROM GR02_USUARIO));

---- 2.
CREATE OR REPLACE VIEW GR02_V_GRUPOS_INTEG
AS
SELECT *
FROM (SELECT g02g.nro_grupo,g02g.nombre_grupo, g02g.tipo_gr, g02g.limite_integrantes, g02tg.caracteristica, g02tg.perfil, cant_usuario
      FROM gr02_grupo g02g
               LEFT JOIN (
          SELECT nro_grupo, caracteristica, null as perfil
          FROM gr02_gr_comun
          UNION
          SELECT nro_grupo, null, perfil
          FROM gr02_gr_exclusivo) AS g02tg
                    ON g02g.nro_grupo = g02tg.nro_grupo
               LEFT JOIN (SELECT i.nro_grupo, COUNT(*) AS cant_usuario FROM gr02_integra i JOIN gr02_grupo g on i.nro_grupo = g.nro_grupo GROUP BY i.nro_grupo) AS cu
                    ON g02g.nro_grupo = cu.nro_grupo) AS grupo;

SELECT * FROM GR02_V_GRUPOS_INTEG;

SELECT *
FROM (SELECT g02g.nro_grupo,g02g.nombre_grupo, g02g.tipo_gr, g02g.limite_integrantes, g02tg.caracteristica, g02tg.perfil
      FROM gr02_grupo g02g
               LEFT JOIN (
          SELECT nro_grupo, caracteristica, null as perfil
          FROM gr02_gr_comun
          UNION
          SELECT nro_grupo, null, perfil
          FROM gr02_gr_exclusivo) AS g02tg
                    ON g02g.nro_grupo = g02tg.nro_grupo
               LEFT JOIN gr02_integra i
                    ON g02g.nro_grupo = i.nro_grupo);

