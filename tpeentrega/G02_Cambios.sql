--Creacion de los atributos solicitados
ALTER TABLE gr02_usuario
    ADD COLUMN cantidad_grupos_comun int DEFAULT 0,
    ADD COLUMN cantidad_grupos_excl  int DEFAULT 0;

ALTER TABLE gr02_integra
    ADD COLUMN activo boolean;

/*
 Establecemos la siguiente/s funcion/es y trigger/s para el suspuesto caso de que existan
 valores en las tablas que han sido cargados ántes de ejecutar lo solicitado por la cátedra.
 */

CREATE OR REPLACE FUNCTION fn_gr02_generar_consistencia() RETURNS VOID AS
$$
DECLARE
    valor_grComun record;
    valor_grExcl  record;
BEGIN
    UPDATE gr02_usuario
    SET cantidad_grupos_comun = 0, cantidad_grupos_excl = 0
    WHERE cod_usuario >= 0;

    FOR valor_grComun IN (SELECT i.tipo_usuario, i.cod_usuario, COUNT(*) AS total
                          FROM gr02_integra i
                                   JOIN gr02_grupo g ON
                              g.nro_grupo = i.nro_grupo
                          WHERE i.activo = true
                            AND g.tipo_gr = 'c'
                          GROUP BY i.tipo_usuario, i.cod_usuario)
        LOOP
            UPDATE gr02_usuario u
            SET cantidad_grupos_comun = valor_grComun.total
            WHERE u.cod_usuario = valor_grComun.cod_usuario
              AND u.tipo_usuario = valor_grComun.tipo_usuario;
        END LOOP;

    FOR valor_grExcl IN (SELECT i.tipo_usuario, i.cod_usuario, COUNT(*) AS total
                         FROM gr02_integra i
                                  JOIN gr02_grupo g ON
                             g.nro_grupo = i.nro_grupo
                         WHERE i.activo = true
                           AND g.tipo_gr = 'e'
                         GROUP BY i.tipo_usuario, i.cod_usuario)
        LOOP
            UPDATE gr02_usuario u
            SET cantidad_grupos_excl = valor_grExcl.total
            WHERE u.cod_usuario = valor_grExcl.cod_usuario
              AND u.tipo_usuario = valor_grExcl.tipo_usuario;
        END LOOP;
END;
$$
    LANGUAGE 'plpgsql';

--La siguiente instruccion actualiza los atributos de cantidades en caso de estar precargados,
-- solicitados en el primer ejercicio del tpe.
-- SELECT fn_gr02_generar_consistencia();

----------------------------------------------------------------------------------------------------------

--La siguiente funcion evita cambiar el tipo de grupo una vez cargado
CREATE OR REPLACE FUNCTION trfn_gr02_modificar_tipo_grupo() RETURNS TRIGGER AS
$$
BEGIN
    IF (NEW.tipo_gr <> OLD.tipo_gr) THEN
        RAISE EXCEPTION 'ERROR, NO PUEDE SER MODIFICADO EL TIPO';
    END IF;
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER tr_gr02_modificar_tipo_grupo
    BEFORE UPDATE OF tipo_gr
    ON gr02_grupo
    FOR EACH ROW
EXECUTE PROCEDURE trfn_gr02_modificar_tipo_grupo();

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/*
                                              EJER 1 TPE

Se le agrega la columna cantidad_grupos_comun (cantidad de grupos comunes) y
cantidad_grupos_excl (cantidad de grupos exclusivos) a la tabla USUARIO y la columna
activo a la tabla INTEGRA. Es necesario mantener actualizada las columnas
cantidad_grupos_comun y cantidad_grupos_excl con la cantidad de grupos comunes y
excluivos activos que pertenece cada usuario (es decir que el campo activo está en true).
Se debe realizar con triggers FOR STATEMENT.
*/

