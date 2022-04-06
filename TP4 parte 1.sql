SET search_path TO unc_esq_peliculas, public;
SET search_path TO unc_esq_voluntario, public;


--1.
SELECT id_institucion, nombre_institucion
FROM institucion
WHERE nombre_institucion LIKE 'FUNDACION%';

--2. Seleccione el identificador de distribuidor, identificador de departamento y nombre de todos los departamentos.(P)
SELECT id_distribuidor, id_departamento, nombre
FROM departamento;

--3-Muestre el nombre, apellido y el teléfono de todos los empleados cuyo id_tarea sea 7231, ordenados por apellido y nombre.(P)
SELECT nombre, apellido, telefono
FROM empleado
WHERE id_tarea = '7231'
ORDER BY 2, 1;

--4-Muestre el apellido e identificador de todos los empleados que no cobran porcentaje de comisión.℗
SELECT apellido, id_empleado
FROM empleado
WHERE porc_comision IS NULL;

--5-Muestre el apellido y el identificador de la tarea de todos los voluntarios que no tienen coordinador.(V)

SELECT apellido, id_tarea
FROM voluntario
WHERE id_coordinador IS NULL;

--6-Muestre los datos de los distribuidores internacionales que no tienen registrado teléfono. ℗

SELECT *
FROM distribuidor
WHERE tipo = 'I' AND telefono IS NULL;

--7-Muestre los apellidos, nombres y mails de los empleados con cuentas de gmail y cuyo sueldo sea superior a $ 1000. ℗
SELECT apellido, nombre, e_mail
FROM empleado
WHERE e_mail LIKE '%@gmail%' AND sueldo > 1000;

--8-Seleccione los diferentes identificadores de tareas que se utilizan en la tabla empleado. (P)
SELECT DISTINCT id_tarea
FROM empleado;

--9-Muestre el apellido, nombre y mail de todos los voluntarios cuyo teléfono comienza con
-- +51. Coloque el encabezado de las columnas de los títulos 'Apellido y Nombre' y
-- 'Dirección de mail'. (V)
SELECT apellido|| ', ' ||nombre AS "Apellido y Nombre", e_mail AS "Direccion de mail"
FROM voluntario
WHERE telefono LIKE '+51%';

--10-Hacer un listado de los cumpleaños de todos los empleados donde se muestre el nombre
-- y el apellido (concatenados y separados por una coma) y su fecha de cumpleaños
-- (solo el día y el mes), ordenado de acuerdo al mes y día de cumpleaños en forma ascendente.(P)
SELECT apellido|| ', ' ||nombre AS "Apellido y Nombre",
       extract(DAY from fecha_nacimiento )|| '-' ||extract(MONTH from fecha_nacimiento) AS "Fecha de cumpleaños"
FROM empleado
ORDER BY extract(MONTH from fecha_nacimiento), extract(DAY from fecha_nacimiento );

--11- recupere la cantidad mínima, máxima y promedio de horas aportadas por los voluntarios nacidos desde 1990. (V)

SELECT MIN(horas_aportadas) AS "Minimo", MAX(horas_aportadas) AS "Maximo", AVG(horas_aportadas) AS "promedio"
FROM voluntario
WHERE fecha_nacimiento > to_date('1990/01/01', 'xxxx/xx/xx');

--12- Listar la cantidad de películas que hay por cada idioma.
SELECT idioma, COUNT(idioma)
FROM pelicula
GROUP BY idioma

--13- Calcular la cantidad de empleados por departamento.

SELECT id_departamento, COUNT(*)
FROM empleado
GROUP BY id_departamento
ORDER BY 1;

--14- Mostrar los códigos de películas que han recibido entre 3 y 5 entregas. (veces entregadas, NO cantidad de películas entregadas).

SELECT codigo_pelicula
FROM renglon_entrega
GROUP BY codigo_pelicula
HAVING COUNT(*) BETWEEN 3 AND 5;

--15- ¿Cuántos cumpleaños de voluntarios hay cada mes?

SELECT extract(MONTH from fecha_nacimiento) AS "Mes" ,COUNT(*) AS "Cantidad cumpleanos"
FROM voluntario
GROUP BY 1
ORDER BY 1;

--16- ¿Cuáles son las 2 instituciones que más voluntarios tienen?

SELECT id_institucion, COUNT(nro_voluntario) AS "Cantidad de voluntarios"
FROM voluntario
GROUP BY 1
ORDER BY 2 DESC
LIMIT 2;

--17- ¿Cuáles son los id de ciudades que tienen más de un departamento?

SELECT id_ciudad, COUNT(id_departamento) AS "Cantidad departamentos"
FROM departamento
GROUP BY 1
HAVING COUNT(id_departamento) > 1
ORDER BY 2;

