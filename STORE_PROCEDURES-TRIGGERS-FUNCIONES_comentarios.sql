USE TP_FINAL_CALLCENTER;

sp_addmessage 50001, 11, 'USUARIO EXISTENTE'
sp_addmessage 50002, 11, 'TIPO DE DOCUMENTO INVALIDO'
sp_addmessage 50003, 11, 'EL USUARIO TIENE UN DNI INCORRECTO'
sp_addmessage 50004, 11, 'FORMATO EMAIL INVALIDO'
sp_addmessage 50005, 11, 'NO SE PUEDE MODIFICAR EL TIPO DE DOCUMENTO SI NO ES UN PROSPECTO'
sp_addmessage 50006, 11, 'NO SE PUEDE ELIMINAR CLIENTE CON SERVICIOS ACTIVOS'
sp_addmessage 50007, 11, 'NO SE PUEDE DAR DE ALTA UNA PERSONA MENOR DE EDAD'
sp_addmessage 50008, 11, 'LA PERSONA QUE TIENE EL TICKET ASIGNADO NO COINCIDE CON LA PASADA POR PARAMETRO'
sp_addmessage 50009, 11, 'EL ESTADO INGRESADO ES INVALIDO'
sp_addmessage 50010, 11, 'TRANSICION DE ESTADOS INVALIDA'
sp_addmessage 50011, 11, 'NO SE PUEDE ASIGNAR A UN CLIENTE INACTIVO UN TICKET'
sp_addmessage 50012, 11, 'NO SE PUEDEN MODIFICAR LOS DATOS YA QUE NO ES UN PROSPECTO'
sp_addmessage 50013, 11, 'EMAIL YA EXISTENTE'
sp_addmessage 50014, 11, 'EL USUARIO NO EXISTE'
sp_addmessage 50015, 11 , 'NRO DE SERVICIO INVALIDO'
sp_addmessage 50016, 11 , 'NOMBRE Y APELLIDO NO PUEDEN ESTAR VACIOS'
sp_addmessage 50017, 11 , 'FECHA DE NACIMIENTO INVALIDA'
sp_addmessage 50018, 11 ,'TIPO DE SERVICIO INVALIDO'
sp_addmessage 50019, 11 ,'EL TICKET YA SE ENCUENTRA CERRADO NO SE PUEDE MODIFICAR EL ESTADO'
sp_addmessage 50020,11, 'NO ES EL DUENIO DEL TICKET, NO TIENE PERMISO PARA MODIFICARLO'
sp_addmessage 50021, 11 , 'NO SE PUEDE ASIGNAR UN EMPLEADO INACTIVO'
sp_addmessage 50022, 11 , 'EL SERVICIO NO PERTENECE AL CLIENTE'
sp_addmessage 50023,11, 'NO SE PUEDE ASIGNAR ESTA TIPOLOGIA AL TIPO DE SERVICIO'
sp_addmessage 50024,11, 'NO SE PUEDE DESACTIVAR UN SERVICIO DESACTIVADO'
sp_addmessage 50025,11,'TIPO DE SERVICIO INCORRECTO'
sp_addmessage 50026,11,'NO SE PUEDEN MODIFICAR LOS DATOS SALVO POR EL MAIL SI ES UN CLIENTE'
sp_addmessage 50027,11,'TIPOLOGIA NO ASOCIABLE AL TIPO DE SERVICIO'

CREATE PROCEDURE ALTA_PERSONA (@DOCUMENTO INT, @TIPO_DOC char(4),@EMAIL VARCHAR(120),@FECHA_NAC DATE,@errorCode int output, @errorMessage char(70) output, @NOMBRE VARCHAR(15), @APELLIDO VARCHAR(15))
AS
/* DOY DE ALTA UNA PERSONA QUE EL NUMERO DE DOCUMENTO TENGA MAS DE 8 DIGITOS ,
		QUE EL TIPO DE DOCUMENTO Y EL DNI NO COINCIDAN,
		QUE EL EMAIL EN CASO DE NO ESTAR VACIO TENGA EL FORMATO CORRECTO Y QUE EL EMAIL NO ESTE REPETIDO*/
		
    BEGIN
		select @ErrorCode = 0
		BEGIN TRY
			
			IF NOT ISNUMERIC(@DOCUMENTO)=1 OR len(@DOCUMENTO) <7 OR ISNULL(@DOCUMENTO,'')=''
			BEGIN
				RAISERROR(50003,11,1)
			END

			IF(SELECT COUNT(1) FROM PERSONA P WHERE P.DOCUMENTO = @DOCUMENTO AND P.TIPO_DOC = @TIPO_DOC ) > 0
			BEGIN
				RAISERROR(50001,11,1)
			END

			IF (SELECT @TIPO_DOC) != 'DOCU' AND (SELECT @TIPO_DOC) != 'LIEN'
			BEGIN
				RAISERROR(50002,11,1)
			END

			if isnull(@Nombre,'')='' OR isnull(@Apellido,'')=''
			BEGIN
				RAISERROR(50016,11,1)
			END
			
			IF (DATEDIFF(Year,@FECHA_NAC,GETDATE()) < '18')
			BEGIN
				RAISERROR(50007,11,1)
			END


			IF (ISNULL(@EMAIL, '') = '')
			BEGIN
				INSERT INTO PERSONA(DOCUMENTO,TIPO_DOC,ESTADO_CLIENTE,EMAIL,FECHA_NAC,NOMBRE,APELLIDO)
				VALUES(@DOCUMENTO,@TIPO_DOC,'PRO',NULL,@FECHA_NAC,@NOMBRE,@APELLIDO)
			END
			else
			begin
				IF @EMAIL NOT LIKE '%_@__%.__%'
					BEGIN
						print 'email invalido'
						RAISERROR(50004,11,1)
					END
					IF (SELECT COUNT(1) FROM PERSONA P WHERE P.EMAIL  = @EMAIL) > 0 
					BEGIN
						RAISERROR(50013,11,1)
					END

					INSERT INTO PERSONA(DOCUMENTO,TIPO_DOC,ESTADO_CLIENTE,EMAIL,FECHA_NAC,NOMBRE,APELLIDO)
					VALUES(@DOCUMENTO,@TIPO_DOC,'PRO',@EMAIL,@FECHA_NAC,@NOMBRE,@APELLIDO)
			end
			
		END TRY 
		BEGIN CATCH
			SELECT @errorCode=ERROR_NUMBER();
			SELECT @errorMessage=ERROR_MESSAGE();
		END CATCH;
    END