CREATE OR REPLACE FUNCTION trfn_gr02_actualizar_usuarios() RETURNS TRIGGER AS
$$
DECLARE
    valor_grComun record;
    valor_grExcl  record;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        FOR valor_grComun IN (SELECT nt.tipo_usuario, nt.cod_usuario, COUNT(*) AS total
                              FROM tabla_nueva nt
                                       JOIN gr02_grupo g ON
                                  g.nro_grupo = nt.nro_grupo
                              WHERE nt.activo = true
                                AND g.tipo_gr = 'c'
                              GROUP BY nt.tipo_usuario, nt.cod_usuario)
            LOOP
                UPDATE gr02_usuario u
                SET cantidad_grupos_comun = cantidad_grupos_comun + valor_grComun.total
                WHERE u.cod_usuario = valor_grComun.cod_usuario
                  AND u.tipo_usuario = valor_grComun.tipo_usuario;
            END LOOP;

        FOR valor_grExcl IN (SELECT nt.tipo_usuario, nt.cod_usuario, COUNT(*) AS total
                             FROM tabla_nueva nt
                                      JOIN gr02_grupo g ON
                                 g.nro_grupo = nt.nro_grupo
                             WHERE nt.activo = true
                               AND g.tipo_gr = 'e'
                             GROUP BY nt.tipo_usuario, nt.cod_usuario)
            LOOP
                UPDATE gr02_usuario u
                SET cantidad_grupos_excl = cantidad_grupos_excl + valor_grExcl.total
                WHERE u.cod_usuario = valor_grExcl.cod_usuario
                  AND u.tipo_usuario = valor_grExcl.tipo_usuario;
            END LOOP;
        RETURN NULL;
    END IF;

    IF (TG_OP = 'DELETE') THEN
        FOR valor_grComun IN (SELECT od.tipo_usuario, od.cod_usuario, COUNT(*) AS total
                              FROM tabla_vieja od
                                       JOIN gr02_grupo g ON
                                  g.nro_grupo = od.nro_grupo
                              WHERE od.activo = true
                                AND g.tipo_gr = 'c'
                              GROUP BY od.tipo_usuario, od.cod_usuario)
            LOOP
                UPDATE gr02_usuario u
                SET cantidad_grupos_comun = cantidad_grupos_comun - valor_grComun.total
                WHERE u.cod_usuario = valor_grComun.cod_usuario
                  AND u.tipo_usuario = valor_grComun.tipo_usuario;
            END LOOP;

        FOR valor_grExcl IN (SELECT od.tipo_usuario, od.cod_usuario, COUNT(*) AS total
                             FROM tabla_vieja od
                                      JOIN gr02_grupo g ON
                                 g.nro_grupo = od.nro_grupo
                             WHERE od.activo = true
                               AND g.tipo_gr = 'e'
                             GROUP BY od.tipo_usuario, od.cod_usuario)
            LOOP
                UPDATE gr02_usuario u
                SET cantidad_grupos_excl = cantidad_grupos_excl - valor_grExcl.total
                WHERE u.cod_usuario = valor_grExcl.cod_usuario
                  AND u.tipo_usuario = valor_grExcl.tipo_usuario;
            END LOOP;
        RETURN NULL;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        FOR valor_grComun IN (SELECT nt.tipo_usuario, nt.cod_usuario, COUNT(*) AS total
                              FROM tabla_nueva nt
                                       JOIN gr02_grupo g ON
                                  g.nro_grupo = nt.nro_grupo
                              WHERE nt.activo = true
                                AND g.tipo_gr = 'c'
                              GROUP BY nt.tipo_usuario, nt.cod_usuario)
            LOOP
                UPDATE gr02_usuario u
                SET cantidad_grupos_comun = cantidad_grupos_comun + valor_grComun.total
                WHERE u.cod_usuario = valor_grComun.cod_usuario
                  AND u.tipo_usuario = valor_grComun.tipo_usuario;
            END LOOP;

        FOR valor_grExcl IN (SELECT nt.tipo_usuario, nt.cod_usuario, COUNT(*) AS total
                             FROM tabla_nueva nt
                                      JOIN gr02_grupo g ON
                                 g.nro_grupo = nt.nro_grupo
                             WHERE nt.activo = true
                               AND g.tipo_gr = 'e'
                             GROUP BY nt.tipo_usuario, nt.cod_usuario)
            LOOP
                UPDATE gr02_usuario u
                SET cantidad_grupos_excl = cantidad_grupos_excl + valor_grExcl.total
                WHERE u.cod_usuario = valor_grExcl.cod_usuario
                  AND u.tipo_usuario = valor_grExcl.tipo_usuario;
            END LOOP;

        FOR valor_grComun IN (SELECT ot.tipo_usuario, ot.cod_usuario, COUNT(*) AS total
                              FROM tabla_vieja ot
                                       JOIN gr02_grupo g ON
                                  g.nro_grupo = ot.nro_grupo
                              WHERE ot.activo = true
                                AND g.tipo_gr = 'c'
                              GROUP BY ot.tipo_usuario, ot.cod_usuario)
            LOOP
                UPDATE gr02_usuario u
                SET cantidad_grupos_comun = cantidad_grupos_comun - valor_grComun.total
                WHERE u.cod_usuario = valor_grComun.cod_usuario
                  AND u.tipo_usuario = valor_grComun.tipo_usuario;
            END LOOP;

        FOR valor_grExcl IN (SELECT ot.tipo_usuario, ot.cod_usuario, COUNT(*) AS total
                             FROM tabla_vieja ot
                                      JOIN gr02_grupo g ON
                                 g.nro_grupo = ot.nro_grupo
                             WHERE ot.activo = true
                               AND g.tipo_gr = 'e'
                             GROUP BY ot.tipo_usuario, ot.cod_usuario)
            LOOP
                UPDATE gr02_usuario u
                SET cantidad_grupos_excl = cantidad_grupos_excl - valor_grExcl.total
                WHERE u.cod_usuario = valor_grExcl.cod_usuario
                  AND u.tipo_usuario = valor_grExcl.tipo_usuario;
            END LOOP;
        RETURN NULL;
    END IF;
