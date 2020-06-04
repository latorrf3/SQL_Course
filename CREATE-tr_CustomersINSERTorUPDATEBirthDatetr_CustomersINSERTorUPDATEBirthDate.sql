USE [Urban_Moves]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 27.05.2020
-- Description:	Trigger for [tb_Customers] that checks that the given [BirthDate] is for an 18 years old person (or older).
--				If it is younger, triggers a error message.
-- =============================================

DROP TRIGGER IF EXISTS [dbo].[tr_CustomersINSERTorUPDATEBirthDate]
GO

CREATE TRIGGER [dbo].[tr_CustomersINSERTorUPDATEBirthDate]
   ON  [dbo].[tb_Customers]
AFTER INSERT, UPDATE --Change
AS 

DECLARE @birthDate date
SET @birthDate = (SELECT [BirthDate] FROM inserted);

IF (YEAR(GETDATE()) - YEAR(@birthDate) -
		(CASE 
			WHEN (Month(@birthDate) > MONTH(GETDATE()))
			OR (Month(@birthDate) = MONTH(GETDATE()))
				AND Day(@birthDate) > DAY(GETDATE())
			THEN 1
			ELSE 0 
		END) < 18)


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	ROLLBACK TRANSACTION;
	RAISERROR ('You are to young, boy!', 1,1);
	

END
GO
