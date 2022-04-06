SET search_path TO unc_esq_peliculas, public;
-- Listar todas las películas que poseen entregas de películas de idioma inglés durante el año 2006. (P)

SELECT codigo_pelicula, titulo, idioma
FROM pelicula
WHERE idioma ='Inglés' AND
codigo_pelicula IN(SELECT codigo_pelicula
                   FROM renglon_entrega
                   WHERE nro_entrega IN(SELECT nro_entrega
                                        FROM entrega
                                        WHERE extract(YEAR FROM fecha_entrega)=2006));

-- Indicar la cantidad de películas que han sido entregadas en 2006 por un distribuidor nacional. Trate de resolverlo utilizando ensambles.(P)

SELECT COUNT(codigo_pelicula)
FROM pelicula
WHERE codigo_pelicula IN(SELECT codigo_pelicula
                         FROM renglon_entrega
                         WHERE nro_entrega IN(SELECT nro_entrega
                         FROM entrega
                         WHERE extract(YEAR FROM fecha_entrega)=2006 AND
                              id_distribuidor IN(SELECT id_distribuidor
                                                 FROM nacional)));

-- Indicar los departamentos que no posean empleados cuya diferencia de sueldo máximo y mínimo (asociado a la tarea que realiza) no supere el 40% del sueldo máximo. (P)

SELECT *
FROM departamento
WHERE id_departamento NOT IN(SELECT id_departamento
					  FROM empleado
					  WHERE id_tarea NOT IN (SELECT id_tarea
									FROM tarea
			WHERE (sueldo_maximo - sueldo_minimo) < (sueldo_maximo * 0.4)));

-- Liste las películas que nunca han sido entregadas por un distribuidor nacional.(P)

SELECT codigo_pelicula, titulo
FROM pelicula
WHERE codigo_pelicula IN(SELECT codigo_pelicula
                         FROM renglon_entrega
                         WHERE nro_entrega IN(SELECT nro_entrega
                                              FROM entrega
                                              WHERE id_distribuidor NOT IN(SELECT id_distribuidor
                                                                           FROM nacional)));

-- Determinar los jefes que poseen personal a cargo y cuyos departamentos (los del jefe)  se encuentren en la Argentina.

SELECT id_jefe
FROM empleado
WHERE id_jefe IN(SELECT id_empleado
                 FROM empleado
                 WHERE id_departamento IN(SELECT id_departamento
                                          FROM departamento
                                          WHERE id_ciudad IN(SELECT id_ciudad
                                                             FROM ciudad
                                                             WHERE id_pais IN(SELECT id_pais
                                                                              FROM pais))));

-- Liste el apellido y nombre de los empleados que pertenecen aquellos departamentos residentes en el país y donde el jefe de departamento
-- posee más del 10% de comisión.

SELECT apellido, nombre
FROM empleado
WHERE id_departamento IN(SELECT id_departamento
                         FROM departamento
                         WHERE id_ciudad IN(SELECT id_ciudad
                                            FROM ciudad
                                            WHERE id_pais IN(SELECT id_pais
                                            FROM pais
                                            WHERE nombre_pais = ‘ARGENTINA’))
                         AND jefe_departamento IN(SELECT id_empleado
                                                  FROM empleado
                                                  WHERE porc_comision > 10));

-- Indicar la cantidad de películas entregadas a partir del 2010, por género.
                --Indicar la cantidad de películas entregadas a partir del 2010.

SELECT genero, COUNT(*)
FROM pelicula
WHERE codigo_pelicula IN(SELECT codigo_pelicula
                         FROM renglon_entrega
                         WHERE nro_entrega IN(SELECT nro_entrega
                                              FROM entrega
                                              WHERE extract(YEAR FROM fecha_entrega)=2010))
GROUP BY genero;

            -- Listar las películas entregadas a partir del 2010, por género.

	SELECT titulo , genero
	FROM pelicula
	WHERE codigo_pelicula IN(SELECT codigo_pelicula
                             FROM renglon_entrega
                             WHERE nro_entrega IN(SELECT nro_entrega
                                                  FROM entrega
                                                  WHERE extract(YEAR FROM fecha_entrega)=2010))
	                                              GROUP BY genero;

--Realizar un resumen de entregas por día, indicando el video club al cual se le realizó la entrega y la cantidad entregada. Ordenar el
-- resultado por fecha.
SELECT re.cantidad AS c, e.fecha_entrega AS fe, e.id_video AS v
FROM entrega e
LEFT JOIN renglon_entrega re
ON e.nro_entrega = re.nro_entrega
GROUP BY c,fe,v;

-- Listar, para cada ciudad, el nombre de la ciudad y la cantidad de empleados mayores de edad que desempeñan tareas en departamentos
-- de la misma y que posean al menos 30 empleados.

SELECT c.nombre_ciudad, COUNT(e.*)
FROM ciudad c
JOIN departamento d
ON c.id_ciudad = d.id_ciudad
JOIN empleado e
ON d.id_departamento = e.id_departamento
WHERE 2021 - extract(YEAR FROM fecha_nacimiento) >= 18
GROUP BY c.nombre_ciudad;