END;
$$
    LANGUAGE 'plpgsql';



CREATE TRIGGER tr_gr02_actualizar_usuarios_insert
    AFTER INSERT
    ON gr02_integra
    REFERENCING NEW TABLE AS tabla_nueva
    FOR EACH STATEMENT
EXECUTE PROCEDURE trfn_gr02_actualizar_usuarios();

CREATE TRIGGER tr_gr02_actualizar_usuarios_delete
    AFTER DELETE
    ON gr02_integra
    REFERENCING OLD TABLE AS tabla_vieja
    FOR EACH STATEMENT
EXECUTE PROCEDURE trfn_gr02_actualizar_usuarios();

CREATE TRIGGER tr_gr02_actualizar_usuarios_update
    AFTER UPDATE
    ON gr02_integra
    REFERENCING NEW TABLE AS tabla_nueva
        OLD TABLE AS tabla_vieja
    FOR EACH STATEMENT
EXECUTE PROCEDURE trfn_gr02_actualizar_usuarios();


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

/*
                                            EJER 2

Utilizando 2 vistas V_GRUPO_COMUN y V_GRUPO_EXCLUSIVO que contienen todos los datos de los grupos comunes
o exclusivos respectivamente, construir los triggers INSTEAD OF necesarios para mantener actualizadas las
tablas de GRUPO, GR_COMUN y GR_EXCLUSIVO de manera de respetar el diseño de datos de la jerarquía.

*/

CREATE VIEW gr02_V_GRUPO_COMUN AS
SELECT g.nro_grupo, g.nombre_grupo, g.limite_integrantes, gc.caracteristica
FROM gr02_grupo g
         NATURAL JOIN gr02_gr_comun gc;

CREATE VIEW gr02_V_GRUPO_EXCLUSIVO AS
SELECT g.nro_grupo, g.nombre_grupo, g.limite_integrantes, ge.perfil
FROM gr02_grupo g
         NATURAL JOIN gr02_gr_exclusivo ge;