GO
CREATE PROCEDURE MODIF_DATOS_PERSONA (@DOCUMENTO INT, @TIPO_DOC char(4), @NVO_TIPO_DOC char(4),@NVO_EMAIL 
VARCHAR(120),@FECHA_NAC DATE,@NOMBRE VARCHAR(15), @APELLIDO VARCHAR(15),@ErrorCode int output, @ErrorMessage char(70) OUTPUT)
AS
BEGIN
	select @ErrorCode = 0
	BEGIN TRY
	/*tengo que ver , si el docu es el mismo, el tipo docu es el mismo , la fecha nac es la misma , el nombre es el mismo y el ape es el mismo para un cliente,
	para un prospecto puedo cambiar todo menos el documento*/


		IF NOT ISNUMERIC(@DOCUMENTO)= 1 OR len(@DOCUMENTO)<7 OR ISNULL(@DOCUMENTO,'')=''
		BEGIN
			RAISERROR(50003,11,1)
		END

		IF (SELECT @TIPO_DOC) != 'DOCU' AND (SELECT @TIPO_DOC) != 'LIEN'
		BEGIN
			RAISERROR(50002,11,1)
		END

		IF(SELECT COUNT(1) FROM PERSONA P WHERE P.DOCUMENTO = @DOCUMENTO AND P.TIPO_DOC = @TIPO_DOC) = 0
		BEGIN
			RAISERROR(50014,11,1)
		END

		IF (NOT ISNULL(@NVO_EMAIL, '') = '')
		BEGIN
			IF @NVO_EMAIL NOT LIKE '%_@__%.__%'
			BEGIN
				RAISERROR(50004,11,1)
			END
		END
		IF(SELECT EMAIL FROM PERSONA P WHERE DOCUMENTO = @DOCUMENTO AND TIPO_DOC = @TIPO_DOC) != @NVO_EMAIL
		BEGIN
			IF (SELECT COUNT(1) FROM PERSONA P WHERE P.EMAIL  = @NVO_EMAIL) > 0 
			BEGIN
				RAISERROR(50013,11,1)
			END
		END

		if isnull(@NOMBRE,'')='' OR isnull(@APELLIDO,'')=''
		BEGIN
			RAISERROR(50016,11,1)
		END


		IF(SELECT ESTADO_CLIENTE FROM PERSONA WHERE DOCUMENTO = @DOCUMENTO AND TIPO_DOC = @TIPO_DOC ) = 'PRO'
		BEGIN

			UPDATE PERSONA SET EMAIL = @NVO_EMAIL, FECHA_NAC = @FECHA_NAC ,TIPO_DOC = @NVO_TIPO_DOC, NOMBRE = @NOMBRE,APELLIDO= @APELLIDO WHERE DOCUMENTO = @DOCUMENTO AND TIPO_DOC = @TIPO_DOC
		
		END
		ELSE
		BEGIN
			IF( SELECT COUNT(*) FROM PERSONA WHERE DOCUMENTO = @DOCUMENTO AND TIPO_DOC = @TIPO_DOC AND NOMBRE = @NOMBRE AND APELLIDO = @APELLIDO AND FECHA_NAC = @FECHA_NAC) = 0
			BEGIN
				RAISERROR(50026, 11 ,1 )
			END
			UPDATE PERSONA SET EMAIL = @NVO_EMAIL WHERE DOCUMENTO = @DOCUMENTO AND TIPO_DOC = @TIPO_DOC
		END
		
	END TRY
	BEGIN CATCH
		SELECT @ErrorCode=ERROR_NUMBER();
		SELECT @ErrorMessage=ERROR_MESSAGE();
	END CATCH
END
GO
CREATE PROCEDURE ALTA_SERVICIO (@DOCUMENTO INT, @TIPO_DOCUMENTO CHAR(4), @DIRECCION VARCHAR(70),
@TELEFONO INT, @TIPO_SERVICIO VARCHAR(12),@ErrorCode int output, @ErrorMessage char(70) OUTPUT, @idRegistro int OUTPUT)
AS
	BEGIN
	/*HAY QUE VALIDAR TAMBIEN EL TIPO DE SERVICIO*/
		select @ErrorCode = 0
		SELECT @idRegistro = -1
	BEGIN TRY
		IF (SELECT COUNT(1) FROM TIPO_SERVICIO TS WHERE TS.TIPO = @TIPO_SERVICIO) = 0
		BEGIN			
			RAISERROR(50025, 11, 1)
		END
		IF(SELECT COUNT(1) FROM PERSONA P WHERE P.DOCUMENTO = @DOCUMENTO AND P.TIPO_DOC = @TIPO_DOCUMENTO) = 0
		BEGIN
			RAISERROR(50014,11,1)
		END

		IF (SELECT @TIPO_DOCUMENTO) != 'DOCU' AND (SELECT @TIPO_DOCUMENTO) != 'LIEN'
		BEGIN
			RAISERROR(50002,11,1)
		END

		IF (SELECT LEN(CONVERT(VARCHAR, @DOCUMENTO)) AS NumLength) < 8
		BEGIN
			RAISERROR(50003,11,1)
		END
		DECLARE @EMAIL_CLIENTE VARCHAR(120) 
		DECLARE @FECHA_NAC DATE

		SELECT @EMAIL_CLIENTE= EMAIL, @FECHA_NAC = FECHA_NAC FROM PERSONA WHERE DOCUMENTO = @DOCUMENTO AND TIPO_DOC = @TIPO_DOCUMENTO

		IF(ISNULL(@EMAIL_CLIENTE, '')) = '' 
		BEGIN
			RAISERROR(50004,11,1)
		END

		IF @EMAIL_CLIENTE NOT LIKE '%_@__%.__%'
		BEGIN
			RAISERROR(50004,11,1)
		END	

		IF ISNULL(@FECHA_NAC , '') = ''
		BEGIN
			RAISERROR(50017,11,1)
		END

		IF (DATEDIFF(Year,@FECHA_NAC,GETDATE()) < '18')
		BEGIN
			RAISERROR(50007,11,1)
		END


		BEGIN TRANSACTION
		IF(SELECT ESTADO_CLIENTE FROM PERSONA WHERE DOCUMENTO = @DOCUMENTO AND TIPO_DOC = @TIPO_DOCUMENTO) != 'CLI'
		BEGIN
			UPDATE PERSONA SET ESTADO_CLIENTE = 'CLI' WHERE DOCUMENTO = @DOCUMENTO AND TIPO_DOC = @TIPO_DOCUMENTO
		END
			
		INSERT INTO SERVICIO(DOC_PERSONA,TIPO_DOC_PERSONA,DIRECCION,ESTADO,TIPO_SERVICIO,FECHA_INICIO,TELEFONO)
		VALUES (@DOCUMENTO,@TIPO_DOCUMENTO,@DIRECCION,'ACTIVO',@TIPO_SERVICIO, GETDATE(),@TELEFONO)
		SET @idRegistro=SCOPE_IDENTITY()
		COMMIT
		
	END TRY 
	BEGIN CATCH
		SELECT @ErrorCode=ERROR_NUMBER();
		SELECT @ErrorMessage=ERROR_MESSAGE();
		IF @@TRANCOUNT > 0 
		ROLLBACK;
	END CATCH;
	END
