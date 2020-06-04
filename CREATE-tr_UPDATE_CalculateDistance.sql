SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 25.05.2020
-- Description:	Data manipulation language (DML) trigger that 
--				runs sp_CalculateDistance when we UPDATE a new location in tb_Destination
-- =============================================

DROP TRIGGER IF EXISTS [dbo].[tr_UPDATE_CalculateDistance]
GO

CREATE TRIGGER [dbo].[tr_UPDATE_CalculateDistance]
   ON  [dbo].[tb_Destination] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DECLARE @addressNumber bigint;
	DECLARE @pointA geography; -- point of interest
	DECLARE @addressType nvarchar(50); -- Type of address by its ID in tb_AddressType

	---  The user interacts with the DB through the [AddressNumber] ---
	SET @addressNumber = (SELECT [AddressNumber] --  sets the AddressNumber in tb_Destination
	FROM [dbo].[tb_Destination]);

	--- Translate [AddressNumber] to [Coordinates]
	SET @pointA = (SELECT [Coordinates] -- sets the point of interest from tb_Address according to the related AddressNumber
	FROM [dbo].[tb_Address]
	WHERE  [AddressNumber] = @addressNumber);

	--INSERT INTO [dbo].[tb_Destination] -- inserts into tb_Destination the value of @pointA
	--		([Destination])
	--	VALUES
	--		(@pointA);

	--- Now we gather the last variable that we need to calculate distances by direct interaction wih the user ---
	SET @addressType = (SELECT [AddressType] -- sets the addressType in tb_Destination
	FROM [dbo].[tb_Destination]);

	EXEC [dbo].[sp_DistanceCalculation] @pointA, @addressType; -- Executes the procedure sp_DistanceCalculation

END
GO