--------------------------------------------------------------------------------------------------------
---------------------------------FUNCIONES PARA TRIGGES INSTEAD OF--------------------------------------
--------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION trfn_gr02_v_grupo_comun() RETURNS TRIGGER AS
$$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO gr02_grupo (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr)
        VALUES (NEW.nro_grupo, NEW.nombre_grupo, NEW.limite_integrantes, 'c');

        INSERT INTO gr02_gr_comun (nro_grupo, caracteristica) VALUES (NEW.nro_grupo, NEW.caracteristica);
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        UPDATE gr02_grupo
        SET nombre_grupo       = NEW.nombre_grupo,
            limite_integrantes = NEW.limite_integrantes
        WHERE nro_grupo = NEW.nro_grupo;

        UPDATE gr02_gr_comun
        SET caracteristica = NEW.caracteristica
        WHERE nro_grupo = NEW.nro_grupo;
    END IF;

    IF (TG_OP = 'DELETE') THEN
        DELETE FROM gr02_gr_comun WHERE nro_grupo = OLD.nro_grupo;
        DELETE FROM gr02_grupo WHERE nro_grupo = OLD.nro_grupo;
    END IF;
    RETURN NULL;
END;
$$
    LANGUAGE 'plpgsql';

-----------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION trfn_gr02_v_grupo_excl() RETURNS TRIGGER AS
$$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO gr02_grupo (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr)
        VALUES (NEW.nro_grupo, NEW.nombre_grupo, NEW.limite_integrantes, 'e');

        INSERT INTO gr02_gr_exclusivo (nro_grupo, perfil) VALUES (NEW.nro_grupo, NEW.perfil);
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        UPDATE gr02_grupo
        SET nombre_grupo       = NEW.nombre_grupo,
            limite_integrantes = NEW.limite_integrantes
        WHERE nro_grupo = NEW.nro_grupo;

        UPDATE gr02_gr_exclusivo
        SET perfil = NEW.perfil
        WHERE nro_grupo = NEW.nro_grupo;
    END IF;

    IF (TG_OP = 'DELETE') THEN
        DELETE FROM gr02_gr_exclusivo WHERE nro_grupo = OLD.nro_grupo;
        DELETE FROM gr02_grupo WHERE nro_grupo = OLD.nro_grupo;
    END IF;
    RETURN NULL;
END;
$$
    LANGUAGE 'plpgsql';
--------------------------------------------------------------------------------------------------------
------------------------------------------- TRIGGES INSTEAD OF------------------------------------------
--------------------------------------------------------------------------------------------------------
--TRIGGER PARA GRUPO COMUN
CREATE TRIGGER tr_gr02_v_grupo_comun
    INSTEAD OF INSERT OR UPDATE OR DELETE
    ON gr02_V_GRUPO_COMUN
    FOR EACH ROW
EXECUTE PROCEDURE trfn_gr02_v_grupo_comun();

--TRIGGER PARA GRUPO EXCL
CREATE TRIGGER tr_gr02_v_grupo_excl
    INSTEAD OF INSERT OR UPDATE OR DELETE
    ON gr02_V_GRUPO_EXCLUSIVO
    FOR EACH ROW
EXECUTE PROCEDURE trfn_gr02_v_grupo_excl();

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
/*
                                            EJER 3

Construya una vista V_GRUPOS_COMP que contenga los grupos que son integrados por
todos los usuarios.

*/
--para cada grupo no tiene que existir un usuario el cual no lo integre
CREATE VIEW gr02_V_GRUPOS_COMP AS
SELECT *
FROM gr02_grupo g
WHERE NOT EXISTS(SELECT 1
                 FROM gr02_usuario u
                 WHERE NOT EXISTS(SELECT 1
                                  FROM gr02_integra i
                                  WHERE i.nro_grupo = g.nro_grupo
                                    AND i.tipo_usuario = u.tipo_usuario
                                    AND i.cod_usuario = u.cod_usuario));

SELECT *
FROM gr02_V_GRUPOS_COMP;

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

/*
                                        EJER 4

Construya una vista V_GRUPOS_INTEG que liste para cada grupo todos sus datos (de
grupo común y exclusivo) junto con la cantidad de usuarios que integran cada uno.
 */

CREATE VIEW gr02_v_grupo_cantidad_usuarios as
SELECT DISTINCT g.*,
                gc.caracteristica,
                ge.perfil,
                COUNT(i.cod_usuario) over (partition by g.nro_grupo)
FROM gr02_grupo g
         LEFT JOIN gr02_integra i ON
    g.nro_grupo = i.nro_grupo
         LEFT JOIN gr02_gr_comun gc on g.nro_grupo = gc.nro_grupo
         LEFT JOIN gr02_gr_exclusivo ge on g.nro_grupo = ge.nro_grupo;


