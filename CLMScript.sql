USE [FINCT_CLM_Overpayments_110960]
GO
/****** Object:  StoredProcedure [dbo].[CreateCLMNewEntries]    Script Date: 18/04/2019 13:00:58 ******/
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
/****** Object:  StoredProcedure [dbo].[CreateCLMNewEntry]    Script Date: 18/04/2019 13:00:58 ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateCLMAssignCasesToPool]    Script Date: 18/04/2019 13:00:58 ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateCLMAssignCaseToPool]    Script Date: 18/04/2019 13:00:58 ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateCLMAssignNextCase]    Script Date: 18/04/2019 13:00:58 ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateCLMReallocateUsersCaseToAnotherUser]    Script Date: 18/04/2019 13:00:58 ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateCLMReassignCase]    Script Date: 18/04/2019 13:00:58 ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateCLMReassignCasesInTemp]    Script Date: 18/04/2019 13:00:58 ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateCLMReassignCasesInTempToNewPool]    Script Date: 18/04/2019 13:00:58 ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateCLMReassignCasesToNewPool]    Script Date: 18/04/2019 13:00:58 ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateCLMResetPool]    Script Date: 18/04/2019 13:00:58 ******/
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
/****** Object:  Table [dbo].[CLMData]    Script Date: 18/04/2019 13:00:58 ******/
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
 CONSTRAINT [PK_CLMData] PRIMARY KEY CLUSTERED 
(
	[AccountingCaseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CLMDataArchive]    Script Date: 18/04/2019 13:00:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CLMDataArchive](
	[AccountingCaseId] [int] NOT NULL,
	[OrganisationalUnit] [nvarchar](50) NULL,
	[AssignedPool] [nvarchar](50) NULL,
	[DateAssignedToPool] [date] NULL,
	[AssignedToPoolBy] [nvarchar](10) NULL,
	[AssignedUser] [nvarchar](10) NULL,
	[DateAssignedToUser] [date] NULL,
	[AssignedToUserBy] [nvarchar](10) NULL,
	[DateArchived] [datetime] NULL,
	[ArchivedBy] [nvarchar](10) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CLMDataTemp]    Script Date: 18/04/2019 13:00:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CLMDataTemp](
	[AccountingCaseId] [int] NOT NULL,
 CONSTRAINT [PK_CLMDataTemp] PRIMARY KEY CLUSTERED 
(
	[AccountingCaseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[luOrganisationalUnits]    Script Date: 18/04/2019 13:00:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[luOrganisationalUnits](
	[OrganisationalUnit] [nvarchar](50) NOT NULL,
	[Historical] [bit] NULL,
 CONSTRAINT [PK_luOrganisationalUnits] PRIMARY KEY CLUSTERED 
(
	[OrganisationalUnit] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[luPools]    Script Date: 18/04/2019 13:00:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[luPools](
	[WorkType] [nvarchar](50) NOT NULL,
	[Pool] [nvarchar](50) NOT NULL,
	[Historical] [bit] NOT NULL,
 CONSTRAINT [PK_luPools] PRIMARY KEY CLUSTERED 
(
	[WorkType] ASC,
	[Pool] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[luOrganisationalUnits] ADD  CONSTRAINT [DF_luOrganisationalUnits_Historical]  DEFAULT ((0)) FOR [Historical]
GO
ALTER TABLE [dbo].[luPools] ADD  CONSTRAINT [DF_luPools_Historical]  DEFAULT ((0)) FOR [Historical]
GO
