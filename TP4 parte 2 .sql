SET search_path TO unc_esq_peliculas, public;
SET search_path TO unc_esq_voluntario, public;
SET search_path TO unc_246295;


--eJ. 1 Consultas con anidamiento (usando IN, NOT IN, EXISTS, NOT EXISTS)

--1.1

SELECT DISTINCT re.codigo_pelicula
FROM unc_esq_peliculas.pelicula p, unc_esq_peliculas.renglon_entrega re, unc_esq_peliculas.entrega e
WHERE p.codigo_pelicula = re.codigo_pelicula
  AND e.nro_entrega = re.nro_entrega
  AND p.idioma = 'Inglés'
  AND extract(YEAR from e.fecha_entrega)= 2006;


SELECT codigo_pelicula
FROM unc_esq_peliculas.pelicula
WHERE idioma = 'Inglés';

SELECT codigo_pelicula
FROM  pelicula
WHERE idioma = 'Inglés' AND
      codigo_pelicula IN (
          SELECT codigo_pelicula
          FROM renglon_entrega
          WHERE nro_entrega IN (
              SELECT nro_entrega
              FROM entrega
              WHERE extract(YEAR from fecha_entrega)= 2006
              )
        );


SELECT nro_entrega
FROM unc_esq_peliculas.entrega e
WHERE extract(YEAR from e.fecha_entrega)= 2006;



SELECT codigo_pelicula, idioma
FROM unc_esq_peliculas.pelicula
WHERE idioma like ('Inglés');


--1.2
SELECT COUNT(codigo_pelicula)
FROM unc_esq_peliculas.pelicula
WHERE codigo_pelicula IN(
    SELECT codigo_pelicula
    FROM unc_esq_peliculas.renglon_entrega
    WHERE nro_entrega IN(
        SELECT nro_entrega
        FROM unc_esq_peliculas.entrega
        WHERE extract(YEAR from entrega.fecha_entrega)= 2006 AND
              id_distribuidor IN(
                  SELECT id_distribuidor
                  FROM unc_esq_peliculas.distribuidor
                  WHERE tipo = 'N'
                )
        )
    );

--1.3



SELECT id_departamento, id_distribuidor
FROM departamento
WHERE (id_departamento, id_distribuidor) NOT IN(
    SELECT empleado.id_departamento, empleado.id_distribuidor
    FROM empleado
    WHERE id_tarea IN (
        SELECT id_tarea
        FROM tarea
        WHERE tarea.sueldo_maximo-tarea.sueldo_minimo < tarea.sueldo_maximo * 0.1
        )
    );


SELECT count(*)
FROM departamento
WHERE (id_departamento, id_distribuidor)  NOT IN (
                        SELECT id_departamento, id_distribuidor
                        FROM  empleado e,
                              tarea t
                        WHERE (e.id_tarea = t.id_tarea)
                        AND (t.sueldo_maximo - t.sueldo_minimo) < (t.sueldo_maximo*0.1)
    );

SELECT id_departamento
FROM departamento
WHERE (id_departamento, id_distribuidor)  NOT IN (SELECT id_departamento, id_distribuidor
                              FROM empleado
                              WHERE id_tarea IN (SELECT tarea.id_tarea
                                                 FROM tarea
                                                 WHERE (sueldo_maximo - sueldo_minimo) < (sueldo_maximo * 0.1)));

--1.4

SELECT p.codigo_pelicula, e.nro_entrega, d.tipo
FROM pelicula p
JOIN renglon_entrega re ON p.codigo_pelicula = re.codigo_pelicula
JOIN entrega e ON re.nro_entrega = e.nro_entrega
JOIN distribuidor d ON e.id_distribuidor = d.id_distribuidor
WHERE re.codigo_pelicula NOT IN(
    SELECT codigo_pelicula
    FROM renglon_entrega
    WHERE nro_entrega IN(
        SELECT nro_entrega
        FROM entrega
        WHERE id_distribuidor IN(
            SELECT id_distribuidor
            FROM distribuidor
            WHERE tipo = 'N'
        )
    )
);



--2.1

SELECT i.nombre_institucion, count(v.nro_voluntario)
FROM institucion i
JOIN voluntario v ON v.id_institucion = i.id_institucion
WHERE horas_aportadas>0
GROUP BY i.id_institucion
ORDER BY 1;

--2.2

SELECT COUNT(v.id_coordinador) AS "Numero de coordinadores", p.nombre_pais, c.nombre_continente
FROM voluntario v
JOIN institucion i on v.id_institucion = i.id_institucion
JOIN direccion d on i.id_direccion = d.id_direccion
JOIN pais p on p.id_pais = d.id_pais
JOIN continente c on c.id_continente = p.id_continente
GROUP BY (p.nombre_pais, c.nombre_continente)
ORDER BY (nombre_continente, nombre_pais);

--2.3

SELECT v.apellido, v.nombre, v.fecha_nacimiento
FROM voluntario v
WHERE id_institucion =
      (SELECT id_institucion
       FROM voluntario
       WHERE apellido = 'Zlotkey') AND v.apellido != 'Zlotkey';

--2.4

SELECT v.nro_voluntario, v.apellido, v.horas_aportadas
FROM voluntario v
WHERE v.horas_aportadas >
      (SELECT AVG(horas_aportadas)
       FROM voluntario)
ORDER BY horas_aportadas ASC;

--3
CREATE TABLE DistribuidorNac
(
id_distribuidor numeric(5,0) NOT NULL,
nombre character varying(80) NOT NULL,
direccion character varying(120) NOT NULL,
telefono character varying(20),
nro_inscripcion numeric(8,0) NOT NULL,
encargado character varying(60) NOT NULL,
id_distrib_mayorista numeric(5,0),
CONSTRAINT pk_distribuidorNac PRIMARY KEY (id_distribuidor)
);