-- 1.a
ALTER TABLE P5P1E1_CONTIENE DROP CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA ;

ALTER TABLE P5P1E1_CONTIENE ADD CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA
    FOREIGN KEY (idioma, cod_palabra)
    REFERENCES P5P1E1_PALABRA (idioma, cod_palabra)
    ON DELETE CASCADE ;

--2.a.1
SELECT * from tp5_p1_ej2_proyecto ;
delete from tp5_p1_ej2_proyecto where id_proyecto = 3;


--2.a.2
update tp5_p1_ej2_proyecto set id_proyecto = 7 where id_proyecto = 3;
SELECT * from tp5_p1_ej2_proyecto ;

--2.a.3
delete from tp5_p1_ej2_proyecto where id_proyecto = 22;

--2.a.4
SELECT * from tp5_p1_ej2_empleado ;
delete from tp5_p1_ej2_empleado where tipo_empleado = 'A' and nro_empleado = 5;

--2.a.5
SELECT * from tp5_p1_ej2_trabaja_en ;
update tp5_p1_ej2_trabaja_en set id_proyecto  = 3 where id_proyecto  =1;

--2.a.6
update tp5_p1_ej2_proyecto  set id_proyecto = 5 where id_proyecto = 2;

--2.b.1
SELECT * from tp5_p1_ej2_auspicio ;
update tp5_p1_ej2_auspicio set id_proyecto= 66, nro_empleado = 10
  where id_proyecto = 22
      and tipo_empleado = 'A'
      and nro_empleado = 5;