GO
CREATE PROCEDURE BAJA_SERVICIO(@NRO_SERVICIO INT,@DOCUMENTO INT , @TIPO_DOCU CHAR(4),@ErrorCode int output, @ErrorMessage char(70) OUTPUT)
AS
	BEGIN
		select @ErrorCode = 0
		BEGIN TRY
		IF (SELECT ESTADO FROM SERVICIO WHERE NRO_SERVICIO = @NRO_SERVICIO) = 'ACTIVO'
		BEGIN
			BEGIN TRANSACTION
			UPDATE SERVICIO SET ESTADO = 'INACTIVO' WHERE NRO_SERVICIO = @NRO_SERVICIO

			IF(SELECT COUNT(*) FROM SERVICIO WHERE DOC_PERSONA = @DOCUMENTO AND TIPO_DOC_PERSONA = @TIPO_DOCU AND SERVICIO.ESTADO = 'ACTIVO') = 0 
			BEGIN
				UPDATE PERSONA SET ESTADO_CLIENTE = 'INA' WHERE DOCUMENTO = @DOCUMENTO AND TIPO_DOC = @TIPO_DOCU 
			END
			COMMIT
		END
		ELSE
		BEGIN
			RAISERROR(50024,11 ,1)
		END
		END TRY
		BEGIN CATCH
			SELECT @ErrorCode=ERROR_NUMBER();
			SELECT @ErrorMessage=ERROR_MESSAGE();
			IF @@TRANCOUNT > 0 
			ROLLBACK;
	END CATCH
	END
GO

CREATE PROCEDURE GENERAR_TICKET(@TIPOLOGIA VARCHAR(45),@EMPLEADO INT,@TIPO_DOC_PERSONA CHAR(4), @DOC_PERSONA INT,@SERVICIO INT, @FECHA_APERTURA DATETIME, @NOMBRE VARCHAR(15), @APELLIDO VARCHAR(15),
@ErrorCode int OUTPUT,@ErrorMessage varchar(70) OUTPUT, @IDREGISTRO INT OUTPUT) 
/*CONVIENE TENER UN TIPO DE SERVICIO QUE SEA CLIENTE O ALGO SIMILAR
PARA PODER VALIDAR LAS TIPOLOGIAS QUE NO ESTEN ASGINADAS A UN TIPO DE SERVICIO*/
/*GENERA UN TICKET CON TODOS LOS DATOS NECESARIOS, POR DEFECTO LO SEATEA EN ABIERTO Y SIN FECHA DE CIERRE*/
/* SI LA PERSONA NO ESTA EN EL SISTEMA , SE LA CREA CON TODOS LOS DATOS QUE SE DISPONEN Y LUEGO SE LE PUEDE MODIFICAR EL MAIL Y LA FECHA NAC
LUEGO SI EL ESTADO DEL CLIENTE ESTA EN ACTIVO SE ASOCIA AL TICKET EL SERVICIO Y EL CLIENTE, Y SI ES UN PROSPECTO SE ASOCIA SOLAMENTE AL CLIENTE*/
AS
BEGIN
	DECLARE @ESTADO_CLI AS CHAR(3)
	DECLARE @ERRORCODE2 INT
	DECLARE @TIPO_SERVICIO VARCHAR(12)
	SET @IDREGISTRO = -1
	SET @TIPO_SERVICIO = (SELECT TIPO_SERVICIO FROM SERVICIO WHERE NRO_SERVICIO = @SERVICIO)
	SET @ERRORCODE2 = 0
	BEGIN TRY
		select * from SERVICIO
		/*FALTA VALIDAR tipoloia asociable al tipo del servicio del contrato.*/
		IF(SELECT COUNT(*) FROM TIPOLOGIA_TIPO_SERVICIO WHERE TIPOLOGIA=@TIPOLOGIA and TIPO_SERVICIO=@TIPO_SERVICIO) = 0
		BEGIN
			RAISERROR(50027,11,1)
		END
		
		IF(SELECT COUNT(1) FROM SERVICIO WHERE NRO_SERVICIO = @SERVICIO) = 0
		BEGIN
			RAISERROR(50015,11,1)
		END
		
		IF(SELECT COUNT(1) FROM SERVICIO WHERE DOC_PERSONA = @DOC_PERSONA AND TIPO_DOC_PERSONA = @TIPO_DOC_PERSONA) = 0
		BEGIN
			RAISERROR(50022,11,1)
		END

		IF(SELECT ESTADO FROM EMPLEADO WHERE ID_LEGAJO = @EMPLEADO) = 'INACTIVO'
		BEGIN
			RAISERROR(50021,11,1)
		END

		IF(SELECT COUNT(*) FROM PERSONA WHERE DOCUMENTO = @DOC_PERSONA AND TIPO_DOC = @TIPO_DOC_PERSONA) = 0
		BEGIN
			RAISERROR(50014,11,1)
		END


		IF (SELECT COUNT(1) FROM TIPOLOGIA_TIPO_SERVICIO WHERE TIPOLOGIA = @TIPOLOGIA AND TIPO_SERVICIO = @TIPO_SERVICIO) = 0
		BEGIN
			RAISERROR(50023,11,1)
		END

		SET @ESTADO_CLI = (SELECT ESTADO_CLIENTE FROM PERSONA WHERE DOCUMENTO = @DOC_PERSONA AND TIPO_DOC = @TIPO_DOC_PERSONA)

		BEGIN TRANSACTION
		/*SI NO TIENE NINGUN SERVICIO ES UN PROSPECTO Y LLEVA LA TIPOLOGIA GENERAL QUE ES PARA RECLAMOS O CONSULTAS
		PERO SI TIENE SERVICIOS ASOCIADOS ES UN CLIENTE*/
		IF (SELECT COUNT(*) FROM SERVICIO WHERE DOC_PERSONA = @DOC_PERSONA AND TIPO_DOC_PERSONA = @TIPO_DOC_PERSONA
		AND NRO_SERVICIO = @SERVICIO) > 0
		BEGIN
			INSERT INTO TICKET(TIPOLOGIA,EMPLEADO,TIPO_DOC_PERSONA,DOC_PERSONA,SERVICIO,ESTADO,FECHA_APERTURA,FECHA_CIERRE)
			VALUES(@TIPOLOGIA,@EMPLEADO,@TIPO_DOC_PERSONA, @DOC_PERSONA, @SERVICIO, 'ABIERTO', GETDATE(),NULL)
		END
		ELSE
		BEGIN
			INSERT INTO TICKET(TIPOLOGIA,EMPLEADO,TIPO_DOC_PERSONA,DOC_PERSONA,SERVICIO,ESTADO,FECHA_APERTURA,FECHA_CIERRE)
			VALUES('GENERAL',@EMPLEADO,@TIPO_DOC_PERSONA, @DOC_PERSONA, NULL, 'ABIERTO', GETDATE(),NULL)
		END
				
		SET @IDREGISTRO = SCOPE_IDENTITY();
		INSERT INTO HISTORIAL (ESTADO,TICKET,FECHA_MODIF,FECHA_INICIO,FECHA_FIN)
				VALUES ('ABIERTO',@IDREGISTRO,NULL,GETDATE(), NULL)

		COMMIT
	END TRY
	BEGIN CATCH
		SELECT @ErrorCode=ERROR_NUMBER();
		SELECT @ErrorMessage=ERROR_MESSAGE();
		IF @@TRANCOUNT > 0 
		ROLLBACK;
	END CATCH;
