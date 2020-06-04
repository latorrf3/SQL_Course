SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 27.05.2020
-- Description:	Procedure that updates [tb_Vehicle], inserting the [StaffID] 
--				from [tb_Staff] in basis to the distance of the staff member to a given vehicle
-- =============================================

DROP PROCEDURE IF EXISTS [dbo].[sp_VehicleStaffCorrelator]
GO

CREATE PROCEDURE [dbo].[sp_VehicleStaffCorrelator] @staffID int
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--	DECLARE @staffID bigint;
	DECLARE @addressNumber bigint;
	DECLARE @vehicleNumber bigint;
--	DECLARE @staffNumber bigint;

    -- Insert statements for procedure here
	DECLARE cursor_correlator CURSOR FOR
	
--	SELECT        dbo.tb_Vehicle.VehicleNumber
--	FROM            dbo.tb_Vehicle INNER JOIN
--                         dbo.tb_Address ON dbo.tb_Vehicle.AdressID = dbo.tb_Address.AddressID CROSS JOIN
--                        dbo.tb_Distance
--	WHERE	dbo.tb_Address.AddressNumber = dbo.tb_Distance.AddressNumber AND dbo.tb_Distance.Distance <= 5000 -- this filters the radius of the staff member
--	ORDER BY dbo.tb_Distance.Distance ASC

--SELECT        dbo.tb_Vehicle.VehicleNumber
--FROM            dbo.tb_Staff 
--				INNER JOIN dbo.tb_Address 
--					ON dbo.tb_Staff.AddressID = dbo.tb_Address.AddressID 
--				INNER JOIN dbo.tb_Vehicle 
--					ON dbo.tb_Address.AddressID = dbo.tb_Vehicle.AdressID

SELECT        dbo.tb_Vehicle.VehicleNumber
FROM            dbo.tb_Staff 
				INNER JOIN dbo.tb_Vehicle 
					ON dbo.tb_Staff.StaffID = dbo.tb_Vehicle.StaffID

	OPEN cursor_correlator;
	FETCH NEXT FROM cursor_correlator INTO @vehicleNumber; -- Version that gives the address of the possible locations
		WHILE @@FETCH_STATUS = 0

		BEGIN

		UPDATE [dbo].[tb_Vehicle]
		   SET [StaffID] = @staffID
		 WHERE [VehicleNumber] = @vehicleNumber

		 PRINT 'Loop running'

		FETCH NEXT FROM cursor_correlator INTO @vehicleNumber;

		END -- Loop's end
		PRINT 'End'
	CLOSE cursor_correlator;
	DEALLOCATE cursor_correlator; -- Cursor ends

END
GO
