SET search_path TO unc_esq_voluntario, public;

-- Muestre, para cada institución, su nombre y la cantidad de voluntarios que realizan aportes. Ordene el resultado por nombre de institución.

SELECT COUNT(v.*), i.nombre_institucion
FROM voluntario v
RIGHT JOIN institucion i
ON v.id_institucion = i.id_institucion
GROUP BY i.nombre_institucion ;

--Determine la cantidad de coordinadores en cada país, agrupados por nombre de país y nombre de continente. Etiquete la primer
-- columna como 'Número de coordinadores'

SELECT COUNT(v.id_coordinador) "Número de coordinadores", c.nombre_continente, p.nombre_pais
FROM pais p
RIGHT JOIN continente c
ON p.id_continente = c.id_continente
RIGHT JOIN voluntario v
ON p.id_pais IN(SELECT d.id_pais
    FROM direccion d
    WHERE d.id_direccion IN(SELECT i.id_direccion
        FROM institucion i
        WHERE i.id_institucion IN(SELECT v.id_institucion
            FROM voluntario v)))
GROUP BY p.nombre_pais, c.nombre_continente;

-- Escriba una consulta para mostrar el apellido, nombre y fecha de nacimiento de cualquier voluntario que trabaje en la misma institución
-- que el Sr. Zlotkey. Excluya del resultado a Zlotkey.

SELECT apellido, nombre, fecha_nacimiento
FROM voluntario
WHERE id_institucion IN(SELECT id_institucion
    FROM voluntario
    WHERE apellido = 'Zlotkey')
AND apellido != 'Zlotkey';

-- Cree una consulta para mostrar los números de voluntarios y los apellidos de todos los voluntarios cuya cantidad de horas aportadas sea
-- mayor que la media de las horas aportadas. Ordene los resultados por horas aportadas en orden ascendente.
    SELECT nro_voluntario, apellido
    FROM voluntario
    WHERE horas_aportadas > (SELECT AVG(horas_aportadas)
    FROM voluntario
    GROUP BY horas_aportadas );