END
GO
CREATE TRIGGER ESTADO_TICKET
ON TICKET
AFTER UPDATE AS
BEGIN
	/* CAMBIA EL ESTADO DEL TICKET , SI EL ESTADO CAMBIA GENERO EN LA TABLA MENSAJES UN REGISTRO*/
	DECLARE @ESTADO VARCHAR(45)
	DECLARE @NRO_TICKET INT
	DECLARE @FECHA_INI DATE
	DECLARE @DOCU INT
	DECLARE @TIPO_DOCU VARCHAR(4)
	DECLARE @EMAIL VARCHAR(120)
	SELECT @NRO_TICKET = ID_TICKET, @ESTADO = ESTADO , @DOCU = DOC_PERSONA,@TIPO_DOCU = TIPO_DOC_PERSONA FROM inserted

	SET @EMAIL = (SELECT EMAIL FROM PERSONA WHERE DOCUMENTO = @DOCU AND TIPO_DOC = @TIPO_DOCU)


	INSERT INTO MENSAJE (ESTADO,TICKET,TEXTO,DESTINATARIO)
	VALUES (@ESTADO,@NRO_TICKET,'Se le notifica el cambio de estado',@EMAIL)

END
GO
CREATE PROCEDURE CAMBIAR_ESTADO_TICKET (@NRO_TICKET INT,@DOCUMENTO INT,@TIPO_DOCU CHAR(4), @EMPLEADO INT, @ESTADO_NUEVO VARCHAR(45), @ErrorCode INT OUTPUT, @ErrorMessage VARCHAR(70) OUTPUT)
AS
	BEGIN
	BEGIN TRY
	/* CAMBIA EL ESTADO DEL TICKET SIEMPRE Y CUANDO LA PERSONA SEA LA MISMA QUE LA QUE TIENE EL TICKET ASIGNADO,
	PONDERA TODOS LOS CAMBIOS DE ESTADO PERMISIBLES, Y VALIDA SI EL ESTADO INGRESADO ES VALIDO O NO*/
		IF(SELECT COUNT(1) FROM TICKET WHERE EMPLEADO = @EMPLEADO) = 0
		BEGIN
			RAISERROR(50020,11,1)
		END

		IF(SELECT DOC_PERSONA FROM TICKET WHERE ID_TICKET = @NRO_TICKET) != @DOCUMENTO 
		AND (SELECT TIPO_DOC_PERSONA FROM TICKET WHERE ID_TICKET = @NRO_TICKET) != @TIPO_DOCU
		BEGIN
			RAISERROR(50008,11,1)
		END
	

		DECLARE @ESTADO AS VARCHAR(45)
		SET @ESTADO = (SELECT ESTADO FROM TICKET WHERE ID_TICKET = @NRO_TICKET)

		IF(SELECT @ESTADO ) = 'CERRADO'
		BEGIN
			RAISERROR(50019,11,1)
		END		

		IF (SELECT @ESTADO_NUEVO )!= 'ABIERTO' AND (SELECT @ESTADO_NUEVO )!= 'CERRADO' AND 
		(SELECT @ESTADO_NUEVO )!= 'RESUELTO' AND (SELECT @ESTADO_NUEVO )!= 'PENDIENTE CLIENTE' AND 
		(SELECT @ESTADO_NUEVO )!= 'EN PROGRESO'
		BEGIN
			RAISERROR(50009,11,1)
		END
		IF (@ESTADO = 'ABIERTO') AND (@ESTADO_NUEVO != 'EN PROGRESO')
		BEGIN
			RAISERROR(50010,11,1)
		END
		IF(@ESTADO = 'EN PROGRESO') AND ((@ESTADO_NUEVO != 'PENDIENTE CLIENTE') AND (@ESTADO_NUEVO != 'RESUELTO'))
		BEGIN
			RAISERROR(50010,11,1)
		END
		IF(@ESTADO = 'PENDIENTE CLIENTE') AND (@ESTADO_NUEVO != 'EN PROGRESO')
		BEGIN
			RAISERROR(50010,11,1)
		END
		IF(@ESTADO = 'RESUELTO') AND (@ESTADO_NUEVO != 'CERRADO')
		BEGIN
			RAISERROR(50010,11,1)
		END

		BEGIN TRANSACTION
		IF(@ESTADO_NUEVO) = 'RESUELTO'
		BEGIN
			UPDATE TICKET SET ESTADO = @ESTADO_NUEVO, FECHA_RESOLUC = GETDATE() WHERE ID_TICKET = @NRO_TICKET
			
		END

		IF(@ESTADO_NUEVO) = 'CERRADO'
		BEGIN
			UPDATE TICKET SET ESTADO = @ESTADO_NUEVO, FECHA_CIERRE = GETDATE() WHERE ID_TICKET = @NRO_TICKET
		END

		DECLARE @FECHA_INI DATETIME
		SET @FECHA_INI = (SELECT FECHA_APERTURA FROM TICKET WHERE ID_TICKET = @NRO_TICKET) 

		IF(@ESTADO_NUEVO) != 'CERRADO' AND (@ESTADO_NUEVO) != 'RESUELTO'
		BEGIN
			UPDATE TICKET SET ESTADO = @ESTADO_NUEVO WHERE ID_TICKET = @NRO_TICKET
			
		END
		/*[GAU]: Est�n actualizando todos los registros de historial. Deben actualizar solo el ultimo*/
		UPDATE HISTORIAL SET FECHA_FIN = GETDATE() WHERE TICKET = @NRO_TICKET  AND FECHA_FIN is null
		
		IF(@ESTADO_NUEVO) = 'CERRADO'
		BEGIN
			INSERT INTO HISTORIAL (ESTADO,TICKET,FECHA_MODIF,FECHA_INICIO,FECHA_FIN)
			VALUES (@ESTADO_NUEVO,@NRO_TICKET,GETDATE(),@FECHA_INI, GETDATE())
		END
		ELSE
		BEGIN	
			INSERT INTO HISTORIAL (ESTADO,TICKET,FECHA_MODIF,FECHA_INICIO,FECHA_FIN)
			VALUES (@ESTADO_NUEVO,@NRO_TICKET,GETDATE(),@FECHA_INI, NULL)
		END
		COMMIT
	END TRY
	BEGIN CATCH
		SELECT @ErrorCode=ERROR_NUMBER();
		SELECT @ErrorMessage=ERROR_MESSAGE();
		IF @@TRANCOUNT > 0 
		ROLLBACK;
	END CATCH;
