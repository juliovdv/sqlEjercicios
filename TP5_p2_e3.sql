--Controlar que las nacionalidades sean 'Argentina' 'Español' 'Inglés' 'Alemán' o 'Chilena'.
-- TIPO - check atributo = dominio
ALTER TABLE P5P1E1_ARTICULO
ADD CONSTRAINT ck_limitar_nacionalidad
CHECK ( nacionalidad IN ('Argentina','Español','Inglés','Alemán','Chilena') );

--Para las fechas de publicaciones se debe considerar que sean fechas posteriores o iguales al 2010.
-- TIPO - check atributo = dominio
ALTER TABLE P5P1E1_ARTICULO
ADD CONSTRAINT ck_fecha_publicacion
CHECK ( extract(year from fecha_publicacion) >= 2010 );

--Cada palabra clave puede aparecer como máximo en 5 artículos.
-- TIPO - TABLA
ALTER TABLE P5P1E1_CONTIENE
ADD CONSTRAINT ck_cantidad_articulos
CHECK (NOT EXISTS ((SELECT 1
        FROM P5P1E1_CONTIENE
        GROUP BY idioma,cod_palabra)
        HAVING COUNT (*) > 5));
--correcta:
ALTER TABLE p5p2e3_contiene
   ADD CONSTRAINT ck_cantpalabra_articulo
   CHECK ( NOT EXISTS (
             SELECT 1
             FROM p5p2e3_contiene
             GROUP BY idioma, cod_palabra
             HAVING COUNT(*) > 5));

--Sólo los autores argentinos pueden publicar artículos que contengan más de 10 palabras claves, pero con un tope de 15 palabras,
-- el resto de los autores sólo pueden publicar artículos que contengan hasta 10 palabras claves.
-- TIPO - general

--correcta:
CREATE ASSERTION CK_CANTIDAD_PALABRAS
   CHECK (NOT EXISTS (
            SELECT 1
            FROM p5p2e3_articulo
            WHERE (nacionalidad LIKE 'Argentina' AND
                  id_articulo IN (SELECT id_articulo
                                  FROM p5p2e3_contiene
                                  GROUP BY id_articulo
                                    HAVING COUNT(*) > 15) ) OR
                  (nacionalidad NOT LIKE 'Argentina' AND
                  id_articulo IN (SELECT id_articulo
                                  FROM p5p2e3_contiene
                                  GROUP BY id_articulo
                                    HAVING COUNT(*) > 10) )))
;