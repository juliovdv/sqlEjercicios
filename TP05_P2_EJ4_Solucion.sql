--A. La modalidad de la imagen médica puede tomar los siguientes valores
-- RADIOLOGIA CONVENCIONAL, FLUOROSCOPIA, ESTUDIOS RADIOGRAFICOS CON FLUOROSCOPIA, MAMOGRAFIA, SONOGRAFIA,
--TIPO - ATRIBUTO
ALTER TABLE p5p2e4_imagen_medica
   ADD CONSTRAINT CK_MODALIDAD_VALIDA
   CHECK (modalidad iN ('RADIOLOGIA CONVENCIONAL', 'FLUOROSCOPIA', 'ESTUDIOS RADIOGRAFICOS CON FLUOROSCOPIA',
                        'MAMOGRAFIA', 'SONOGRAFIA' ))
;

-- B. Cada imagen de cada paciente no debe tener más de 5 procesamientos.
-- TIPO TABLA
/*
ALTER TABLE p5p2e4_procesamiento
   ADD CONSTRAINT CK_CANTIDAD_PROCESAMIENTOS
   CHECK ( NOT EXISTS (
            SELECT 1
            FROM p5p2e4_procesamiento
            GROUP BY id_paciente, id_imagen
            HAVING COUNT(*) > 5
       ))
;

*/

-- C. Agregue dos atributos de tipo fecha a las tablas Imagen_medica y Procesamiento,
-- una indica la fecha de la imagen y la otra la fecha de procesamiento de la imagen
-- y controle que la segunda no sea menor que la primera.
--TIPO GENERAL

ALTER TABLE p5p2e4_imagen_medica
ADD COLUMN fecha_img date;

ALTER TABLE p5p2e4_procesamiento
ADD COLUMN fecha_proc date;

/*
CREATE ASSERTION
   CHECK ( NOT EXISTS (
            select 1
            FROM p5p2e4_imagen_medica i JOIN p5p2e4_procesamiento p
            ON (i.id_paciente = p.id_paciente and i.id_imagen = p.id_imagen)
            WHERE fecha_proc < fecha_img )
   )
;

*/

-- D. Sólo se pueden realizar dos FLUOROSCOPIA anuales por paciente
--  TIPO TABLA.
/*
ALTER TABLE p5p2e4_imagen_medica
   ADD CONSTRAINT CK_CANTIDAD_PROCESAMIENTOS
   CHECK ( NOT EXISTS (
                SELECT 1
                FROM p5p2e4_imagen_medica
                WHERE modalidad = 'FLUOROSCOPIA'
                GROUP BY id_paciente, extract(year from fecha_img)
                HAVING COUNT(*) > 2 ))
;

*/

--E. No se pueden aplicar algoritmos de costo computacional “O(n)” a imágenes de FLUOROSCOPIA
-- TIPO - GENERAL
/*
CREATE ASSERTION
   CHECK ( NOT EXISTS (
                SELECT 1
                FROM p5p2e4_imagen_medica i JOIN p5p2e4_procesamiento p ON
                    (i.id_paciente = p.id_paciente AND i.id_imagen = p.id_imagen)
                    JOIN p5p2e4_algoritmo a ON ( p.id_algoritmo = a.id_algoritmo )
                WHERE modalidad = 'FLUOROSCOPIA' AND
                    costo_computacional = 'O(n)'
));
*/
