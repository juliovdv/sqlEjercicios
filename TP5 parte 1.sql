

--1.A
ALTER TABLE p5p1e1_contiene DROP CONSTRAINT fk_p5p1e1_contiene_palabra;

ALTER TABLE p5p1e1_contiene ADD CONSTRAINT fk_p5p1e1_contiene_palabra
FOREIGN KEY (idioma, cod_palabra)
REFERENCES p5p1e1_palabra (idioma, cod_palabra)
MATCH SIMPLE
ON UPDATE CASCADE
ON DELETE CASCADE;