
-- Base de datos enCicla
USE Bicycles
GO

-- drop table if exists recorrido;
create table zona(
 id_zona INT PRIMARY KEY,
 descripcion VARCHAR(100)
);

create table operacion(
id_operacion INT PRIMARY KEY,
descripcion VARCHAR(100)
);	

CREATE TABLE usuario(
 id_usuario INT PRIMARY KEY,
 edad INT,
 id_zona INT,
 constraint fk_userzona foreign key(id_zona) REFERENCES zona(id_zona)
);

create table estacion(
id_estacion INT PRIMARY KEY,
nombre_estacion VARCHAR(100) NOT NULL UNIQUE,
descripcion_ubicacion VARCHAR(100),
capacidad_bici INT,
id_zona INT,
id_operacion INT,
constraint fk_estzona foreign key(id_zona) references zona(id_zona),
foreign key(id_operacion) references operacion(id_operacion)
);

create table recorrido(
	id_recorrido INT PRIMARY KEY,
	fecha_prestamo DATE,
	hora_inicio INT,
	hora_final INT,
	id_usuario INT,
	id_estacion INT,
	id_destino INT,
	foreign key(id_usuario) references usuario(id_usuario),
	constraint fk_estarecorr foreign key(id_estacion) references estacion(id_estacion),
	constraint fk_destrecorr foreign key(id_destino) references estacion(id_estacion)
);


GO


-- Contenido tabla zonas
INSERT INTO dbo.zona values(1, 'Nororiental'),
(2, 'Noroccidental'),
(3, 'Centro oriental'),
(4, 'Centro occidental'),
(5, 'Suroriental'),
(6, 'Suroccidental')
go

-- Contenido tabla operaciones
INSERT INTO dbo.operacion 
VALUES
(1, 'manual'),
(2, 'automático');
GO

/* Los demás contenidos han sido insertados mediante la insercción comun que se hace para grandes cantidades de datos*/
