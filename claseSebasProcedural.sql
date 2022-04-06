SELECT * FROM get_peliculas(8);
drop function get_peliculas;
CREATE OR REPLACE FUNCTION get_peliculas (p_cantidad int)
   RETURNS TABLE (
      _codigo_pelicula unc_esq_peliculas.pelicula.codigo_pelicula%type,
      _titulo unc_esq_peliculas.pelicula.titulo%type,
      _cantidad bigint
)
AS $$
BEGIN
   RETURN QUERY
 SELECT p.codigo_pelicula, p.titulo,t.cantidad
   FROM  unc_esq_peliculas.pelicula p
      JOIN
      (
       SELECT e.codigo_pelicula, COUNT(*) AS "cantidad"
       FROM unc_esq_peliculas.renglon_entrega e JOIN unc_esq_peliculas.entrega et
                           ON e.nro_entrega = et.nro_entrega
       WHERE et.fecha_entrega > NOW() - INTERVAL '1006 MONTH'
       GROUP BY e.codigo_pelicula
       ORDER BY cantidad DESC, e.codigo_pelicula
       LIMIT p_cantidad
      ) as t

ON (p.codigo_pelicula = t.codigo_pelicula);
END;
$$
LANGUAGE 'plpgsql';