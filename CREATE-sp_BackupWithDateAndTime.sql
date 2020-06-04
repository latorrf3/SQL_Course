SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 23.05.2020
-- Description:	Procedure that creates a backup while it names the file using 
--				the date and time when it runs
-- =============================================

DROP PROCEDURE IF EXISTS [dbo].[sp_BackupWithDateAndTime]
GO

CREATE PROCEDURE [dbo].[sp_BackupWithDateAndTime]
	-- Add the parameters for the stored procedure here
	@path varchar(256)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-----------------------------------------------
	DECLARE @backupFile VARCHAR(MAX) -- file name
	DECLARE @dbname VARCHAR(MAX) -- database name
	DECLARE @fullDBackupName VARCHAR(MAX) --  full name of the backup file
	DECLARE @fileDate VARCHAR(8); -- String with the date
	DECLARE @fileTime VARCHAR(9); -- String with the time
	DECLARE @fileDateTime VARCHAR(18); -- Combination of @fileDate and @fileTime
	-----------------------------------------------
	-- Path confirmation --
	-- It checks that the folder's path provided in the EXEC script existis
	DECLARE @t TABLE (FileExists int, FileIsDir int, ParentDirExists int);
	INSERT INTO @t EXEC master.dbo.xp_fileexist @path
	
	-- In case it doesn´t exists, creates the folder in the especified path
	IF NOT (SELECT FileIsDir FROM @t) = 1 -- Ordner existiert nicht
		EXEC master.dbo.xp_create_subdir @path -- Ordner erstellen

    -- Insert statements for procedure here
--	SELECT  name
--	FROM MASTER.dbo.sysdatabases
--	WHERE name = 'Urban_Moves';

	--- Date and Time stamp ---
	SET @fileDate = CONVERT(VARCHAR(18), GETDATE(), 112); --  Format: yyyymmdd
	SET @fileTime =  REPLACE(CONVERT(VARCHAR(18), GETDATE(), 114), ':', ''); -- Format:hhmmss(ms)
	--- Dataname ---
	SET @dbname = 'Urban_Moves'; -- name of the data base
	SET @fileDateTime = @fileDate + '-' + @fileTime;
	SET @backupFile = @dbname + '-' + @fileDateTime + '.bak';
	--- Path und Dataname ---
	SET @fullDBackupName = @path + @backupFile; 
	--- BACKUP ---
	BACKUP DATABASE @dbname TO DISK = @fullDBackupName; -- Saves the DB
	---

	PRINT 'End' -- Prints End in the console

END
GO