END
GO
CREATE PROCEDURE ASIGNAR_TICKET (@NRO_TICKET INT, @DOCUMENTO INT , @TIPO_DOCU CHAR(4),@EMPLEADO INT, @ErrorCode INT OUTPUT, @ErrorMessage VARCHAR(70) OUTPUT)
AS
	BEGIN
	BEGIN TRY
	/*REVISAR BIEN SI ERA ASI O NO ESTO */
	/*SE LE ASIGNA A UNA PERSONA UN TICKET SIEMPRE Y CUANDO NO ESTE INACTIVA*/
		DECLARE @ESTADO_TICKET VARCHAR(45)
		DECLARE @ESTADO_EMPLEADO VARCHAR(10)
		SET @ESTADO_EMPLEADO = (SELECT ESTADO FROM EMPLEADO WHERE ID_LEGAJO = @EMPLEADO)
		SET @ESTADO_TICKET = (SELECT ESTADO FROM TICKET WHERE ID_TICKET = @NRO_TICKET)

		IF(SELECT @ESTADO_TICKET ) = 'CERRADO'
		BEGIN
			RAISERROR(50019,11,1)
		END

		IF(SELECT ESTADO FROM EMPLEADO WHERE ID_LEGAJO= @EMPLEADO) = 'ACTIVO'
		BEGIN
			UPDATE TICKET SET EMPLEADO = @EMPLEADO WHERE ID_TICKET = @NRO_TICKET
		END
		ELSE 
		BEGIN
			RAISERROR(50021,11,1)
		END
	
	END TRY
	BEGIN CATCH
		SELECT @ErrorCode=ERROR_NUMBER();
		SELECT @ErrorMessage=ERROR_MESSAGE();
	END CATCH;
	END
GO

/*INSERTO UNA PERSONA COMO PROSPECTO*/

INSERT INTO ESTADO_CLIENTE(TIPO_ESTADO,DESCRIPCION)
VALUES ('PRO','PROSPECTO')
INSERT INTO ESTADO_CLIENTE(TIPO_ESTADO,DESCRIPCION)
VALUES ('INA','INACTIVO')
INSERT INTO ESTADO_CLIENTE(TIPO_ESTADO,DESCRIPCION)
VALUES ('CLI','CLIENTE')

SELECT * FROM ESTADO_CLIENTE



/*Intentar dar de alta un cliente (prospecto) sin datos m�nimos requeridos o err�neos (probar las distintas alternativas de campos)*/


DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC ALTA_PERSONA @DOCUMENTO = 40000000, @TIPO_DOC = 'DO', @EMAIL = 'federico.nicolas.facchin@gmail.com' , @FECHA_NAC = '1994-06-01', @errorCode =  @ErrorCode output, @errorMessage = @ErrorMessage output
,@NOMBRE = 'FEDERICO', @APELLIDO = 'FACCHIN';

print @ErrorCode;
print @ErrorMessage;

SELECT * FROM PERSONA WHERE DOCUMENTO = 40000000 AND TIPO_DOC ='DO'




DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC ALTA_PERSONA @DOCUMENTO = 1, @TIPO_DOC = 'DOCU', @EMAIL = 'federico.nicolas.facchin@gmail.com' , @FECHA_NAC = '1994-06-01', @errorCode =  @ErrorCode output, @errorMessage = @ErrorMessage output
,@NOMBRE = 'FEDERICO', @APELLIDO = 'FACCHIN';

