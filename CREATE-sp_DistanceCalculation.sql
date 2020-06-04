USE [Urban_Moves]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 24.05.2020
-- Description:	Procedure with a cursor that calculates the distances between the current 
--				location and all the valid coordinates from tb_Address
-- =============================================
DROP PROCEDURE IF EXISTS [dbo].[sp_DistanceCalculation]
GO

CREATE PROCEDURE [dbo].[sp_DistanceCalculation] @pointA geography, @addressType nvarchar(50) --@pointA as parameter of the procedure
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--	DECLARE @pointA geography; -- desired destination
	DECLARE @pointB geography; -- possible locations
	DECLARE @addressID bigint;
--	DECLARE @streetName nvarchar(50); -- street name of @pointB
--	DECLARE @houseNumber nvarchar(50); -- house number of @pointB
--	DECLARE @addressType bigint; -- Type of addres of @pointB
--	DECLARE @addressType nvarchar(50); -- Corresponding string value of @addressType
--	DECLARE @select nvarchar(max); -- Variable to which function is ti run a scalar function inside a cursor in the proper way
	DECLARE @addressNumber bigint;

    -- Insert statements for procedure here

	--- Deletes the info from tb_Distance before calculating the distances ---
	DELETE
	FROM [dbo].[tb_Distance]
	--- ---

--	SET @select = SELECT [dbo].[sf_AddressTypeIDToString](@addressType); -- @deprecated line of code, because it wasn't a good praxis, but still a interesting thing to learn how to do it

	DECLARE cursor_distance CURSOR FOR
--	SELECT [Coordinates] -- Version without the address of the posible locations
--	SELECT [tb_Address].[Coordinates],[tb_Address].[StreetName],[tb_Address].[HouseNumber], [tb_Address].[AddressNumber]
--		,[tb_AddressType].[AddressType] -- Version that gives the address of the possible locations
	SELECT [tb_Address].[Coordinates], [tb_Address].[AddressID]
--	FROM [dbo].[tb_Address]
	FROM dbo.tb_Address 
		INNER JOIN dbo.tb_AddressType 
			ON dbo.tb_Address.AddressTypeID = dbo.tb_AddressType.AddressTypeID
---	Look at [tb_AddressType] to what to filter ---
--	WHERE NOT [AddressTypeID] BETWEEN 4 AND 6; -- Filter vehicles and Charging Stations' locations
--	WHERE [AddressTypeID] = 7; -- Filter only vehicles' locations
	WHERE [tb_AddressType].[AddressType] = @addressType;

	OPEN cursor_distance;
--		FETCH NEXT FROM cursor_distance INTO @pointB -- Version without the address of the posible locations
--		FETCH NEXT FROM cursor_distance INTO @pointB, @streetName, @houseNumber, @addressNumber, @addressType; -- Version that gives the address of the possible locations
		FETCH NEXT FROM cursor_distance INTO @pointB, @addressID;
		WHILE @@FETCH_STATUS = 0

		BEGIN
--			SET @pointA =  geography::Point(13.463083,52.514612,4326); -- change to choose another destination
--																		when commented, it should be declared and setted in the EXEC script

--			SELECT	--@pointA AS 'Current location', --Old version
--					@pointB AS 'Desired Location',
--					@streetName AS 'Address',
--					@pointA.STDistance(@pointB) AS 'Distance (m)';

			--- Runs scalar function sf_AddressTypeIDToString to transform @addressTypeID 
			--- into the corresponding @addressType as a variable ... LOL ---
--			SET @select = [dbo].[sf_AddressTypeIDToString](@addressTypeID);

			--- Inserts into tb_Distance the calculated distances (in meters) ---
			INSERT INTO [dbo].[tb_Distance]
--						([Distance],[Coordinates],[StreetName],[HouseNumber],[AddressNumber],[AddressType])
						([Distance],[AddressID])
			VALUES
--				(@pointA.STDistance(@pointB), @pointB, @streetName, @houseNumber, @addressNumber, @addressType);
				(@pointA.STDistance(@pointB),@addressID);
			--- ---
			--- Calculates next distance ---
--			FETCH NEXT FROM cursor_distance INTO @pointB;-- Version without the address of the posible locations
--			FETCH NEXT FROM cursor_distance INTO @pointB, @streetName, @houseNumber,@addressNumber, @addressType; -- Version that gives the address of the possible locations
			FETCH NEXT FROM cursor_distance INTO @pointB, @addressID;

		END -- Loop's end
		PRINT 'End'
	CLOSE cursor_distance;
	DEALLOCATE cursor_distance; -- Cursor ends

	--- Prints a table with the calculated distances and show them in ascended order ---
--	SELECT [Distance],[Coordinates],[StreetName] AS 'Street name',[HouseNumber] AS 'House number'
--		, [AddressNumber] AS 'Address number', [AddressType] AS 'Address Type'
--		FROM [Urban_Moves].[dbo].[tb_Distance]
--		WHERE [Distance] <= 10530386 -- Shows only the distances from an expecified threshold
--		ORDER BY [Distance] ASC;

	SELECT	dbo.tb_Distance.Distance, dbo.tb_Address.StreetName, dbo.tb_Address.HouseNumber
			, dbo.tb_Address.Coordinates, dbo.tb_AddressType.AddressType
	FROM	dbo.tb_Distance 
				INNER JOIN dbo.tb_Address 
					ON dbo.tb_Distance.AddressID = dbo.tb_Address.AddressID 
				INNER JOIN dbo.tb_AddressType 
					ON dbo.tb_Address.AddressTypeID = dbo.tb_AddressType.AddressTypeID
	ORDER BY [Distance] ASC;

END -- Procedure's end
