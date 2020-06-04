SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 27.05.2020
-- Description:	Trigger that calculates distances between a staff member [@staffNumber] and all the vehicles.
--				Afterwards updates the [StaffID] in [tb_Vehicle] according the the smallest distance.
-- =============================================

DROP TRIGGER IF EXISTS [dbo].[tr_DistanceINSERTStaffVehicle] 
GO

CREATE TRIGGER [dbo].[tr_DistanceINSERTStaffVehicle] 
   ON  [dbo].[tb_Staff] 
   AFTER INSERT, UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here	
	DECLARE @staffNumber int;
	DECLARE @pointA geography; -- point of interest
	DECLARE @addressType nvarchar(50); -- Type of address by its ID in tb_AddressType
	DECLARE @staffID bigint;
	
	--- WHEN we update or insert data into the [tb_Staff] we run a sp_DistanceCalculation ---
	SET @staffNumber = (SELECT [StaffNumber] FROM inserted); -- takes the value of [StaffNumber] from [tb_Staff] that has been updated or inserted
--	SET @staffNumber = 100; --costant value for testing

	SET @pointA = (SELECT [Coordinates] -- sets the point of interest from tb_Address according to the related AddressNumber
	FROM            dbo.tb_Address INNER JOIN
                         dbo.tb_Staff ON dbo.tb_Address.AddressID = dbo.tb_Staff.AddressID
	WHERE        (dbo.tb_Staff.StaffNumber = @staffNumber));

	SET @addressType = 'Vehicle';

	EXEC [dbo].[sp_DistanceCalculation] @pointA, @addressType;
	PRINT 'End: Part 1'

	------ Update table vehicle with the staff near to the vehicle -----
	SET @staffID = (SELECT [StaffID] FROM [dbo].[tb_Staff] WHERE [StaffNumber] = @staffNumber);

	EXEC [dbo].[sp_VehicleStaffCorrelator] @staffID; -- executes [dbo].[sp_VehicleStaffCorrelator] to update the [tb_Vehicle] with the proper values of [StaffID]
	PRINT 'End: Part 2'

END
GO
