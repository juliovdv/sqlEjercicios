SET search_path TO unc_esq_peliculas, public;
SET search_path TO unc_esq_voluntario, public;
SET search_path TO unc_246295;

SELECT ep.nombre_productora, COUNT(DISTINCT codigo_pelicula)
FROM pelicula p
JOIN empresa_productora ep ON p.codigo_productora = ep.codigo_productora
WHERE codigo_pelicula IN (
    SELECT codigo_pelicula
    FROM renglon_entrega)
GROUP BY ep.codigo_productora
ORDER BY 2 DESC;


SELECT e.nombre_productora, COUNT(*)
FROM empresa_productora e JOIN pelicula p ON (e.codigo_productora=p.codigo_productora)
WHERE EXISTS(
      SELECT 1
      FROM renglon_entrega r
      WHERE r.codigo_pelicula = p.codigo_pelicula)
GROUP BY e.nombre_productora
ORDER BY COUNT(*) DESC
LIMIT 2;


-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2021-05-17 13:07:29.238

-- tables
-- Table: GRUPO
CREATE TABLE GRUPO (
    nro_grupo int  NOT NULL,
    nombre_grupo varchar(40)  NOT NULL,
    limite_integrantes int  NOT NULL,
    tipo_gr char(1)  NOT NULL,
    CONSTRAINT PK_GRUPO PRIMARY KEY (nro_grupo)
);

-- Table: GR_COMUN
CREATE TABLE GR_COMUN (
    nro_grupo int  NOT NULL,
    caracteristica varchar(30)  NOT NULL,
    CONSTRAINT PK_GR_COMUN PRIMARY KEY (nro_grupo)
);

-- Table: GR_EXCLUSIVO
CREATE TABLE GR_EXCLUSIVO (
    nro_grupo int  NOT NULL,
    perfil varchar(30)  NOT NULL,
    CONSTRAINT PK_GR_EXCLUSIVO PRIMARY KEY (nro_grupo)
);

-- Table: INTEGRA
CREATE TABLE INTEGRA (
    tipo_usuario char(3)  NOT NULL,
    cod_usuario int  NOT NULL,
    nro_grupo int  NOT NULL,
    fecha date  NOT NULL,
    CONSTRAINT PK_INTEGRA PRIMARY KEY (tipo_usuario,cod_usuario,nro_grupo)
);

-- Table: USUARIO
CREATE TABLE USUARIO (
    tipo_usuario char(3)  NOT NULL,
    cod_usuario int  NOT NULL,
    apellido varchar(30)  NOT NULL,
    nombre varchar(30)  NOT NULL,
    nick varchar(15)  NULL,
    CONSTRAINT PK_USUARIO PRIMARY KEY (tipo_usuario,cod_usuario)
);

