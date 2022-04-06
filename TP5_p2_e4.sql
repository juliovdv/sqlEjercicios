--La modalidad de la imagen médica puede tomar los siguientes valores
-- RADIOLOGIA CONVENCIONAL, FLUOROSCOPIA, ESTUDIOS RADIOGRAFICOS CON FLUOROSCOPIA, MAMOGRAFIA, SONOGRAFIA
-- TIPO - check atributo = dominio
ALTER TABLE P5P2E4_IMAGEN_MEDICA
ADD CONSTRAINT ck_modalidad
CHECK (modalidad IN ('RADIOLOGIA CONVENCIONAL', 'FLUOROSCOPIA', 'ESTUDIOS RADIOGRAFICOS CON FLUOROSCOPIA','MAMOGRAFIA', 'SONOGRAFIA'));

--Cada imagen no debe tener más de 5 procesamientos.
ALTER TABLE P5P2E4_PROCESAMIENTO
ADD CONSTRAINT ck_cantidad_procesamiento_imagen
CHECK (NOT EXISTS (SELECT 1
    FROM P5P2E4_PROCESAMIENTO
    GROUP BY id_imagen
    HAVING COUNT(*) > 5));

--Agregue dos atributos de tipo fecha a las tablas Imagen_medica y Procesamiento, una indica la fecha de la imagen y
-- la otra la fecha de procesamiento de la imagen y controle que la segunda no sea menor que la primera.
--TIPO: general
ALTER TABLE P5P2E4_IMAGEN_MEDICA ADD COLUMN fecha_imagen DATE;
ALTER TABLE P5P2E4_PROCESAMIENTO ADD COLUMN fecha_procesamiento_imagen DATE;

CREATE ASSERTION ck_fechas
   CHECK (NOT EXISTS (
            SELECT 1
            FROM P5P2E4_PROCESAMIENTO p
            WHERE id_imagen IN (SELECT id_imagen)
                                  FROM P5P2E4_IMAGEN_MEDICA i)
            AND p.fecha_procesamiento_imagen < i.fecha_imagen);

--Cada paciente sólo puede realizar dos FLUOROSCOPIA anuales.
--Tipo: tabla
ALTER TABLE P5P2E4_IMAGEN_MEDICA
ADD CONSTRAINT ck_cantidad_fluoroscopia
CHECK (NOT EXISTS (SELECT 1
    FROM P5P2E4_IMAGEN_MEDICA
    WHERE modalidad = 'FLUOROSCOPIA'
    GROUP BY id_paciente, EXTRACT(year from p5p2e4_imagen_medica.fecha_imagen)
    HAVING COUNT(*) > 2));



--No se pueden aplicar algoritmos de costo computacional “O(n)” a imágenes de FLUOROSCOPIA
--tipo: general

CREATE ASSERTION ck_costo_computacional
   CHECK (NOT EXISTS (
            SELECT 1
            FROM P5P2E4_PROCESAMIENTO p
            JOIN P5P2E4_ALGORITMO a
            ON p.id_algoritmo = a.id_algoritmo
            JOIN P5P2E4_IMAGEN_MEDICA i
            ON p.id_imagen = i.id_imagen
            WHERE a.costo_computacional = 'O(n)'
            AND i.modalidad = 'FLUOROSCOPIA';));