use Bicycles
go
/* 
Para las siguientes preguntas, implemente funciones y vistas que considere necesarios para facilitar la
generación de los resultados.
*/

/*En el año 2022, los usuarios que viven en la zona Centro occidental de Medellín,
cuántos recorridos por cada mes se hicieron cuya estación de origen es la ubicada en UPB 
y que iniciaron antes de las 10 am?  */

/* Tablas: usuarios, zona = 4, recorridos, estacion
*/
select top 1 * from zona;
go
SELECT TOP 1 * FROM dbo.usuario
go
select top 1 * from recorrido
go
select top 1 * from estacion
go

-- Pregunta 1 resulta.
SELECT 
	r.id_recorrido, 
	r.fecha_prestamo, 
	u.id_usuario, 
	z.descripcion, 
	e.nombre_estacion, 
	DATEPART(yy, r.fecha_prestamo) as 'Fecha_Prestamo'
	FROM usuario as u inner join zona as z
		on u.id_zona = z.id_zona
		inner join recorrido as r on r.id_usuario = u.id_usuario
		inner join estacion as e on e.id_estacion = r.id_estacion 
	where z.descripcion = 'Centro occidental' and e.nombre_estacion = 'UPB'
		and r.fecha_prestamo between '2022-01-01' and '2022-12-31'
		and r.hora_inicio < 10;
go
/*En el año 2022, los usuarios que viven en la zona Centro occidental de Medellín,
cuántos recorridos por cada mes se hicieron cuya estación de origen es la ubicada en UPB 
y que iniciaron antes de las 10 am?  */
-- misma consulta, pero ahora esta esta buscando desde la vista ya creada
SELECT f.id_usuario, f.id_recorrido, usr.edad, usr.id_zona, f.fecha_prestamo MES
FROM fullDetailAboutRecorrido f inner join usuario usr
		ON f.id_usuario = usr.id_usuario
WHERE  f.descripcion = 'Centro occidental'
		AND f.hora_inicio < 10
		AND f.nombre_estacion = 'UPB' 
		AND f.año = 2022
go


-- Consultando la vista creada
SELECT * FROM fullDetailAboutRecorrido as ODC
--where ODC.nombre_estacion = 'upb'
go

/* Vista que muestra todo el detalle de un recorrido*/
CREATE VIEW fullDetailAboutRecorrido AS
	SELECT r.id_recorrido, r.fecha_prestamo, u.id_usuario, z.descripcion, e.nombre_estacion,
	r.hora_inicio, r.hora_final, r.id_estacion as 'estOrigen', r.id_destino as 'estDestino',
	(r.hora_final - r.hora_inicio) as 'recorridoTotal',
	DATEPART(yy, r.fecha_prestamo)
	as 'año'
	FROM usuario as u inner join zona as z
	on u.id_zona = z.id_zona
	inner join recorrido as r on r.id_usuario = u.id_usuario
	inner join estacion as e on e.id_estacion = r.id_estacion
go


-- Consultando la vista creada
SELECT * FROM fullDetailAboutRecorrido
go

/* 
2. Una persona es considerada adulto mayor si su edad es superior a 60 años. En el 2022, cual fue
la duración promedio en horas de los recorridos por cada edad, por cada mes y por cada
estación de origen?
*/ -- horas = avg(horas) por cada edad > 60 
-- Promedio recorrido por edad
-- Por mes
-- por estacion
SELECT
	f.id_usuario, 
	e.id_operacion,
	f.hora_inicio,
	f.hora_final,
	usr.edad,
	e.id_estacion, 
	e.nombre_estacion,
	DATEPART(mm, f.fecha_prestamo), -- ene = 1, dic = 12
	avg(f.recorridoTotal)
	FROM fullDetailAboutRecorrido as f inner join estacion e
	ON f.estOrigen = e.id_estacion
		INNER JOIN usuario usr on usr.id_usuario = f.id_usuario
	WHERE f.estOrigen = 10 -- por estacion de origen.
		AND DATEPART(mm, f.fecha_prestamo) = 7 -- buscando el promedio por el mes
		AND usr.edad = 62 -- por edad
		--AND EDAD > 60
	GROUP BY f.id_usuario, e.id_estacion, e.id_operacion, 
		f.hora_inicio, 
		f.hora_final, 
		usr.edad,
		e.nombre_estacion,
		DATEPART(mm, f.fecha_prestamo)