CREATE OR REPLACE VIEW gr02_V_GRUPOS_INTEG as
SELECT gcu.nro_grupo,
       gcu.nombre_grupo,
       gcu.limite_integrantes,
       gcu.tipo_gr,
       gcu.caracteristica,
       gcu.perfil,
       gcu.count AS total
FROM gr02_v_grupo_cantidad_usuarios gcu;

/*
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
               LEFT JOIN (SELECT nro_grupo, COUNT(*) AS cant_usuario FROM gr02_integra GROUP BY nro_grupo) AS cu
                    ON g02g.nro_grupo = cu.nro_grupo) AS grupo;

 */

-- ========== CONSULTAS DE PRUEBA ========== -

--------------------------------------------------------------------------------------------------------
-- EJERCICIO 1 -----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

INSERT INTO gr02_usuario (TIPO_USUARIO, COD_USUARIO, APELLIDO, NOMBRE, NICK)
values (1, 1, 'Van Der Vluet', 'Julio', 'Cesar');
INSERT INTO gr02_usuario (TIPO_USUARIO, COD_USUARIO, APELLIDO, NOMBRE, NICK)
values (1, 2, 'Marsico', 'Cristian', 'no');
INSERT INTO gr02_usuario (TIPO_USUARIO, COD_USUARIO, APELLIDO, NOMBRE, NICK)
values (1, 3, 'Hernández', 'Francisco', 'no');

INSERT INTO gr02_grupo (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr)
VALUES (1, 'GR1', 10, 'c');
INSERT INTO gr02_grupo (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr)
VALUES (2, 'GR2', 12, 'c');
INSERT INTO gr02_grupo (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr)
VALUES (3, 'GR3', 13, 'e');
INSERT INTO gr02_grupo (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr)
VALUES (4, 'GR4', 13, 'e');
INSERT INTO gr02_gr_comun (nro_grupo, caracteristica)
VALUES
    (1, 'Grupo 1 Común'),
    (2, 'Grupo 2 Común');
INSERT INTO gr02_gr_exclusivo (nro_grupo, perfil)
VALUES (3, 'Grupo 3 Exclusivo'),
       (4, 'Grupo 4 Exclusivo');

INSERT INTO gr02_integra (tipo_usuario, cod_usuario, nro_grupo, fecha, activo)
VALUES (1, 1, 1, to_date('2020-12-2', 'yyyy-mm-dd'), true);
INSERT INTO gr02_integra (tipo_usuario, cod_usuario, nro_grupo, fecha, activo)
VALUES (1, 2, 3, to_date('2020-12-2', 'yyyy-mm-dd'), true);
INSERT INTO gr02_integra (tipo_usuario, cod_usuario, nro_grupo, fecha, activo)
VALUES (1, 3, 2, to_date('2020-12-2', 'yyyy-mm-dd'), true),
       (1, 3, 1, to_date('2020-12-2', 'yyyy-mm-dd'), false),
       (1, 3, 3, to_date('2020-12-2', 'yyyy-mm-dd'), true);

INSERT INTO gr02_integra (tipo_usuario, cod_usuario, nro_grupo, fecha, activo)
VALUES
('1', 1, 2, to_date('2021-06-10', 'YYYY-MM-DD'), true),
('1', 2, 2, to_date('2021-07-10', 'YYYY-MM-DD'), false),
('1', 3, 4, to_date('2021-07-12', 'YYYY-MM-DD'), false);

UPDATE gr02_integra SET activo = true
WHERE tipo_usuario = '1' AND cod_usuario = 2 AND nro_grupo = 2;
UPDATE gr02_integra SET activo = true
WHERE tipo_usuario = '1' AND cod_usuario = 3 AND nro_grupo = 4;

DELETE FROM gr02_integra
WHERE tipo_usuario = '1' AND cod_usuario = 1 AND nro_grupo = 2;
DELETE FROM gr02_integra
WHERE tipo_usuario = '1' AND cod_usuario = 2 AND nro_grupo = 2;
DELETE FROM gr02_integra
WHERE tipo_usuario = '1' AND cod_usuario = 3 AND nro_grupo = 4;