print @ErrorCode;
print @ErrorMessage;

SELECT * FROM PERSONA WHERE DOCUMENTO = 1 AND TIPO_DOC ='DOCU'





DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC ALTA_PERSONA @DOCUMENTO = 11000000, @TIPO_DOC = 'DOCU', @EMAIL = 'federico.nicolas.facchin@gmail.com' , @FECHA_NAC = '1994-06-01', @errorCode =  @ErrorCode output, @errorMessage = @ErrorMessage output
,@NOMBRE = 'FEDERICO', @APELLIDO = 'FACCHIN';
print @ErrorCode;
print @ErrorMessage;
SELECT * FROM PERSONA WHERE DOCUMENTO = 11000000 AND TIPO_DOC ='DOCU'


DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC ALTA_PERSONA @DOCUMENTO = 40000000, @TIPO_DOC = 'DOCU', @EMAIL = 'federico.nicolas.facchin@gmail.com' , @FECHA_NAC = '1994-06-01', @errorCode =  @ErrorCode output, @errorMessage = @ErrorMessage output
,@NOMBRE = '', @APELLIDO = '';

print @ErrorCode;
print @ErrorMessage;
SELECT * FROM PERSONA WHERE DOCUMENTO = 40000000 AND TIPO_DOC ='DOCU'





/*Crear un nuevo servicio a un Prospecto
Debe crearse el servicio y cambiarse el cliente a Activo
Se debe crear el servicio activo
*/
INSERT INTO TIPO_SERVICIO(TIPO,DESCRIPCION)
VALUES('TELE FIJA','TELEFONIA FIJA')
INSERT INTO TIPO_SERVICIO(TIPO,DESCRIPCION)
VALUES('INTERNET','INTERNET')
INSERT INTO TIPO_SERVICIO(TIPO,DESCRIPCION)
VALUES('VOIP','VOIP')
INSERT INTO TIPO_SERVICIO(TIPO, DESCRIPCION)
VALUES('CLIENTE', 'PERSONA SIN SERVICIOS')

SELECT * FROM TIPO_SERVICIO


DECLARE @errorCode INT
DECLARE @errorMessage VARCHAR(70)
DECLARE @IDREGISTRO INT
EXEC ALTA_SERVICIO @DOCUMENTO =11000000, @TIPO_DOCUMENTO ='DOCU', @DIRECCION = 'CALLE LINCOLN 1733', @TELEFONO = 1173698812, @TIPO_SERVICIO = 'TELE FIJA',
@ErrorCode = @errorCode OUTPUT, @ErrorMessage = @errorMessage OUTPUT, @idRegistro = @IDREGISTRO OUTPUT

print @errorCode;
print @errorMessage;
PRINT @IDREGISTRO

SELECT * FROM SERVICIO WHERE SERVICIO.DOC_PERSONA = 11000000
SELECT * FROM PERSONA WHERE DOCUMENTO = 11000000 AND TIPO_DOC = 'DOCU'



/*DAR DE BAJA SERVICIO A UN CLIENTE CON 1 SERVICIO */
DECLARE @errorCode INT
DECLARE @errorMessage VARCHAR(70)
EXEC BAJA_SERVICIO @NRO_SERVICIO = 1, @DOCUMENTO = 11000000 , @TIPO_DOCU = 'DOCU', @errorCode = @ErrorCode OUTPUT, @errorMessage = @ErrorMessage OUTPUT
print @errorCode;
print @errorMessage;

SELECT * FROM SERVICIO WHERE SERVICIO.DOC_PERSONA = 11000000
SELECT * FROM PERSONA WHERE DOCUMENTO = 11000000 AND TIPO_DOC = 'DOCU'


/*Inactivar un Servicio a un cliente con m�s de un servicio activo*/

DECLARE @errorCode int
DECLARE @errorMessage varchar(70)
EXEC ALTA_PERSONA @DOCUMENTO = 38324151, @TIPO_DOC = 'DOCU', @EMAIL = 'federicoooo@gmail.com' , @FECHA_NAC = '1994-06-01', @errorCode =  @ErrorCode output, @errorMessage = @ErrorMessage output
,@NOMBRE = 'FEDERICO', @APELLIDO = 'FACCHIN';





DECLARE @errorCode int
DECLARE @errorMessage varchar(70)
DECLARE @IDREGISTRO INT
EXEC ALTA_SERVICIO @DOCUMENTO =38324151, @TIPO_DOCUMENTO ='DOCU', @DIRECCION = 'CALLE LINCOLN 1733', @TELEFONO = 1173698812, @TIPO_SERVICIO = 'TELE FIJA',
@ErrorCode = @errorCode OUTPUT, @ErrorMessage = @errorMessage OUTPUT, @idRegistro = @IDREGISTRO OUTPUT
PRINT @IDREGISTRO



DECLARE @errorCode INT
DECLARE @errorMessage VARCHAR(70)
DECLARE @IDREGISTRO INT
EXEC ALTA_SERVICIO @DOCUMENTO =38324151, @TIPO_DOCUMENTO ='DOCU', @DIRECCION = 'CALLE LINCOLN 1733', @TELEFONO = 1173698812, @TIPO_SERVICIO = 'TELE FIJA',
@ErrorCode = @errorCode OUTPUT, @ErrorMessage = @errorMessage OUTPUT, @idRegistro = @IDREGISTRO OUTPUT

print @errorCode;
print @errorMessage;
PRINT @IDREGISTRO


SELECT * FROM SERVICIO WHERE SERVICIO.DOC_PERSONA = 38324151

DECLARE @errorCode INT
DECLARE @errorMessage VARCHAR(70)
EXEC BAJA_SERVICIO @NRO_SERVICIO = 2, @DOCUMENTO = 38324151 , @TIPO_DOCU = 'DOCU', @errorCode = @ErrorCode OUTPUT, @errorMessage = @ErrorMessage OUTPUT
print @errorCode;
print @errorMessage;

SELECT * FROM PERSONA WHERE DOCUMENTO = 38324151
SELECT * FROM SERVICIO WHERE SERVICIO.DOC_PERSONA = 38324151