GO




-- Consultando la vista creada
SELECT * FROM fullDetailAboutRecorrido re INNER JOIN estacion e on re.estOrigen = e.id_estacion
go
-- ¿Cuáles estaciones y cuándo (día y hora) se quedaron sin bicicletas para prestar?
SELECT count(re.nombre_estacion)  --* --count(re.hora_inicio)
	FROM fullDetailAboutRecorrido as re
	INNER JOIN estacion e on re.estOrigen = e.id_estacion
	where re.fecha_prestamo = '2022-01-02' 
	--and re.hora_inicio = 8
go


CREATE FUNCTION f_validandoBicicletasDisponibles


-- contar los registros de los nombres de las estaciones y restar de el total capacidad_bici ese total

select * from estacion where capacidad_bici = 48
go

select top 1 * from zona;
go
SELECT TOP 1 * FROM dbo.usuario
go
select top 1 * from recorrido
go
select top 1 * from estacion
go

-- estOrigen = id_estacion, estDestino = id_estacion

/* 
1.Implemente un procedimiento almacenado que permita ingresar un nuevo recorrido,
continuando con la numeración asignada. No debe permitir registrar recorridos que no cumplan
las validaciones establecidas por las restricciones de claves foráneas.
*/

create procedure dbo.p_AddingNewRecorrido(
	@id_recorrido INT,
	@fecha_prestamo DATE, 
	@hora_inicio INT,
	@hora_final INT,
	@id_usuario INT,
	@id_estacion INT,
	@id_destino INT,
	@messageToClient VARCHAR(50)
)
AS
	SET NOCOUNT ON;
	BEGIN;
		IF(EXISTS(SELECT * FROM dbo.recorrido WHERE id_recorrido = @id_recorrido))
		BEGIN
			PRINT 'The recorrido already exists can"t added the same PK.'
		END;
		ELSE
		BEGIN
-- Tomamos el ultimo registro de la tabla, para luego sumarlo en la creación de un nuevo registro
				SELECT @id_recorrido = MAX(id_recorrido) FROM dbo.recorrido;
				
				INSERT INTO dbo.recorrido(
				id_recorrido,
				fecha_prestamo,
				hora_inicio,
				hora_final,
				id_usuario ,
				id_estacion,
				id_destino)
				VALUES(@id_recorrido + 1, @fecha_prestamo, @hora_inicio, @hora_final, @id_usuario, @id_estacion, @id_destino );
			SET @messageToClient = 'Product created succesful.'
			PRINT '**> DONE.'
		END;

	END
GO

select count(*) from dbo.recorrido
go
select * from dbo.recorrido where id_recorrido = 3705
go

select * from dbo.recorrido
go
delete recorrido from recorrido where id_recorrido = 0;
go
-- Ejecutamos el procedimiento que crea un nuevo recorrido
dbo.p_AddingNewRecorrido null, '2008-02-7', 8, 10, 645, 58, 11, ''
GO


/*
2. Implemente un procedimiento que permita actualizar la información de un recorrido
previamente registrado. No debe permitir registrar información que no cumpla con las
validaciones establecidas por las restricciones de claves foráneas.
*/

CREATE PROCEDURE p_updateRecorrido
	@id_recorrido INT,
	@fecha_prestamo DATE, 
	@hora_inicio INT,
	@hora_final INT,
	@id_usuario INT,
	@id_estacion INT,
	@id_destino INT,
	@messageToClient VARCHAR(50)
AS
	SET NOCOUNT ON;
	BEGIN
		IF (NOT EXISTS(SELECT * FROM dbo.recorrido WHERE id_recorrido = @id_recorrido))
		BEGIN
			PRINT '***** / The product doesn"t exists'
		END;
		else
		BEGIN
			UPDATE dbo.recorrido SET
				fecha_prestamo = @fecha_prestamo,
				hora_inicio = @hora_inicio,
				hora_final = @hora_final,
				id_usuario = @id_usuario,
				id_estacion = @id_estacion,
				id_destino = @id_destino
			WHERE id_recorrido = @id_recorrido
			SET @messageToClient = 'Product updated succesful.'
			PRINT '***** > Product UPDATED'
		END
	END
GO

p_updateRecorrido 3707, '2007-02-07', 12, 21, 645, 61, 11, ''
GO

select * from recorrido