--------------------------------------------------------------------------------------------------------
-- EJERCICIO 2 -----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
-------------------------------------------PRUEBAS DE VISTAS--------------------------------------------
--------------------------------------------------------------------------------------------------------

--PRUEBAS PARA EL TRIGGER tr_gr02_v_grupo_comun

SELECT *
FROM gr02_V_GRUPO_COMUN;

INSERT INTO gr02_v_grupo_comun (nro_grupo, nombre_grupo, limite_integrantes, caracteristica)
VALUES (5, 'gr5 desde VISTA', 14, 'grupo comun 5'),
       (6, 'gr6 desde VISTA', 15, 'grupo comun 6');

UPDATE gr02_v_grupo_comun
SET nombre_grupo       = 'gr5_desde_VISTAS',
    limite_integrantes = 11,
    caracteristica= 'grupo_comun_5'
WHERE nro_grupo = 5;

DELETE
FROM gr02_v_grupo_comun
WHERE nro_grupo = 5;

INSERT INTO gr02_v_grupo_comun (nro_grupo, nombre_grupo, limite_integrantes, caracteristica)
VALUES (7, 'gr7 desde VISTA', 14, 'grupo comun 7'),
       (8, 'gr8 desde VISTA', 15, 'grupo comun 8');

UPDATE gr02_V_GRUPO_COMUN
SET nombre_grupo = 'LOS SOSOSOROSOS UNIDOS'
WHERE nro_grupo = 7;

DELETE FROM gr02_V_GRUPO_COMUN
WHERE nro_grupo = 8;

--PRUEBAS PARA EL TRIGGER tr_gr02_v_grupo_excl

SELECT *
FROM gr02_V_GRUPO_EXCLUSIVO;

INSERT INTO gr02_v_grupo_exclusivo (nro_grupo, nombre_grupo, limite_integrantes, perfil)
VALUES (9, 'gr9 exc desde VISTA', 14, 'grupo exc 9'),
       (10, 'gr10 exc desde VISTA', 15, 'grupo exc 10');

UPDATE gr02_v_grupo_exclusivo
SET nombre_grupo       = 'gr9_exc_desde_VISTAS',
    limite_integrantes = 11,
    perfil= 'grupo_comun_9'
WHERE nro_grupo = 9;

DELETE
FROM gr02_v_grupo_exclusivo
WHERE nro_grupo = 10;

INSERT INTO gr02_V_GRUPO_EXCLUSIVO (nro_grupo, nombre_grupo, limite_integrantes, perfil)
VALUES
(11, 'Eeeeeeee', 65536, 'Perfil grupo 11'),
(12, 'Aaaaaaaa', 32768, 'Perfil grupo 12');

UPDATE gr02_V_GRUPO_EXCLUSIVO
SET nombre_grupo = 'Grupo Exclusivo 11'
WHERE nro_grupo = 11;
UPDATE gr02_V_GRUPO_EXCLUSIVO
SET nombre_grupo = 'Grupo Exclusivo 12'
WHERE nro_grupo = 12;

DELETE FROM gr02_V_GRUPO_EXCLUSIVO
WHERE nro_grupo = 11;

--------------------------------------------------------------------------------------------------------
-- EJERCICIO 3 -----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

INSERT INTO gr02_integra (tipo_usuario, cod_usuario, nro_grupo, fecha, activo)
VALUES (1, 2, 1, to_date('2021-07-10', 'YYYY-MM-DD'), true);

SELECT * FROM gr02_V_GRUPOS_COMP;

UPDATE gr02_V_GRUPOS_COMP
SET nombre_grupo = 'SOSOROSO'
WHERE nro_grupo = 1;
UPDATE gr02_V_GRUPOS_COMP
SET nombre_grupo = 'GR1'
WHERE nro_grupo = 1;

INSERT INTO gr02_V_GRUPOS_COMP (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr)
VALUES (14, 'GR14', 99, 'e');

--------------------------------------------------------------------------------------------------------
-- EJERCICIO 4 -----------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

SELECT * FROM GR02_V_GRUPOS_INTEG;