-- foreign keys
-- Reference: FK_GR_COMUN_GRUPO (table: GR_COMUN)
ALTER TABLE GR_COMUN ADD CONSTRAINT FK_GR_COMUN_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GRUPO (nro_grupo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_GR_EXCLUSIVO_GRUPO (table: GR_EXCLUSIVO)
ALTER TABLE GR_EXCLUSIVO ADD CONSTRAINT FK_GR_EXCLUSIVO_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GRUPO (nro_grupo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_INTEGRA_GRUPO (table: INTEGRA)
ALTER TABLE INTEGRA ADD CONSTRAINT FK_INTEGRA_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GRUPO (nro_grupo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_INTEGRA_USUARIO (table: INTEGRA)
ALTER TABLE INTEGRA ADD CONSTRAINT FK_INTEGRA_USUARIO
    FOREIGN KEY (tipo_usuario, cod_usuario)
    REFERENCES USUARIO (tipo_usuario, cod_usuario)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- End of file.


SELECT u.tipo_usuario, u.cod_usuario, nombre, apellido
FROM usuario u
JOIN integra i ON u.tipo_usuario = i.tipo_usuario AND u.cod_usuario = i.cod_usuario
JOIN grupo g ON i.nro_grupo = g.nro_grupo
WHERE (g.limite_integrantes = 40 AND g.tipo_gr='C')
GROUP BY u.tipo_usuario, u.cod_usuario
HAVING COUNT() BETWEEN 2 AND 5;

INSERT INTO usuario (tipo_usuario, cod_usuario, apellido, nombre, nick) VALUES ('A',2,'Nombre2','Apellido2',22);
INSERT INTO usuario (tipo_usuario, cod_usuario, apellido, nombre, nick) VALUES ('A',3,'Nombre3','Apellido3',33);

INSERT INTO grupo (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr) VALUES (1, 'GRUPO 1', 40, 'C');
INSERT INTO grupo (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr) VALUES (2, 'GRUPO 2', 40, 'C');
INSERT INTO grupo (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr) VALUES (3, 'GRUPO 3', 40, 'C');
INSERT INTO grupo (nro_grupo, nombre_grupo, limite_integrantes, tipo_gr) VALUES (4, 'GRUPO 4', 39, 'C');
ALTER TABLE GRUPO
    ADD CONSTRAINT CK_LIMITE_INTEGRANTES_GRUPO_COMUN
    CHECK ( NOT EXISTS (
        SELECT 1
        FROM GRUPO
        WHERE tipo_gr='C' AND limite_integrantes<10));

SELECT i.id_direccion, count(id_institucion) cant

FROM institucion i JOIN direccion d ON (i.id_direccion = d.id_direccion)

WHERE provincia IS NOT NULL

GROUP BY i.id_direccion;

--HAVING count(id_institucion) >10;

SELECT i.id_direccion, count(id_institucion) cant

FROM institucion i JOIN direccion d ON (i.id_direccion = d.id_direccion)

WHERE provincia IS NOT NULL

GROUP BY i.id_institucion;

HAVING count(id_institucion) >10;

SELECT i.id_direccion, count(id_institucion) cant

FROM institucion i JOIN direccion d ON (i.id_direccion = d.id_direccion)

WHERE provincia != NULL

GROUP BY i.id_direccion

--HAVING count(*) >10;

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2020-06-03 19:09:29.178

-- tables
-- Table: CLIENTE
CREATE TABLE CLIENTE (
    id_cliente int  NOT NULL,
    apellido varchar(30)  NOT NULL,
    nombre varchar(30)  NOT NULL,
    CONSTRAINT CLIENTE_pk PRIMARY KEY (id_cliente)
);

-- Table: ORDEN
CREATE TABLE ORDEN (
    nro_orden int  NOT NULL,
    fecha date  NOT NULL,
    id_cliente int  NOT NULL DEFAULT 0,
    CONSTRAINT PK_MENSAJE PRIMARY KEY (nro_orden)
);

-- Table: PRODUCTO
CREATE TABLE PRODUCTO (
    id_producto int  NOT NULL,
    descripcion_prod varchar(60)  NOT NULL,
    precio decimal(7,2)  NOT NULL,
    categoria_tipo char(3)  NOT NULL DEFAULT 'Z',
    id_tipo int  NOT NULL DEFAULT 1,
    CONSTRAINT PK_ADJUNTO PRIMARY KEY (id_producto)
);

-- Table: PRODUCTOXORDEN
CREATE TABLE PRODUCTOXORDEN (
    nro_orden int  NOT NULL,
    id_producto int  NOT NULL,
    cantidad decimal(5,2)  NOT NULL,
    CONSTRAINT PK_CONTIENE PRIMARY KEY (nro_orden,id_producto)
);

-- Table: STOCK
CREATE TABLE STOCK (
    anio int  NOT NULL,
    mes int  NOT NULL,
    id_producto int  NOT NULL,
    cantidad decimal(5,2)  NOT NULL,
    CONSTRAINT PK_AUDIO PRIMARY KEY (anio,mes)
);

-- Table: TIPO
CREATE TABLE TIPO (
    categoria_tipo char(3)  NOT NULL,
    id_tipo int  NOT NULL,
    descripcion_tipo varchar(60)  NOT NULL,
    CONSTRAINT TIPO_pk PRIMARY KEY (categoria_tipo,id_tipo)
);

-- foreign keys
-- Reference: FK_O_C (table: ORDEN)
ALTER TABLE ORDEN ADD CONSTRAINT FK_O_C
    FOREIGN KEY (id_cliente)
    REFERENCES CLIENTE (id_cliente)
    ON DELETE  SET DEFAULT
    ON UPDATE  SET DEFAULT
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_PO_O (table: PRODUCTOXORDEN)
ALTER TABLE PRODUCTOXORDEN ADD CONSTRAINT FK_PO_O
    FOREIGN KEY (nro_orden)
    REFERENCES ORDEN (nro_orden)
    ON DELETE  CASCADE
    ON UPDATE  CASCADE
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_PO_P (table: PRODUCTOXORDEN)
ALTER TABLE PRODUCTOXORDEN ADD CONSTRAINT FK_PO_P
    FOREIGN KEY (id_producto)
    REFERENCES PRODUCTO (id_producto)
    ON DELETE  RESTRICT
    ON UPDATE  CASCADE
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_P_T (table: PRODUCTO)
ALTER TABLE PRODUCTO ADD CONSTRAINT FK_P_T
    FOREIGN KEY (categoria_tipo, id_tipo)
    REFERENCES TIPO (categoria_tipo, id_tipo)
    ON DELETE  SET DEFAULT
    ON UPDATE  SET DEFAULT
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_S_P (table: STOCK)
ALTER TABLE STOCK ADD CONSTRAINT FK_S_P
    FOREIGN KEY (id_producto)
    REFERENCES PRODUCTO (id_producto)
    ON DELETE  CASCADE
    ON UPDATE  CASCADE
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

update PRODUCTOXORDEN set id_producto= 100 where id_producto=99;

SELECT id_pais
FROM empresa_productora ep
JOIN ciudad c ON ep.id_ciudad = c.id_ciudad
WHERE ep.codigo_productora IN
(SELECT codigo_productora
FROM pelicula
GROUP BY codigo_productora
ORDER BY count(*) DESC
LIMIT 3);

SELECT nombre_productora
FROM empresa_productora
WHERE codigo_productora IN(
    SELECT p.codigo_productora
    FROM pelicula p
    WHERE p.codigo_productora IN(
        SELECT p.codigo_productora
        FROM pelicula p
        WHERE idioma = 'Coreano')
    GROUP BY p.codigo_productora
    ORDER BY count(*) DESC
    LIMIT 3);

SELECT count(*)
FROM pelicula
WHERE idioma = 'Coreano'

SELECT codigo_pelicula, formato, idioma
FROM unc_esq_peliculas.pelicula
WHERE (formato = 'Formato 8' AND idioma = 'Francés') OR formato != 'Formato 8'
ORDER BY formato;

SELECT idioma
FROM unc_esq_peliculas.pelicula
WHERE idioma LIKE 'Fran%';






SELECT dis.nombre
FROM distribuidor dis JOIN departamento dep ON dis.id_distribuidor = dep.id_distribuidor
WHERE (jefe_departamento IN (
    SELECT id_empleado
    FROM empleado e1
    WHERE e1.porc_comision > 20)) AND
             NOT EXISTS (
              SELECT 1
              FROM empleado e2
              WHERE e2.id_distribuidor = dep.id_distribuidor AND e2.id_departamento = dep.id_departamento AND
              e2.telefono NOT LIKE '600%'
              )
ORDER BY 1 ASC;



S


SELECT DISTINCT DI.nombre, E.porc_comision, ED.telefono
FROM Distribuidor DI
    JOIN Departamento D    ON D.id_distribuidor  = DI.id_distribuidor
    JOIN Empleado E    ON E.id_empleado = D.jefe_departamento
    JOIN Empleado ED ON ED.id_departamento = D.id_departamento AND ED.id_distribuidor = D.id_distribuidor
WHERE E.porc_comision > 20
    AND ED.telefono LIKE '600%'
ORDER BY DI.nombre
LIMIT 3;

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2021-05-17 13:07:29.238

-- tables
-- Table: GRUPO
CREATE TABLE GRUPO (
    nro_grupo int  NOT NULL,
    nombre_grupo varchar(40)  NOT NULL,
    limite_integrantes int  NOT NULL,
    tipo_gr char(1)  NOT NULL,
    CONSTRAINT PK_GRUPO PRIMARY KEY (nro_grupo)
);

-- Table: GR_COMUN
CREATE TABLE GR_COMUN (
    nro_grupo int  NOT NULL,
    caracteristica varchar(30)  NOT NULL,
    CONSTRAINT PK_GR_COMUN PRIMARY KEY (nro_grupo)
);

-- Table: GR_EXCLUSIVO
CREATE TABLE GR_EXCLUSIVO (
    nro_grupo int  NOT NULL,
    perfil varchar(30)  NOT NULL,
    CONSTRAINT PK_GR_EXCLUSIVO PRIMARY KEY (nro_grupo)
);

-- Table: INTEGRA
CREATE TABLE INTEGRA (
    tipo_usuario char(3)  NOT NULL,
    cod_usuario int  NOT NULL,
    nro_grupo int  NOT NULL,
    fecha date  NOT NULL,
    CONSTRAINT PK_INTEGRA PRIMARY KEY (tipo_usuario,cod_usuario,nro_grupo)
);

-- Table: USUARIO
CREATE TABLE USUARIO (
    tipo_usuario char(3)  NOT NULL,
    cod_usuario int  NOT NULL,
    apellido varchar(30)  NOT NULL,
    nombre varchar(30)  NOT NULL,
    nick varchar(15)  NULL,
    CONSTRAINT PK_USUARIO PRIMARY KEY (tipo_usuario,cod_usuario)
);

-- foreign keys
-- Reference: FK_GR_COMUN_GRUPO (table: GR_COMUN)
ALTER TABLE GR_COMUN ADD CONSTRAINT FK_GR_COMUN_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GRUPO (nro_grupo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_GR_EXCLUSIVO_GRUPO (table: GR_EXCLUSIVO)
ALTER TABLE GR_EXCLUSIVO ADD CONSTRAINT FK_GR_EXCLUSIVO_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GRUPO (nro_grupo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_INTEGRA_GRUPO (table: INTEGRA)
ALTER TABLE INTEGRA ADD CONSTRAINT FK_INTEGRA_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GRUPO (nro_grupo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_INTEGRA_USUARIO (table: INTEGRA)
ALTER TABLE INTEGRA ADD CONSTRAINT FK_INTEGRA_USUARIO
    FOREIGN KEY (tipo_usuario, cod_usuario)
    REFERENCES USUARIO (tipo_usuario, cod_usuario)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- End of file.



SELECT *
FROM usuario u
WHERE (nick IS NULL OR nick = '') AND (tipo_usuario, cod_usuario) NOT IN (
    SELECT tipo_usuario, cod_usuario
    FROM integra
    WHERE fecha > to_date('01/01/2000', 'dd/mm/yyyy')
    );

ALTER TABLE INTEGRA
ADD CONSTRAINT CK_LIMITE_INTEGRANTES_GRUPO
    CHECK (NOT EXISTS(
            SELECT 1
            FROM integra
            GROUP BY nro_grupo
            HAVING count(*)>=15
        )
    );

SELECT d.id_distribuidor, tipo, COUNT(*)
FROM distribuidor d JOIN
    entrega e on d.id_distribuidor = e.id_distribuidor
WHERE tipo = 'N'
GROUP BY d.id_distribuidor
ORDER BY 2 DESC;

SELECT min(id_pais)
FROM direccion d JOIN institucion i
ON (d.id_direccion = i.id_direccion)
GROUP BY d.id_pais;

SELECT count(*)
                   FROM direccion d JOIN institucion i
                    ON (d.id_direccion = i.id_direccion)
                    GROUP BY d.id_pais
                    ORDER BY 1;

SELECT d.id_pais, Count(*)

FROM direccion d JOIN institucion i ON (d.id_direccion = i.id_direccion)
GROUP BY d.id_pais
--HAVING count(*) = ( SELECT count(*)
                 --  FROM direccion d JOIN institucion i
                  --  ON (d.id_direccion = i.id_direccion)
                 --   GROUP BY d.id_pais
                  --  ORDER BY 1 LIMIT 1)
SELECT count(*)
                   FROM direccion d JOIN institucion i
                    ON (d.id_direccion = i.id_direccion)
                    GROUP BY d.id_pais;

SELECT min(id_pais)
                   FROM direccion d JOIN institucion i
                    ON (d.id_direccion = i.id_direccion)
                    GROUP BY d.id_pais;

update persona set id_persona = id_persona + 1000;

 update persona set nombre = 'a' where id_persona=1001;


SELECT d.id_pais, count(*)

FROM direccion d JOIN institucion i ON (d.id_direccion = i.id_direccion)
GROUP BY d.id_pais


-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2021-06-07 01:08:33.371

-- tables
-- Table: MESA
CREATE TABLE MESA (
    codigo int  NOT NULL,
    nro_mesa int  NOT NULL,
    capacidad int  NOT NULL,
    CONSTRAINT PK_MESA PRIMARY KEY (nro_mesa,codigo)
);

-- Table: RESERVA
CREATE TABLE RESERVA (
    nro_reserva int  NOT NULL,
    fecha date  NOT NULL,
    hora time  NOT NULL,
    cant_personas int  NOT NULL,
    nro_mesa int  NOT NULL,
    codigo int  NOT NULL,
    e_mail varchar(240)  NOT NULL,
    CONSTRAINT PK_RESERVA PRIMARY KEY (nro_reserva)
);

-- Table: RESTAURANT
CREATE TABLE RESTAURANT (
    codigo int  NOT NULL,
    nombre varchar(40)  NOT NULL,
    direccion varchar(140)  NOT NULL,
    ciudad varchar(80)  NOT NULL,
    CONSTRAINT PK_RESTAURANT PRIMARY KEY (codigo)
);

-- Table: USUARIO
CREATE TABLE USUARIO (
    e_mail varchar(240)  NOT NULL,
    apellido_nombre varchar(200)  NOT NULL,
    ciudad varchar(80)  NOT NULL,
    CONSTRAINT PK_USUARIO PRIMARY KEY (e_mail)
);

-- foreign keys
-- Reference: FK_MESA_RESTAURANT (table: MESA)
ALTER TABLE MESA ADD CONSTRAINT FK_MESA_RESTAURANT
    FOREIGN KEY (codigo)
    REFERENCES RESTAURANT (codigo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_RESERVA_USUARIO (table: RESERVA)
ALTER TABLE RESERVA ADD CONSTRAINT FK_RESERVA_USUARIO
    FOREIGN KEY (e_mail)
    REFERENCES USUARIO (e_mail)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: RESERVA_MESA (table: RESERVA)
ALTER TABLE RESERVA ADD CONSTRAINT RESERVA_MESA
    FOREIGN KEY (nro_mesa, codigo)
    REFERENCES MESA (nro_mesa, codigo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- End of file.


CREATE ASSERTION ASS_1
CHECK (NOT EXISTS (
              SELECT 1
              FROM reserva NATURAL JOIN mesa
              WHERE cant_personas < capacidad
                        and extract (month from fecha) = 12));

SELECT codigo
FROM mesa
GROUP BY codigo
HAVING count(*)>30



-----------RESERVA-------------
CREATE TRIGGER TR_CTRL_CANT_PERSONAS_RESERVA
    BEFORE INSERT OR UPDATE OF fecha, cant_personas, nro_mesa
    ON reserva
    FOR EACH ROW
EXECUTE PROCEDURE FN_CTRL_CANT_PERSONAS_RESERVA();

-----------MESA--------------
CREATE TRIGGER TR_CTRL_CAPACIDAD_MESA
    BEFORE UPDATE OF capacidad
    ON mesa
    FOR EACH ROW
EXECUTE PROCEDURE FN_CTRL_CAPACIDAD_MESA();


CREATE OR REPLACE FUNCTION FN_CTRL_CANT_PERSONAS_RESERVA()
    RETURNS TRIGGER AS
$$

DECLARE
    cap_mesa INTEGER;
BEGIN
    SELECT capacidad
    INTO cap_mesa
    FROM mesa m
    WHERE m.codigo = NEW.codigo
      AND m.nro_mesa = NEW.nro_mesa;

    IF NEW.cant_personas < cap_mesa AND extract(month from NEW.fecha) = 12 THEN
        RAISE EXCEPTION 'no se puede efectuar la reserva por % personas en diciembre, la capacidad de esta mesa es %', NEW.cant_personas, cap_mesa;
    END IF;
    RETURN NEW;
END
$$

CREATE VIEW distribuidor_nacional
AS (SELECT id_distribuidor, nombre
    FROM unc_esq_peliculas.distribuidor
    WHERE tipo = 'N');

SELECT *
FROM distribuidor_nacional
ORDER BY 1;

SELECT current_date - INTERVAL '106 MONTH'


EXPLAIN ANALYZE SELECT * from RESERVA JOIN esq_vol_voluntario evv on RESERVA.e_mail = evv.e_mail;

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2021-05-17 13:07:29.238

-- tables
-- Table: GRUPO
CREATE TABLE GRUPO (
    nro_grupo int  NOT NULL,
    nombre_grupo varchar(40)  NOT NULL,
    limite_integrantes int  NOT NULL,
    tipo_gr char(1)  NOT NULL,
    CONSTRAINT PK_GRUPO PRIMARY KEY (nro_grupo)
);

-- Table: GR_COMUN
CREATE TABLE GR_COMUN (
    nro_grupo int  NOT NULL,
    caracteristica varchar(30)  NOT NULL,
    CONSTRAINT PK_GR_COMUN PRIMARY KEY (nro_grupo)
);

-- Table: GR_EXCLUSIVO
CREATE TABLE GR_EXCLUSIVO (
    nro_grupo int  NOT NULL,
    perfil varchar(30)  NOT NULL,
    CONSTRAINT PK_GR_EXCLUSIVO PRIMARY KEY (nro_grupo)
);

-- Table: INTEGRA
CREATE TABLE INTEGRA (
    tipo_usuario char(3)  NOT NULL,
    cod_usuario int  NOT NULL,
    nro_grupo int  NOT NULL,
    fecha date  NOT NULL,
    CONSTRAINT PK_INTEGRA PRIMARY KEY (tipo_usuario,cod_usuario,nro_grupo)
);

-- Table: USUARIO
CREATE TABLE USUARIO (
    tipo_usuario char(3)  NOT NULL,
    cod_usuario int  NOT NULL,
    apellido varchar(30)  NOT NULL,
    nombre varchar(30)  NOT NULL,
    nick varchar(15)  NULL,
    CONSTRAINT PK_USUARIO PRIMARY KEY (tipo_usuario,cod_usuario)
);

-- foreign keys
-- Reference: FK_GR_COMUN_GRUPO (table: GR_COMUN)
ALTER TABLE GR_COMUN ADD CONSTRAINT FK_GR_COMUN_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GRUPO (nro_grupo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_GR_EXCLUSIVO_GRUPO (table: GR_EXCLUSIVO)
ALTER TABLE GR_EXCLUSIVO ADD CONSTRAINT FK_GR_EXCLUSIVO_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GRUPO (nro_grupo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_INTEGRA_GRUPO (table: INTEGRA)
ALTER TABLE INTEGRA ADD CONSTRAINT FK_INTEGRA_GRUPO
    FOREIGN KEY (nro_grupo)
    REFERENCES GRUPO (nro_grupo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_INTEGRA_USUARIO (table: INTEGRA)
ALTER TABLE INTEGRA ADD CONSTRAINT FK_INTEGRA_USUARIO
    FOREIGN KEY (tipo_usuario, cod_usuario)
    REFERENCES USUARIO (tipo_usuario, cod_usuario)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- End of file.

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2021-05-17 13:35:11.621

-- tables
-- Table: ASIGNATURA
CREATE TABLE ASIGNATURA (
    tipo_asig char(2)  NOT NULL,
    cod_asig int  NOT NULL,
    nombre_asig varchar(40)  NOT NULL,
    cant_hs_t int  NOT NULL,
    cant_hs_p int  NOT NULL,
    CONSTRAINT PK_ASIGNATURA PRIMARY KEY (tipo_asig,cod_asig)
);

-- Table: ASIGNATURA_PROFESOR
CREATE TABLE ASIGNATURA_PROFESOR (
    dni int  NOT NULL,
    tipo_asig char(2)  NOT NULL,
    cod_asig int  NOT NULL,
    cuatrimestre int  NOT NULL,
    cantidad_horas int  NOT NULL,
    CONSTRAINT PK_ASIGNATURA_PROFESOR PRIMARY KEY (dni,tipo_asig,cod_asig)
);

-- Table: PROFESOR
CREATE TABLE PROFESOR (
    dni int  NOT NULL,
    apellido varchar(50)  NOT NULL,
    nombre varchar(30)  NOT NULL,
    titulo varchar(30)  NULL,
    departamento int  NOT NULL,
    tipo_prof int  NOT NULL,
    CONSTRAINT PK_PROFESOR PRIMARY KEY (dni)
);

-- Table: PROF_EXCLUSIVO
CREATE TABLE PROF_EXCLUSIVO (
    dni int  NOT NULL,
    proy_investig varchar(20)  NOT NULL,
    CONSTRAINT PK_PROF_EXCLUSIVO PRIMARY KEY (dni)
);

-- Table: PROF_SIMPLE
CREATE TABLE PROF_SIMPLE (
    dni int  NOT NULL,
    perfil varchar(120)  NOT NULL,
    CONSTRAINT PK_PROF_SIMPLE PRIMARY KEY (dni)
);

-- foreign keys
-- Reference: FK_ASIGNATURA_PROFESOR_ASIGNATURA (table: ASIGNATURA_PROFESOR)
ALTER TABLE ASIGNATURA_PROFESOR ADD CONSTRAINT FK_ASIGNATURA_PROFESOR_ASIGNATURA
    FOREIGN KEY (tipo_asig, cod_asig)
    REFERENCES ASIGNATURA (tipo_asig, cod_asig)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_ASIGNATURA_PROFESOR_PROFESOR (table: ASIGNATURA_PROFESOR)
ALTER TABLE ASIGNATURA_PROFESOR ADD CONSTRAINT FK_ASIGNATURA_PROFESOR_PROFESOR
    FOREIGN KEY (dni)
    REFERENCES PROFESOR (dni)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_PROF_EXCLUSIVO_PROFESOR (table: PROF_EXCLUSIVO)
ALTER TABLE PROF_EXCLUSIVO ADD CONSTRAINT FK_PROF_EXCLUSIVO_PROFESOR
    FOREIGN KEY (dni)
    REFERENCES PROFESOR (dni)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_PROF_SIMPLE_PROFESOR (table: PROF_SIMPLE)
ALTER TABLE PROF_SIMPLE ADD CONSTRAINT FK_PROF_SIMPLE_PROFESOR
    FOREIGN KEY (dni)
    REFERENCES PROFESOR (dni)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- End of file.

-------------------------------------------------------
--Ejercicio 1.-


CREATE OR REPLACE FUNCTION FN_CONTROL_LIMITES_ASIGNATURA()
    RETURNS TRIGGER AS
$$
DECLARE
    nro_profesores INTEGER;
BEGIN
    SELECT count(*)
    INTO nro_profesores
    FROM asignatura_profesor ap
    WHERE ap.tipo_asig = NEW.tipo_asig AND ap.cod_asig = NEW.cod_asig;

    IF nro_profesores > 10 THEN
        RAISE EXCEPTION 'La materia no puede tener mas de 10 profesores';
    END IF;
    RETURN NEW;
END
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION FN_CONTROL_LIMITES_ASIGNATURA_PROFESOR()
    RETURNS TRIGGER AS
$$
DECLARE
    nro_profesores INTEGER;
    cant_horas     INTEGER;
BEGIN
    SELECT cant_hs_t
    INTO cant_horas
    FROM asignatura a
    WHERE a.tipo_asig = NEW.tipo_asig
      AND a.cod_asig = NEW.cod_asig;


    IF cant_horas < 3 THEN
        SELECT count(*)
        INTO nro_profesores
        FROM asignatura_profesor ap
        WHERE ap.tipo_asig = NEW.tipo_asig
          AND ap.cod_asig = NEW.cod_asig;

        IF nro_profesores > 10 THEN
            RAISE EXCEPTION 'La materia no puede tener mas de 10 profesores';

        END IF;
    END IF;
    RETURN NEW;
END
$$
    LANGUAGE 'plpgsql';



CREATE TRIGGER TR_CONTROL_LIMITES_ASIGNATURA_PROFESOR
    BEFORE INSERT OR UPDATE OF tipo_asig, cod_asig
    ON asignatura_profesor
    FOR EACH ROW
EXECUTE PROCEDURE FN_CONTROL_LIMITES_ASIGNATURA_PROFESOR();

CREATE TRIGGER TR_CONTROL_LIMITES_ASIGNATURA
    BEFORE UPDATE OF cant_hs_t
    ON asignatura
    FOR EACH ROW
    WHEN (NEW.cant_hs_t < 3)
EXECUTE PROCEDURE FN_CONTROL_LIMITES_ASIGNATURA();

-------------------------------------------------------------------------
--Ejercicio 2-

CREATE VIEW USUARIOS_DE_GRUPOS_CON_MAS_DE_DIEZ_INTEGRANTES
AS
SELECT *
FROM usuario
WHERE (tipo_usuario, cod_usuario) IN (
    SELECT tipo_usuario, cod_usuario
    FROM integra
    WHERE nro_grupo IN
          (SELECT nro_grupo
           FROM integra
           GROUP BY nro_grupo
           HAVING count(*) > 10));

INSERT INTO asignatura (tipo_asig, cod_asig, nombre_asig, cant_hs_t, cant_hs_p) VALUES ('A',1,'AAA',3,3);

---------------------------------------------------------------------------------
--Ejercicio 4-

CREATE OR REPLACE FUNCTION FN_CANTIDAD_ASIGNATURAS()
    RETURNS TRIGGER AS
$$

BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE profesor p
        SET cantidad_asignaturas = cantidad_asignaturas + 1
        WHERE p.dni = NEW.dni;
        RETURN NEW;
    ELSE
        IF (TG_OP = 'DELETE') THEN
            UPDATE profesor p
            SET cantidad_asignaturas = cantidad_asignaturas - 1
            WHERE p.dni = OLD.dni;
            RETURN OLD;
        ELSE
            IF (TG_OP = 'UPDATE') THEN
                UPDATE profesor p
                SET cantidad_asignaturas = cantidad_asignaturas + 1
                WHERE p.dni = NEW.dni;
                UPDATE profesor p
                SET cantidad_asignaturas = cantidad_asignaturas - 1
                WHERE p.dni = OLD.dni;
                RETURN NEW;
            END IF;
        END IF;
    END IF;


END
$$
LANGUAGE 'plpgsql';


CREATE TRIGGER TR_CANTIDAD_ASIGNATURAS
    AFTER INSERT OR DELETE OR UPDATE OF dni
    ON asignatura_profesor
    FOR EACH ROW
EXECUTE PROCEDURE FN_CANTIDAD_ASIGNATURAS();

-----------------------TRABAJO PRACTICO ESPECIAL

---- A. TRIGGERS y SERVICIOS
---- 1.
---- 2.

CREATE VIEW GR02_V_GRUPO_COMUN
AS
SELECT g02g.nro_grupo, nombre_grupo, limite_integrantes, tipo_gr, caracteristica
FROM gr02_gr_comun g02gc JOIN gr02_grupo g02g on g02g.nro_grupo = g02gc.nro_grupo;

CREATE VIEW GR02_V_GRUPO_EXCLUSIVO
AS
SELECT g02g.nro_grupo, nombre_grupo, limite_integrantes, tipo_gr, perfil
FROM gr02_gr_exclusivo g02ge  JOIN gr02_grupo g02g on g02g.nro_grupo = g02ge.nro_grupo;

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




CREATE TRIGGER TR_GR02_V_GRUPO_COMUN
    INSTEAD OF INSERT OR UPDATE OR DELETE
    ON GR02_V_GRUPO_COMUN
    FOR EACH ROW
    EXECUTE PROCEDURE FN_GR02_V_GRUPO_COMUN();


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

SELECT *
FROM GR02_V_GRUPO_COMUN;

SELECT *
FROM gr02_gr_comun;
SELECT *
FROM GR02_GRUPO;
SELECT *
FROM gr02_gr_exclusivo;


CREATE TRIGGER TR_GR02_V_GRUPO_EXCLUSIVO
    INSTEAD OF INSERT OR UPDATE
    ON GR02_V_GRUPO_EXCLUSIVO
    FOR EACH ROW
    EXECUTE PROCEDURE FN_GR02_V_GRUPO_EXCLUSIVO();


---- B. VISTAS
---- 1.
CREATE VIEW GR02_V_GRUPOS_COMP
AS
EXPLAIN SELECT *
FROM GR02_GRUPO
WHERE nro_grupo IN (
    SELECT nro_grupo
    FROM GR02_INTEGRA
    GROUP BY nro_grupo
    HAVING count(*) = (
        SELECT count(*)
        FROM GR02_USUARIO));

---- 2.
CREATE VIEW GR02_V_GRUPOS_INTEG
AS
SELECT *
FROM (SELECT g02g.nro_grupo,g02g.nombre_grupo, g02g.tipo_gr, g02g.limite_integrantes, g02tg.caracteristica AS detalle_grupo, cant_usuario
      FROM gr02_grupo g02g
               JOIN (
          SELECT *
          FROM gr02_gr_comun
          UNION
          SELECT *
          FROM gr02_gr_exclusivo) AS g02tg
                    ON g02g.nro_grupo = g02tg.nro_grupo
               JOIN (SELECT nro_grupo, COUNT(*) AS cant_usuario FROM gr02_integra GROUP BY nro_grupo) AS cu
                    ON g02g.nro_grupo = cu.nro_grupo) AS grupo;



EXPLAIN SELECT *
FROM gr02_grupo g
WHERE NOT EXISTS(SELECT 1
                 FROM gr02_usuario u
                 WHERE NOT EXISTS(SELECT 1
                                  FROM gr02_integra i
                                  WHERE i.nro_grupo = g.nro_grupo
                                    AND i.tipo_usuario = u.tipo_usuario
                                    AND i.cod_usuario = u.cod_usuario));

