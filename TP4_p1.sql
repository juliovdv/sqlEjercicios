--Seleccione el identificador y nombre de todas las instituciones que son Fundaciones.(V)
SET search_path TO unc_esq_voluntario, public;
--SET search_path TO unc_esq_peliculas, public;
SELECT id_institucion, nombre_institucion
FROM institucion
WHERE nombre_institucion LIKE 'FUNDACION%';
--Seleccione el identificador de distribuidor, identificador de departamento y nombre de todos los departamentos.(P)
SET search_path TO unc_esq_peliculas, public;
SELECT id_distribuidor, id_departamento, nombre
FROM departamento;
--Muestre el nombre, apellido y el teléfono de todos los empleados cuyo id_tarea sea 7231, ordenados por apellido y nombre.(P)
SET search_path TO unc_esq_peliculas, public;
SELECT nombre, apellido, telefono
FROM empleado
WHERE id_tarea = '7231'
ORDER BY apellido, nombre ;
--Muestre el apellido e identificador de todos los empleados que no cobran porcentaje de comisión.(P)
SELECT nombre, apellido, id_empleado, porc_comision
FROM empleado
WHERE porc_comision IS NULL;
--Muestre el apellido y el identificador de la tarea de todos los voluntarios que no tienen coordinador.(V)
SET search_path TO unc_esq_voluntario, public;
SELECT nombre, apellido, id_tarea
FROM voluntario
WHERE id_coordinador IS NULL;
--Muestre los datos de los distribuidores internacionales que no tienen registrado teléfono. (P)
SET search_path TO unc_esq_peliculas, public;
SELECT *
FROM distribuidor
WHERE telefono IS NULL AND tipo = UPPER('I');
--Muestre los apellidos, nombres y mails de los empleados con cuentas de gmail y cuyo sueldo sea superior a $ 1000. (P)
SELECT apellido, nombre, e_mail
FROM empleado
WHERE e_mail LIKE '%gmail%' AND sueldo > '1000' ;
--Seleccione los diferentes identificadores de tareas que se utilizan en la tabla empleado. (P)
SELECT DISTINCT(id_tarea)
FROM empleado;
--Muestre el apellido, nombre y mail de todos los voluntarios cuyo teléfono comienza con +51. Coloque el encabezado de las columnas de los títulos
-- 'Apellido y Nombre' y 'Dirección de mail'. (V)
SET search_path TO unc_esq_voluntario, public;
SELECT apellido ||' '|| nombre "Apellido y Nombre", e_mail "Direccion de mail"
FROM voluntario
WHERE telefono LIKE '+51%';
--Hacer un listado de los cumpleaños de todos los empleados donde se muestre el nombre y el apellido (concatenados y separados por una coma)
-- y su fecha de cumpleaños (solo el día y el mes), ordenado de acuerdo al mes y día de cumpleaños en forma ascendente.	(P)
SET search_path TO unc_esq_peliculas, public;
SELECT nombre ||', '|| apellido "Apellido y Nombre", EXTRACT(DAY from fecha_nacimiento) "dia", EXTRACT(MONTH from fecha_nacimiento) "mes"
FROM empleado
ORDER BY mes , dia ;
--Recupere la cantidad mínima, máxima y promedio de horas aportadas por los voluntarios nacidos desde 1990. (V)
SET search_path TO unc_esq_voluntario, public;
SELECT MAX(horas_aportadas) "Max", MIN(horas_aportadas) "Min", AVG(horas_aportadas) "Prom"
FROM voluntario
WHERE fecha_nacimiento > TO_DATE('1990/01/01','YYYY/MM/DD');
--Listar la cantidad de películas que hay por cada idioma. (P)
SET search_path TO unc_esq_peliculas, public;
SELECT COUNT(*), idioma
FROM pelicula
GROUP BY idioma;
--Calcular la cantidad de empleados por departamento. (P)
SELECT COUNT(*), id_departamento, id_distribuidor
FROM empleado
GROUP BY id_departamento, id_distribuidor;
--Mostrar los códigos de películas que han recibido entre 3 y 5 entregas.
-- (veces entregadas, NO cantidad de películas entregadas).
SELECT codigo_pelicula, COUNT(codigo_pelicula) "cuenta"
FROM renglon_entrega
GROUP BY codigo_pelicula
HAVING COUNT(codigo_pelicula) BETWEEN '3' AND '5';
--¿Cuántos cumpleaños de voluntarios hay cada mes?
SET search_path TO unc_esq_voluntario, public;
SELECT COUNT(EXTRACT(MONTH from fecha_nacimiento)), EXTRACT(MONTH from fecha_nacimiento)
FROM voluntario
GROUP BY EXTRACT(MONTH from fecha_nacimiento)
ORDER BY EXTRACT(MONTH from fecha_nacimiento);
--¿Cuáles son las 2 instituciones que más voluntarios tienen?
SELECT id_institucion, COUNT(id_institucion)
FROM voluntario
GROUP BY id_institucion
ORDER BY COUNT(id_institucion) DESC
LIMIT 2;
--¿Cuáles son los id de ciudades que tienen más de un departamento?
SET search_path TO unc_esq_peliculas, public;
SELECT id_ciudad, COUNT(id_ciudad)
FROM unc_esq_peliculas.departamento
GROUP BY id_ciudad
HAVING COUNT(id_ciudad) > '1';



SELECT nro_voluntario AS "V NRO", apellido, nombre, v.id_tarea AS "V TAREA", t.id_tarea AS "T TAREA", nombre_tarea
FROM voluntario v
FULL JOIN tarea t
ON (v.id_tarea = v.id_tarea)
JOIN institucion i
ON (v.id_institucion = i.id_institucion)
ORDER BY 1;

SET search_path TO unc_esq_peliculas, public;
SELECT COUNT(*)
FROM distribuidor
WHERE tipo = UPPER('i') AND telefono LIKE '%2';

SELECT id_pais, COUNT(*)
FROM ciudad
WHERE nombre_ciudad LIKE '%ia'
GROUP BY id_pais;