/*Generar un nuevo ticket*/
INSERT INTO TIPOLOGIA (MOTIVO,DESCRIPCION)
VALUES('Reimpresi�n de Factura','Reimpresi�n de Factura')
INSERT INTO TIPOLOGIA (MOTIVO,DESCRIPCION)
VALUES('Servicio Degradado','Servicio Degradado')
INSERT INTO TIPOLOGIA (MOTIVO,DESCRIPCION)
VALUES('Baja de Servicio','Baja de Servicio')
INSERT INTO TIPOLOGIA (MOTIVO,DESCRIPCION)
VALUES('Facturaci�n de Cargos Err�neos','Facturaci�n de Cargos Err�neos')
INSERT INTO TIPOLOGIA (MOTIVO,DESCRIPCION)
VALUES('Cambio de Velocidad','Cambio de Velocidad')
INSERT INTO TIPOLOGIA (MOTIVO,DESCRIPCION)
VALUES('Mudanza de servicio','Mudanza de servicio')
INSERT INTO TIPOLOGIA (MOTIVO,DESCRIPCION)
VALUES('GENERAL', 'Queja o consulta sin servicio asociado')
SELECT * FROM TIPOLOGIA

INSERT INTO TIPOLOGIA_TIPO_SERVICIO(TIPOLOGIA,TIPO_SERVICIO,SLA)
VALUES('Reimpresi�n de Factura','TELE FIJA',1)
INSERT INTO TIPOLOGIA_TIPO_SERVICIO(TIPOLOGIA,TIPO_SERVICIO,SLA)
VALUES('Servicio Degradado','INTERNET',2)
INSERT INTO TIPOLOGIA_TIPO_SERVICIO(TIPOLOGIA,TIPO_SERVICIO,SLA)
VALUES('Baja de Servicio','VOIP',3)
INSERT INTO TIPOLOGIA_TIPO_SERVICIO(TIPOLOGIA,TIPO_SERVICIO,SLA)
VALUES('Facturaci�n de Cargos Err�neos','INTERNET',4)

SELECT * FROM TIPOLOGIA_TIPO_SERVICIO




INSERT INTO EMPLEADO(ID_LEGAJO,NOMBRE,APELLIDO,ESTADO,LOGIN)
VALUES (1001,'JORGE','PEREZ','INACTIVO','UNMAILCUALQUIERA@GMAIL.COM')


INSERT INTO EMPLEADO(ID_LEGAJO,NOMBRE,APELLIDO,ESTADO,LOGIN)
VALUES (1002,'RAMIRO','RAMIREZ','ACTIVO','OTROMAILCUALQUIERA1@GMAIL.COM')

INSERT INTO EMPLEADO(ID_LEGAJO,NOMBRE,APELLIDO,ESTADO,LOGIN)
VALUES (1003,'DANIEL','LOPEZ','ACTIVO','OTROMAS@GMAIL.COM')

SELECT * FROM SERVICIO

select * from PERSONA

DECLARE @errorCode int
DECLARE @errorMessage varchar(70)
DECLARE @fecha_apertura DATETIME
DECLARE @idRegistro INT
SET @fecha_apertura = GETDATE()
EXEC GENERAR_TICKET @TIPOLOGIA ='Reimpresi�n de Factura',@EMPLEADO = 1002,@TIPO_DOC_PERSONA='DOCU', @DOC_PERSONA= 11000000,@SERVICIO=1,@FECHA_APERTURA= @fecha_apertura,@NOMBRE='FEDERICO',
@APELLIDO ='FACCHIN', @ErrorCode = @errorCode OUTPUT,@ErrorMessage = @errorMessage OUTPUT, @IDREGISTRO = @idRegistro OUTPUT
PRINT @errorCode
PRINT @errorMessage
PRINT @idRegistro

SELECT * FROM TICKET


/*Intentar modificar el nombre o apellido para un cliente activo*/ 

DECLARE @errorCode int
DECLARE @errorMessage varchar(70)
exec MODIF_DATOS_PERSONA @DOCUMENTO= 38324151,@TIPO_DOC= 'DOCU',@NVO_TIPO_DOC = 'DOCU',@NOMBRE = 'lucas',@APELLIDO = 'castel',@NVO_EMAIL = 'federico1994@gmail.com',
@FECHA_NAC = '1994-06-01',@ErrorCode = @errorCode OUTPUT,@ErrorMessage = @errorMessage OUTPUT
PRINT @errorCode
PRINT @errorMessage


SELECT * FROM PERSONA

/*Modificar el nombre, apellido o fecha de nacimiento para un prospecto*/


DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC ALTA_PERSONA @DOCUMENTO= 45000000, @TIPO_DOC='DOCU', @EMAIL= 'EMAILDEPRUEBA2@HOTMAIL.COM', @FECHA_NAC= '1990-05-24', @errorCode = @ErrorCode OUTPUT, @errorMessage = @ErrorMessage OUTPUT,
@NOMBRE ='MARIANO', @APELLIDO = 'BONDAR'
PRINT @errorCode
PRINT @errorMessage

SELECT * FROM PERSONA

DECLARE @errorCode int
DECLARE @errorMessage varchar(70)
EXEC MODIF_DATOS_PERSONA @DOCUMENTO=45000000,@TIPO_DOC='DOCU',@NVO_TIPO_DOC = 'LIEN',@NOMBRE='RAMIRO',@APELLIDO='RAMIREZ',@NVO_EMAIL = 'RAMIRO_RAMIREZ@gmail.com',
@FECHA_NAC = '1980-11-11',@ErrorCode = @errorCode OUTPUT, @ErrorMessage = @errorMessage OUTPUT
PRINT @errorCode
PRINT @errorMessage
SELECT * FROM PERSONA


DECLARE @ERRORCODE INT
DECLARE @ERRORMESSAGE VARCHAR(70)
EXEC MODIF_DATOS_PERSONA @DOCUMENTO=45000000,@TIPO_DOC='LIEN',@NVO_TIPO_DOC = 'DOCU',@NOMBRE='RAMIRO',@APELLIDO='RAMIREZ',@NVO_EMAIL='UnMailDiferente@gmail.com',@FECHA_NAC = '1980-11-11',@ErrorCode = @ERRORCODE output, @ErrorMessage = @ERRORMESSAGE output
PRINT @ERRORCODE
PRINT @ERRORMESSAGE
select * from PERSONA


