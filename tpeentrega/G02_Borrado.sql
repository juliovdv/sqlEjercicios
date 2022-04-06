--Borrado de triggers y funciones
DROP FUNCTION IF EXISTS fn_gr02_generar_consistencia() CASCADE;
DROP FUNCTION IF EXISTS trfn_gr02_modificar_tipo_grupo() CASCADE;
DROP FUNCTION IF EXISTS trfn_gr02_actualizar_usuarios() CASCADE;
DROP FUNCTION IF EXISTS trfn_gr02_v_grupo_comun() CASCADE;
DROP FUNCTION IF EXISTS trfn_gr02_v_grupo_excl() CASCADE;

--Borrado de vistas
DROP VIEW IF EXISTS gr02_v_grupo_exclusivo CASCADE;
DROP VIEW IF EXISTS gr02_v_grupo_comun CASCADE;
DROP VIEW IF EXISTS gr02_v_grupos_comp CASCADE;
DROP VIEW IF EXISTS gr02_v_grupos_integ CASCADE;
DROP VIEW IF EXISTS gr02_v_grupo_cantidad_usuarios CASCADE;

--Borrado de tablas
DROP TABLE IF EXISTS gr02_integra CASCADE;
DROP TABLE IF EXISTS gr02_gr_exclusivo CASCADE;
DROP TABLE IF EXISTS gr02_gr_comun CASCADE;
DROP TABLE IF EXISTS gr02_grupo CASCADE;
DROP TABLE IF EXISTS gr02_usuario CASCADE;