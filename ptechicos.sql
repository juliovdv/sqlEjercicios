/**==================================================================*/
--                     GRUPO 01 - ESQUEMA E1
/**==================================================================*/

-- tables
-- Table: ALQUILA
CREATE TABLE GR01_ALQUILA (
    tipo_doc char(3)  NOT NULL,
    nro_doc int  NOT NULL,
    id_oficina int  NOT NULL,
    fecha_desde date  NOT NULL,
    fecha_hasta date  NULL,
    CONSTRAINT PK_GR01_ALQUILA PRIMARY KEY (tipo_doc,nro_doc,id_oficina)
);

-- Table: CLIENTE
CREATE TABLE GR01_CLIENTE (
    tipo_doc char(3)  NOT NULL,
    nro_doc int  NOT NULL,
    nombre varchar(50)  NOT NULL,
    apellido varchar(50)  NOT NULL,
    e_mail varchar(50)  NOT NULL,
    CONSTRAINT PK_GR01_CLIENTE PRIMARY KEY (tipo_doc,nro_doc)
);

-- Table: OFICINA
CREATE TABLE GR01_OFICINA (
    id_oficina int  NOT NULL,
    superficie int  NOT NULL,
    cant_max_personas int  NOT NULL,
    monto_alquiler decimal(10,2)  NOT NULL,
    tipo_o char(1)  NOT NULL,
    CONSTRAINT PK_GR01_OFICINA PRIMARY KEY (id_oficina)
);

-- Table: OFICINA_REG
CREATE TABLE GR01_OFICINA_REG (
    id_oficina int  NOT NULL,
    cant_escritorios int  NOT NULL,
    cant_pc int  NOT NULL,
    CONSTRAINT PK_GR01_OFICINA_REG PRIMARY KEY (id_oficina)
);

-- Table: SALA_CONVENCION
CREATE TABLE GR01_SALA_CONVENCION (
    id_oficina int  NOT NULL,
    cant_sillas int  NOT NULL,
    cant_pantallas int  NOT NULL,
    CONSTRAINT PK_GR01_SALA_CONVENCION PRIMARY KEY (id_oficina)
);

-- foreign keys
-- Reference: FK_ALQUILA_CLIENTE (table: ALQUILA)
ALTER TABLE GR01_ALQUILA ADD CONSTRAINT FK_GR01_ALQUILA_CLIENTE
    FOREIGN KEY (tipo_doc, nro_doc)
    REFERENCES GR01_CLIENTE (tipo_doc, nro_doc)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_ALQUILA_OFICINA (table: ALQUILA)
ALTER TABLE GR01_ALQUILA ADD CONSTRAINT FK_GR01_ALQUILA_OFICINA
    FOREIGN KEY (id_oficina)
    REFERENCES GR01_OFICINA (id_oficina)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_OFICINA_REG_OFICINA (table: OFICINA_REG)
ALTER TABLE GR01_OFICINA_REG ADD CONSTRAINT FK_GR01_OFICINA_REG_OFICINA
    FOREIGN KEY (id_oficina)
    REFERENCES GR01_OFICINA (id_oficina)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_SALA_CONVENCION_OFICINA (table: SALA_CONVENCION)
ALTER TABLE GR01_SALA_CONVENCION ADD CONSTRAINT FK_GR01_SALA_CONVENCION_OFICINA
    FOREIGN KEY (id_oficina)
    REFERENCES GR01_OFICINA (id_oficina)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- End of file.






CREATE VIEW GR01_V_OFICINA_REGULAR AS
    SELECT r.id_oficina, o.superficie,o.cant_max_personas, o.monto_alquiler,r.cant_escritorios, r.cant_pc
    FROM GR01_OFICINA o NATURAL JOIN GR01_OFICINA_REG r;
/*SELECT * FROM GR01_V_OFICINA_REGULAR;*/

CREATE VIEW GR01_V_SALA_CONVENCION AS
    SELECT s.id_oficina, o.superficie, o.cant_max_personas, o.monto_alquiler, s.cant_pantallas,s.cant_sillas
    FROM GR01_OFICINA o NATURAL JOIN GR01_SALA_CONVENCION s;

CREATE OR REPLACE FUNCTION FN_GR01_V_OFICINA_REGULAR()
RETURNS TRIGGER AS $$
    BEGIN


        IF (TG_OP = 'UPDATE') THEN
            UPDATE GR01_OFICINA
                SET superficie = NEW.superficie,cant_max_personas = NEW.cant_max_personas, monto_alquiler = NEW.monto_alquiler
                WHERE id_oficina = NEW.id_oficina;
            UPDATE GR01_OFICINA_REG
                SET cant_escritorios = NEW.cant_escritorios, cant_pc = NEW.cant_pc
                WHERE id_oficina = NEW.id_oficina;
        ELSE

            BEGIN
            --RAISE EXCEPTION '%,%,%,%',new.id_oficina , new.superficie, new.cant_max_personas, new.monto_alquiler;
            INSERT INTO GR01_OFICINA (id_oficina, superficie, cant_max_personas, monto_alquiler, tipo_o)
                VALUES (new.id_oficina , new.superficie, new.cant_max_personas, new.monto_alquiler,'R');
                --VALUES (new.id_oficina , 8, 8, 8.10,'R');
            INSERT INTO GR01_OFICINA_REG (id_oficina, cant_escritorios,cant_pc)
             VALUES (NEW.id_oficina,NEW.cant_escritorios,NEW.cant_pc);
            END;
        END IF;
        RETURN NULL;
    END;
    $$
    LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION FN_GR01_V_SALA_CONVENCION()
RETURNS TRIGGER AS $$
    BEGIN
        IF (TG_OP = 'UPDATE') THEN
            UPDATE GR01_OFICINA
                SET superficie = NEW.superficie,cant_max_personas = NEW.cant_max_personas, monto_alquiler = NEW.monto_alquiler
                WHERE id_oficina = NEW.id_oficina;
            UPDATE GR01_V_SALA_CONVENCION
                SET cant_sillas = NEW.cant_sillas, cant_pantallas = NEW.cant_pantallas
                WHERE id_oficina = NEW.id_oficina;
        end if;
        IF (tg_op= 'INSERT') THEN
            INSERT INTO GR01_OFICINA (id_oficina, superficie, cant_max_personas, monto_alquiler, tipo_o)
                VALUES (NEW.id_oficina, new.superficie , new.cant_max_personas, new.monto_alquiler,'C');
            INSERT INTO GR01_V_SALA_CONVENCION (id_oficina,cant_pantallas, cant_sillas)
                VALUES (NEW.id_oficina, NEW.cant_pantallas,NEW.cant_sillas);
            return null;

        END IF;
        RETURN NULL;
    END;
    $$
    LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR01_V_SALA_CONVENCION
    INSTEAD OF INSERT OR UPDATE
    ON GR01_V_SALA_CONVENCION
    FOR EACH ROW
    EXECUTE PROCEDURE FN_GR01_V_SALA_CONVENCION();

CREATE TRIGGER TR_GR01_V_OFICINA_REGULAR
    INSTEAD OF INSERT OR UPDATE
    ON GR01_V_OFICINA_REGULAR
    FOR EACH ROW
    EXECUTE PROCEDURE FN_GR01_V_OFICINA_REGULAR();



INSERT INTO gr01_v_oficina_regular (id_oficina,superficie,cant_max_personas,monto_alquiler,cant_escritorios,cant_pc)
        VALUES (2008, 93, 8, 55.54, 2, 2);

select *
from  gr01_v_oficina_regular;