/*Intentar modificar la fecha de nacimiento de un cliente Activo*/

DECLARE @errorCode int
DECLARE @errorMessage varchar(70)
EXEC MODIF_DATOS_PERSONA @DOCUMENTO= 38324151, @TIPO_DOC= 'DOCU',@NVO_TIPO_DOC= 'DOCU',@NOMBRE='FEDERICO',@APELLIDO='FACCHIN', @FECHA_NAC = '1990-03-06',@NVO_EMAIL='OTROMAIL@gmail.com', @ErrorCode = @errorCode OUTPUT, @ErrorMessage = @errorMessage OUTPUT
PRINT @errorCode
PRINT @errorMessage

SELECT * FROM PERSONA
/*INTENTAR CREAR UN CLIENTE CON UN EMAIL INVALIDO*/

DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC ALTA_PERSONA  @DOCUMENTO= 12312334,@TIPO_DOC= 'DOCU',@EMAIL='SADFSADFASFAFAFAFDA',@FECHA_NAC ='1990-05-06', @ErrorCode = @ErrorCode OUTPUT, @ErrorMessage = @ErrorMessage OUTPUT,
@NOMBRE= 'NOMBRE', @APELLIDO = 'APELLIDO'
PRINT @ErrorCode
PRINT @ErrorMessage


/*Cambiar el estado de un Ticket a un estado diferente de resuelto (transici�n permitida)*/
SELECT * FROM TICKET
SELECT * FROM EMPLEADO

DECLARE @errorCode int
DECLARE @errorMessage varchar(70)
EXEC CAMBIAR_ESTADO_TICKET @NRO_TICKET= 1 ,@DOCUMENTO = 11000000 ,@TIPO_DOCU = 'DOCU',@EMPLEADO = 1002 ,@ESTADO_NUEVO ='EN PROGRESO',@ErrorCode = @errorCode OUTPUT,@ErrorMessage = @errorMessage OUTPUT
PRINT @errorCode
PRINT @errorMessage

select * from historial
SELECT * FROM TICKET


/*Cambiar el estado de un Ticket a Resuelto*/
DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC CAMBIAR_ESTADO_TICKET @NRO_TICKET= 1 ,@DOCUMENTO = 11000000 ,@TIPO_DOCU = 'DOCU',@EMPLEADO = 1002 ,@ESTADO_NUEVO ='RESUELTO',@ErrorCode = @errorCode OUTPUT,@ErrorMessage = @errorMessage OUTPUT
PRINT @ErrorCode
PRINT @ErrorMessage

SELECT * FROM TICKET
SELECT * FROM HISTORIAL
SELECT * FROM MENSAJE

/*Intentar hacer un cambio en el ticket con una transicion no permitida*/
SELECT * FROM TICKET
SELECT * FROM EMPLEADO

DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC CAMBIAR_ESTADO_TICKET @NRO_TICKET= 1 ,@DOCUMENTO = 11000000 ,@TIPO_DOCU = 'DOCU',@EMPLEADO = 1002 ,@ESTADO_NUEVO ='ABIERTO',@ErrorCode = @errorCode OUTPUT,@ErrorMessage = @errorMessage OUTPUT
PRINT @ErrorCode
PRINT @ErrorMessage

SELECT * FROM HISTORIAL
SELECT * FROM TICKET

DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC CAMBIAR_ESTADO_TICKET @NRO_TICKET=1 ,@DOCUMENTO = 11000000 ,@TIPO_DOCU = 'DOCU',@EMPLEADO = 1002 ,@ESTADO_NUEVO ='PENDIENTE CLIENTE',@ErrorCode = @ErrorCode OUTPUT,@ErrorMessage = @ErrorMessage OUTPUT
PRINT @ErrorCode
PRINT @ErrorMessage

SELECT * FROM HISTORIAL
SELECT * FROM TICKET


/*Reasignar un Ticket abierto a un usuario inactivo*/
SELECT * FROM EMPLEADO
DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC ASIGNAR_TICKET @NRO_TICKET=1,@DOCUMENTO=11000000,@TIPO_DOCU= 'DOCU',@EMPLEADO= 1001,@ErrorCode= @ErrorCode OUTPUT,@ErrorMessage= @ErrorMessage OUTPUT
PRINT @ErrorCode
PRINT @ErrorMessage
SELECT * FROM EMPLEADO

/*Reasignar un Ticket abierto a un usuario activo*/
SELECT * FROM EMPLEADO
DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC ASIGNAR_TICKET @NRO_TICKET=1,@DOCUMENTO=11000000,@TIPO_DOCU= 'DOCU',@EMPLEADO= 1003,@ErrorCode= @ErrorCode OUTPUT,@ErrorMessage= @ErrorMessage OUTPUT
PRINT @ErrorCode
PRINT @ErrorMessage

SELECT * FROM TICKET

/*CAMBIAR UN ESTADO DE TICKET A CERRADO*/

DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC CAMBIAR_ESTADO_TICKET @NRO_TICKET=1 ,@DOCUMENTO = 11000000 ,@TIPO_DOCU = 'DOCU',@EMPLEADO = 1003,@ESTADO_NUEVO ='CERRADO',@ErrorCode = @ErrorCode OUTPUT,@ErrorMessage = @ErrorMessage OUTPUT
PRINT @ErrorCode
PRINT @ErrorMessage

SELECT * FROM HISTORIAL
SELECT * FROM TICKET

/*Intentar hacer cualquier cambio del ticket con un usuario diferente al due�o*/
SELECT * FROM TICKET
SELECT * FROM EMPLEADO

DECLARE @ErrorCode int
DECLARE @ErrorMessage varchar(70)
EXEC CAMBIAR_ESTADO_TICKET @NRO_TICKET= 3 ,@DOCUMENTO = 11000000 ,@TIPO_DOCU = 'DOCU',@EMPLEADO = 1005 ,@ESTADO_NUEVO ='EN PROGRESO',@ErrorCode = @errorCode OUTPUT,@ErrorMessage = @errorMessage OUTPUT
PRINT @ErrorCode
PRINT @ErrorMessage

SELECT * FROM HISTORIAL