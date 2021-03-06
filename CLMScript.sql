USE [FINCT_CLM_Overpayments_110960]
GO
/****** Object:  StoredProcedure [dbo].[CreateCLMNewEntries]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CreateCLMNewEntries] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- The way that missing CLM entries are identified and added will be specific to each instance
	-- The query below relates to the specific OAS data instance
	-- In this instance the passed organisational unit is ignored
	INSERT INTO CLMData(AccountingCaseId, OrganisationalUnit)
		SELECT OASData.AccountingCaseId, OASData.OrganisationalUnit
		FROM [FINCT_CLM_Overpayments_110960].[dbo].[OASData]
		LEFT OUTER JOIN CLMData ON OASData.AccountingCaseId = CLMData.AccountingCaseID
		WHERE CLMData.AccountingCaseId IS NULL
END

GO
/****** Object:  StoredProcedure [dbo].[CreateCLMNewEntry]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CreateCLMNewEntry]
	-- Add the parameters for the stored procedure here
	@AccountingCaseId int
	, @OrganisationalUnit nvarchar(50)
	, @AssignedPool nvarchar(50) = null
	, @AssignedUser nvarchar(10) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
	
		BEGIN TRAN
			DECLARE @UserId nvarchar(50)
			SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

			INSERT INTO CLMData(AccountingCaseId, OrganisationalUnit, AssignedPool, AssignedUser)
			VALUES(@AccountingCaseId, @OrganisationalUnit, @AssignedPool, @AssignedUser)

			IF (@AssignedUser IS NOT NULL AND @AssignedUser != '')
				IF (@AssignedPool IS NULL OR @AssignedPool = '')
					RAISERROR('The case must be assigned to a pool before it can be assigned to a user.', 15,1)
				ELSE
					UPDATE CLMData
					SET AssignedPool = @AssignedPool
					,DateAssignedToPool = GETDATE()
					,AssignedToPoolBy = @UserId
					,AssignedUser = @AssignedUser
					,DateAssignedToUser = GETDATE()
					,AssignedToUserBy = @UserId
					WHERE AccountingCaseId = @AccountingCaseId
			ELSE
				if (@AssignedPool IS NOT NULL OR @AssignedPool != '')
					UPDATE CLMData
					SET AssignedPool = @AssignedPool
					,DateAssignedToPool = GETDATE()
					,AssignedToPoolBy = @UserId
					WHERE AccountingCaseId = @AccountingCaseId
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		DECLARE @ErrorNumber int = ERROR_NUMBER();
		DECLARE @ErrorLine int = ERROR_LINE();
		DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity int = ERROR_SEVERITY();
		DECLARE @ErrorState int = ERROR_STATE();

		RAISERROR(@ErrorMEssage, @ErrorSeverity, @ErrorState)
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMAssignedEntries]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMAssignedEntries] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @UserId nvarchar(50)
	SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
  FROM [CLMData]
  WHERE AssignedUser = @UserId AND Cleared = 0
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMAssignedEntryByUnitAndPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMAssignedEntryByUnitAndPool] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50) = null
	, @Pool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @UserId nvarchar(50)
	SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
  FROM [CLMData]
  WHERE OrganisationalUnit = @OrganisationalUnit AND AssignedPool = @Pool AND AssignedUser = @UserId AND Cleared = 0
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMEntry]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMEntry] 
	-- Add the parameters for the stored procedure here
	@AccountingCaseId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
  FROM [CLMData]
  WHERE AccountingCaseId = @AccountingCaseId
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMMyCases]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMMyCases] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- This is a query stub only - it must be customised for the data that the CLM is associated with
	-- The query also relies on there being a date in the associated case data (for instance, date
	-- paid, date to OAS, etc.)
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
DECLARE @UserId nvarchar(50)
SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0  AND AssignedUser = @UserId
  
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMMyCasesByDateAssigned]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMMyCasesByDateAssigned] 
	-- Add the parameters for the stored procedure here
	@StartDate nchar(8)
	, @EndDate nchar(8)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- This is a query stub only - it must be customised for the data that the CLM is associated with
	-- The query also relies on there being a date in the associated case data (for instance, date
	-- paid, date to OAS, etc.)
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
DECLARE @UserId nvarchar(50)
SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0  AND AssignedUser = @UserId AND (DateAssignedToUser BETWEEN @StartDate and @EndDate)
  
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMMyCasesByDateOfCase]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMMyCasesByDateOfCase] 
	-- Add the parameters for the stored procedure here
	@StartDate nchar(8)
	, @EndDate nchar(8)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- This is a query stub only - it must be customised for the data that the CLM is associated with
	-- The query also relies on there being a date in the associated case data (for instance, date
	-- paid, date to OAS, etc.)
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
DECLARE @UserId nvarchar(50)
SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0  AND AssignedUser = @UserId 
  
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMMyCasesByPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMMyCasesByPool] 
	-- Add the parameters for the stored procedure here
	@Pool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- This is a query stub only - it must be customised for the data that the CLM is associated with
	-- The query also relies on there being a date in the associated case data (for instance, date
	-- paid, date to OAS, etc.)
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
DECLARE @UserId nvarchar(50)
SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0  AND AssignedUser = @UserId AND AssignedPool = @Pool
  
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMMyCasesByUnitAndDateOfCase]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMMyCasesByUnitAndDateOfCase] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50)
	, @StartDate nchar(8)
	, @EndDate nchar(8)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- This is a query stub only - it must be customised for the data that the CLM is associated with
	-- The query also relies on there being a date in the associated case data (for instance, date
	-- paid, date to OAS, etc.)
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
DECLARE @UserId nvarchar(50)
SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0  AND AssignedUser = @UserId 
  
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMMyCasesByUnitAndPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMMyCasesByUnitAndPool] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50)
	, @Pool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- This is a query stub only - it must be customised for the data that the CLM is associated with
	-- The query also relies on there being a date in the associated case data (for instance, date
	-- paid, date to OAS, etc.)
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
DECLARE @UserId nvarchar(50)
SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0  AND AssignedUser = @UserId AND OrganisationalUnit = @OrganisationalUnit AND AssignedPool = @Pool
  
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMMyCasesByUnitPoolAndDateOfCase]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMMyCasesByUnitPoolAndDateOfCase] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50)
	, @Pool nvarchar(50)
	, @StartDate nchar(8)
	, @EndDate nchar(8)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- This is a query stub only - it must be customised for the data that the CLM is associated with
	-- The query also relies on there being a date in the associated case data (for instance, date
	-- paid, date to OAS, etc.)
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
DECLARE @UserId nvarchar(50)
SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0  AND AssignedUser = @UserId 
  AND OrganisationalUnit = @OrganisationalUnit
  AND AssignedPool = @Pool
  
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMNextAssignedCase]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMNextAssignedCase] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @UserId nvarchar(50)
	SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
  FROM [CLMData]
  WHERE AssignedUser = @UserId AND NextAction IS NULL AND Cleared = 0
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMNextAssignedEntryByUnitAndPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMNextAssignedEntryByUnitAndPool] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50) = null
	, @Pool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @UserId nvarchar(50)
	SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
  FROM [CLMData]
  WHERE OrganisationalUnit = @OrganisationalUnit 
  AND AssignedPool = @Pool 
  AND AssignedUser = @UserId 
  AND NextAction IS NULL
  AND Cleared = 0
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMOUnassignedEntriesInOrganisationalUnit]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMOUnassignedEntriesInOrganisationalUnit] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0 AND OrganisationalUnit = @OrganisationalUnit AND (AssignedUser IS NULL OR AssignedUser = '')
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMOutstandingEntriesAll]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMOutstandingEntriesAll] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMOutstandingEntriesInOrganisationalUnit]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMOutstandingEntriesInOrganisationalUnit] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0 AND OrganisationalUnit = @OrganisationalUnit
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMOutstandingEntriesInOrganisationalUnitAndPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMOutstandingEntriesInOrganisationalUnitAndPool] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50)
	, @Pool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0 AND OrganisationalUnit = @OrganisationalUnit AND AssignedPool = @Pool
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMOutstandingEntriesInOrganisationalUnitAndPoolByDateAssignedToUser]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMOutstandingEntriesInOrganisationalUnitAndPoolByDateAssignedToUser] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50)
	, @Pool nvarchar(50)
	, @StartDate nchar(8)
	, @EndDate nchar(8)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0 AND OrganisationalUnit = @OrganisationalUnit AND AssignedPool = @Pool
  AND DateAssignedToUser BETWEEN @StartDate AND @EndDate
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMOutstandingEntriesInOrganisationalUnitAndPoolByDateOfCase]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMOutstandingEntriesInOrganisationalUnitAndPoolByDateOfCase] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50)
	, @Pool nvarchar(50)
	, @StartDate nchar(8)
	, @EndDate nchar(8)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- This is a query stub only - it must be customised for the data that the CLM is associated with
	-- The query also relies on there being a date in the associated case data (for instance, date
	-- paid, date to OAS, etc.)
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0 AND OrganisationalUnit = @OrganisationalUnit AND AssignedPool = @Pool
  
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMOutstandingEntriesInOrganisationalUnitByDateOfCase]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMOutstandingEntriesInOrganisationalUnitByDateOfCase] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50)
	, @Pool nvarchar(50)
	, @StartDate nchar(8)
	, @EndDate nchar(8)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- This is a query stub only - it must be customised for the data that the CLM is associated with
	-- The query also relies on there being a date in the associated case data (for instance, date
	-- paid, date to OAS, etc.)
	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0 AND OrganisationalUnit = @OrganisationalUnit 
  
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMOutstandingEntriesInPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMOutstandingEntriesInPool] 
	-- Add the parameters for the stored procedure here
	@Pool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0 AND AssignedPool = @Pool
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMUnassignedEntriesInOrganisationalUnit]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMUnassignedEntriesInOrganisationalUnit] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0 AND (AssignedUser IS NULL OR AssignedUser = '') AND OrganisationalUnit = @OrganisationalUnit
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMUnassignedEntriesInOrganisationalUnitAndPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMUnassignedEntriesInOrganisationalUnitAndPool] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50)
	, @Pool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0 AND OrganisationalUnit = @OrganisationalUnit AND AssignedPool = @Pool
  AND (AssignedUser IS NULL OR AssignedUser = '')
END

GO
/****** Object:  StoredProcedure [dbo].[ReturnCLMUnassignedEntriesInPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReturnCLMUnassignedEntriesInPool] 
	-- Add the parameters for the stored procedure here
	@Pool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	-- This query should be customised to join the CLM data to the specific case data that you want
	-- to return. This includes adjusting the where clause to only select the 'unworked' case(s) (i.e.
	-- cases where the case was assigned but no actions have been taken)
SELECT [AccountingCaseId]
      ,[OrganisationalUnit]
      ,[AssignedPool]
      ,[DateAssignedToPool]
      ,[AssignedToPoolBy]
      ,[AssignedUser]
      ,[DateAssignedToUser]
      ,[AssignedToUserBy]
	  ,[NextAction]
  FROM [CLMData]
  WHERE Cleared = 0 AND (AssignedUser IS NULL OR AssignedUser = '') AND AssignedPool = @Pool
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateCLMAssignCasesToPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCLMAssignCasesToPool] 
	-- Add the parameters for the stored procedure here
	@Pool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @UserId nvarchar(50)
	SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

	BEGIN TRY
		BEGIN TRAN

		UPDATE CLMData 
		SET AssignedPool = @Pool, DateAssignedToPool = GETDATE(), AssignedToPoolBy = @UserId
		WHERE AccountingCaseId IN
		(
			SELECT AccountingCaseId FROM CLMDataTemp
		)

		DELETE FROM CLMDataTemp

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		DECLARE @ErrorNumber int = ERROR_NUMBER();
		DECLARE @ErrorLine int = ERROR_LINE();
		DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity int = ERROR_SEVERITY();
		DECLARE @ErrorState int = ERROR_STATE();

		RAISERROR(@ErrorMEssage, @ErrorSeverity, @ErrorState)
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateCLMAssignCaseToPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCLMAssignCaseToPool]
	-- Add the parameters for the stored procedure here
	@AccountingCaseId int
	, @Pool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @UserId nvarchar(50)
	SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

	UPDATE CLMData
	SET AssignedPool = @Pool, DateAssignedToPool = GETDATE(), AssignedToPoolBy = @UserId
	WHERE AccountingCaseId = @AccountingCaseId

END

GO
/****** Object:  StoredProcedure [dbo].[UpdateCLMAssignNextCase]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCLMAssignNextCase] 
	-- Add the parameters for the stored procedure here
	@Pool nvarchar(50)
	, @OrganisationalUnit nvarchar(50) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @UserId nvarchar(50)
	SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

	DECLARE @NextCase int
	SELECT TOP 1 
	@NextCase = OASData.AccountingCaseId 
	FROM CLMDATA
	LEFT OUTER JOIN OASData ON CLMData.AccountingCaseId = OASData.AccountingCaseId 
	WHERE AssignedPool = @Pool AND CLMData.OrganisationalUnit = @OrganisationalUnit AND (AssignedUser IS NULL OR AssignedUser = '')
	ORDER BY DateOverPaid ASC, Office ASC, Amount DESC

	IF @NextCase IS NULL 
		RAISERROR('There are currently no unassigned cases in the specified pool.', 15,1)
	ELSE
		UPDATE CLMData
		SET AssignedUser = @UserId, DateAssignedToUser = GETDATE(), AssignedToUserBy = @UserId
		WHERE AccountingCaseId = @NextCase
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateCLMReallocateUsersCaseToAnotherUser]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCLMReallocateUsersCaseToAnotherUser] 
	-- Add the parameters for the stored procedure here
	@AssignedUser nvarchar(10)
	, @OrganisationalUnit nvarchar(50) = NULL
	, @AssignTo nvarchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		INSERT INTO CLMDataTemp
		SELECT CLMData.AccountingCaseId FROM CLMData
		INNER JOIN OASData ON CLMData.AccountingCaseId = OASData.AccountingCaseId
		WHERE AssignedUser = @AssignedUser AND Cleared = 0 AND CLMData.OrganisationalUnit = @OrganisationalUnit

		EXEC UpdateCLMReassignCasesInTemp @AssignTo

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		DECLARE @ErrorNumber int = ERROR_NUMBER();
		DECLARE @ErrorLine int = ERROR_LINE();
		DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity int = ERROR_SEVERITY();
		DECLARE @ErrorState int = ERROR_STATE();

		RAISERROR(@ErrorMEssage, @ErrorSeverity, @ErrorState)
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateCLMReassignCase]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCLMReassignCase] 
	-- Add the parameters for the stored procedure here
	@AccountingCaseId int
	, @ReassignCaseTo nvarchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
DECLARE @UserId nvarchar(50)
SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

BEGIN TRY
	BEGIN TRAN
		INSERT INTO CLMDataArchive
		SELECT 
			[AccountingCaseId]
			,[OrganisationalUnit]
			,[AssignedPool]
			,[DateAssignedToPool]
			,[AssignedToPoolBy]
			,[AssignedUser]
			,[DateAssignedToUser]
			,[AssignedToUserBy]
			, GETDATE()
			, @UserId
		FROM [FINCT_CLM_Overpayments_110960].[dbo].[CLMData]
		WHERE AccountingCaseId = @AccountingCaseId

		UPDATE CLMData
		SET AssignedUser = @ReassignCaseTo, DateAssignedToUser = GETDATE(), AssignedToUserBy = @UserId
		WHERE AccountingCaseId = @AccountingCaseId

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @ErrorNumber int = ERROR_NUMBER();
	DECLARE @ErrorLine int = ERROR_LINE();
	DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
	DECLARE @ErrorSeverity int = ERROR_SEVERITY();
	DECLARE @ErrorState int = ERROR_STATE();

	RAISERROR(@ErrorMEssage, @ErrorSeverity, @ErrorState)
END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateCLMReassignCasesInTemp]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCLMReassignCasesInTemp] 
	-- Add the parameters for the stored procedure here
	@ReassignCaseTo nvarchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
DECLARE @UserId nvarchar(50)
SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

BEGIN TRY
	BEGIN TRAN
		INSERT INTO CLMDataArchive
		SELECT 
			[AccountingCaseId]
			,[OrganisationalUnit]
			,[AssignedPool]
			,[DateAssignedToPool]
			,[AssignedToPoolBy]
			,[AssignedUser]
			,[DateAssignedToUser]
			,[AssignedToUserBy]
			, GETDATE()
			, @UserId
		FROM [FINCT_CLM_Overpayments_110960].[dbo].[CLMData]
		WHERE AccountingCaseId IN
		(
			SELECT AccountingCaseId FROM CLMDataTemp
		)

		UPDATE CLMData
		SET AssignedUser = @ReassignCaseTo, DateAssignedToUser = GETDATE(), AssignedToUserBy = @UserId
		WHERE AccountingCaseId IN
		(
			SELECT AccountingCaseId FROM CLMDataTemp
		)

		DELETE FROM CLMDataTemp

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @ErrorNumber int = ERROR_NUMBER();
	DECLARE @ErrorLine int = ERROR_LINE();
	DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
	DECLARE @ErrorSeverity int = ERROR_SEVERITY();
	DECLARE @ErrorState int = ERROR_STATE();

	RAISERROR(@ErrorMEssage, @ErrorSeverity, @ErrorState)
END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateCLMReassignCasesInTempToNewPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCLMReassignCasesInTempToNewPool] 
	-- Add the parameters for the stored procedure here
	@Pool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
DECLARE @UserId nvarchar(50)
SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

BEGIN TRY
	BEGIN TRAN
		INSERT INTO CLMDataArchive
		SELECT 
			[AccountingCaseId]
			,[OrganisationalUnit]
			,[AssignedPool]
			,[DateAssignedToPool]
			,[AssignedToPoolBy]
			,[AssignedUser]
			,[DateAssignedToUser]
			,[AssignedToUserBy]
			, GETDATE()
			, @UserId
		FROM [FINCT_CLM_Overpayments_110960].[dbo].[CLMData]
		WHERE AccountingCaseId IN
		(
			SELECT AccountingCaseId FROM CLMDataTemp
		)

		UPDATE CLMData
		SET AssignedPool = @Pool, DateAssignedToPool = GETDATE(), AssignedToPoolBy = @UserId
		WHERE AccountingCaseId IN
		(
			SELECT AccountingCaseId FROM CLMDataTemp
		)

		DELETE FROM CLMDataTemp

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @ErrorNumber int = ERROR_NUMBER();
	DECLARE @ErrorLine int = ERROR_LINE();
	DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
	DECLARE @ErrorSeverity int = ERROR_SEVERITY();
	DECLARE @ErrorState int = ERROR_STATE();

	RAISERROR(@ErrorMEssage, @ErrorSeverity, @ErrorState)
END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateCLMReassignCasesToNewPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCLMReassignCasesToNewPool]
	-- Add the parameters for the stored procedure here
	@AssignedPool nvarchar(50)
	, @OrganisationalUnit nvarchar(50) = null
	, @NewPool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
BEGIN TRY
	BEGIN TRAN

		INSERT INTO CLMDataTemp
		SELECT CLMData.AccountingCaseId
		FROM CLMData
		INNER JOIN OASData ON CLMData.AccountingCaseId = OASData.AccountingCaseId
		WHERE CLMData.AssignedPool = @AssignedPool AND CLMData.OrganisationalUnit = @OrganisationalUnit AND OASData.Cleared = 0

		EXEC UpdateCLMReassignCasesInTempToNewPool @NewPool

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @ErrorNumber int = ERROR_NUMBER();
	DECLARE @ErrorLine int = ERROR_LINE();
	DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
	DECLARE @ErrorSeverity int = ERROR_SEVERITY();
	DECLARE @ErrorState int = ERROR_STATE();

	RAISERROR(@ErrorMEssage, @ErrorSeverity, @ErrorState)
END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateCLMResetPool]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateCLMResetPool] 
	-- Add the parameters for the stored procedure here
	@OrganisationalUnit nvarchar(50) = null
	, @Pool nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @UserId nvarchar(50)
	SELECT @UserId = admin.NT_USER_NAME from SYS.dm_exec_sessions admin where admin.session_id = @@SPID

	INSERT INTO CLMDataTemp
	SELECT CLMData.AccountingCaseId
	FROM CLMData
	INNER JOIN OASData ON CLMData.AccountingCaseId = OASData.AccountingCaseId
	WHERE CLMData.AssignedPool = @Pool AND CLMData.OrganisationalUnit = @OrganisationalUnit AND OASData.Cleared = 0

	INSERT INTO CLMDataArchive
		SELECT 
			[AccountingCaseId]
			,[OrganisationalUnit]
			,[AssignedPool]
			,[DateAssignedToPool]
			,[AssignedToPoolBy]
			,[AssignedUser]
			,[DateAssignedToUser]
			,[AssignedToUserBy]
			, GETDATE()
			, @UserId
		FROM [FINCT_CLM_Overpayments_110960].[dbo].[CLMData]
		WHERE AccountingCaseId IN
		(
			SELECT AccountingCaseId FROM CLMDataTemp
		)

		UPDATE CLMData
		SET AssignedPool = null, DateAssignedToPool = null, AssignedToPoolBy = null, AssignedUser = null, DateAssignedToUser = null, AssignedToUserBy = null
		WHERE AccountingCaseId IN
		(
			SELECT AccountingCaseId FROM CLMDataTemp
		)

		DELETE FROM CLMDataTemp

END

GO
/****** Object:  Table [dbo].[CLMData]    Script Date: 30/04/2019 13:44:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CLMData](
	[AccountingCaseId] [int] NOT NULL,
	[OrganisationalUnit] [nvarchar](50) NULL,
	[AssignedPool] [nvarchar](50) NULL,
	[DateAssignedToPool] [date] NULL,
	[AssignedToPoolBy] [nvarchar](10) NULL,
	[AssignedUser] [nvarchar](10) NULL,
	[DateAssignedToUser] [date] NULL,
	[AssignedToUserBy] [nvarchar](10) NULL,
	[NextAction] [nvarchar](50) NULL,
	[Cleared] [bit] NOT NULL,
 CONSTRAINT [PK_CLMData] PRIMARY KEY CLUSTERED 
(
	[AccountingCaseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CLMData] ADD  CONSTRAINT [DF_CLMData_Cleared]  DEFAULT ((0)) FOR [Cleared]
GO
