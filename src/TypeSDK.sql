USE [master]
GO
/****** Object:  Database [TypeSDK]    Script Date: 2016/10/31 0:35:32 ******/
CREATE DATABASE [TypeSDK]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TypeSDK', FILENAME = N'D:\MSSQL\DATA\TypeSDK.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'TypeSDK_log', FILENAME = N'D:\MSSQL\DATA\TypeSDK_log.ldf' , SIZE = 1536KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [TypeSDK] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TypeSDK].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [TypeSDK] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TypeSDK] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TypeSDK] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TypeSDK] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TypeSDK] SET ARITHABORT OFF 
GO
ALTER DATABASE [TypeSDK] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [TypeSDK] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [TypeSDK] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TypeSDK] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TypeSDK] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TypeSDK] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TypeSDK] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TypeSDK] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TypeSDK] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TypeSDK] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TypeSDK] SET  DISABLE_BROKER 
GO
ALTER DATABASE [TypeSDK] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TypeSDK] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TypeSDK] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [TypeSDK] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [TypeSDK] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TypeSDK] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TypeSDK] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [TypeSDK] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [TypeSDK] SET  MULTI_USER 
GO
ALTER DATABASE [TypeSDK] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TypeSDK] SET DB_CHAINING OFF 
GO
ALTER DATABASE [TypeSDK] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [TypeSDK] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [TypeSDK]
GO
/****** Object:  User [TypeSDK_user]    Script Date: 2016/10/31 0:35:32 ******/
CREATE USER [TypeSDK_user] FOR LOGIN [TypeSDK_user] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [TypeSDK_user]
GO
/****** Object:  StoredProcedure [dbo].[sdk_addGame]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-01-27>
-- Description:	<添加游戏>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_addGame]
	@GameName nvarchar(50) ,
	@GameDisplayName nvarchar(50) ,
	@AndroidVersionID int ,
	@IOSVersionID int ,
	@AndroidKeyID int ,
	@IOSKeyID int ,
	@GameIcon nvarchar(100) ,
	@CreateUser nvarchar(50),  
	@GameNameSpell nvarchar(50),  
	@UnityVer nvarchar(50),  
	@ProductName nvarchar(50),
	@IsEncryption nvarchar(50),
	@SDKGameID nvarchar(50),
	@SDKGameKey nvarchar(50),
	@strErrorDescribe NVARCHAR(127) output		-- 输出参数
AS
BEGIN
	SET NOCOUNT ON;
	Declare @GameID int
	if not exists(select * from sdk_GameInfo where GameName=@GameName and GameDisplayName=@GameDisplayName)
	begin
		INSERT INTO [sdk_GameInfo] ([GameName],[GameDisplayName],[AndroidVersionID],[IOSVersionID],[AndroidKeyID],[GameIcon],[CreateUser],[GameNameSpell],[UnityVer],ProductName,[SDKGameID],[SDKGameKey])
        VALUES (@GameName,@GameDisplayName,@AndroidVersionID,@IOSVersionID,@AndroidKeyID,@GameIcon,@CreateUser,@GameNameSpell,@UnityVer,@ProductName,@SDKGameID,@SDKGameKey)
		if @@ERROR<>0
		begin			
			set @strErrorDescribe=N'游戏添加失败！'
			return 1
		end
		else
		begin
			set @GameID=@@IDENTITY
			insert into [sdk_icon] ([iconName],[SystemID],[GameID]) values (@GameName+'_Default',1,@GameID)
			return 0
		end
	end
	begin
		set @strErrorDescribe=N'游戏已存在！'
		return 1
	end
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_addGameVersion]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-11>
-- Description:	<添加游戏版本>
-- =============================================

CREATE PROCEDURE [dbo].[sdk_addGameVersion]
	@GameName nvarchar(200),
	@GameVersion nvarchar(200),
	@isDefault bit
AS
	declare @VersionId int
BEGIN
	SET NOCOUNT ON;
	insert into [dbo].[sdk_GameVersion](GameName,GameVersion,GameVersionStatus)
			values(@GameName,@GameVersion,2)

	set @VersionId = @@IDENTITY

    if(@isDefault = 1)
	begin
		update sdk_GameVersion 
			set GameVersionStatus = 2
			where GameName = @GameName

		update sdk_GameVersion
			set GameVersionStatus = 1
			where Id = @VersionId
	end


END





GO
/****** Object:  StoredProcedure [dbo].[sdk_AddMyVersion]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-11>
-- Description:	<新增版本>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_AddMyVersion] 
	@dwMyVersionName NVARCHAR(50),			-- 版本名
	@dwAccoutns NVARCHAR(50),				-- 操作用户
	@dwMyVersionID int,						-- 基础版本ID
	@dwFlatformID int,						-- 平台ID
	@strErrorDescribe NVARCHAR(127) output	-- 输出参数
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @NEWID INT
	 
	select id from sdk_TypeSdkVersion where MyVersion=@dwMyVersionName and PlatformID=@dwFlatformID
	if @@ROWCOUNT<>0
	begin
		set @strErrorDescribe =N'版本已存在！'
		return 1
	end
	insert into [sdk_TypeSdkVersion] ([MyVersion],[CreateUser],[PlatformID]) values (@dwMyVersionName,@dwAccoutns,@dwFlatformID)
	if @@ERROR<>0
	begin
		set @strErrorDescribe =N'新增版本失败，请重试！'
		return 2
	end

	SET @NEWID=@@IDENTITY
	INSERT INTO [sdk_Platform] SELECT [PlatformID]
      ,[SdkVersion]
      ,[MyVersionID]=@NEWID
      ,[SystemID]=@dwFlatformID from [sdk_Platform] WHERE [MyVersionID]=@dwMyVersionID and SystemID=@dwFlatformID

	SET @strErrorDescribe =N'新增版本成功！'
	RETURN 0
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_AddNewAdPackageTask]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016.01.06>
-- Description:	<分包任务>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_AddNewAdPackageTask]
	@RecID int,
	@GameID int,
	@AdID int,
	@AdName nvarchar(50),
	@CreateTaskID nvarchar(50),
	@CreateUser nvarchar(128)
AS
BEGIN
	if not exists(select 1 from sdk_AdPackageCreateTask where recid=@RecID and adid=@AdID)
	insert into sdk_AdPackageCreateTask (recid,gameid,adid,adname,CreateTaskID,CreateUser) values (@RecID,@GameID,@AdID,@AdName,@CreateTaskID,@CreateUser)
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_AddNewPackageTask]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016.01.06>
-- Description:	<新建任务>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_AddNewPackageTask] 
	@dwTaskID int,							-- 关联文件ID
	@dwCreateUser nvarchar(50),				-- 创建人
	@dwPlaceIDList nvarchar(500),			-- 渠道ID列表
	@dwCreateTaskID nvarchar(50),			-- 任务批次ID
	@SystemName nvarchar(9),					-- 平台名称
	@GameID int,
	@GameVersion nvarchar(50),
	@GameLable nvarchar(50),
	@PlatformVersionList nvarchar(500),
	@IsEncryption nvarchar(1)

AS

DECLARE @placeid int
DECLARE @count int
DECLARE @split nvarchar(1)
DECLARE @str nvarchar(500)
DECLARE @str2 nvarchar(500)
DECLARE @strsql nvarchar(200)
DECLARE @pos1 NVARCHAR(20)
DECLARE @pos2 NVARCHAR(20)
DECLARE @m int
DECLARE @n int
DECLARE @m2 int
DECLARE @n2 int

BEGIN TRAN
	SET NOCOUNT ON;
	SET @str=@dwPlaceIDList+','
	SET @str2=@PlatformVersionList+','
	SET @split=','
	SET @m=CHARINDEX(@split,@str)
	SET @m2=CHARINDEX(@split,@str2)
	SET @n=1
	SET @n2=1

	WHILE @m>0
	BEGIN 
		SET @pos1=SUBSTRING(@str,@n,@m-@n)
		SET @pos2=SUBSTRING(@str2,@n2,@m2-@n2)
		IF @SystemName='Android'
		BEGIN		
			insert into sdk_NewPackageCreateTask (PackageTaskID,CreateUser,PlatFormID,CreateTaskID,GameID,GameFileVersion,GameVersionLable,PlatformVersion,IsEncryption) values (@dwTaskID,@dwCreateUser,@pos1,@dwCreateTaskID,@GameID,@GameVersion,@GameLable,@pos2,@IsEncryption)		
		END
		ELSE
		BEGIN
			insert into sdk_NewPackageCreateTask_IOS (PackageTaskID,CreateUser,PlatFormID,CreateTaskID,GameID,GameFileVersion,GameVersionLable,PlatformVersion) values (@dwTaskID,@dwCreateUser,@pos1,@dwCreateTaskID,@GameID,@GameVersion,@GameLable,@pos2)
		END

		if @@ERROR<>0
		BEGIN		
			ROLLBACK TRAN
			RETURN 1
		END
		SET @n=@m+1
		SET @n2=@m2+1
		SET @m=CHARINDEX(@split,@str,@n)
		SET @m2=CHARINDEX(@split,@str2,@n2)
	END
	
	COMMIT TRAN
	RETURN 0



GO
/****** Object:  StoredProcedure [dbo].[sdk_AddNewPackageTaskTest]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016.01.06>
-- Description:	<新建任务>
-- =============================================
Create PROCEDURE [dbo].[sdk_AddNewPackageTaskTest] 
	@dwTaskID int,							-- 关联文件ID
	@dwCreateUser nvarchar(50),				-- 创建人
	@dwPlaceIDList nvarchar(500),			-- 渠道ID列表
	@dwCreateTaskID nvarchar(50),			-- 任务批次ID
	@SystemName nvarchar(9),					-- 平台名称
	@GameID int,
	@GameVersion nvarchar(50),
	@GameLable nvarchar(50),
	@PlatformVersionList nvarchar(500),
	@IsEncryption nvarchar(1)

AS

DECLARE @placeid int
DECLARE @count int
DECLARE @split nvarchar(1)
DECLARE @str nvarchar(500)
DECLARE @str2 nvarchar(500)
DECLARE @strsql nvarchar(200)
DECLARE @pos1 NVARCHAR(20)
DECLARE @pos2 NVARCHAR(20)
DECLARE @m int
DECLARE @n int
DECLARE @m2 int
DECLARE @n2 int

BEGIN TRAN


	SET NOCOUNT ON;
	SET @str=@dwPlaceIDList+','
	SET @str2=@PlatformVersionList+','
	SET @split=','
	SET @m=CHARINDEX(@split,@str)
	SET @m2=CHARINDEX(@split,@str2)
	SET @n=1
	SET @n2=1


	WHILE @m>0
	BEGIN 
		SET @pos1=SUBSTRING(@str,@n,@m-@n)
		SET @pos2=SUBSTRING(@str2,@n2,@m2-@n2)

		IF @SystemName='Android'
		BEGIN		
			insert into sdk_NewPackageCreateTask (PackageTaskID,CreateUser,PlatFormID,CreateTaskID,GameID,GameFileVersion,GameVersionLable,PlatformVersion,IsEncryption) values (@dwTaskID,@dwCreateUser,@pos1,@dwCreateTaskID,@GameID,@GameVersion,@GameLable,@pos2,@IsEncryption)		
		END
		ELSE
		BEGIN
			insert into sdk_NewPackageCreateTask_IOS (PackageTaskID,CreateUser,PlatFormID,CreateTaskID,GameID,GameFileVersion,GameVersionLable,PlatformVersion) values (@dwTaskID,@dwCreateUser,@pos1,@dwCreateTaskID,@GameID,@GameVersion,@GameLable,@pos2)
		END
		
		if @@ERROR<>0
		BEGIN		
			ROLLBACK TRAN
			RETURN 1
		END
		SET @n=@m+1
		SET @n2=@m2+1
		SET @m=CHARINDEX(@split,@str,@n)
		SET @m2=CHARINDEX(@split,@str2,@n2)
	END
	
	COMMIT TRAN
	RETURN 0




GO
/****** Object:  StoredProcedure [dbo].[sdk_AddPackageProject]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		TypeSDK
-- Create date: 2016.1.6
-- Description:	添加打包数据
-- =============================================
CREATE PROCEDURE [dbo].[sdk_AddPackageProject]
	@dwUploadUser nvarchar(50),			-- 上传账号
	@dwGameVersion nvarchar(150),		-- 版本号
	@dwPageageTable nvarchar(150),		-- 标签
	@dwFileSize decimal(18,2),			-- 包大小
	@dwGameName nvarchar(50),			-- 游戏简称
	@dwGamePlatFrom nvarchar(20),		-- 游戏平台
	@dwStrCollectDatetime nvarchar(20),	-- 创建时间字符串
	@dwGameID int
AS
BEGIN
	INSERT INTO sdk_UploadPackageInfo (GameVersion,PageageTable,FileSize,UploadUser,GameName,GamePlatFrom,StrCollectDatetime,GameID) VALUES (@dwGameVersion,@dwPageageTable,@dwFileSize,@dwUploadUser,@dwGameName,@dwGamePlatFrom,@dwStrCollectDatetime,@dwGameID)
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_AddPlatfrom]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<添加渠道>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_AddPlatfrom]
	@dwPlatformName nvarchar(50),				-- 渠道简称
	@dwPlatformDisplayName nvarchar(50),		-- 渠道名称
	@dwSdkVersion nvarchar(50),					-- 渠道版本
	@dwMyVersionID int,							-- 版本ID
	@dwSystemID int,							-- 平台ID
	@dwPlatformIcon nvarchar(150),				-- 渠道Icon
	@CREATEUSER NVARCHAR(50),					-- 创建人
	@strErrorDescribe NVARCHAR(127) output		-- 输出参数
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @DefaultPlatformID int
	DECLARE @NEWID INT
	SELECT @DefaultPlatformID=id FROM sdk_DefaultPlatform WHERE PlatformName=@dwPlatformName AND PlatformDisplayName=@dwPlatformDisplayName and SystemID=@dwSystemID
	IF @@ROWCOUNT<>0
	BEGIN
		SELECT * FROM sdk_Platform WHERE PlatformID=@DefaultPlatformID AND MyVersionID=@dwMyVersionID AND SystemID=@dwSystemID
		IF @@ROWCOUNT<>0
		BEGIN
			SET @strErrorDescribe=N'渠道名称或简称重复，请确认！'
			RETURN 1
		END
		ELSE
		BEGIN
			INSERT INTO sdk_PlatformVersion ([PlatformID],[Version],[CreateUser],[SystemID]) VALUES (@DefaultPlatformID,@dwSdkVersion,@CREATEUSER,@dwSystemID)
			IF @@ERROR<>0
			BEGIN
				SET @strErrorDescribe=N'渠道版本插入失败，请重试！'
				RETURN 3
			END

			SET @NEWID=@@IDENTITY

			INSERT INTO sdk_Platform ([PlatformID],[SdkVersion],[MyVersionID],[SystemID]) VALUES (@DefaultPlatformID,@NEWID,@dwMyVersionID,@dwSystemID)
			IF @@ERROR<>0
			BEGIN
				SET @strErrorDescribe=N'渠道添加失败，请重试！'
				RETURN 2
			END
			ELSE
			BEGIN
				SET @strErrorDescribe=N'渠道添加成功！'
				RETURN 0
			END
		END
	END
	ELSE
	BEGIN TRAN
		DECLARE @NwePlatformID INT
		INSERT INTO sdk_DefaultPlatform ([PlatformName],[PlatformDisplayName],[PlatformStatus],[PlatformIcon],SystemID,PlugInID) VALUES (@dwPlatformName,@dwPlatformDisplayName,1,@dwPlatformIcon,@dwSystemID,0)
		IF @@ERROR<>0
		BEGIN
			SET @strErrorDescribe=N'渠道添加失败，请重试！'
			ROLLBACK TRAN
			RETURN 2
		END
		SET @NwePlatformID=@@IDENTITY
		INSERT INTO sdk_PlatformVersion ([PlatformID],[Version],[CreateUser],[SystemID]) VALUES (@NwePlatformID,@dwSdkVersion,@CREATEUSER,@dwSystemID)
		IF @@ERROR<>0
		BEGIN
			SET @strErrorDescribe=N'渠道版本插入失败，请重试！'
			ROLLBACK TRAN
			RETURN 3
		END
		SET @NEWID=@@IDENTITY

		INSERT INTO sdk_Platform ([PlatformID],[SdkVersion],[MyVersionID],[SystemID]) VALUES (@NwePlatformID,@NEWID,@dwMyVersionID,@dwSystemID)
		IF @@ERROR<>0
		BEGIN
			SET @strErrorDescribe=N'渠道添加失败，请重试！'
			ROLLBACK TRAN
			RETURN 2
		END
		INSERT INTO [sdk_DefaultPlatformConfig] SELECT [PlatformID]=@NwePlatformID,[SDKKey],[Explain],[StringValue],[isCPSetting],[isBuilding],[isServer],[SYSTEMID]=@dwSystemID FROM [sdk_PlatformConfigKey]
	COMMIT TRAN
	SET @strErrorDescribe=N'渠道添加成功！'
	RETURN 0


END




GO
/****** Object:  StoredProcedure [dbo].[sdk_addSignatureKey]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<添加签名密钥>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_addSignatureKey]
	@keyId int,
	@keyName nvarchar(200),
	@keyStore nvarchar(200),
	@keyStorePassword nvarchar(200),
	@keyAlias nvarchar(200),
	@keyAliasPassword nvarchar(200)

AS
BEGIN
	SET NOCOUNT ON;

    if(@keyId = 0)
	begin
		insert into [dbo].[sdk_SignatureKey](KeyName,KeyStore,KeyStorePassword,KeyAlias,KeyAliasPassword)
			values(@keyName,@keyStore,@keyStorePassword,@keyAlias,@keyAliasPassword)
	end
	else
	begin
		update [dbo].[sdk_SignatureKey]
			set KeyName = @keyName
				,KeyStore = @keyStore
				,KeyStorePassword = @keyStorePassword
				,KeyAlias = @keyAlias
				,KeyAliasPassword = @keyAliasPassword
			where id = @keyId;
	end

END





GO
/****** Object:  StoredProcedure [dbo].[sdk_deleteGame]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<删除游戏>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_deleteGame]
	@GameID nvarchar(50),
	@strErrorDescribe nvarchar(127) output
AS
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	delete from sdk_GameInfo where GameID=@GameID
	if @@ERROR<>0
	begin
		set @strErrorDescribe=N'游戏删除失败！'
		return 1
	end
	delete from sdk_GamePlatformIcon where GameName=@GameID
	delete from sdk_GamePlatFromInfo where GameID=@GameID
	delete from sdk_NewPackageCreateTask where PackageTaskID in (select RecID from sdk_UploadPackageInfo where GameID=@GameID)
	delete from sdk_PlatformConfig where GameName=@GameID
	delete from sdk_UploadPackageInfo where GameID=@GameID	
	delete from sdk_NewPackageCreateTask_IOS where PackageTaskID in (select RecID from sdk_UploadPackageInfo where GameID=@GameID)
	set @strErrorDescribe=N'游戏删除成功！'
	return 0
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_deletePackageCreateTask]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<删除渠道包任务>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_deletePackageCreateTask]
	@RecID int,
	@SystemName nvarchar(7)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @SystemName='Android'
    delete from sdk_NewPackageCreateTask where RecID=@RecID
	else
    delete from sdk_NewPackageCreateTask_IOS where RecID=@RecID
END





GO
/****** Object:  StoredProcedure [dbo].[sdk_deletePlugIn]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<删除插件>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_deletePlugIn]
	@ID int
AS
BEGIN
	delete from sdk_PlugInList where id=@ID
END





GO
/****** Object:  StoredProcedure [dbo].[sdk_deletePlugInVersion]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<删除插件版本>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_deletePlugInVersion]
	@ID int
AS
BEGIN
	delete from sdk_PlugInVersion where id=@ID
END





GO
/****** Object:  StoredProcedure [dbo].[sdk_deleteUser]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<添加用户>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_deleteUser]
	@ID nvarchar(128)
AS
BEGIN
	delete from AspNetUsers where Id=@ID
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getAdPackageTask]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<获取分包任务>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getAdPackageTask]
AS
	SET NOCOUNT ON;
	DECLARE @RecID int
	DECLARE @GameName nvarchar(50)
	DECLARE @GameID int
	DECLARE @AdID int
	DECLARE @AdName nvarchar(50)
	DECLARE @CreateTaskID nvarchar(50)
	DECLARE @PackageName nvarchar(150)
BEGIN
	update sdk_AdPackageCreateTask set PackageTaskStatus=1 where DATEDIFF(N,StartDatetime,GETDATE())>30 and PackageTaskStatus=2

	select top 1 @RecID=ad.recid,@GameID=ad.gameid,@AdID=ad.adid,@AdName=ad.adname,@GameName=gi.GameName,@CreateTaskID=npct.CreateTaskID,@PackageName=npct.PackageName from sdk_AdPackageCreateTask ad
	left join sdk_GameInfo gi on ad.GameID=gi.GameID
	left join sdk_NewPackageCreateTask npct on ad.recid=npct.recid 
	where ad.PackageTaskStatus=1 order by ad.CollectDatetime
	if @@ROWCOUNT<>0
	UPDATE sdk_AdPackageCreateTask SET StartDatetime=GETDATE(),PackageTaskStatus=0 WHERE RecID=@RecID and AdID=@AdID
	else
	begin
	set @RecID=0
	set @GameID=0
	set @GameName=N''
	set @AdID=0
	set @AdName=N''
	set @CreateTaskID=N''
	set @PackageName=N''
	end
	select @RecID as RecID,@GameID as GameID,@GameName as GameName,@AdID as AdID,@AdName as AdName,@CreateTaskID as CreateTaskID,@PackageName as PackageName
	
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getAdPackageTaskList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-01-28>
-- Description:	<获取打包任务详情>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getAdPackageTaskList]
	@PackageTaskStatus int,
	@GameID int,
	@UserName nvarchar(50),
	@IsMy bit
AS
BEGIN

	if @PackageTaskStatus=0
	begin
		if @GameID=0
		begin 
			if @IsMy=0
			begin
				select apct.recid,apct.adid,apct.adname,apct.CreateTaskID,apct.PackageTaskStatus,apct.PackageName,apct.StartDatetime,npct.PlugInID,npct.IsEncryption,npct.PlatformVersion,npct.GameFileVersion,gi.GameName,gi.GameDisplayName,us.Compellation 
				from sdk_AdPackageCreateTask apct
				inner join sdk_NewPackageCreateTask npct on apct.recid=npct.RecID
				inner join sdk_GameInfo gi on apct.GameID=gi.GameID
				left join AspNetUsers us on apct.CreateUser=us.Email
				order by apct.CollectDatetime desc
			end
			else
			begin
				select apct.recid,apct.adid,apct.adname,apct.CreateTaskID,apct.PackageTaskStatus,apct.PackageName,apct.StartDatetime,npct.PlugInID,npct.IsEncryption,npct.PlatformVersion,npct.GameFileVersion,gi.GameName,gi.GameDisplayName,us.Compellation 
				from sdk_AdPackageCreateTask apct
				inner join sdk_NewPackageCreateTask npct on apct.recid=npct.RecID
				inner join sdk_GameInfo gi on apct.GameID=gi.GameID
				left join AspNetUsers us on apct.CreateUser=us.Email
				where apct.createuser=@UserName
				order by apct.CollectDatetime desc
			end
		end
		else
		begin
		if @IsMy=0
			begin
				select apct.recid,apct.adid,apct.adname,apct.CreateTaskID,apct.PackageTaskStatus,apct.PackageName,apct.StartDatetime,npct.PlugInID,npct.IsEncryption,npct.PlatformVersion,npct.GameFileVersion,gi.GameName,gi.GameDisplayName,us.Compellation 
				from sdk_AdPackageCreateTask apct
				inner join sdk_NewPackageCreateTask npct on apct.recid=npct.RecID
				inner join sdk_GameInfo gi on apct.GameID=gi.GameID
				left join AspNetUsers us on apct.CreateUser=us.Email
				where apct.gameid=@GameID
				order by apct.CollectDatetime desc
			end
		else
			begin
				select apct.recid,apct.adid,apct.adname,apct.CreateTaskID,apct.PackageTaskStatus,apct.PackageName,apct.StartDatetime,npct.PlugInID,npct.IsEncryption,npct.PlatformVersion,npct.GameFileVersion,gi.GameName,gi.GameDisplayName,us.Compellation 
				from sdk_AdPackageCreateTask apct
				inner join sdk_NewPackageCreateTask npct on apct.recid=npct.RecID
				inner join sdk_GameInfo gi on apct.GameID=gi.GameID
				left join AspNetUsers us on apct.CreateUser=us.Email
				where apct.createuser=@UserName and apct.gameid=@GameID
				order by apct.CollectDatetime desc
			end
			
		end

	end
	else if @PackageTaskStatus=1
	begin
		if @GameID=0
		begin 
		if @IsMy=0
			begin
				select apct.recid,apct.adid,apct.adname,apct.CreateTaskID,apct.PackageTaskStatus,apct.PackageName,apct.StartDatetime,npct.PlugInID,npct.IsEncryption,npct.PlatformVersion,npct.GameFileVersion,gi.GameName,gi.GameDisplayName,us.Compellation 
				from sdk_AdPackageCreateTask apct
				inner join sdk_NewPackageCreateTask npct on apct.recid=npct.RecID
				inner join sdk_GameInfo gi on apct.GameID=gi.GameID
				left join AspNetUsers us on apct.CreateUser=us.Email
				where apct.PackageTaskStatus in (0,1,2)
				order by apct.CollectDatetime desc
			end
		else
			begin
				select apct.recid,apct.adid,apct.adname,apct.CreateTaskID,apct.PackageTaskStatus,apct.PackageName,apct.StartDatetime,npct.PlugInID,npct.IsEncryption,npct.PlatformVersion,npct.GameFileVersion,gi.GameName,gi.GameDisplayName,us.Compellation 
				from sdk_AdPackageCreateTask apct
				inner join sdk_NewPackageCreateTask npct on apct.recid=npct.RecID
				inner join sdk_GameInfo gi on apct.GameID=gi.GameID
				left join AspNetUsers us on apct.CreateUser=us.Email
				where apct.PackageTaskStatus in (0,1,2) and apct.createuser=@UserName 
				order by apct.CollectDatetime desc
			end			
		end
		else
		begin
		if @IsMy=0
			begin
				select apct.recid,apct.adid,apct.adname,apct.CreateTaskID,apct.PackageTaskStatus,apct.PackageName,apct.StartDatetime,npct.PlugInID,npct.IsEncryption,npct.PlatformVersion,npct.GameFileVersion,gi.GameName,gi.GameDisplayName,us.Compellation 
				from sdk_AdPackageCreateTask apct
				inner join sdk_NewPackageCreateTask npct on apct.recid=npct.RecID
				inner join sdk_GameInfo gi on apct.GameID=gi.GameID
				left join AspNetUsers us on apct.CreateUser=us.Email
				where apct.PackageTaskStatus in (0,1,2) and apct.gameid=@GameID
				order by apct.CollectDatetime desc
			end
		else
			begin
				select apct.recid,apct.adid,apct.adname,apct.CreateTaskID,apct.PackageTaskStatus,apct.PackageName,apct.StartDatetime,npct.PlugInID,npct.IsEncryption,npct.PlatformVersion,npct.GameFileVersion,gi.GameName,gi.GameDisplayName,us.Compellation 
				from sdk_AdPackageCreateTask apct
				inner join sdk_NewPackageCreateTask npct on apct.recid=npct.RecID
				inner join sdk_GameInfo gi on apct.GameID=gi.GameID
				left join AspNetUsers us on apct.CreateUser=us.Email
				where apct.PackageTaskStatus in (0,1,2) and apct.gameid=@GameID and apct.createuser=@UserName 
				order by apct.CollectDatetime desc
			end
		end
	end
	else
	begin
		if @GameID=0
		begin 
		if @IsMy=0
			begin
				select apct.recid,apct.adid,apct.adname,apct.CreateTaskID,apct.PackageTaskStatus,apct.PackageName,apct.StartDatetime,npct.PlugInID,npct.IsEncryption,npct.PlatformVersion,npct.GameFileVersion,gi.GameName,gi.GameDisplayName,us.Compellation 
				from sdk_AdPackageCreateTask apct
				inner join sdk_NewPackageCreateTask npct on apct.recid=npct.RecID
				inner join sdk_GameInfo gi on apct.GameID=gi.GameID
				left join AspNetUsers us on apct.CreateUser=us.Email
				where apct.PackageTaskStatus=@PackageTaskStatus
				order by apct.CollectDatetime desc
			end
		else
			begin
				select apct.recid,apct.adid,apct.adname,apct.CreateTaskID,apct.PackageTaskStatus,apct.PackageName,apct.StartDatetime,npct.PlugInID,npct.IsEncryption,npct.PlatformVersion,npct.GameFileVersion,gi.GameName,gi.GameDisplayName,us.Compellation 
				from sdk_AdPackageCreateTask apct
				inner join sdk_NewPackageCreateTask npct on apct.recid=npct.RecID
				inner join sdk_GameInfo gi on apct.GameID=gi.GameID
				left join AspNetUsers us on apct.CreateUser=us.Email
				where apct.PackageTaskStatus=@PackageTaskStatus and apct.createuser=@UserName 
				order by apct.CollectDatetime desc
			end
		end
		else
		begin
		if @IsMy=0
			begin
				select apct.recid,apct.adid,apct.adname,apct.CreateTaskID,apct.PackageTaskStatus,apct.PackageName,apct.StartDatetime,npct.PlugInID,npct.IsEncryption,npct.PlatformVersion,npct.GameFileVersion,gi.GameName,gi.GameDisplayName,us.Compellation 
				from sdk_AdPackageCreateTask apct
				inner join sdk_NewPackageCreateTask npct on apct.recid=npct.RecID
				inner join sdk_GameInfo gi on apct.GameID=gi.GameID
				left join AspNetUsers us on apct.CreateUser=us.Email
				where apct.PackageTaskStatus=@PackageTaskStatus and apct.gameid=@GameID
				order by apct.CollectDatetime desc
			end
		else
			begin
				select apct.recid,apct.adid,apct.adname,apct.CreateTaskID,apct.PackageTaskStatus,apct.PackageName,apct.StartDatetime,npct.PlugInID,npct.IsEncryption,npct.PlatformVersion,npct.GameFileVersion,gi.GameName,gi.GameDisplayName,us.Compellation 
				from sdk_AdPackageCreateTask apct
				inner join sdk_NewPackageCreateTask npct on apct.recid=npct.RecID
				inner join sdk_GameInfo gi on apct.GameID=gi.GameID
				left join AspNetUsers us on apct.CreateUser=us.Email
				where apct.PackageTaskStatus=@PackageTaskStatus and apct.gameid=@GameID and apct.createuser=@UserName
				order by apct.CollectDatetime desc
			end
		end
	end	
END





GO
/****** Object:  StoredProcedure [dbo].[sdk_getGameFinalPlatforms]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016.1.6>
-- Description:	<获取最终渠道准备打包>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGameFinalPlatforms]
	@GameID nvarchar(11),
	@SystemID nvarchar(10),
	@PlaceIDList nvarchar(500)
AS
declare @sql nvarchar(2000)
BEGIN
	SET NOCOUNT ON;
	if @SystemID='Android'
	begin		
		set @sql='select dpf.Id,dpf.PlatformName,dpf.PlatformDisplayName,pf.SdkVersion,pv.[Version],gpi.PlugInID from
		sdk_GamePlatFromInfo gpi
		inner join sdk_DefaultPlatform dpf on gpi.VersionPlatFromID=dpf.id and gpi.GameID=' + @GameID + ' and gpi.selectid in ('''+@PlaceIDList+''') and gpi.SystemID=1
		left join sdk_GameInfo gi on gpi.GameID=gi.GameId
		left join sdk_Platform pf on dpf.Id=pf.PlatformID and pf.MyVersionID=gi.AndroidVersionID
		left join sdk_PlatformVersion pv on gpi.VersionID=pv.ID '
		EXECUTE   sp_executesql   @sql
	end
	else
	begin		
		set @sql='select dpf.Id,dpf.PlatformName,dpf.PlatformDisplayName,pf.SdkVersion,[Version]=0,PlugInID=0,PlugInVersion=0 from
		sdk_GamePlatFromInfo gpi
		inner join sdk_DefaultPlatform dpf on gpi.VersionPlatFromID=dpf.id and gpi.GameID='+@GameID+' and dpf.Id in ('+@PlaceIDList+') and gpi.SystemID=2
		left join sdk_GameInfo gi on gpi.GameID=gi.GameID
		left join sdk_Platform pf on dpf.Id=pf.PlatformID and pf.MyVersionID=gi.IOSVersionID'
		exec(@sql)
	end
END





GO
/****** Object:  StoredProcedure [dbo].[sdk_getGameIconList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-08-12>
-- Description:	<获取ICON列表>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGameIconList]
	@GameID int,
	@SystemID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [Id]
      ,[iconName] as IconName
      ,[SystemID]
      ,g.[GameID]
	  ,GameName
	  ,GameNameSpell
  FROM [sdk_icon] i
	inner join sdk_GameInfo g on i.GameID = g.GameID
	where g.GameID=@GameID and SystemID = @SystemID
END



GO
/****** Object:  StoredProcedure [dbo].[sdk_getGameIconList_byGameName]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-08-12>
-- Description:	<获取ICON列表>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGameIconList_byGameName]
	@GameName nvarchar(32),
	@SystemID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [Id]
      ,[iconName] as IconName
      ,[SystemID]
      ,g.[GameID]
	  ,GameName
	  ,GameNameSpell
  FROM [sdk_icon] i
	inner join sdk_GameInfo g on i.GameID = g.GameID
	where g.GameName=@GameName and SystemID = @SystemID
END



GO
/****** Object:  StoredProcedure [dbo].[sdk_getGameInfo]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-15>
-- Description:	<获取游戏基本信息>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGameInfo] 
	@GameID int,
	@PlatformID int,
	@SignatureKeyID int,
	@SystemID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select dpf.PlatformDisplayName,dpf.PlatformName,pf.SdkVersion,sk.KeyName,ps.PlatformStatusName,pf.SystemID,ggpv.MyVersion from 
	[sdk_GamePlatFromInfo] gpfi
	inner join sdk_DefaultPlatform dpf on gpfi.VersionPlatFromID=dpf.Id and GameID=@GameID and VersionPlatFromID=@PlatformID and gpfi.SignatureKeyID=@SignatureKeyID
	left join sdk_GameInfo gi on gpfi.GameID=gi.GameID
	left join [sdk_Platform] pf on dpf.id=pf.PlatformID and pf.MyVersionID=gi.AndroidVersionID and pf.SystemID=@SystemID
	left join sdk_SignatureKey sk on gpfi.SignatureKeyID=sk.Id
	left join sdk_PlatformStatus ps on dpf.PlatformStatus=ps.Id
	left join sdk_TypeSdkVersion ggpv on gi.AndroidVersionID=ggpv.ID
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getGameInfoList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-01-27>
-- Description:	<获取游戏列表详情（游戏管理）>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGameInfoList]
	@UserName nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @UserID nvarchar(128)
	select @UserID=Id from AspNetUsers where Email=@UserName
	if not exists (	SELECT  1  FROM [AspNetUserRoles]  where UserId=@UserID and RoleId in (2,3)) -- 权限不够
	begin
		Declare @GameID int
		-- Insert statements for procedure here
		select @GameID=GameID from sdk_RoleGamePower where UserID =@UserID and GameID=0
		if @GameID is not null
		begin			
			select tt.*,gpv.MyVersion as iosversion from (
                        select gi.[GameID],gi.[GameName],gi.[GameDisplayName],gi.AndroidVersionID,gi.AndroidKeyID,gi.IOSVersionID,gi.GameIcon,gi.GameNameSpell,gi.UnityVer,gi.ProductName,gi.IsEncryption,gpv.MyVersion as androidversion,gi.SDKGameID,gi.SDKGameKey from 
                        [sdk_GameInfo] gi,
                        sdk_TypeSdkVersion gpv
                        where gi.[AndroidVersionID]=gpv.ID) tt,
                        sdk_TypeSdkVersion gpv
                        where tt.IOSVersionID=gpv.ID
		end
		else
		begin
			select t1.* from (
			select tt.*,gpv.MyVersion as iosversion from (
                        select gi.[GameID],gi.[GameName],gi.[GameDisplayName],gi.AndroidVersionID,gi.AndroidKeyID,gi.IOSVersionID,gi.GameIcon,gi.GameNameSpell,gi.UnityVer,gi.ProductName,gi.IsEncryption,gpv.MyVersion as androidversion,gi.SDKGameID,gi.SDKGameKey  from 
                        [sdk_GameInfo] gi,
                        sdk_TypeSdkVersion gpv
                        where gi.[AndroidVersionID]=gpv.ID) tt,
                        sdk_TypeSdkVersion gpv
                        where tt.IOSVersionID=gpv.ID
			) t1 inner join 
			(select GameID from sdk_RoleGamePower where UserID =@UserID) t2 on t1.GameID=t2.GameID
		end
	end
	else -- 权限足够
	begin
		select tt.*,gpv.MyVersion as iosversion from (
                        select gi.[GameID],gi.[GameName],gi.[GameDisplayName],gi.AndroidVersionID,gi.AndroidKeyID,gi.IOSVersionID,gi.GameIcon,gi.GameNameSpell,gi.UnityVer,gi.ProductName,gi.IsEncryption,gpv.MyVersion as androidversion,gi.SDKGameID,gi.SDKGameKey  from 
                        [sdk_GameInfo] gi,
                        sdk_TypeSdkVersion gpv
                        where gi.[AndroidVersionID]=gpv.ID) tt,
                        sdk_TypeSdkVersion gpv
                        where tt.IOSVersionID=gpv.ID	
	end
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getGameList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-01-27>
-- Description:	<获取游戏列表>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGameList]
	@UserName nvarchar(128)
AS
BEGIN

	SET NOCOUNT ON;
	Declare @UserID nvarchar(128)
	select @UserID=Id from AspNetUsers where Email=@UserName
	if not exists (	SELECT  [UserId]  FROM [AspNetUserRoles]  where UserId=@UserID and RoleId in (2,3)) -- 权限不够
	begin
		Declare @GameID int
		-- Insert statements for procedure here
		select @GameID=GameID from sdk_RoleGamePower where UserID =@UserID and GameID='0'
		if @GameID is not null
		begin
			select GameID,GameDisplayName,GameIcon,GameName,[GameNameSpell],[UnityVer] from sdk_GameInfo
		end
		else
		begin
			select gi.GameID,gi.GameDisplayName,gi.GameIcon,gi.GameName,gi.[GameNameSpell],gi.[UnityVer] from sdk_GameInfo gi inner join 
			(select GameID from sdk_RoleGamePower where UserID =@UserID) tt on gi.GameID=tt.GameID
		end
	end
	else -- 权限足够
	begin
		select GameID,GameDisplayName,GameIcon,GameName,[GameNameSpell],[UnityVer] from sdk_GameInfo		
	end
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getGamePackages]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<获取完成编译的渠道包>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGamePackages]
	@Game nvarchar(200),
	@GameVersion nvarchar(200),
	@IsSigne nvarchar(10)
AS
BEGIN
	SET NOCOUNT ON;
	select *
		from sdk_Package
		where gameName = @Game
			and gameVersion = @GameVersion
			and isSigne = @IsSigne
		order by createDatetime desc
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getGamePlatformIcon]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sdk_getGamePlatformIcon]
	@GameID int,
	@PlatformID int
AS
BEGIN
	SET NOCOUNT ON;

    select gpi.iconName,gpi.GameName
		from sdk_GamePlatformIcon gpi
		where gpi.GameName = @GameID
		and gpi.PlatformName = @PlatformID
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getGamePlatformList_Android]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<获取游戏渠道列表>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGamePlatformList_Android]
	@GameID int,

	@SystemID int
AS
BEGIN

	SET NOCOUNT ON;

	select tt.SignatureKeyID,
		tt.GameID,
		tt.GameName,
		tt.GameDisplayName,
		tt.platformid,
		tt.PlatformName,
		tt.PlatformDisplayName,
		tt.KeyName,
		tt.PlugInID,
		pf.SdkVersion,
		pf.id,
		pv.ID as pvid,
		pv.[Version] 
		from
			(select 
			gpfi.SignatureKeyID,
			gpfi.SystemID,
			gpfi.VersionID,
			gpfi.PlugInID,
			gi.GameID,
			gi.GameName,
			gi.GameDisplayName,
			dpf.PlatformName,
			dpf.PlatformDisplayName,
			dpf.Id as platformid,
			gi.AndroidVersionID,
			sk.KeyName 
				from sdk_GamePlatFromInfo gpfi 
					inner join [sdk_GameInfo] gi on gpfi.GameID=gi.GameID and gi.GameID=@GameID and gpfi.SystemID=@SystemID 
					inner join sdk_defaultPlatform dpf on gpfi.[VersionPlatFromID]=dpf.id
					left join sdk_SignatureKey sk on gpfi.SignatureKeyID=sk.Id) tt
				left join [sdk_Platform] pf on tt.platformid=pf.PlatformID and tt.AndroidVersionID=pf.MyVersionID and pf.SystemID=tt.SystemID
				left join sdk_PlatformVersion pv on tt.VersionID=pv.ID order by tt.platformid

END



GO
/****** Object:  StoredProcedure [dbo].[sdk_getGamePlatformList_IOS]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<获取游戏渠道列表>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGamePlatformList_IOS]
	@GameID int,
	@SystemID int
AS
BEGIN

	SET NOCOUNT ON;

	select tt.SignatureKeyID,
		tt.GameID,
		tt.GameName,
		tt.GameDisplayName,
		tt.platformid,
		tt.PlatformName,
		tt.PlatformDisplayName,
		tt.KeyName,
		pf.SdkVersion,
		pf.id 
		from
		(select gpfi.SignatureKeyID,
			gpfi.SystemID,
			gi.GameID,
			gi.GameName,
			gi.GameDisplayName,
			dpf.PlatformName,
			dpf.PlatformDisplayName,
			dpf.Id as platformid,
			gi.IOSVersionID,sk.KeyName 
			from sdk_GamePlatFromInfo gpfi 
				inner join sdk_GameInfo gi on gpfi.GameID=gi.GameID and gi.GameID=@GameID and gpfi.SystemID=@SystemID
				left join sdk_defaultPlatform dpf on gpfi.VersionPlatFromID=dpf.id
				left join sdk_SignatureKey sk on gpfi.SignatureKeyID=sk.Id) tt
			left join sdk_Platform pf on tt.platformid=pf.PlatformID and tt.IOSVersionID=pf.MyVersionID and pf.SystemID=tt.SystemID order by tt.platformid

END





GO
/****** Object:  StoredProcedure [dbo].[sdk_getGamePlatforms]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<获取渠道>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGamePlatforms]
	@GameID int,
	@SystemID nvarchar(10)
AS
Declare @versiontype nvarchar(50)
BEGIN
	SET NOCOUNT ON;
	Declare @System_ID int
	if @SystemID='Android' 
	begin
		select tt.*,IsNull(gpi.iconName,0) as iconFlag,error='' from (
	select dpf.Id,dpf.Nullity,gpi.GameID,gpi.VersionPlatFromID,gpi.PlugInID,gpi.PlugInVersion,dpf.PlatformName,dpf.PlatformDisplayName,pf.SdkVersion,pv.[Version] from
	sdk_GamePlatFromInfo gpi
	inner join sdk_DefaultPlatform dpf on gpi.VersionPlatFromID=dpf.id and gpi.GameID=@GameID and gpi.SystemID=1
	left join sdk_GameInfo gi on gpi.GameID=gi.GameID
	left join sdk_Platform pf on dpf.Id=pf.PlatformID and pf.MyVersionID=gi.AndroidVersionID and pf.SystemID=gpi.SystemID
	left join sdk_PlatformVersion pv on gpi.VersionID=pv.ID) tt 
	left join sdk_GamePlatformIcon gpi on tt.GameID=gpi.GameName and tt.VersionPlatFromID=gpi.PlatformName order by tt.PlugInID,tt.VersionPlatFromID
	end
	else
	begin
			select tt.*,IsNull(gpi.iconName,0) as iconFlag,[Version]='0',error='',PlugInID=0,PlugInVersion='' from (
	select dpf.Id,dpf.Nullity,gpi.GameID,gpi.VersionPlatFromID,dpf.PlatformName,dpf.PlatformDisplayName,pf.SdkVersion from
	sdk_GamePlatFromInfo gpi
	inner join sdk_DefaultPlatform dpf on gpi.VersionPlatFromID=dpf.id and gpi.GameID=@GameID and gpi.SystemID=2
	left join sdk_GameInfo gi on gpi.GameID=gi.GameID
	left join sdk_Platform pf on dpf.Id=pf.PlatformID and pf.MyVersionID=gi.IOSVersionID and pf.SystemID=gpi.SystemID
	) tt 
	left join sdk_GamePlatformIcon gpi on tt.GameID=gpi.GameName and tt.VersionPlatFromID=gpi.PlatformName
	end

   
END






GO
/****** Object:  StoredProcedure [dbo].[sdk_getGamePlatfromConfig]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-15>
-- Description:	<获取游戏渠道参数>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGamePlatfromConfig]
	@GameID nvarchar(50),
	@PlatformID nvarchar(50),
	@PlugInID nvarchar(1)
AS
DECLARE @COUNT INT
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT @COUNT=COUNT(ID) FROM [sdk_PlatformConfig] WHERE [GameName]=@GameID AND [PlatformName]=@PlatformID and PlugInID=@PlugInID
	IF @COUNT=0
	BEGIN
		DECLARE @signKeyName nvarchar(50)
		select @signKeyName=sk.KeyName from [sdk_GamePlatFromInfo] gpi inner join sdk_SignatureKey sk on gpi.SignatureKeyID=sk.Id and gpi.GameID=@GameID and VersionPlatFromID=@PlatformID	-- 获取秘钥名称

		INSERT INTO [sdk_PlatformConfig] SELECT [GameName]=@GameID
      ,[PlatformName]=@PlatformID
      ,[SDKKey]
      ,[Explain]
      ,[StringValue]
      ,[isCPSetting]
      ,[isBuilding]
      ,[isServer]
	  ,[PlugInID]=@PlugInID FROM [sdk_PlatformConfigKey]
	  
		update [sdk_PlatformConfig] set StringValue=@signKeyName where GameName=@GameID and PlatformName=@PlatformID and SDKKey='SignatureKey' and PlugInID=@PlugInID
	END
	SELECT * FROM [sdk_PlatformConfig] WHERE [GameName]=@GameID AND [PlatformName]=@PlatformID	and SDKKey!='SignatureKey' and PlugInID=@PlugInID order by SDKKey
		
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getGamePlatfromProductList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<typesdk>
-- Create date: <2016-1-15>
-- Description:	<获取游戏渠道商品列表>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGamePlatfromProductList]
	@GameID nvarchar(50),
	@PlatformID nvarchar(50)
AS
DECLARE @COUNT INT
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM [sdk_PlatformConfigProductList] WHERE [GameName]=@GameID AND [PlatformName]=@PlatformID order by [itemid]
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getGames]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<获取渠道列表>
-- =============================================

CREATE PROCEDURE [dbo].[sdk_getGames]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	select GameName,GameDisplayName from sdk_Games;
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getGamesInfo]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<获取游戏所有数据>
-- =============================================

CREATE PROCEDURE [dbo].[sdk_getGamesInfo]
AS
BEGIN
	SET NOCOUNT ON;

    select * from sdk_Games;
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getGameVersion]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<获取游戏版本数据>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGameVersion]
	@GameName nvarchar(200)
	
AS
BEGIN
	
	SET NOCOUNT ON;

	select GameVersion
		from sdk_GameVersion
		where GameName = @GameName
		order by GameVersionStatus,id
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getGameVersionList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2015.1.5>
-- Description:	<获取上传项目>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getGameVersionList]
	@dwGameName nvarchar(50),			-- 游戏简称
	@dwPlatForm nvarchar(20)			-- 平台
AS
BEGIN
	select * from sdk_UploadPackageInfo where GameName=@dwGameName and GamePlatFrom=@dwPlatForm order by CollectDatetime desc
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getIcon]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<获取平台可用桌面图标>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getIcon]
	@GameID int,
	@SystemName nvarchar(9)
AS
SET NOCOUNT ON;
Declare @SystemID int
BEGIN
	if @SystemName='Android' set @SystemID=1 else set @SystemID=2
    select * from sdk_icon where GameID=@GameID and SystemID=@SystemID order by id desc;
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getPackageInfo]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<获取整体出包任务信息>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPackageInfo]
	@SystemName nvarchar(9)
AS
	SET NOCOUNT ON;
	declare @BeginCount int
	declare @WaitCount int
BEGIN
    if @SystemName='Android'
	begin
		SELECT @BeginCount=COUNT(recid) from sdk_NewPackageCreateTask where PackageTaskStatus=2
		SELECT @WaitCount=COUNT(recid) from sdk_NewPackageCreateTask where PackageTaskStatus in (0.1)
	end
	else
	begin
		SELECT @BeginCount=COUNT(recid) from sdk_NewPackageCreateTask_IOS where PackageTaskStatus=2
		SELECT @WaitCount=COUNT(recid) from sdk_NewPackageCreateTask_IOS where PackageTaskStatus in (0.1)
	end
	select @BeginCount as BeginCount,@WaitCount as WaitCount
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getPackageList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-01-27>
-- Description:	<获取下载包>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPackageList]
	@GameID int,
	@PackTaskID int,
	@SystemName nvarchar(9),
	@IsSign nvarchar(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--set @PackTaskID=16
	--set @SystemName='Android'
	--set @IsSign='1'
	IF @SystemName='Android'
	begin
	IF @PackTaskID=0
	begin
		select npct.RecID,npct.PackageName,npct.PlatFormID,npct.CreateTaskID,npct.CollectDatetime,npct.AdName,gi.GameName ,dpf.PlatformName,us.Compellation,npct.GameFileVersion as GameVersion ,npct.GameVersionLable as PageageTable,IsSign=1,npct.PlugInID
		from sdk_NewPackageCreateTask npct
		left join sdk_DefaultPlatform dpf on npct.PlatFormID=dpf.Id
		left join sdk_GameInfo gi on gi.GameID=npct.GameID
		left join AspNetUsers us on us.UserName=npct.CreateUser
		where npct.GameID=@GameID and npct.PackageTaskStatus=3 and npct.CompileMode='release'
		order by npct.RecID desc
	end
	else
	begin
    select npct.RecID,npct.PackageName,npct.PlatFormID,npct.CreateTaskID,npct.CollectDatetime,npct.AdName ,dpf.PlatformName,(case when @IsSign='0' then '0' else '1' end) as IsSign,upi.GameName,us.Compellation,upi.GameVersion,upi.PageageTable,npct.PlugInID
	from sdk_NewPackageCreateTask npct
	inner join sdk_UploadPackageInfo upi on npct.PackageTaskID=upi.ID and upi.ID=@PackTaskID and upi.GameID=@GameID
	and npct.PackageTaskStatus=3 and upi.GamePlatFrom=@SystemName
	inner join sdk_DefaultPlatform dpf on npct.PlatFormID=dpf.Id
	inner join AspNetUsers us on npct.CreateUser=us.UserName
	where npct.CompileMode='release'
	order by npct.RecID desc
	end
	end
	else -- ios
	begin
	IF @PackTaskID=0
	begin
	    select npct.PackageName,npct.PlatFormID,npct.CreateTaskID,npct.CollectDatetime ,dpf.PlatformName,(case when @IsSign='0' then '0' else '1' end) as IsSign,upi.GameName,us.Compellation,upi.GameVersion,upi.PageageTable,gi.GameNameSpell
	from sdk_NewPackageCreateTask_IOS npct
	inner join sdk_UploadPackageInfo upi on npct.PackageTaskID=upi.ID and upi.GameID=@GameID
	and npct.PackageTaskStatus=3 and upi.GamePlatFrom=@SystemName
	inner join sdk_DefaultPlatform dpf on npct.PlatFormID=dpf.Id
	inner join AspNetUsers us on npct.CreateUser=us.UserName
	inner join sdk_GameInfo gi on upi.GameID=gi.GameID
	order by npct.RecID desc
	end
	else
	begin
    select npct.PackageName,npct.PlatFormID,npct.CreateTaskID,npct.CollectDatetime ,dpf.PlatformName,(case when @IsSign='0' then '0' else '1' end) as IsSign,upi.GameName,us.Compellation,upi.GameVersion,upi.PageageTable,gi.GameNameSpell
	from sdk_NewPackageCreateTask_IOS npct
	inner join sdk_UploadPackageInfo upi on npct.PackageTaskID=upi.ID and upi.ID=@PackTaskID and upi.GameID=@GameID
	and npct.PackageTaskStatus=3 and upi.GamePlatFrom=@SystemName
	inner join sdk_DefaultPlatform dpf on npct.PlatFormID=dpf.Id
	inner join AspNetUsers us on npct.CreateUser=us.UserName
	inner join sdk_GameInfo gi on upi.GameID=gi.GameID
	order by npct.RecID desc
	end
	end
	

END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getPackageTask]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016.1.8>
-- Description:	<分配打包任务>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPackageTask] 
	@SystemName nvarchar(7)		-- 平台名称
AS

	SET NOCOUNT ON;
	DECLARE @RecID int
	DECLARE @GameName nvarchar(50)
	DECLARE @PlatFormName nvarchar(50)
	DECLARE @GameVersion NVARCHAR(50)
	DECLARE @StrCollectDatetime NVARCHAR(20)
	DECLARE @IconPath nvarchar(100)
	DECLARE @CreateTaskID nvarchar(50)
	DECLARE @MyVersion nvarchar(50)
	DECLARE @UnityVer nvarchar(50)
	DECLARE @GameNameSpell nvarchar(50)
	DECLARE @ProductName nvarchar(50)
	DECLARE @ChannelVersion nvarchar(50)
	DECLARE @IsEncryption nvarchar(50)
	DECLARE @AdID nvarchar(50)
	DECLARE @PlugInID int
	DECLARE @PlugInVersion nvarchar(50)
	DECLARE @CompileMode nvarchar(7)
	DECLARE @KeyName nvarchar(50)
BEGIN
	IF @SystemName='Android'
	begin
		update [sdk_NewPackageCreateTask] set PackageTaskStatus=1 where DATEDIFF(N,StartDatetime,GETDATE())>30 and PackageTaskStatus=2

		select top 1 @RecID= npct.RecID,@IsEncryption=npct.IsEncryption,@AdID=npct.adid,@PlugInID=npct.PlugInID,@PlugInVersion=npct.PlugInVersion,@GameName=upi.GameName,@PlatFormName=dpf.PlatformName,@GameVersion=upi.GameVersion,@StrCollectDatetime=upi.StrCollectDatetime,@IconPath=gui.iconName,@CreateTaskID=npct.CreateTaskID,@MyVersion=ggpv.MyVersion,@ChannelVersion=pv.[Version],@CompileMode=npct.CompileMode,@KeyName=sk.KeyName from 
		[sdk_NewPackageCreateTask] npct ,
		sdk_UploadPackageInfo upi ,
		sdk_GamePlatformIcon gui ,
		sdk_DefaultPlatform dpf,
		sdk_GameInfo gi,
		sdk_TypeSdkVersion ggpv,
		sdk_GamePlatFromInfo gpi,--
		sdk_SignatureKey sk,
		sdk_PlatformVersion pv
		where npct.PackageTaskID=upi.ID and upi.GamePlatFrom=@SystemName and npct.PackageTaskStatus=0 and npct.PlatFormID=dpf.Id
		and gui.PlatformName=dpf.Id and upi.GameID=gi.GameID and gui.SystemID=1 and gi.AndroidVersionID=ggpv.ID
		and DATEDIFF(N,npct.StartDatetime,GETDATE())>5 and upi.GameID=gui.GameName and npct.GameID=gi.GameID and npct.GameID=gpi.GameID--
		and gpi.VersionID=pv.ID  and gpi.PlugInID=npct.PlugInID
		and gpi.SignatureKeyID=sk.Id
		and dpf.Id=pv.PlatformID order by npct.RecID
		IF @@ROWCOUNT<>0
		BEGIN
			UPDATE [sdk_NewPackageCreateTask] SET StartDatetime=GETDATE() WHERE RecID=@RecID
			IF @@ERROR<>0
			BEGIN
				RETURN 1
			END	
		END
		ELSE
		BEGIN
			select top 1 @RecID= npct.RecID,@IsEncryption=npct.IsEncryption,@AdID=npct.adid,@PlugInID=npct.PlugInID,@PlugInVersion=npct.PlugInVersion,@GameName=upi.GameName,@PlatFormName=dpf.PlatformName,@GameVersion=upi.GameVersion,@StrCollectDatetime=upi.StrCollectDatetime,@IconPath=gui.iconName,@CreateTaskID=npct.CreateTaskID,@MyVersion=ggpv.MyVersion,@ChannelVersion=pv.[Version],@CompileMode=npct.CompileMode,@KeyName=sk.KeyName  from 
			[sdk_NewPackageCreateTask] npct ,
			sdk_UploadPackageInfo upi ,
			sdk_GamePlatformIcon gui,
			sdk_DefaultPlatform dpf,		
			sdk_GameInfo gi,
			sdk_TypeSdkVersion ggpv,
			sdk_GamePlatFromInfo gpi,--
			sdk_SignatureKey sk,
			sdk_PlatformVersion pv
			where npct.PackageTaskID=upi.ID and upi.GamePlatFrom=@SystemName and npct.PackageTaskStatus=1 and npct.PlatFormID=dpf.Id and upi.GameID=gui.GameName
			and gui.PlatformName=dpf.Id and upi.GameID=gi.GameID and gui.SystemID=1 and gi.AndroidVersionID=ggpv.ID and npct.GameID=gpi.GameID-- 
			and npct.GameID=gi.GameID 
			and gpi.VersionID=pv.ID  and gpi.PlugInID=npct.PlugInID
			and gpi.SignatureKeyID=sk.Id
			and dpf.Id=pv.PlatformID
			order by npct.CollectDatetime
			IF @@ROWCOUNT<>0
			BEGIN
				UPDATE [sdk_NewPackageCreateTask] SET StartDatetime=GETDATE(),PackageTaskStatus=0 WHERE RecID=@RecID
				IF @@ERROR<>0
				BEGIN
					RETURN 1
				END	
			END
			ELSE 
			BEGIN
				SET @RecID=0
				SET @GameName=N'0'
				SET @PlatFormName=N'0'
				SET @GameVersion=N'0'
				SET @StrCollectDatetime=N'0'
				SET @IconPath=N'0'
				SET @CreateTaskID=N'0'
				SET @ChannelVersion=N'0'
				SET @KeyName=N''
			END
		END

		SELECT @RecID AS RecID,@GameName AS GameName,@PlatFormName as PlatformName,@GameVersion AS GameVersion,@StrCollectDatetime AS StrCollectDatetime,@IconPath AS IconPath,@CreateTaskID AS CreateTaskID,@MyVersion as MyVersion,@ChannelVersion as ChannelVersion,@IsEncryption as IsEncryption,@AdID as AdID,@PlugInID as PlugInID,@PlugInVersion as PlugInVersion,@CompileMode as CompileMode,@KeyName as KeyName
		RETURN 0
	
	end
	else	-- ios
	begin
		update [sdk_NewPackageCreateTask_IOS] set PackageTaskStatus=1 where DATEDIFF(N,StartDatetime,GETDATE())>30 and PackageTaskStatus=2

		select top 1 @RecID= npct.RecID,@GameName=upi.GameName,@PlatFormName=dpf.PlatformName,@GameVersion=upi.GameVersion,@StrCollectDatetime=upi.StrCollectDatetime,@IconPath=gui.iconName,@CreateTaskID=npct.CreateTaskID,@MyVersion=ggpv.MyVersion,@GameNameSpell=gi.GameNameSpell,@UnityVer=gi.UnityVer,@ProductName=gi.ProductName from 
		[sdk_NewPackageCreateTask_IOS] npct ,
		sdk_UploadPackageInfo upi ,
		sdk_GamePlatformIcon gui ,
		sdk_DefaultPlatform dpf,
		sdk_GameInfo gi,
		sdk_TypeSdkVersion ggpv
		where npct.PackageTaskID=upi.ID and upi.GamePlatFrom=@SystemName and npct.PackageTaskStatus=0 and npct.PlatFormID=dpf.Id
		and gui.PlatformName=dpf.Id and upi.GameID=gi.GameID and gui.SystemID=2 and gi.AndroidVersionID=ggpv.ID
		and DATEDIFF(N,npct.StartDatetime,GETDATE())>5 and upi.GameID=gui.GameName order by npct.RecID
		IF @@ROWCOUNT<>0
		BEGIN
			UPDATE [sdk_NewPackageCreateTask_IOS] SET StartDatetime=GETDATE() WHERE RecID=@RecID
			IF @@ERROR<>0
			BEGIN
				RETURN 1
			END	
		END
		ELSE
		BEGIN
			select top 1 @RecID= npct.RecID,@GameName=upi.GameName,@PlatFormName=dpf.PlatformName,@GameVersion=upi.GameVersion,@StrCollectDatetime=upi.StrCollectDatetime,@IconPath=gui.iconName,@CreateTaskID=npct.CreateTaskID,@MyVersion=ggpv.MyVersion,@GameNameSpell=gi.GameNameSpell,@UnityVer=gi.UnityVer,@ProductName=gi.ProductName from 
			[sdk_NewPackageCreateTask_IOS] npct ,
			sdk_UploadPackageInfo upi ,
			sdk_GamePlatformIcon gui,
			sdk_DefaultPlatform dpf,		
			sdk_GameInfo gi,
			sdk_TypeSdkVersion ggpv
			where npct.PackageTaskID=upi.ID and upi.GamePlatFrom=@SystemName and npct.PackageTaskStatus=1 and npct.PlatFormID=dpf.Id and upi.GameID=gui.GameName
			and gui.PlatformName=dpf.Id and upi.GameID=gi.GameID and gui.SystemID=2 and gi.AndroidVersionID=ggpv.ID
			order by npct.CollectDatetime
			IF @@ROWCOUNT<>0
			BEGIN
				UPDATE [sdk_NewPackageCreateTask_IOS] SET StartDatetime=GETDATE(),PackageTaskStatus=0 WHERE RecID=@RecID
				IF @@ERROR<>0
				BEGIN
					RETURN 1
				END	
			END
			ELSE 
			BEGIN
				SET @RecID=0
				SET @GameName=N'0'
				SET @PlatFormName=N'0'
				SET @GameVersion=N'0'
				SET @StrCollectDatetime=N'0'
				SET @IconPath=N'0'
				SET @CreateTaskID=N'0'
				SET @GameNameSpell=N'0'
				SET @UnityVer=N'0'
				SET @ProductName=N'0'
			END
		END

		SELECT @RecID AS RecID,@GameName AS GameName,@PlatFormName as PlatformName,@GameVersion AS GameVersion,@StrCollectDatetime AS StrCollectDatetime,@IconPath AS IconPath,@CreateTaskID AS CreateTaskID,@MyVersion as MyVersion,@GameNameSpell as GameNameSpell,@UnityVer as UnityVer,@ProductName as ProductName
		RETURN 0
	end
END





GO
/****** Object:  StoredProcedure [dbo].[sdk_getPackageTaskList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-01-28>
-- Description:	<获取打包任务详情>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPackageTaskList]
	@PackageTaskStatus int,
	@GameID int,
	@SystemName nvarchar(9),
	@UserName nvarchar(50),
	@IsMy bit
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @UserRole int

	select @UserRole=tt.RoleId from (
	select ISNULL(ur.RoleId,1) RoleId from (select id from AspNetUsers where UserName=@UserName )us
	left join (select Max(RoleId) RoleId,UserId from AspNetUserRoles group by UserId) ur 
	on us.Id=ur.UserId) tt

	if @SystemName='Android'
	begin
	if @PackageTaskStatus=0
	begin
		if @GameID=0
		begin 
			if @IsMy=0
			begin
				select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end) from (
				select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,nct.IsEncryption,nct.adname,nct.PlugInID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion,nct.CompileMode
				from [sdk_NewPackageCreateTask] nct 
				inner join [sdk_DefaultPlatform] pf	on nct.platformid=pf.id
				inner join sdk_GameInfo gi on nct.GameID=gi.GameID
				left join AspNetUsers us on nct.CreateUser=us.Email) tt 
				left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName
				order by tt.RecID desc
			end
			else
			begin
				select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end) from (
				select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,nct.IsEncryption,nct.adname,nct.PlugInID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion,nct.CompileMode
				from [sdk_NewPackageCreateTask] nct 
				inner join [sdk_DefaultPlatform] pf	on nct.platformid=pf.id
				inner join sdk_GameInfo gi on nct.GameID=gi.GameID
				left join AspNetUsers us on nct.CreateUser=us.Email) tt 
				left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName
				where tt.UserName=@UserName
				order by tt.RecID desc
			end
		end
		else
		begin
		if @IsMy=0
			begin
				select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end) from (
				select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,nct.IsEncryption,nct.adname,nct.PlugInID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion,nct.CompileMode
				from [sdk_NewPackageCreateTask] nct inner join
				[sdk_DefaultPlatform] pf
				on nct.platformid=pf.id
				inner join sdk_GameInfo gi on nct.GameID=gi.GameID and nct.GameID=@GameID
				left join AspNetUsers us on nct.CreateUser=us.Email) tt
				left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName
				order by tt.RecID desc
			end
		else
			begin
				select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end) from (
				select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,nct.IsEncryption,nct.adname,nct.PlugInID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion,nct.CompileMode
				from [sdk_NewPackageCreateTask] nct inner join
				[sdk_DefaultPlatform] pf
				on nct.platformid=pf.id
				inner join sdk_GameInfo gi on nct.GameID=gi.GameID and nct.GameID=@GameID
				left join AspNetUsers us on nct.CreateUser=us.Email) tt
				left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName
				where tt.UserName=@UserName
				order by tt.RecID desc
			end
			
		end

	end
	else if @PackageTaskStatus=1
	begin
		if @GameID=0
		begin 
		if @IsMy=0
			begin
				select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end) from (
				select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,nct.IsEncryption,nct.adname,nct.PlugInID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion,nct.CompileMode
				from [sdk_NewPackageCreateTask] nct inner join
				[sdk_DefaultPlatform] pf
				on nct.platformid=pf.id and nct.PackageTaskStatus in (0,1,2)
				inner join sdk_GameInfo gi on nct.GameID=gi.GameID
				left join AspNetUsers us on nct.CreateUser=us.Email) tt
				left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName
				order by tt.RecID desc
			end
		else
			begin
				select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end) from (
				select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,nct.IsEncryption,nct.adname,nct.PlugInID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion,nct.CompileMode
				from [sdk_NewPackageCreateTask] nct inner join
				[sdk_DefaultPlatform] pf
				on nct.platformid=pf.id and nct.PackageTaskStatus in (0,1,2)
				inner join sdk_GameInfo gi on nct.GameID=gi.GameID
				left join AspNetUsers us on nct.CreateUser=us.Email) tt
				left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName
				where tt.UserName=@UserName
				order by tt.RecID desc
			end			
		end
		else
		begin
		if @IsMy=0
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end) from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,nct.IsEncryption,nct.adname,nct.PlugInID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion,nct.CompileMode
			from [sdk_NewPackageCreateTask] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus in (0,1,2)
			inner join sdk_GameInfo gi on nct.GameID=gi.GameID and nct.GameID=@GameID
			left join AspNetUsers us on nct.CreateUser=us.Email)tt
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName		
			order by tt.RecID desc
			end
		else
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end) from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,nct.IsEncryption,nct.adname,nct.PlugInID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion,nct.CompileMode
			from [sdk_NewPackageCreateTask] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus in (0,1,2)
			inner join sdk_GameInfo gi on nct.GameID=gi.GameID and nct.GameID=@GameID
			left join AspNetUsers us on nct.CreateUser=us.Email)tt
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName		
			where tt.UserName=@UserName
			order by tt.RecID desc
			end
		end
	end
	else
	begin
		if @GameID=0
		begin 
		if @IsMy=0
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end) from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,nct.IsEncryption,nct.adname,nct.PlugInID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion,nct.CompileMode
			from [sdk_NewPackageCreateTask] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus=@PackageTaskStatus
			inner join sdk_GameInfo gi on nct.GameID=gi.GameID
			left join AspNetUsers us on nct.CreateUser=us.Email) tt
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName
			order by tt.RecID desc
			end
		else
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end) from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,nct.IsEncryption,nct.adname,nct.PlugInID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion,nct.CompileMode
			from [sdk_NewPackageCreateTask] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus=@PackageTaskStatus
			inner join sdk_GameInfo gi on nct.GameID=gi.GameID
			left join AspNetUsers us on nct.CreateUser=us.Email) tt
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName	
			where tt.UserName=@UserName
			order by tt.RecID desc
			end
		end
		else
		begin
		if @IsMy=0
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end) from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,nct.IsEncryption,nct.adname,nct.PlugInID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion,nct.CompileMode
			from [sdk_NewPackageCreateTask] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus=@PackageTaskStatus
			inner join sdk_GameInfo gi on nct.GameID=gi.GameID and nct.GameID=@GameID
			left join AspNetUsers us on nct.CreateUser=us.Email) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName
			order by tt.RecID desc
			end
		else
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end) from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,nct.IsEncryption,nct.adname,nct.PlugInID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion,nct.CompileMode
			from [sdk_NewPackageCreateTask] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus=@PackageTaskStatus
			inner join sdk_GameInfo gi on nct.GameID=gi.GameID and nct.GameID=@GameID
			left join AspNetUsers us on nct.CreateUser=us.Email) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName	
			where tt.UserName=@UserName
			order by tt.RecID desc
			end
		end
	end
	end
	else -- ios
	begin
	if @PackageTaskStatus=0
	begin
		if @GameID=0
		begin 
		if @IsMy=0
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end),IsEncryption=0,adname='',PlugInID='0' from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameNameSpell,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion
			from [sdk_NewPackageCreateTask_IOS] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id
			left join AspNetUsers us on nct.CreateUser=us.Email
			left join sdk_GameInfo gi on nct.GameID=gi.GameID) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName	
			order by tt.RecID desc
			end
		else
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end),IsEncryption=0,adname='',PlugInID='0' from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameNameSpell,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion
			from [sdk_NewPackageCreateTask_IOS] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id
			left join AspNetUsers us on nct.CreateUser=us.Email
			left join sdk_GameInfo gi on nct.GameID=gi.GameID) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName	
			where tt.UserName=@UserName order by tt.RecID desc
			end
		end
		else
		begin
		if @IsMy=0
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end),IsEncryption=0,adname='',PlugInID='0' from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameNameSpell,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion
			from [sdk_NewPackageCreateTask_IOS] nct inner join
			[sdk_DefaultPlatform] pf on nct.platformid=pf.id
			left join AspNetUsers us on nct.CreateUser=us.Email 
			left join sdk_GameInfo gi on nct.GameID=gi.GameID and nct.GameID=@GameID) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName	
			order by tt.RecID desc
			end
		else
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end),IsEncryption=0,adname='',PlugInID='0' from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameNameSpell,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion
			from [sdk_NewPackageCreateTask_IOS] nct inner join
			[sdk_DefaultPlatform] pf on nct.platformid=pf.id
			left join AspNetUsers us on nct.CreateUser=us.Email 
			left join sdk_GameInfo gi on nct.GameID=gi.GameID and nct.GameID=@GameID) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName	
			where tt.UserName=@UserName order by tt.RecID desc
			end
		end

	end
	else if @PackageTaskStatus=1
	begin
		if @GameID=0
		begin 
		if @IsMy=0
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end),IsEncryption=0,adname='',PlugInID='0' from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameNameSpell,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion
			from [sdk_NewPackageCreateTask_IOS] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus in (0,1,2)
			left join AspNetUsers us on nct.CreateUser=us.Email
			left join sdk_GameInfo gi on nct.GameID=gi.GameID) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName	
			order by tt.RecID desc
			end
		else
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end),IsEncryption=0,adname='',PlugInID='0' from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameNameSpell,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion
			from [sdk_NewPackageCreateTask_IOS] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus in (0,1,2)
			left join AspNetUsers us on nct.CreateUser=us.Email
			left join sdk_GameInfo gi on nct.GameID=gi.GameID) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName	
			where tt.UserName=@UserName  order by tt.RecID desc
			end
		end
		else
		begin
		if @IsMy=0
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end),IsEncryption=0,adname='',PlugInID='0' from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameNameSpell,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion
			from [sdk_NewPackageCreateTask_IOS] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus in (0,1,2)
			left join AspNetUsers us on nct.CreateUser=us.Email
			left join sdk_GameInfo gi on nct.GameID=gi.GameID and nct.GameID=@GameID) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName 	
			order by tt.RecID desc
			end
		else
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end),IsEncryption=0,adname='',PlugInID='0' from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameNameSpell,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion
			from [sdk_NewPackageCreateTask_IOS] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus in (0,1,2)
			left join AspNetUsers us on nct.CreateUser=us.Email
			left join sdk_GameInfo gi on nct.GameID=gi.GameID and nct.GameID=@GameID) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName 	
			where tt.UserName=@UserName order by tt.RecID desc
			end
		end
	end
	else
	begin
		if @GameID=0
		begin 
		if @IsMy=0
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end),IsEncryption=0,adname='',PlugInID='0' from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameNameSpell,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion
			from [sdk_NewPackageCreateTask_IOS] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus=@PackageTaskStatus
			left join AspNetUsers us on nct.CreateUser=us.Email
			left join sdk_GameInfo gi on nct.GameID=gi.GameID) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName 	
			order by tt.RecID desc
			end
		else
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end),IsEncryption=0,adname='',PlugInID='0' from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameNameSpell,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion
			from [sdk_NewPackageCreateTask_IOS] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus=@PackageTaskStatus
			left join AspNetUsers us on nct.CreateUser=us.Email
			left join sdk_GameInfo gi on nct.GameID=gi.GameID) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName 	
			where tt.UserName=@UserName order by tt.RecID desc
			end
		end
		else
		begin
		if @IsMy=0
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end),IsEncryption=0,adname='',PlugInID='0' from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameNameSpell,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion
			from [sdk_NewPackageCreateTask_IOS] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus=@PackageTaskStatus
			left join AspNetUsers us on nct.CreateUser=us.Email
			left join sdk_GameInfo gi on nct.GameID=gi.GameID and nct.GameID=@GameID) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName	
			order by tt.RecID desc
			end
		else
			begin
			select tt.*,(case when ISNUll(us.UserName,'0') = '0'  then 0 else 1 end) as qx, qx2=(case when @UserRole = 1  then 0 else 1 end),IsEncryption=0,adname='',PlugInID='0' from (
			select us.UserName,pf.PlatformDisplayName,pf.PlatformName,nct.PackageTaskStatus,nct.PackageName,nct.RecID,nct.CreateTaskID,gi.GameName,us.Compellation,nct.CollectDatetime,nct.StartDatetime,nct.FinishDatetime,gi.GameNameSpell,gi.GameDisplayName,nct.PlatformVersion,nct.GameFileVersion
			from [sdk_NewPackageCreateTask_IOS] nct inner join
			[sdk_DefaultPlatform] pf
			on nct.platformid=pf.id and nct.PackageTaskStatus=@PackageTaskStatus
			left join AspNetUsers us on nct.CreateUser=us.Email
			left join sdk_GameInfo gi on nct.GameID=gi.GameID and nct.GameID=@GameID) tt 
			left join AspNetUsers us on tt.UserName=us.UserName and us.UserName=@UserName	
			where tt.UserName=@UserName  order by tt.RecID desc
			end
		end
	end
	end

END


GO
/****** Object:  StoredProcedure [dbo].[sdk_getPlatform]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<获取渠道列表>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPlatform]
	@PlatformID nvarchar(20)
AS
BEGIN

	SET NOCOUNT ON;

    select pf.Id,pf.SdkVersion,dpf.PlatformName,dpf.PlatformDisplayName,ps.PlatformStatusName,gv.MyVersion from sdk_Platform pf,
	sdk_DefaultPlatform dpf,
	[sdk_PlatformStatus] ps,
	sdk_TypeSdkVersion gv
	where pf.PlatformID=dpf.id and dpf.PlatformStatus=ps.Id and pf.Id=@PlatformID and pf.MyVersionID=gv.ID

END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getPlatformConfigCPSetting]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<获取渠道配置参数>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPlatformConfigCPSetting]
	@GameName nvarchar(200),
	@PlatformName nvarchar(200),
	@PlugInID int
AS
BEGIN

	SET NOCOUNT ON;

    select SDKKey,StringValue
		from sdk_PlatformConfig
		where GameName in (@GameName,'Default')
			and PlatformName in (@PlatformName ,'Default')
			and isCPSetting = 1 and PlugInID=@PlugInID
END





GO
/****** Object:  StoredProcedure [dbo].[sdk_getPlatformConfigLocal]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<获取签名密钥配置参数>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPlatformConfigLocal]
	@GameName nvarchar(200),
	@PlatformName nvarchar(200),
	@PlugInID int
AS
	declare @SignatureKey nvarchar(50)
BEGIN
	
	SET NOCOUNT ON;

	select @SignatureKey = StringValue
		from sdk_PlatformConfig
		where GameName = @GameName
			and PlatformName = @PlatformName
			and PlugInID=@PlugInID
			and SDKKey = 'SignatureKey'

    select SDKKey,StringValue
		from sdk_PlatformConfig
		where GameName in (@GameName,'Default')
			and PlatformName in (@PlatformName ,'Default')
			and PlugInID=@PlugInID
			and isBuilding = 1
	union
	select 'key.store',KeyStore
		from sdk_SignatureKey
		where KeyName = @SignatureKey
	union
	select 'key.store.password',KeyStorePassword
		from sdk_SignatureKey
		where KeyName = @SignatureKey
	union
	select 'key.alias',KeyAlias
		from sdk_SignatureKey
		where KeyName = @SignatureKey
	union
	select 'key.alias.password',KeyAliasPassword
		from sdk_SignatureKey
		where KeyName = @SignatureKey
END





GO
/****** Object:  StoredProcedure [dbo].[sdk_getPlatformList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-13>
-- Description:	<获取渠道列表>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPlatformList]
	@SystemID int 
	
AS
BEGIN
	select id,PlatformDisplayName from sdk_DefaultPlatform where SystemID=@SystemID and PlugInID=0
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getPlatformListBySystem]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<获取游戏渠道列表>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPlatformListBySystem]
	@SystemName nvarchar(9)
AS
BEGIN
if @SystemName='Android'
	SELECT [Id],[PlatformDisplayName] FROM [sdk_DefaultPlatform] where SystemID=1 and PlugInID=0
	else SELECT [Id],[PlatformDisplayName] FROM [sdk_DefaultPlatform] where SystemID=2
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getPlatformListInfo]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<渠道列表页面>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPlatformListInfo]
	@SdkVersion int,
	@SystemID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	  select pf.id,pf.MyVersionID,pf.SdkVersion SdkVersionID,dpf.id as dpfid,dpf.platformname,dpf.platformdisplayname,dpf.platformicon,ISNULL( pv.[Version],' ') as SdkVersion,dpf.Nullity from 
  [sdk_Platform] pf inner join
  sdk_DefaultPlatform dpf  on pf.PlatformID=dpf.id and pf.MyVersionID=@SdkVersion and pf.SystemID=@SystemID
  left join sdk_PlatformVersion pv on pf.PlatformID=pv.PlatformID and pf.SdkVersion=pv.ID
  where dpf.PlugInID=0
  order by pf.PlatformID
END






GO
/****** Object:  StoredProcedure [dbo].[sdk_getPlatformManifest]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<获取渠道AndroidManifest配置结点>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPlatformManifest]
	@platformName nvarchar(200)

AS
BEGIN
	SET NOCOUNT ON;

    select ConfigKey,ConfigContent from sdk_PlatformAndroidManifest where platformName = @platformName;
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getPlatformSignatureKey]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sdk_getPlatformSignatureKey]
	@Game nvarchar(200),
	@PlatfromName nvarchar(200)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT top 1 StringValue
		from sdk_PlatformConfig
		where GameName = @Game
			and PlatformName = @PlatfromName
			and SDKKey = 'SignatureKey'
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getPlatformVersion]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<获取渠道SDK版本列表>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPlatformVersion] 
	@PlatformID int,
	@SystemID int
AS
BEGIN
	SET NOCOUNT ON;
	select pv.ID,pv.[Version],pv.CreateUser,pv.CollectDatetime,us.Compellation from sdk_PlatformVersion pv
	inner join sdk_DefaultPlatform dpf on pv.[PlatformID]=dpf.Id and pv.[PlatformID]=@PlatformID and pv.SystemID=@SystemID
	left join AspNetUsers us on pv.CreateUser=us.UserName
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getPlugInList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<获取插件列表>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPlugInList]
AS
BEGIN
	select * from sdk_PlugInList
END





GO
/****** Object:  StoredProcedure [dbo].[sdk_getPlugInVersion]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<获取插件版本>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getPlugInVersion]
	@PlugInID int
AS
BEGIN
	select * from sdk_PlugInVersion where PlugInID=@PlugInID order by id 
END





GO
/****** Object:  StoredProcedure [dbo].[sdk_getUserGame]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-26>
-- Description:	<获取角色游戏权限>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getUserGame]
	@UserID nvarchar(128)
AS
BEGIN
	Declare @GameID nvarchar(100)
	Declare @Gamename nvarchar(256)
	SET NOCOUNT ON;
	select @GameID=GameID from sdk_RoleGamePower where UserID=@UserID and GameID='0'--所有游戏权限
	if @GameID is Null
	begin
		SELECT gi.GameDisplayName as GameName FROM sdk_RoleGamePower rgp
		inner join sdk_GameInfo gi on rgp.UserID=@UserID  and rgp.GameID=gi.GameID
	end
	else
	begin
		SET @Gamename='所有游戏'
		select @Gamename as GameName
	end
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getUserGamePower]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-25>
-- Description:	<获取角色游戏权限>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getUserGamePower]
	@UserID nvarchar(128)
AS
BEGIN
	Declare @GameID nvarchar(100)
	SET NOCOUNT ON;
	select @GameID=GameID from sdk_RoleGamePower where UserID=@UserID and GameID='0'--所有游戏权限
	if @GameID is Null
	begin
		select gi.GameID,gi.GameDisplayName,(case when ISNUll(rgp.GameID,0) = 0  then 0 else 1 end) as rolepower
		from sdk_GameInfo gi
		left join sdk_RoleGamePower rgp on gi.GameID=rgp.GameID and rgp.UserID=@UserID
	end
	else
	begin
		select GameID,GameDisplayName,rolepower=-1 from sdk_GameInfo
	end
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_getUsers]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<获取用户权限>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_getUsers]
AS
BEGIN
	SET NOCOUNT ON;

    select Id,UserName,EmailConfirmed,[Compellation],
		(case when r1.RoleId is null then cast(0 as bit)
			else cast(1 as bit) end) as isQA,
		(case when r2.RoleId is null then cast(0 as bit)
			else cast(1 as bit) end) as isDevelop,
		(case when r3.RoleId is null then cast(0 as bit)
			else cast(1 as bit) end) as isAdmin
		from AspNetUsers u
			left join AspNetUserRoles r1 on r1.UserId = u.Id and r1.RoleId=1
			left join AspNetUserRoles r2 on r2.UserId = u.Id and r2.RoleId=2
			left join AspNetUserRoles r3 on r3.UserId = u.Id and r3.RoleId=3
			order by u.createdate desc,Compellation
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_setIcon]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<设置引用icon>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_setIcon]
	@IconName nvarchar(200),
	@SystemID int,
	@GameName nvarchar(32)
AS
BEGIN
	SET NOCOUNT ON;

	declare @GameID int
	
	select @GameID=GameID from sdk_GameInfo where GameName = @GameName 

	if not exists (select 1 from sdk_icon where iconName = @IconName and SystemID=@SystemID and GameID=@GameID)
		insert into sdk_icon(iconName,SystemID,GameID) values(@IconName,@SystemID,@GameID)
	else
		update sdk_icon set iconName=@IconName where iconName = @IconName and SystemID=@SystemID and GameID=@GameID
END



GO
/****** Object:  StoredProcedure [dbo].[sdk_setPlatformGameIcon]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sdk_setPlatformGameIcon]
	@IconName nvarchar(200),
	@GameID int,
	@PlatformID int
AS
BEGIN
	SET NOCOUNT ON;

	delete from sdk_GamePlatformIcon
		where GameName = @GameID
			and PlatformName = @PlatformID

    insert into sdk_GamePlatformIcon(
		GameName,
		PlatformName,
		iconName,
		SystemID
		)
		select @GameID,@PlatformID,iconName,SystemID
			from sdk_icon
			where iconName = @IconName 
				and GameID = @GameID
	
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_setPlatformSignatureKey]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<设置渠道使用签名密钥>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_setPlatformSignatureKey]
	@GameName nvarchar(200),
	@PlatfromName nvarchar(200),
	@SignatureKey nvarchar(200)
AS
BEGIN
	SET NOCOUNT ON;

    if exists (
		select * 
			from sdk_PlatformConfig
			where GameName = @GameName
				and PlatformName = @PlatfromName
				and SDKKey = 'SignatureKey'
		)
		update sdk_PlatformConfig
			set StringValue = @SignatureKey
			where GameName = @GameName
				and PlatformName = @PlatfromName
				and SDKKey = 'SignatureKey'
	else
		insert into sdk_PlatformConfig
			(GameName
			,PlatformName
			,SDKKey
			,StringValue)
			values
			(@GameName
			,@PlatfromName
			,'SignatureKey'
			,@SignatureKey)
			
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_setPlatformVersion]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<设置添加渠道SDK版本>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_setPlatformVersion] 
	@PlatformID int,
	@SystemID int,
	@PlatformVersion nvarchar(50),
	@CreateUser nvarchar(50),
	@strErrorDescribe nvarchar(127) output
AS
BEGIN
	if not exists(select id from sdk_PlatformVersion where [Version]=@PlatformVersion and PlatformID=@PlatformID)
	begin
		insert into sdk_PlatformVersion ([PlatformID],[Version],[CreateUser],[SystemID])
		values (@PlatformID,@PlatformVersion,@CreateUser,@SystemID)
		set @strErrorDescribe=N'版本新增成功！'
		return 0
	end
	else
	begin
		set @strErrorDescribe=N'当前版本已存在！'
		return 1
	end
END




GO
/****** Object:  StoredProcedure [dbo].[sdk_setPlugIn]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<添加插件>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_setPlugIn]
	@PlugInName nvarchar(50),
	@PlugInDisplayName nvarchar(50)
AS
BEGIN
	if not exists(select * from sdk_PlugInList where PlugInName=@PlugInName or PlugInDisplayName=@PlugInDisplayName)
	insert into sdk_PlugInList (PlugInName,PlugInDisplayName) values (@PlugInName,@PlugInDisplayName)
END





GO
/****** Object:  StoredProcedure [dbo].[sdk_setPlugInVersion]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<添加插件版本>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_setPlugInVersion]
	@PlugInID int,
	@PlugInVersion nvarchar(50)
AS
BEGIN
	if not exists(select 1 from sdk_PlugInVersion where PlugInID=@PlugInID and PlugInVersion=@PlugInVersion)
	insert into sdk_PlugInVersion (PlugInID,PlugInVersion) values (@PlugInID,@PlugInVersion)
END





GO
/****** Object:  StoredProcedure [dbo].[sdk_setUserGamePower]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-25>
-- Description:	<获取角色游戏权限>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_setUserGamePower]
	@UserID nvarchar(128),
	@GameIDList nvarchar(100)
AS
BEGIN tran
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	delete from sdk_RoleGamePower where UserID=@UserID
	if @GameIDList=''
	begin
		insert into sdk_RoleGamePower (UserID,GameID) values (@UserID,'-1')
	end
    else if @GameIDList='0'
	begin
		insert into sdk_RoleGamePower (UserID,GameID) values (@UserID,@GameIDList)
	end
	else
	begin
		DECLARE @placeid int
		DECLARE @count int
		DECLARE @split nvarchar(1)
		DECLARE @str nvarchar(500)
		--DECLARE @strsql nvarchar(200)
		DECLARE @pos1 NVARCHAR(20)
		DECLARE @m int
		DECLARE @n int
		-- statr --
		SET @str=@GameIDList+','
		SET @split=','
		SET @m=CHARINDEX(@split,@str)
		SET @n=1
		while @m>0
		begin
			SET @pos1=SUBSTRING(@str,@n,@m-@n)
			insert into sdk_RoleGamePower (UserID,GameID) values (@UserID,@pos1)
			if @@ERROR<>0
			BEGIN		
				ROLLBACK TRAN
				RETURN 1
			END
			SET @n=@m+1
			SET @m=CHARINDEX(@split,@str,@n)
		end
	end
commit tran
return 0




GO
/****** Object:  StoredProcedure [dbo].[sdk_setUserRole]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<配置用户权限>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_setUserRole]
	@Id nvarchar(200),
	@Compellation nvarchar(15),
	@EmailConfirmed bit,
	@isAdmin bit,
	@isDevelop bit,
	@isQA bit
AS
BEGIN
	SET NOCOUNT ON;

    update AspNetUsers set EmailConfirmed = @EmailConfirmed,Compellation=@Compellation
		where Id = @Id;

	if @isQA = 1
	begin
		if not exists (select 1 from AspNetUserRoles where UserId = @Id and RoleId = 1)
		insert into AspNetUserRoles values(@Id,1)
	end
	else
	begin
		delete from AspNetUserRoles where UserId = @Id and RoleId = 1
	end

		if @isDevelop = 1
	begin
		if not exists (select 1 from AspNetUserRoles where UserId = @Id and RoleId = 2)
		insert into AspNetUserRoles values(@Id,2)
	end
	else
	begin
		delete from AspNetUserRoles where UserId = @Id and RoleId = 2
	end

		if @isAdmin = 1
	begin
		if not exists (select 1 from AspNetUserRoles where UserId = @Id and RoleId = 3)
		insert into AspNetUserRoles values(@Id,3)
	end
	else
	begin
		delete from AspNetUserRoles where UserId = @Id and RoleId = 3
	end

END




GO
/****** Object:  StoredProcedure [dbo].[sdk_UpdateGamePlatform]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<修改游戏渠道>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_UpdateGamePlatform] 
	@GameID nvarchar(50),							-- 游戏ID
	@PlatfomrList nvarchar(500),			-- 渠道ID列表
	@VersionList nvarchar(500),				-- 版本ID列表
	@SignatureKeyIDList nvarchar(500),		-- 秘钥ID
	@SystemID nvarchar(1),							-- 秘钥ID
	@PlugInID varchar(1),							-- 插件id
	@PlugInVersion nvarchar(50),			-- 插件版本
	@strErrorDescribe NVARCHAR(127) output	-- 输出参数
AS
DECLARE @m int
DECLARE @n int
DECLARE @m2 int
DECLARE @n2 int
DECLARE @m3 int
DECLARE @n3 int
DECLARE @str nvarchar(500)
DECLARE @str2 nvarchar(500)
DECLARE @str3 nvarchar(500)
DECLARE @split nvarchar(1)
DECLARE @pos1 NVARCHAR(20)
DECLARE @pos2 NVARCHAR(20)
DECLARE @pos3 NVARCHAR(20)
DECLARE @signKeyName nvarchar(50)

declare @PlugInName nvarchar(50)
declare @PlugInDisPlayName nvarchar(50)
BEGIN TRAN
	SET @split=','
	SET @str=@PlatfomrList+','	
	SET @str2=@SignatureKeyIDList+','
	SET @str3=@VersionList+','
	SET @m=CHARINDEX(@split,@str)
	SET @n=1
	SET @m2=CHARINDEX(@split,@str2)
	SET @n2=1
	SET @m3=CHARINDEX(@split,@str3)
	SET @n3=1
	DELETE FROM sdk_GamePlatFromInfo WHERE GameID=@GameID and SystemID=@SystemID and PlugInID=@PlugInID
	if @PlatfomrList='' set @m=0
	WHILE @m>0
	BEGIN
		SET @pos1=SUBSTRING(@str,@n,@m-@n)
		SET @pos2=SUBSTRING(@str2,@n2,@m2-@n2)	
		SET @pos3=SUBSTRING(@str3,@n3,@m3-@n3)	
		SET @n=@m+1
		SET @n2=@m2+1
		SET @n3=@m3+1
		SET @m=CHARINDEX(@split,@str,@n)
		SET @m2=CHARINDEX(@split,@str2,@n2)
		SET @m3=CHARINDEX(@split,@str3,@n3)
			select @signKeyName=KeyName from sdk_SignatureKey where id=@pos2	-- 获取秘钥名称
			if @signKeyName is not null
			begin
				declare @v_sql nvarchar(500)
				update [sdk_PlatformConfig] set StringValue=@signKeyName where SDKKey='SignatureKey' and GameName=@GameID and PlatformName=@pos1
				if @@ERROR<>0
				begin
					SET @strErrorDescribe=N'渠道关联失败！'
					ROLLBACK TRAN
					RETURN 1
				end
			end
			
			INSERT INTO sdk_GamePlatFromInfo ([GameID],[VersionPlatFromID],[SignatureKeyID],SystemID,VersionID,PlugInID,PlugInVersion,selectid) VALUES (@GameID,@pos1,@pos2,@SystemID,@pos3,@PlugInID,@PlugInVersion,CONCAT( @pos1,'_',@PlugInID))
			IF @@ERROR<>0
			BEGIN
				SET @strErrorDescribe=N'渠道关联失败！'
				ROLLBACK TRAN
				RETURN 1
			END
		--END
	END

COMMIT TRAN
return 0




GO
/****** Object:  StoredProcedure [dbo].[sdk_UpdateGamePlatform_IOS]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<修改游戏渠道>
-- =============================================
CREATE PROCEDURE [dbo].[sdk_UpdateGamePlatform_IOS] 
	@GameID int,							-- 游戏ID
	@PlatfomrList nvarchar(500),			-- 渠道ID列表
	@SystemID int,							-- 平台ID
	@strErrorDescribe NVARCHAR(127) output	-- 输出参数
AS
SET NOCOUNT ON;
DECLARE @m int
DECLARE @n int
DECLARE @m2 int
DECLARE @str nvarchar(500)
DECLARE @split nvarchar(1)
DECLARE @pos1 NVARCHAR(20)
BEGIN TRAN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--
	SET @split=','
	SET @str=@PlatfomrList+','	
	SET @m=CHARINDEX(@split,@str)
	SET @n=1
	DELETE FROM sdk_GamePlatFromInfo WHERE GameID=@GameID and SystemID=@SystemID
	WHILE @m>0
	BEGIN
		SET @pos1=SUBSTRING(@str,@n,@m-@n)
		SET @n=@m+1
		SET @m=CHARINDEX(@split,@str,@n)
			INSERT INTO sdk_GamePlatFromInfo ([GameID],[VersionPlatFromID],[SignatureKeyID],SystemID) VALUES (@GameID,@pos1,0,@SystemID)
			IF @@ERROR<>0
			BEGIN
				SET @strErrorDescribe=N'渠道关联失败！'
				ROLLBACK TRAN
				RETURN 1
			END
		--END
	END

COMMIT TRAN



GO
/****** Object:  StoredProcedure [dbo].[server_add_game_commodityList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
------------------------------------
CREATE PROCEDURE [dbo].[server_add_game_commodityList]
@gameid int,
@platformid int,
@name nvarchar(50),
@price nvarchar(10),
@itemcpid nvarchar(50),
@itemid nvarchar(50),
@type nvarchar(50),
@remark nvarchar(50),
@createUser nvarchar(128)

 AS 
	INSERT INTO [server_game_commodityList](
	[gameid],[platformid],[name],[price],[itemcpid],[itemid],[type],[remark],[createUser]
	)VALUES(
	@gameid,@platformid,@name,@price,@itemcpid,@itemid,@type,@remark,@createUser
	)





GO
/****** Object:  StoredProcedure [dbo].[server_add_list]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_add_list]
	@auth nvarchar(32),
	@host nvarchar(15),
	@keys_pattern nvarchar(50),
	@name nvarchar(50),
	@namespace_separator nvarchar(50),
	@port nvarchar(5),
	@ssh_port nvarchar(5),
	@timeout_connect nvarchar(10),
	@timeout_execute nvarchar(10)
AS
BEGIN
	if not exists (select 1 from server_list where [host]=@host and [port]=@port)
	insert into server_list ([auth]
      ,[host]
      ,[keys_pattern]
      ,[name]
      ,[namespace_separator]
      ,[port]
      ,[ssh_port]
      ,[timeout_connect]
      ,[timeout_execute]) values
	  (@auth,@host,@keys_pattern,@name,@namespace_separator,@port,@ssh_port,@timeout_connect,@timeout_execute )
END




GO
/****** Object:  StoredProcedure [dbo].[server_addPlatform]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器阐述管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_addPlatform]
	@platformid int,
	@platformname nvarchar(50),
	@platformdisplayname nvarchar(50),
	@systemid int,
	@ver nvarchar(50),
	@force int,
	@gameVerMin int,
	@gameVerMax int,
	@updateURL nvarchar(200),
	@ClientMD5 nvarchar(32),
	@ClientURL nvarchar(200),
	@createUser nvarchar(128),
	@strErrorDescribe NVARCHAR(127) output	-- 输出参数

AS
BEGIN
	if not exists(select 1 from server_platform where platformid=@platformid and platformname=@platformname and systemid=@systemid)
	begin
		insert into server_platform (platformid,platformname,platformdisplayname,systemid,ver,[force],gameVerMin,gameVerMax,updateURL,ClientMD5,ClientURL,createUser)
		values (@platformid,@platformname,@platformdisplayname,@systemid,@ver,@force,@gameVerMin,@gameVerMax,@updateURL,@ClientMD5,@ClientURL,@createUser)
	end
	else
	begin
		set @strErrorDescribe=N'抱歉，渠道已存在！'
		return 1
	end
	--插入日志
	insert into server_platform_operationLog (platformid,typeid,log_content,createUser) values (@platformid,1,'新建servser_platform渠道',@createUser)
	set @strErrorDescribe=N'渠道添加成功！'
	return 0
END




GO
/****** Object:  StoredProcedure [dbo].[server_del_game_commodityList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_del_game_commodityList]
	@id int
AS
BEGIN
	delete from server_game_commodityList where id=@id
END




GO
/****** Object:  StoredProcedure [dbo].[server_delete_list]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_delete_list]
	@id int
AS
BEGIN
	delete from server_list where id=@id
	delete from server_game_permission where serverid=@id
END




GO
/****** Object:  StoredProcedure [dbo].[server_get_game_commodityList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_get_game_commodityList]
	@gameid int,
	@platformid int
AS
BEGIN
	select * from server_game_commodityList where gameid=@gameid and platformid=@platformid
END




GO
/****** Object:  StoredProcedure [dbo].[server_get_game_platformlist]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_get_game_platformlist]
	@gameid int,
	@systemid int
AS
BEGIN
	select sp.platformid,sp.platformdisplayname,sp.platformname,isnull(spg.gameid,0) as gameid,us.Compellation,spg.modifydatetime from server_platform sp
	left join server_platform_gameInfo spg on sp.platformid=spg.platformid and spg.gameid=@gameid
	left join AspNetUsers us on spg.modifyuser=us.UserName
	where sp.systemid=@systemid
END




GO
/****** Object:  StoredProcedure [dbo].[server_get_list]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_get_list]
AS
BEGIN
	select * from server_list order by id
END




GO
/****** Object:  StoredProcedure [dbo].[server_getGamePlatformInfo]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_getGamePlatformInfo]
	@gameid int,
	@platformid int
AS
DECLARE @gid int
DECLARE @pid int
DECLARE @ver nvarchar(50)
DECLARE @force int
DECLARE @gameVerMin int
DECLARE @gameVerMax int
DECLARE @updateURL nvarchar(50)
DECLARE @ClientMD5 nvarchar(50)
DECLARE @ClientURL nvarchar(50)
BEGIN

	select @gid=gameid
	  ,@pid=platformid
	  ,@ver=[ver]
      ,@force=[force]
      ,@gameVerMin=[gameVerMin]
      ,@gameVerMax=[gameVerMax]
      ,@updateURL=[updateURL]
      ,@ClientMD5=[ClientMD5]
      ,@ClientURL=[ClientURL] from [server_platform_gameInfo] where gameid=@gameid and platformid=@platformid
	  if @gid is null
	  begin
		set @gid=0
		set @pid=0
		set @ver=''
		set @force=0
		set @gameVerMin=0
		set @gameVerMax=0
		set @updateURL=''
		set @ClientMD5=''
		set @ClientURL=''
	  end

	  select @gid as gameid,@pid as platformid, @ver as ver,@force as force,@gameVerMin as gameVerMin,@gameVerMax as gameVerMax,@updateURL as updateURL,@ClientMD5 as ClientMD5,@ClientURL as ClientURL
END




GO
/****** Object:  StoredProcedure [dbo].[server_getPlatformInfo]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_getPlatformInfo] 
	@platformid int
AS
BEGIN
	select * from server_platform where platformid=@platformid
END




GO
/****** Object:  StoredProcedure [dbo].[server_getPlatformList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_getPlatformList]
	@systemid int
AS
BEGIN
	select sp.platformid,sp.platformdisplayname,sp.platformname,sp.collectdatetime,sp.modifydatetime,us1.Compellation as createuser,us2.Compellation as modifyuser from server_platform sp
	left join AspNetUsers us1 on sp.createuser=us1.UserName
	left join AspNetUsers us2 on sp.modifyuser=us2.UserName
	where sp.systemid=@systemid
	order by sp.platformid
END




GO
/****** Object:  StoredProcedure [dbo].[server_init_platform_game]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_init_platform_game]
	@gameid int,
	@platformid int,
	@strErrorDescribe NVARCHAR(127) output	-- 输出参数
AS
BEGIN
	-- 插入游戏渠道基本数据
	if not exists(select 1 from server_platform_gameInfo where gameid=@gameid and platformid=@platformid)
	begin
		insert into server_platform_gameInfo (gameid,platformid,ver,[force],gameVerMin,gameVerMax,
		updateURL,ClientMD5,ClientURL) select gameid=@gameid,platformid,ver,[force],gameVerMin,gameVerMax,
		updateURL,ClientMD5,ClientURL from server_platform where platformid=@platformid


	end
	-- 已存在
	else
	begin
		set @strErrorDescribe=N'游戏参数已存在'
		return 1
	end
	return 0
END




GO
/****** Object:  StoredProcedure [dbo].[server_update_game_commodityList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_update_game_commodityList]
	@id int,
	@name nvarchar(50),
    @price nvarchar(10),
    @itemcpid nvarchar(50),
    @itemid nvarchar(50),
    @type nvarchar(50),
    @remark nvarchar(50),
    @modifyUser nvarchar(128)
AS
BEGIN
	update server_game_commodityList set 
	name=@name,
	price=@price,
	itemcpid=@itemcpid,
	itemid=@itemid,
	[type]=@type,
	remark=@remark,
	modifyUser=@modifyUser,
	modifydatetime=getdate() where id=@id
END




GO
/****** Object:  StoredProcedure [dbo].[server_update_list]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_update_list]
	@id int,
	@auth nvarchar(32),
	@host nvarchar(15),
	@keys_pattern nvarchar(50),
	@name nvarchar(50),
	@namespace_separator nvarchar(50),
	@port nvarchar(5),
	@ssh_port nvarchar(5),
	@timeout_connect nvarchar(10),
	@timeout_execute nvarchar(10)
AS
BEGIN
	if not exists (select 1 from server_list where [host]=@host and [port]=@port and id!=@id)
	update server_list set [auth]=@auth
      ,[host]=@host
      ,[keys_pattern]=@keys_pattern
      ,[name]=@name
      ,[namespace_separator]=@namespace_separator
      ,[port]=@port
      ,[ssh_port]=@ssh_port
      ,[timeout_connect]=@timeout_connect
      ,[timeout_execute] =@timeout_execute
END




GO
/****** Object:  StoredProcedure [dbo].[server_updateGamePlatform]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_updateGamePlatform]
	@gameid int,
	@platformid int,	
	@ver nvarchar(50),
	@force int,
	@gameVerMin int,
	@gameVerMax int,
	@updateURL nvarchar(200),
	@ClientMD5 nvarchar(32),
	@ClientURL nvarchar(200),
	@modifyUser nvarchar(128),
	@strErrorDescribe NVARCHAR(127) output	-- 输出参数
AS
BEGIN
	update server_platform_gameInfo set 
	ver=@ver,
	[force]=@force ,
	gameVerMin=@gameVerMin ,
	gameVerMax=@gameVerMax ,
	updateURL=@updateURL ,
	ClientMD5=@ClientMD5 ,
	ClientURL=@ClientURL ,
	modifyUser=@modifyUser ,
	modifydatetime=getdate()
	where gameid=@gameid and platformid=@platformid
	if @@ROWCOUNT=0
	begin
		set @strErrorDescribe=N'配置参数更新失败'
		return 1
	end
	--插入日志
	insert into server_platform_operationLog (platformid,typeid,log_content,createUser) values (@platformid,3,'更新servser_game_platform参数值',@modifyUser)
	
	set @strErrorDescribe=N'配置参数更新成功'
	return 0
END




GO
/****** Object:  StoredProcedure [dbo].[server_updatePlatform]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<服务器参数管理>
-- =============================================
CREATE PROCEDURE [dbo].[server_updatePlatform]
	@platformid int,
	@platformname nvarchar(50),
	@platformdisplayname nvarchar(50),
	@systemid int,
	@ver nvarchar(50),
	@force int,
	@gameVerMin int,
	@gameVerMax int,
	@updateURL nvarchar(200),
	@ClientMD5 nvarchar(32),
	@ClientURL nvarchar(200),
	@modifyUser nvarchar(128),
	@strErrorDescribe NVARCHAR(127) output	-- 输出参数

AS
BEGIN
	if not exists(select 1 from server_platform where platformid!=@platformid and platformname=@platformname and systemid=@systemid)
	begin
		update server_platform set platformname=@platformname,platformdisplayname=@platformdisplayname,ver=@ver,[force]=@force,gameVerMin=@gameVerMin,
		gameVerMax=@gameVerMax,updateURL=@updateURL,ClientMD5=@ClientMD5,ClientURL=@ClientURL,modifyUser=@modifyUser,modifydatetime=GETDATE() where platformid=@platformid
	end
	else
	begin
		set @strErrorDescribe=N'抱歉，渠道已存在！'
		return 1
	end
	
	insert into server_platform_operationLog (platformid,typeid,log_content,createUser) values (@platformid,2,'更新servser_platform渠道',@modifyUser)
	set @strErrorDescribe=N'渠道更新成功！'
	return 0
END




GO
/****** Object:  StoredProcedure [dbo].[skd_getSignatureKeys]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TypeSDK>
-- Create date: <2016-1-14>
-- Description:	<获取签名列表>
-- =============================================

CREATE PROCEDURE [dbo].[skd_getSignatureKeys]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT KeyName
		from sdk_SignatureKey
		order by id
END




GO
/****** Object:  Table [dbo].[__MigrationHistory]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[__MigrationHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ContextKey] [nvarchar](300) NOT NULL,
	[Model] [varbinary](max) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK_dbo.__MigrationHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC,
	[ContextKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AspNetRoles]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserClaims]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.AspNetUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserLogins]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserLogins](
	[LoginProvider] [nvarchar](128) NOT NULL,
	[ProviderKey] [nvarchar](128) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUserLogins] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserRoles]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [nvarchar](128) NOT NULL,
	[RoleId] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUsers]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [nvarchar](128) NOT NULL,
	[Email] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEndDateUtc] [datetime] NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[UserName] [nvarchar](256) NOT NULL,
	[Compellation] [nvarchar](15) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[delete_sdk_Games]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[delete_sdk_Games](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GameName] [nvarchar](50) NOT NULL,
	[GameDisplayName] [nvarchar](50) NOT NULL,
	[GameStatus] [int] NOT NULL,
	[GamePic] [nvarchar](200) NULL,
	[GameIntroduce] [nvarchar](1000) NULL,
	[GameWebSite] [nvarchar](200) NULL,
 CONSTRAINT [PK_sdk_Games] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[delete_sdk_GameVersion]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[delete_sdk_GameVersion](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GameName] [nvarchar](50) NOT NULL,
	[GameVersion] [nvarchar](50) NOT NULL,
	[GameVersionStatus] [int] NOT NULL,
	[Package] [nvarchar](50) NULL,
 CONSTRAINT [PK_sdk_GameVersion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_AdPackageCreateTask]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_AdPackageCreateTask](
	[Recid] [int] NOT NULL,
	[AdID] [int] NOT NULL,
	[AdName] [nvarchar](50) NOT NULL,
	[GameID] [int] NOT NULL,
	[PackageTaskStatus] [int] NOT NULL,
	[CreateTaskID] [nvarchar](50) NULL,
	[CollectDatetime] [datetime] NULL,
	[StartDatetime] [datetime] NULL,
	[FinishDatetime] [datetime] NULL,
	[PackageName] [nvarchar](200) NULL,
	[CreateUser] [nvarchar](128) NULL,
 CONSTRAINT [PK_sdk_AdPackageCreateTask] PRIMARY KEY CLUSTERED 
(
	[Recid] ASC,
	[AdID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_DefaultPlatform]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_DefaultPlatform](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PlatformName] [nvarchar](50) NOT NULL,
	[PlatformDisplayName] [nvarchar](50) NOT NULL,
	[PlatformStatus] [tinyint] NOT NULL,
	[PlatformIcon] [nvarchar](150) NULL,
	[SystemID] [int] NULL,
	[Nullity] [tinyint] NOT NULL,
	[PlugInID] [int] NULL,
	[ParentID] [int] NULL,
 CONSTRAINT [PK_sdk_DefaultPlatform] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_DefaultPlatformConfig]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_DefaultPlatformConfig](
	[PlatformID] [int] NOT NULL,
	[SDKKey] [nvarchar](200) NOT NULL,
	[Explain] [nvarchar](1000) NULL,
	[StringValue] [nvarchar](4000) NULL,
	[isCPSetting] [bit] NOT NULL,
	[isBuilding] [bit] NOT NULL,
	[isServer] [bit] NOT NULL,
	[SystemID] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_GameInfo]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_GameInfo](
	[GameID] [int] IDENTITY(1,1) NOT NULL,
	[GameName] [nvarchar](50) NOT NULL,
	[GameDisplayName] [nvarchar](50) NOT NULL,
	[AndroidVersionID] [int] NOT NULL,
	[IOSVersionID] [int] NOT NULL,
	[AndroidKeyID] [int] NOT NULL,
	[IOSKeyID] [int] NULL,
	[GameIcon] [nvarchar](100) NULL,
	[CreateUser] [nvarchar](50) NOT NULL,
	[CollectDatetime] [datetime] NOT NULL,
	[ModifyDatetime] [datetime] NULL,
	[ModifyUser] [nvarchar](50) NULL,
	[GameNameSpell] [nvarchar](50) NULL,
	[UnityVer] [nvarchar](50) NULL,
	[ProductName] [nvarchar](50) NULL,
	[IsEncryption] [tinyint] NULL,
	[SDKGameID] [nvarchar](50) NULL,
	[SDKGameKey] [nvarchar](50) NULL,
 CONSTRAINT [PK_GameInfo] PRIMARY KEY CLUSTERED 
(
	[GameID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_GamePlatformConfig]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_GamePlatformConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GameID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SDKKey] [nvarchar](200) NOT NULL,
	[Explain] [nvarchar](1000) NULL,
	[StringValue] [nvarchar](4000) NULL,
	[isCPSetting] [bit] NOT NULL,
	[isBuilding] [bit] NOT NULL,
	[isServer] [bit] NOT NULL,
 CONSTRAINT [PK_sdk_GamePlatformConfig] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_GamePlatformIcon]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_GamePlatformIcon](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GameName] [nvarchar](50) NOT NULL,
	[PlatformName] [nvarchar](50) NOT NULL,
	[iconName] [nvarchar](50) NOT NULL,
	[SystemID] [int] NULL,
	[UpdateDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_sdk_GamePlatfromIcon] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_GamePlatFromInfo]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_GamePlatFromInfo](
	[GameID] [int] NOT NULL,
	[VersionPlatFromID] [int] NOT NULL,
	[SignatureKeyID] [int] NULL,
	[SystemID] [int] NULL,
	[VersionID] [int] NULL,
	[PlugInID] [int] NULL,
	[PlugInVersion] [nvarchar](50) NULL,
	[SelectID] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_icon]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_icon](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[iconName] [nvarchar](50) NOT NULL,
	[SystemID] [int] NULL,
	[GameID] [int] NULL,
 CONSTRAINT [PK_sdk_icon] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_InitPlatformConfig]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_InitPlatformConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GameName] [nvarchar](50) NULL,
	[PlatformName] [nvarchar](50) NULL,
	[SDKKey] [nvarchar](200) NULL,
	[Explain] [nvarchar](1000) NULL,
	[StringValue] [nvarchar](4000) NULL,
	[isCPSetting] [bit] NOT NULL,
	[isBuilding] [bit] NOT NULL,
	[isServer] [bit] NOT NULL,
 CONSTRAINT [PK_sdk_InitPlatformConfig] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_NewPackageCreateTask]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_NewPackageCreateTask](
	[RecID] [int] IDENTITY(1,1) NOT NULL,
	[PackageTaskID] [int] NOT NULL,
	[CreateUser] [nvarchar](50) NOT NULL,
	[CollectDatetime] [datetime] NOT NULL,
	[PlatFormID] [int] NOT NULL,
	[PackageTaskStatus] [int] NOT NULL,
	[StartDatetime] [datetime] NULL,
	[FinishDatetime] [datetime] NULL,
	[CreateTaskID] [nvarchar](50) NULL,
	[ServerAddr] [nvarchar](20) NULL,
	[FileAddr] [nvarchar](100) NULL,
	[FileName] [nvarchar](50) NULL,
	[PackageAddr] [nvarchar](20) NULL,
	[PackageName] [nvarchar](100) NULL,
	[GameID] [int] NULL,
	[GameFileVersion] [nvarchar](50) NULL,
	[PlatformVersion] [nvarchar](50) NULL,
	[GameVersionLable] [nvarchar](50) NULL,
	[IsEncryption] [tinyint] NULL,
	[AdID] [nvarchar](50) NULL,
	[AdName] [nvarchar](50) NULL,
	[PlugInID] [int] NULL,
	[PlugInVersion] [nvarchar](50) NULL,
	[CompileMode] [nvarchar](50) NULL,
 CONSTRAINT [PK_sdk_NewPackageCreateTask] PRIMARY KEY CLUSTERED 
(
	[RecID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_NewPackageCreateTask_IOS]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_NewPackageCreateTask_IOS](
	[RecID] [int] IDENTITY(1,1) NOT NULL,
	[PackageTaskID] [int] NOT NULL,
	[CreateUser] [nvarchar](50) NOT NULL,
	[CollectDatetime] [datetime] NOT NULL,
	[PlatFormID] [int] NOT NULL,
	[PackageTaskStatus] [int] NOT NULL,
	[StartDatetime] [datetime] NULL,
	[FinishDatetime] [datetime] NULL,
	[CreateTaskID] [nvarchar](50) NULL,
	[ServerAddr] [nvarchar](20) NULL,
	[FileAddr] [nvarchar](100) NULL,
	[FileName] [nvarchar](50) NULL,
	[PackageAddr] [nvarchar](20) NULL,
	[PackageName] [nvarchar](100) NULL,
	[GameID] [int] NULL,
	[GameFileVersion] [nvarchar](50) NULL,
	[PlatformVersion] [nvarchar](50) NULL,
	[GameVersionLable] [nvarchar](50) NULL,
 CONSTRAINT [PK_sdk_NewPackageCreateTask_IOS] PRIMARY KEY CLUSTERED 
(
	[RecID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_Package]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_Package](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[packageName] [nvarchar](50) NOT NULL,
	[packageMD5] [nvarchar](50) NULL,
	[gameName] [nvarchar](50) NULL,
	[gameVersion] [nvarchar](50) NULL,
	[platformName] [nvarchar](50) NULL,
	[createDatetime] [datetime] NOT NULL,
	[createUser] [nvarchar](50) NULL,
	[isSigne] [nvarchar](50) NULL,
	[createTask] [nvarchar](50) NULL,
 CONSTRAINT [PK_sdk_Package] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_PackageCreateTask]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_PackageCreateTask](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CreaterName] [nvarchar](50) NOT NULL,
	[CreateDatetime] [datetime] NOT NULL,
	[GameName] [nvarchar](50) NOT NULL,
	[GameVersionName] [nvarchar](50) NOT NULL,
	[Platforms] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_sdk_PackageCreateTask] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_Platform]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_Platform](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PlatformID] [int] NOT NULL,
	[SdkVersion] [nvarchar](50) NULL,
	[MyVersionID] [nvarchar](50) NULL,
	[SystemID] [int] NOT NULL,
 CONSTRAINT [PK_sdk_Platform] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_PlatformAndroidManifest]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_PlatformAndroidManifest](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PlatformName] [nvarchar](50) NOT NULL,
	[ConfigKey] [text] NOT NULL,
	[ConfigContent] [text] NOT NULL,
 CONSTRAINT [PK_sdk_PlatformAndroidManifest] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_PlatformConfig]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_PlatformConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GameName] [nvarchar](50) NULL,
	[PlatformName] [nvarchar](50) NULL,
	[SDKKey] [nvarchar](200) NULL,
	[Explain] [nvarchar](1000) NULL,
	[StringValue] [nvarchar](4000) NULL,
	[isCPSetting] [bit] NOT NULL,
	[isBuilding] [bit] NOT NULL,
	[isServer] [bit] NOT NULL,
	[PlugInID] [nvarchar](1) NULL,
 CONSTRAINT [PK_sdk_PlatformConfig] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_PlatformConfigKey]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_PlatformConfigKey](
	[SDKKey] [nvarchar](50) NOT NULL,
	[Explain] [nvarchar](100) NULL,
	[StringValue] [nvarchar](50) NULL,
	[isCPSetting] [bit] NOT NULL,
	[isBuilding] [bit] NOT NULL,
	[isServer] [bit] NOT NULL,
 CONSTRAINT [PK_sdk_PlatformConfigKey] PRIMARY KEY CLUSTERED 
(
	[SDKKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_PlatformConfigProductList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_PlatformConfigProductList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GameName] [nvarchar](50) NOT NULL,
	[PlatformName] [nvarchar](50) NOT NULL,
	[itemid] [nvarchar](50) NOT NULL,
	[itemcpid] [nvarchar](50) NOT NULL,
	[price] [int] NOT NULL,
	[name] [nvarchar](100) NULL,
	[type] [int] NOT NULL,
	[info] [nvarchar](300) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_PlatformGameSignatureKey]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_PlatformGameSignatureKey](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[GameName] [nvarchar](200) NOT NULL,
	[PlatformName] [nvarchar](200) NOT NULL,
	[SignatureKeyName] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_sdk_PlatformGameSignatureKey] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_PlatformStatus]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_PlatformStatus](
	[Id] [int] NOT NULL,
	[PlatformStatusName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_sdk_PlatformStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_PlatformVersion]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_PlatformVersion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlatformID] [int] NOT NULL,
	[Version] [nvarchar](50) NOT NULL,
	[CreateUser] [nvarchar](50) NOT NULL,
	[CollectDatetime] [datetime] NOT NULL,
	[SystemID] [int] NOT NULL,
 CONSTRAINT [PK_PlatformVersion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_PlugInList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_PlugInList](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlugInName] [nvarchar](50) NOT NULL,
	[PlugInDisplayName] [nvarchar](50) NOT NULL,
	[CollectDatetime] [datetime] NOT NULL,
 CONSTRAINT [PK_PlugInList] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_PlugInVersion]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_PlugInVersion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PlugInID] [int] NOT NULL,
	[PlugInVersion] [nvarchar](50) NOT NULL,
	[CollectDatetime] [datetime] NOT NULL,
 CONSTRAINT [PK_PlugVersion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_RoleGamePower]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_RoleGamePower](
	[UserID] [nvarchar](128) NOT NULL,
	[GameID] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_SignatureKey]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_SignatureKey](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[KeyName] [nvarchar](50) NULL,
	[KeyStore] [nvarchar](500) NULL,
	[KeyStorePassword] [nvarchar](50) NULL,
	[KeyAlias] [nvarchar](50) NULL,
	[KeyAliasPassword] [nvarchar](50) NULL,
 CONSTRAINT [PK_sdk_SignatureKey] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_TypeSdkVersion]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_TypeSdkVersion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MyVersion] [nvarchar](50) NOT NULL,
	[CreateUser] [nvarchar](50) NOT NULL,
	[CollectDatetime] [datetime] NOT NULL,
	[PlatFormID] [int] NOT NULL,
 CONSTRAINT [PK_GdeGamePlatformVersion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[sdk_UploadPackageInfo]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sdk_UploadPackageInfo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GameVersion] [nvarchar](150) NOT NULL,
	[PageageTable] [nvarchar](150) NOT NULL,
	[CollectDatetime] [datetime] NOT NULL,
	[FileSize] [decimal](18, 2) NOT NULL,
	[UploadUser] [nvarchar](50) NOT NULL,
	[GameName] [nvarchar](20) NOT NULL,
	[GamePlatFrom] [nvarchar](20) NULL,
	[StrCollectDatetime] [nvarchar](20) NULL,
	[FileName] [nvarchar](150) NULL,
	[GameID] [int] NULL,
 CONSTRAINT [PK_sdk_UploadPackageInfo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[server_game_commodityList]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[server_game_commodityList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[gameid] [int] NOT NULL,
	[platformid] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[price] [nvarchar](10) NOT NULL,
	[itemcpid] [nvarchar](50) NOT NULL,
	[itemid] [nvarchar](50) NOT NULL,
	[type] [nvarchar](50) NULL,
	[remark] [nvarchar](50) NULL,
	[createUser] [nvarchar](128) NOT NULL,
	[collectdatetime] [datetime] NOT NULL,
	[modifyUser] [nvarchar](128) NULL,
	[modifydatetime] [datetime] NULL,
 CONSTRAINT [PK_server_game_commodityList] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[server_game_permission]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[server_game_permission](
	[serverid] [int] NOT NULL,
	[gameid] [int] NOT NULL,
 CONSTRAINT [PK_server_game_permission] PRIMARY KEY CLUSTERED 
(
	[serverid] ASC,
	[gameid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[server_list]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[server_list](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[auth] [nvarchar](32) NULL,
	[host] [nvarchar](15) NOT NULL,
	[keys_pattern] [nvarchar](50) NULL,
	[name] [nvarchar](50) NOT NULL,
	[namespace_separator] [nvarchar](50) NULL,
	[port] [nvarchar](5) NOT NULL,
	[ssh_port] [nvarchar](5) NULL,
	[timeout_connect] [nvarchar](10) NULL,
	[timeout_execute] [nvarchar](10) NULL,
 CONSTRAINT [PK_server_list] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[server_platform]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[server_platform](
	[platformid] [int] NOT NULL,
	[platformname] [nvarchar](50) NOT NULL,
	[platformdisplayname] [nvarchar](50) NOT NULL,
	[systemid] [int] NOT NULL,
	[ver] [nvarchar](50) NOT NULL,
	[force] [int] NOT NULL,
	[gameVerMin] [int] NOT NULL,
	[gameVerMax] [int] NOT NULL,
	[updateURL] [nvarchar](200) NOT NULL,
	[ClientMD5] [nvarchar](32) NOT NULL,
	[ClientURL] [nvarchar](200) NOT NULL,
	[nullity] [bit] NULL,
	[collectdatetime] [datetime] NULL,
	[createUser] [nvarchar](128) NOT NULL,
	[modifydatetime] [datetime] NULL,
	[modifyUser] [nvarchar](128) NULL,
	[synchrodata] [bit] NULL,
 CONSTRAINT [PK_server_Platform] PRIMARY KEY CLUSTERED 
(
	[platformid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[server_platform_attrs]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[server_platform_attrs](
	[platformid] [int] NOT NULL,
	[gameid] [int] NOT NULL,
	[attrs_key] [nvarchar](50) NOT NULL,
	[attrs_val] [nvarchar](512) NULL,
	[collectdatetime] [datetime] NULL,
 CONSTRAINT [PK_server_platform_attrs] PRIMARY KEY CLUSTERED 
(
	[platformid] ASC,
	[gameid] ASC,
	[attrs_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[server_platform_gameInfo]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[server_platform_gameInfo](
	[gameid] [int] NOT NULL,
	[platformid] [int] NOT NULL,
	[ver] [nvarchar](50) NOT NULL,
	[force] [int] NOT NULL,
	[gameVerMin] [int] NOT NULL,
	[gameVerMax] [int] NOT NULL,
	[updateURL] [nvarchar](200) NOT NULL,
	[ClientMD5] [nvarchar](32) NOT NULL,
	[ClientURL] [nvarchar](200) NOT NULL,
	[nullity] [bit] NOT NULL,
	[collectdatetime] [datetime] NOT NULL,
	[modifyUser] [nvarchar](128) NULL,
	[modifydatetime] [datetime] NULL,
	[synchrodata] [bit] NULL,
	[paramChange] [bit] NOT NULL,
 CONSTRAINT [PK_server_platform_gameInfo] PRIMARY KEY CLUSTERED 
(
	[gameid] ASC,
	[platformid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[server_platform_operationLog]    Script Date: 2016/10/31 0:35:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[server_platform_operationLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[platformid] [int] NOT NULL,
	[gameid] [int] NOT NULL,
	[typeid] [int] NOT NULL,
	[log_content] [nvarchar](50) NOT NULL,
	[createUser] [nvarchar](128) NOT NULL,
	[collectdatetime] [datetime] NULL,
 CONSTRAINT [PK_server_platform_operationLog] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
INSERT [dbo].[__MigrationHistory] ([MigrationId], [ContextKey], [Model], [ProductVersion]) VALUES (N'201503200925005_InitialCreate', N'SDKPackage.Models.ApplicationDbContext', 0x1F8B0800000000000400DD5CDB6EDC36107D2FD07F10F4D416CECA9726488DDD14CEDA6E8DC417649DA06F0157E2AE85489422518E8DA25FD6877E527FA14389BAF1A2CBAEBCBB2E020416393C331C0EC9E170B8FFFEFDCFF8D707DF33EE7114BB01999807A37DD3C0C40E1C972C276642172F5E9BBFBEF9FEBBF199E33F189F72BA2346072D493C31EF280D8F2D2BB6EFB08FE291EFDA5110070B3AB203DF424E601DEEEFFF621D1C5818204CC0328CF1878450D7C7E9077C4E0362E39026C8BB0C1CECC5BC1C6A6629AA71857C1C87C8C6137376FAEE06D95FD0128F3262D338F15C0482CCB0B7300D4448401105318F3FC67846A3802C67211420EFF631C440B7405E8CB9F8C72579D79EEC1FB29E5865C31CCA4E621AF83D010F8EB86A2CB1F94A0A360BD581F2CE40C9F491F53A55E0C4BC70705AF421F0400122C3E3A91731E2897959B03889C32B4C4779C35106791E01DCB720FA32AA22EE199DDBED15A67438DA67FFF68C69E2D124C21382131A216FCFB849E69E6BBFC38FB7C1174C264707F3C5D1EB97AF9073F4EA677CF4B2DA53E82BD0D50AA0E8260A421C816C7851F4DF34AC7A3B4B6C5834ABB4C9B402B604B3C2342ED1C37B4C96F40EE6CBE16BD338771FB0939770E3FA485C9844D08846097C5E259E87E61E2EEAAD469EECFF06AE872F5F0DC2F50ADDBBCB74E805FE30712298571FB097D6C6776E984DAFDA787FE664E751E0B3EFBA7D65B59F674112D9AC338196E416454B4CEBD28DADD2783B9934831ADEAC73D4DD376D26A96CDE4A52D6A1556642CE62D3B32197F769F976B6B8933084C14B4D8B69A4C9E0A4BD6A2434DE334A92D2700EBA1A0E810EFD9FD7C1331FB9DE000B61072EE0822CDCC8C7452FDF06607688F496F906C531AC03CEEF28BE6B101DFE1C40F419B69308CC7346911F3E39B79BBB80E0ABC49F33ABDF1CAFC186E6F65B708E6C1A446784B55A1BEF7D607F09127A469C5344F1476AE780ECF3D6F5BB030C22CE896DE3383E0763C6CE34000F3B07BC20F4E8B0371C5B9FB6ED884C3DE4FA6A4F4458493FE7A4A537A2A6903C120D99CA2B6912F57DB0744937517352BDA81945ABA89CACAFA80CAC9BA49C522F684AD02A674635989F978ED0F08E5E0ABBFB9EDE7A9BB76E2DA8A871062B24FE0D131CC132E6DC204A7144CA11E8B26E6CC35948878F317DF2BD29E5F40979C9D0AC569A0DE92230FC6C4861777F36A46242F1BDEB30AFA4C3F1272706F84EF4EA9355FB9C1324DBF474A87573D3CC37B306E8A6CB491C07B69BCE0245E08B872DEAF2830F67B4C730B2DE887110E81818BACBB63C2881BE99A2515D9353EC618A8D133B0B0C4E516C2347562374C8E92158BEA32A042BE32175E17E927882A5E3883542EC1014C34C750995A7854B6C37445EAB9684961DB730D6F7828758738A434C18C3564D7461AE0E7F30010A3EC2A0B469686C552CAED910355EAB6ECCDB5CD872DCA5A8C4466CB2C577D6D825F7DF9EC4309B35B601E36C56491701B4A1BC6D18283FAB743500F1E0B26B062A9C983406CA5DAA8D18685D635B30D0BA4A9E9D816647D4AEE32F9C5777CD3CEB07E5CD6FEB8DEADA826DD6F4B163A699F99ED086420B1CC9E6793A6795F8812A0E6720273F9FC5DCD5154D8481CF30AD876C4A7F57E9875ACD20A21135019686D602CA2F0125206942F5102E8FE5354AC7BD881EB079DCAD1196AFFD026CC50664ECEA656885507F652A1A67A7D347D1B3C21A2423EF7458A8E0280C425CBCEA1DEFA0145D5C56564C175FB88F375CE9181F8C0605B578AE1A25E59D195C4BB969B66B49E590F571C9D6D292E03E69B4947766702D711B6D5792C229E8E116ACA5A2FA163ED064CB231DC56E53D48DAD2C458A178C2D4D2ED5F81285A14B9695DC2A5E62CCB2C4AAE98B59FF94233FC3B0EC58917954485B70A241849658A805D620E9B91BC5F4145134472CCE33757C894CB9B76A96FF9C6575FB940731DF07726AF637BF5995AEEE6B5BADEC8B708873E8A0CF1C9A348AAE187E757383A5BA210F458AC0FD34F0129FE8FD2B7DEBECFAAEDA3E2B9111C69620BFE43F49CA92BCDCBAE63B8D8B3C278619A3C27B597D9CF4103A6DE7BE6755DF3A7F548F9287A7AA28BA90D5D6C64DE7C6F4192BD141EC3F54AD084F33AB78564A158017F5C4A82436486095BAEEA8F5DC932A66BDA63BA29060528514AA7A48594D23A90959AD58094FA3513545770E72E248155DAEED8EAC4821A9422BAA57C056C82CD67547556499548115D5DDB1CB9413710DDDE17D4B7B6C5975E3CA0EB6EBED5C1A8CA7591087D9F82AF7F755A04A714F2C7E432F81F1F29D3426EDE96E5563CAC219EB19930643BFEED42EBEEBCB4EE36DBD1EB3769B5D5BDA9B6EF3F578FD4CF6490D433ADB892405F7E28C279CE5C6FC5CD5FE78463A686524A691AB11CCE931A6D81F3182D1ECAB37F55CCC16F19CE012117781639A65709887FB0787C2039CDD790C63C5B1E329CEA5BA1731F531DB403216B947917D87223935628D072325A81475BE200E7E98987FA6AD8ED30006FB2B2DDE332EE28FC4FD9A40C56D9460E32F39D5739804FAE613D68E3E77E8AED58B3F3E674DF78CEB0866CCB1B12FE8729511AE3F82E8254DD6740D69567E1AF17C2754EDE58112559810AB3F3498BB74904706B9943FF8E8E1C7BEA2291F12AC85A8782C3014DE202AD43D0658054BFB10C0814F9A3E04E8D759F5C3805544D33E0A70497F30F14940F765286FB9C5AD467124DAC49294EAB935A57AADFCCA6DEF4D52E6F55A135DCEAEEE01B74606F50A96F1CC928F07DB1D15B9C583616FD3B49F3CA178577288CBEC8EEDA60E6F325BB8E14EE87F9524BC03696D8A349DEDA7026FDAD67461DC1DCFA7EC97F0BB63C6C693B7B69FD6BB6963D3857977DCD87A25EFEE98AD6D6BFFDCB2A575DE42B79E8A2B671569AE6354B1E0B654DB2C700E27FC790046907994D90B49756E57535E6A0BC39244CF549F54263296268EC457A26866DBAFAF7CC36FEC2CA76966AB49C56CE2CDD7FF46DE9CA699B726C1711B49C2CA144355E276CB3AD69401F59C92826B3D69C9416FF3591BEFD69F530EF0204AA9CD1ECD1DF1F349F91D4425434E9D1E29BEF2752FEC9D955F5484FD3B76972504FB7D4582EDDAAE59D05C9045906FDE8244398910A1B9C41439B0A59E44D45D209B42358B31A74FBCD3B81DBBE99863E7825C27344C287419FB73AF16F0624E4013FF348FB92EF3F83A4C7FAD64882E80982E8BCD5F93B789EB3985DCE78A9890068279173CA2CBC692B2C8EEF2B140BA0A484720AEBEC229BAC57EE801587C4D66E81EAF221B98DF7BBC44F6631901D481B40F445DEDE353172D23E4C71CA36C0F9F60C38EFFF0E63F36E1A47858540000, N'6.1.0-30225')
INSERT [dbo].[AspNetRoles] ([Id], [Name]) VALUES (N'3', N'Admin')
INSERT [dbo].[AspNetRoles] ([Id], [Name]) VALUES (N'2', N'Develop')
INSERT [dbo].[AspNetRoles] ([Id], [Name]) VALUES (N'1', N'QA')
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'd759cdfe-ea7f-4beb-b2da-ed25ce71abe3', N'1')
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'd759cdfe-ea7f-4beb-b2da-ed25ce71abe3', N'2')
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'd759cdfe-ea7f-4beb-b2da-ed25ce71abe3', N'3')
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName], [Compellation], [CreateDate]) VALUES (N'd759cdfe-ea7f-4beb-b2da-ed25ce71abe3', N'demo@typesdk.com', 1, N'AAKpdirLMZA7uDeOPF9tZ8u31sIkobO5d1HixBiHbeh0BARXkhKHFUGiTcZjtyEKYQ==', N'cdaea4eb-f9dd-4afb-98f6-9ddb56a7c54b', NULL, 0, 0, NULL, 0, 0, N'demo@typesdk.com', N'Demo', CAST(0x0000A67500F0270F AS DateTime))
SET IDENTITY_INSERT [dbo].[sdk_DefaultPlatform] ON 

INSERT [dbo].[sdk_DefaultPlatform] ([Id], [PlatformName], [PlatformDisplayName], [PlatformStatus], [PlatformIcon], [SystemID], [Nullity], [PlugInID], [ParentID]) VALUES (5, N'360', N'360', 1, NULL, 1, 0, 0, 0)
INSERT [dbo].[sdk_DefaultPlatform] ([Id], [PlatformName], [PlatformDisplayName], [PlatformStatus], [PlatformIcon], [SystemID], [Nullity], [PlugInID], [ParentID]) VALUES (6, N'WanDouJia', N'豌豆荚', 1, NULL, 1, 0, 0, 0)
INSERT [dbo].[sdk_DefaultPlatform] ([Id], [PlatformName], [PlatformDisplayName], [PlatformStatus], [PlatformIcon], [SystemID], [Nullity], [PlugInID], [ParentID]) VALUES (7, N'Downjoy', N'当乐', 1, N'/img/platformicon/20160219165352_7038.png', 1, 0, 0, 0)
INSERT [dbo].[sdk_DefaultPlatform] ([Id], [PlatformName], [PlatformDisplayName], [PlatformStatus], [PlatformIcon], [SystemID], [Nullity], [PlugInID], [ParentID]) VALUES (8, N'UC', N'UC', 1, N'/img/platformicon/20160816113411_8463.png', 1, 0, 0, 0)
INSERT [dbo].[sdk_DefaultPlatform] ([Id], [PlatformName], [PlatformDisplayName], [PlatformStatus], [PlatformIcon], [SystemID], [Nullity], [PlugInID], [ParentID]) VALUES (9, N'XiaoMi', N'小米', 1, NULL, 1, 0, 0, 0)
INSERT [dbo].[sdk_DefaultPlatform] ([Id], [PlatformName], [PlatformDisplayName], [PlatformStatus], [PlatformIcon], [SystemID], [Nullity], [PlugInID], [ParentID]) VALUES (10, N'Baidu', N'百度', 1, N'/img/platformicon/20160816113516_3932.png', 1, 0, 0, 0)
INSERT [dbo].[sdk_DefaultPlatform] ([Id], [PlatformName], [PlatformDisplayName], [PlatformStatus], [PlatformIcon], [SystemID], [Nullity], [PlugInID], [ParentID]) VALUES (21, N'HuaWei', N'华为', 1, NULL, 1, 0, 0, 0)
INSERT [dbo].[sdk_DefaultPlatform] ([Id], [PlatformName], [PlatformDisplayName], [PlatformStatus], [PlatformIcon], [SystemID], [Nullity], [PlugInID], [ParentID]) VALUES (26, N'Oppo', N'Oppo', 1, NULL, 1, 0, 0, 0)
INSERT [dbo].[sdk_DefaultPlatform] ([Id], [PlatformName], [PlatformDisplayName], [PlatformStatus], [PlatformIcon], [SystemID], [Nullity], [PlugInID], [ParentID]) VALUES (34, N'Vivo', N'Vivo', 1, NULL, 1, 0, 0, 0)
INSERT [dbo].[sdk_DefaultPlatform] ([Id], [PlatformName], [PlatformDisplayName], [PlatformStatus], [PlatformIcon], [SystemID], [Nullity], [PlugInID], [ParentID]) VALUES (36, N'YouKu', N'优酷', 1, NULL, 1, 0, 0, 0)
SET IDENTITY_INSERT [dbo].[sdk_DefaultPlatform] OFF
SET IDENTITY_INSERT [dbo].[sdk_GameInfo] ON 

INSERT [dbo].[sdk_GameInfo] ([GameID], [GameName], [GameDisplayName], [AndroidVersionID], [IOSVersionID], [AndroidKeyID], [IOSKeyID], [GameIcon], [CreateUser], [CollectDatetime], [ModifyDatetime], [ModifyUser], [GameNameSpell], [UnityVer], [ProductName], [IsEncryption], [SDKGameID], [SDKGameKey]) VALUES (30, N'demo', N'Demo', 4017, 4015, 2014, NULL, N'/img/gameicon/20161025105502_9371.png', N'demo@typesdk.com', CAST(0x0000A66A00EAD778 AS DateTime), NULL, NULL, N'demo', N'4.7.11', N'demo', 0, N'1001', N'typesdk_app_key')
SET IDENTITY_INSERT [dbo].[sdk_GameInfo] OFF
SET IDENTITY_INSERT [dbo].[sdk_GamePlatformIcon] ON 

INSERT [dbo].[sdk_GamePlatformIcon] ([Id], [GameName], [PlatformName], [iconName], [SystemID], [UpdateDateTime]) VALUES (11631, N'30', N'10', N'demo_baidu', 1, CAST(0x0000A6A2014619BE AS DateTime))
INSERT [dbo].[sdk_GamePlatformIcon] ([Id], [GameName], [PlatformName], [iconName], [SystemID], [UpdateDateTime]) VALUES (11635, N'30', N'9', N'demo', 1, CAST(0x0000A6A40160B7E1 AS DateTime))
INSERT [dbo].[sdk_GamePlatformIcon] ([Id], [GameName], [PlatformName], [iconName], [SystemID], [UpdateDateTime]) VALUES (11640, N'30', N'8', N'demo_uc', 1, CAST(0x0000A6AB01156BCC AS DateTime))
INSERT [dbo].[sdk_GamePlatformIcon] ([Id], [GameName], [PlatformName], [iconName], [SystemID], [UpdateDateTime]) VALUES (11641, N'30', N'6', N'demo', 1, CAST(0x0000A6AB0118F008 AS DateTime))
INSERT [dbo].[sdk_GamePlatformIcon] ([Id], [GameName], [PlatformName], [iconName], [SystemID], [UpdateDateTime]) VALUES (11642, N'30', N'7', N'demo_downjoy', 1, CAST(0x0000A6AB011C2606 AS DateTime))
INSERT [dbo].[sdk_GamePlatformIcon] ([Id], [GameName], [PlatformName], [iconName], [SystemID], [UpdateDateTime]) VALUES (11643, N'30', N'21', N'demo', 1, CAST(0x0000A6AB01249A5F AS DateTime))
INSERT [dbo].[sdk_GamePlatformIcon] ([Id], [GameName], [PlatformName], [iconName], [SystemID], [UpdateDateTime]) VALUES (11644, N'30', N'26', N'demo', 1, CAST(0x0000A6AB0124A1E5 AS DateTime))
INSERT [dbo].[sdk_GamePlatformIcon] ([Id], [GameName], [PlatformName], [iconName], [SystemID], [UpdateDateTime]) VALUES (11645, N'30', N'34', N'demo', 1, CAST(0x0000A6AB0124AABD AS DateTime))
INSERT [dbo].[sdk_GamePlatformIcon] ([Id], [GameName], [PlatformName], [iconName], [SystemID], [UpdateDateTime]) VALUES (11646, N'30', N'36', N'demo', 1, CAST(0x0000A6AB0124B451 AS DateTime))
INSERT [dbo].[sdk_GamePlatformIcon] ([Id], [GameName], [PlatformName], [iconName], [SystemID], [UpdateDateTime]) VALUES (12639, N'30', N'5', N'demo', 1, CAST(0x0000A6AC00BC0766 AS DateTime))
SET IDENTITY_INSERT [dbo].[sdk_GamePlatformIcon] OFF
INSERT [dbo].[sdk_GamePlatFromInfo] ([GameID], [VersionPlatFromID], [SignatureKeyID], [SystemID], [VersionID], [PlugInID], [PlugInVersion], [SelectID]) VALUES (30, 5, 2014, 1, 9218, 0, N'', N'5_0')
INSERT [dbo].[sdk_GamePlatFromInfo] ([GameID], [VersionPlatFromID], [SignatureKeyID], [SystemID], [VersionID], [PlugInID], [PlugInVersion], [SelectID]) VALUES (30, 6, 2014, 1, 6233, 0, N'', N'6_0')
INSERT [dbo].[sdk_GamePlatFromInfo] ([GameID], [VersionPlatFromID], [SignatureKeyID], [SystemID], [VersionID], [PlugInID], [PlugInVersion], [SelectID]) VALUES (30, 7, 2014, 1, 9223, 0, N'', N'7_0')
INSERT [dbo].[sdk_GamePlatFromInfo] ([GameID], [VersionPlatFromID], [SignatureKeyID], [SystemID], [VersionID], [PlugInID], [PlugInVersion], [SelectID]) VALUES (30, 8, 2014, 1, 9220, 0, N'', N'8_0')
INSERT [dbo].[sdk_GamePlatFromInfo] ([GameID], [VersionPlatFromID], [SignatureKeyID], [SystemID], [VersionID], [PlugInID], [PlugInVersion], [SelectID]) VALUES (30, 9, 2014, 1, 7215, 0, N'', N'9_0')
INSERT [dbo].[sdk_GamePlatFromInfo] ([GameID], [VersionPlatFromID], [SignatureKeyID], [SystemID], [VersionID], [PlugInID], [PlugInVersion], [SelectID]) VALUES (30, 10, 2014, 1, 9219, 0, N'', N'10_0')
INSERT [dbo].[sdk_GamePlatFromInfo] ([GameID], [VersionPlatFromID], [SignatureKeyID], [SystemID], [VersionID], [PlugInID], [PlugInVersion], [SelectID]) VALUES (30, 21, 2014, 1, 9225, 0, N'', N'21_0')
INSERT [dbo].[sdk_GamePlatFromInfo] ([GameID], [VersionPlatFromID], [SignatureKeyID], [SystemID], [VersionID], [PlugInID], [PlugInVersion], [SelectID]) VALUES (30, 26, 2014, 1, 5210, 0, N'', N'26_0')
INSERT [dbo].[sdk_GamePlatFromInfo] ([GameID], [VersionPlatFromID], [SignatureKeyID], [SystemID], [VersionID], [PlugInID], [PlugInVersion], [SelectID]) VALUES (30, 34, 2014, 1, 9224, 0, N'', N'34_0')
INSERT [dbo].[sdk_GamePlatFromInfo] ([GameID], [VersionPlatFromID], [SignatureKeyID], [SystemID], [VersionID], [PlugInID], [PlugInVersion], [SelectID]) VALUES (30, 36, 2014, 1, 7226, 0, N'', N'36_0')
INSERT [dbo].[sdk_GamePlatFromInfo] ([GameID], [VersionPlatFromID], [SignatureKeyID], [SystemID], [VersionID], [PlugInID], [PlugInVersion], [SelectID]) VALUES (30, 38, 2014, 1, 5204, 0, N'', N'38_0')
SET IDENTITY_INSERT [dbo].[sdk_icon] ON 

INSERT [dbo].[sdk_icon] ([Id], [iconName], [SystemID], [GameID]) VALUES (1, N'white', NULL, NULL)
INSERT [dbo].[sdk_icon] ([Id], [iconName], [SystemID], [GameID]) VALUES (12373, N'demo', 1, 30)
INSERT [dbo].[sdk_icon] ([Id], [iconName], [SystemID], [GameID]) VALUES (12380, N'demo_baidu', 1, 30)
INSERT [dbo].[sdk_icon] ([Id], [iconName], [SystemID], [GameID]) VALUES (12381, N'demo_uc', 1, 30)
INSERT [dbo].[sdk_icon] ([Id], [iconName], [SystemID], [GameID]) VALUES (12382, N'demo_downjoy', 1, 30)
SET IDENTITY_INSERT [dbo].[sdk_icon] OFF
SET IDENTITY_INSERT [dbo].[sdk_Platform] ON 

INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8392, 5, N'9227', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8393, 6, N'6233', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8394, 8, N'9220', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8395, 9, N'7215', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8396, 10, N'9219', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8397, 21, N'9225', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8399, 26, N'5210', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8400, 34, N'9224', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8402, 1049, N'8', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8403, 1050, N'0', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8404, 1067, N'54', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8405, 2070, N'1057', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8406, 2071, N'1058', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8407, 2072, N'1059', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8408, 2073, N'1060', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8409, 2074, N'1061', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8410, 2075, N'1062', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8411, 2076, N'1063', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8412, 2077, N'1064', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8413, 2078, N'1065', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8414, 2082, N'4191', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8415, 2083, N'1076', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8416, 2084, N'1077', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8417, 2085, N'1078', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8418, 2086, N'1079', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8419, 2087, N'1080', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8420, 2088, N'1081', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8421, 2090, N'1087', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8422, 2091, N'1088', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8423, 2092, N'1089', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8424, 2093, N'1090', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8425, 2094, N'1091', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8426, 2095, N'1092', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8427, 2096, N'1093', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8428, 2097, N'1094', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8429, 2098, N'1095', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8430, 2099, N'1096', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8431, 2100, N'1097', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8432, 2101, N'1098', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8433, 2102, N'1099', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8435, 2104, N'1105', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8436, 4117, N'4189', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8437, 4119, N'4194', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8438, 4120, N'4195', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8439, 4122, N'4202', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8440, 4123, N'4203', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8441, 7, N'9226', N'4017', 1)
INSERT [dbo].[sdk_Platform] ([Id], [PlatformID], [SdkVersion], [MyVersionID], [SystemID]) VALUES (8442, 36, N'7226', N'4017', 1)
SET IDENTITY_INSERT [dbo].[sdk_Platform] OFF
SET IDENTITY_INSERT [dbo].[sdk_PlatformAndroidManifest] ON 

INSERT [dbo].[sdk_PlatformAndroidManifest] ([Id], [PlatformName], [ConfigKey], [ConfigContent]) VALUES (1, N'360', N'<!--application_sdk-->', N'<!-- 添加360SDK必需的activity：com.qihoopay.insdk.activity.ContainerActivity -->
        <activity
            android:name="com.qihoo.gamecenter.sdk.activity.ContainerActivity"
            android:configChanges="fontScale|orientation|keyboardHidden|locale|navigation|screenSize|uiMode"
            android:theme="@android:style/Theme.Translucent.NoTitleBar"
            android:exported="true" >
        </activity>

        <!-- payment activities begin -->
        <!-- 添加360SDK必需的activity：com.qihoopp.qcoinpay.QcoinActivity -->
        <activity
            android:name="com.qihoopp.qcoinpay.QcoinActivity"
            android:configChanges="fontScale|orientation|keyboardHidden|locale|navigation|screenSize|uiMode"
            android:theme="@android:style/Theme.Translucent.NoTitleBar"
            android:windowSoftInputMode="stateAlwaysHidden|adjustResize" >
        </activity>

        <!-- alipay sdk begin -->
        <activity
            android:name="com.alipay.sdk.app.H5PayActivity"
            android:screenOrientation="sensorLandscape" >
        </activity>
        <!-- alipay sdk end -->


        <!-- payment activities end -->

        <meta-data
            android:name="QHOPENSDK_APPKEY"
            android:value="@app_key@" >
        </meta-data>
        <meta-data
            android:name="QHOPENSDK_PRIVATEKEY"
            android:value="@private_key@" >
        </meta-data>
        <meta-data
            android:name="QHOPENSDK_APPID"
            android:value="@app_id@" >
        </meta-data>

        <!-- 如下是360游戏实时推送SDK必要声明，不可修改 -->
        <receiver
            android:name="com.qihoo.psdk.local.QBootReceiver"
            android:permission="android.permission.RECEIVE_BOOT_COMPLETED" >
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
            <intent-filter>
                <action android:name="android.net.conn.CONNECTIVITY_CHANGE" />
            </intent-filter>
        </receiver>

        <activity
            android:name="com.qihoo.psdk.app.QStatActivity"
            android:launchMode="singleInstance"
            android:theme="@android:style/Theme.Translucent.NoTitleBar" >
        </activity>

        <service
            android:name="com.qihoo.psdk.remote.QRemoteService"
            android:exported="true"
            android:process=":QRemote" >
            <intent-filter>
                <action android:name="com.qihoo.psdk.service.action.remote" />
            </intent-filter>
        </service>
        <service
            android:name="com.qihoo.psdk.local.QLocalService"
            android:exported="true"
            android:process=":QLocal" >
            <intent-filter>
                <action android:name="com.qihoo.psdk.service.action.local" />
            </intent-filter>
        </service>
        <!-- 推送SDK end -->


        <!-- 微信SDK -->
        <!-- 微信相关的activity，如果游戏接入微信分享需要在游戏工程内实现这个activity，请直接使用demo中的代码实现，并放在游戏的工程的对应路径下。 -->
        <!-- <activity
            android:name="com.shark.sdk.android.qihoo.WXEntryActivity"
            android:exported="true"
            android:label="@string/app_name"
            android:theme="@android:style/Theme.Translucent.NoTitleBar" />

                         从微信开放平台申请的appid，游戏需要去申请自己的appid
        <meta-data
            android:name="QHOPENSDK_WEIXIN_APPID"
            android:value="wx02faa6a503e262e5" >
        </meta-data> -->
        <!-- 微信SDK end -->')
INSERT [dbo].[sdk_PlatformAndroidManifest] ([Id], [PlatformName], [ConfigKey], [ConfigContent]) VALUES (2, N'360', N'<!--manifest_sdk-->', N'<!-- 添加360SDK必需要的权限。 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.SEND_SMS" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.READ_SMS" />
    <uses-permission android:name="android.permission.WRITE_SMS" />

    <!-- payment -->
    <uses-permission android:name="android.permission.GET_TASKS" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.RECEIVE_SMS" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.RESTART_PACKAGES" />
    <!-- float sdk -->
    <uses-permission android:name="android.permission.MOUNT_UNMOUNT_FILESYSTEMS" />
    <uses-permission android:name="android.permission.VIBRATE" />

    <!-- weixin -->
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    
    <uses-permission android:name="android.permission.WAKE_LOCK" />')
SET IDENTITY_INSERT [dbo].[sdk_PlatformAndroidManifest] OFF
SET IDENTITY_INSERT [dbo].[sdk_PlatformConfig] ON 

INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14293, N'30', N'8', N'app_id', N'渠道GAMEID', N'[your app id]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14294, N'30', N'8', N'app_key', N'渠道APIKEY', N'[your app key]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14295, N'30', N'8', N'check_update_url', N'包更新功能接口地址，修改为包更新服务器地址，详见服务器相关文档。', N'http://[check.update.url]:[port]/[cp_id]/[api]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14296, N'30', N'8', N'cp_id', N'TypeSDK的cpid，可理解为游戏ID，请修改为与服务端redis的gameid相同id', N'1001', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14297, N'30', N'8', N'minSdkVersion', N'最小兼容android版本，修改可能造成代码无法使用', N'14', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14298, N'30', N'8', N'package', N'包名，需修改为发布的app包名', N'[package.name.at.channel]', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14299, N'30', N'8', N'pay_call_back_url', N'UC渠道SDK的DEBUG模式使用客户端支付回调', N'http://[sdk.server.url]/[cp_id]/[channel_id]/Pay', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14300, N'30', N'8', N'platform', N'游戏开发平台unity或android', N'unity', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14303, N'30', N'8', N'sdk_cp_id', N'UC提供的CPID', N'[cp id at channel]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14304, N'30', N'8', N'sdk_name', N'Typesdk渠道名称请勿改动', N'UC', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14305, N'30', N'8', N'sdk_request_and_support', N'自定义flag，说明当前sdk需要支持功能模块', N'support_exit_window', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14307, N'30', N'8', N'SignatureKey', NULL, N'typesdk', 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14308, N'30', N'8', N'targetSdkVersion', N'编译Android SDK版本', N'21', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14309, N'30', N'8', N'switchconfig_url', N'应用功能开关配置文件URL，开关文件建议发布至CDN，这里填写客户端开关文件下载地址', N'http://[config.download.url]:[prot]/getConfig/[cp_id]/[channel_id]/config.txt', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14311, N'30', N'8', N'channel_id', N'Typesdk渠道ID请勿改动', N'1', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14312, N'30', N'8', N'channelName', N'启动项所在包名的渠道名称，请勿改动', N'uc', 1, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14333, N'30', N'5', N'app_id', N'请填入360SDK APPID，已斜杠开头用来解决自动转换为数字类型问题', N'[your app id]', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14334, N'30', N'5', N'app_key', N'请填入360SDK APPKEY', N'[your app key]', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14335, N'30', N'5', N'check_update_url', N'包更新功能接口地址，修改为包更新服务器地址，详见服务器相关文档。', N'http://[check.update.url]:[port]/[cp_id]/[api]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14336, N'30', N'5', N'cp_id', N'TypeSDK的cpid，可理解为游戏ID，请修改为与服务端redis的gameid相同id', N'1001', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14337, N'30', N'5', N'minSdkVersion', N'最小兼容android版本，修改可能造成代码无法使用', N'14', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14338, N'30', N'5', N'package', N'包名，需修改为发布的app包名，已.qh360结尾', N'[package.name.at.channel]', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14339, N'30', N'5', N'pay_call_back_url', N'360渠道需要在客户端定义支付回调地址，修改为SDK服务端360回调URL。', N'http://[sdk.server.url]/[cp_id]/[channel_id]/Pay', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14340, N'30', N'5', N'platform', N'游戏开发平台unity或android', N'unity', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14344, N'30', N'5', N'sdk_name', N'Typesdk渠道名称请勿改动', N'360', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14345, N'30', N'5', N'sdk_request_and_support', N'渠道sdk需要支持功能模块,请勿改动,详细请参考客户端文档', N'support_exit_window', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14346, N'30', N'5', N'secret_key', N'填写360渠道提供的 App-Secret', N'[your secret key]', 0, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14347, N'30', N'5', N'SignatureKey', N'自定义签名密钥，需要和签名管理内的密钥名称一至', N'typesdk', 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14348, N'30', N'5', N'targetSdkVersion', N'		编译Android SDK版本', N'21', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14349, N'30', N'5', N'channel_id', N'Typesdk渠道ID请勿改动', N'3', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14350, N'30', N'5', N'channelName', N'启动项所在包名的渠道名称，请勿改动', N'qihoo', 1, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14354, N'30', N'5', N'switchconfig_url', N'应用功能开关配置文件URL，开关文件建议发布至CDN，这里填写客户端开关文件下载地址。', N'http://[config.download.url]:[prot]/getConfig/[cp_id]/[channel_id]/config.txt', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14355, N'30', N'26', N'app_id', N'渠道app id 斜杠用来解决被值被自动转换为数字问题', N'[your app id]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14356, N'30', N'26', N'app_key', N'	渠道appKey', N'[your app key]', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14357, N'30', N'26', N'check_update_url', N'包更新功能接口地址，修改为包更新服务器地址，详见服务器相关文档', N'http://[check.update.url]:[port]/[cp_id]/[api]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14358, N'30', N'26', N'cp_id', N'	TypeSDK的cpid，可理解为游戏ID，请修改为与服务端redis的gameid相同id', N'1001', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14359, N'30', N'26', N'minSdkVersion', N'	最小兼容android版本，修改可能造成代码无法使用', N'14', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14360, N'30', N'26', N'package', N'	包名，需修改为发布的app包名', N'[package.name.at.channel]', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14361, N'30', N'26', N'pay_call_back_url', N'客户端定义支付回调地址，部分渠道需要创建订单时候提交。', N'http://[sdk.server.url]/[cp_id]/[channel_id]/Pay', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14362, N'30', N'26', N'platform', N'	游戏开发平台unity或android', N'unity', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14366, N'30', N'26', N'sdk_name', N'	Typesdk渠道名称请勿改动', N'Oppo', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14367, N'30', N'26', N'sdk_request_and_support', N'渠道sdk需要支持功能模块,请勿改动,详细请参考客户端文档', N'support_exit_window', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14368, N'30', N'26', N'secret_key', N'渠道appsecret', N'[your secret key]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14369, N'30', N'26', N'SignatureKey', N'自定义签名密钥，需要和签名管理内的密钥名称一至', N'typesdk', 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14370, N'30', N'26', N'targetSdkVersion', N'	编译Android SDK版本', N'21', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14371, N'30', N'26', N'channel_id', N'	Typesdk渠道ID请勿改动', N'10', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14372, N'30', N'26', N'channelName', N'	启动项所在包名的渠道名称，请勿改动', N'oppo', 1, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14375, N'30', N'26', N'switchconfig_url', N'应用功能开关配置文件URL，开关文件建议发布至CDN，这里填写客户端开关文件下载地址', N'http://[config.download.url]:[prot]/getConfig/[cp_id]/[channel_id]/config.txt', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14378, N'30', N'10', N'app_id', N'渠道app id 斜杠用来解决被值被自动转换为数字问题', N'[your app id]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14379, N'30', N'10', N'app_key', N'渠道ProductKey', N'[your app key]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14380, N'30', N'10', N'check_update_url', N'包更新功能接口地址，修改为包更新服务器地址，详见服务器相关文档', N'http://[check.update.url]:[port]/[cp_id]/[api]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14381, N'30', N'10', N'cp_id', N'	TypeSDK的cpid，可理解为游戏ID，请修改为与服务端redis的gameid相同id', N'1001', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14382, N'30', N'10', N'minSdkVersion', N'	最小兼容android版本，修改可能造成代码无法使用', N'14', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14383, N'30', N'10', N'package', N'包名，需修改为发布的app包名', N'[package.name.at.channel]', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14385, N'30', N'10', N'platform', N'	游戏开发平台unity或android', N'unity', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14389, N'30', N'10', N'sdk_name', N'	Typesdk渠道名称请勿改动', N'Baidu', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14390, N'30', N'10', N'sdk_request_and_support', N'	渠道sdk需要支持功能模块,请勿改动,详细请参考客户端文档', N'support_exit_window', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14391, N'30', N'10', N'secret_key', N'渠道ProductSecret', N'[your secret key]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14392, N'30', N'10', N'SignatureKey', N'自定义签名密钥，需要和签名管理内的密钥名称一至', N'typesdk', 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14393, N'30', N'10', N'targetSdkVersion', N'编译版本', N'21', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14394, N'30', N'10', N'channel_id', N'	Typesdk渠道ID请勿改动', N'5', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14395, N'30', N'10', N'channelName', N'	启动项所在包名的渠道名称，请勿改动', N'baidu', 1, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14399, N'30', N'10', N'switchconfig_url', N'应用功能开关配置文件URL，开关文件建议发布至CDN，这里填写客户端开关文件下载地址', N'http://[config.download.url]:[prot]/getConfig/[cp_id]/[channel_id]/config.txt', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14400, N'30', N'34', N'app_id', N'	渠道app id 斜杠用来解决被值被自动转换为数字问题', N'[your app id]', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14401, N'30', N'34', N'app_key', N'渠道cpkey', N'[your app key]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14402, N'30', N'34', N'check_update_url', N'	包更新功能接口地址，修改为包更新服务器地址，详见服务器相关文档', N'http://[check.update.url]:[port]/[cp_id]/[api]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14403, N'30', N'34', N'cp_id', N'	TypeSDK的cpid，可理解为游戏ID，请修改为与服务端redis的gameid相同id', N'1001', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14404, N'30', N'34', N'minSdkVersion', N'最小兼容android版本，修改可能造成代码无法使用', N'14', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14405, N'30', N'34', N'package', N'	包名，需修改为发布的app包名', N'[package.name.at.channel]', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14407, N'30', N'34', N'platform', N'	游戏开发平台unity或android', N'unity', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14411, N'30', N'34', N'sdk_name', N'Typesdk渠道名称请勿改动', N'Vivo', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14412, N'30', N'34', N'sdk_request_and_support', N'	渠道sdk需要支持功能模块,请勿改动,详细请参考客户端文档', NULL, 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14413, N'30', N'34', N'secret_key', N'渠道secret key', N'[your secret key]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14414, N'30', N'34', N'SignatureKey', N'自定义签名密钥，需要和签名管理内的密钥名称一至', N'typesdk', 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14415, N'30', N'34', N'targetSdkVersion', N'	编译Android SDK版本', N'21', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14416, N'30', N'34', N'channel_id', N'	Typesdk渠道ID请勿改动', N'14', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14417, N'30', N'34', N'url', N'获取密钥接口URL', N'http://[sdk.server.url]:[port]/[cp_id]/14/CreateChannelOrder', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14418, N'30', N'34', N'channelName', N'	启动项所在包名的渠道名称，请勿改动', N'vivo', 1, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14421, N'30', N'34', N'wx_path', N'渠道微信支付', N'.', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14422, N'30', N'34', N'switchconfig_url', N'	应用功能开关配置文件URL，开关文件建议发布至CDN，这里填写客户端开关文件下载地址', N'http://[config.download.url]:[prot]/getConfig/[cp_id]/[channel_id]/config.txt', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14424, N'30', N'9', N'app_id', N'渠道app id 斜杠用来解决被值被自动转换为数字问题', N'[your app id]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14425, N'30', N'9', N'app_key', N'渠道app key', N'[your app key]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14426, N'30', N'9', N'check_update_url', N'包更新功能接口地址，修改为包更新服务器地址，详见服务器相关文档', N'http://[check.update.url]:[port]/[cp_id]/[api]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14427, N'30', N'9', N'cp_id', N'TypeSDK的cpid，可理解为游戏ID，请修改为与服务端redis的gameid相同id', N'1001', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14428, N'30', N'9', N'minSdkVersion', N'	最小兼容android版本，修改可能造成代码无法使用', N'14', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14429, N'30', N'9', N'package', N'	包名，需修改为发布的app包名', N'[package.name.at.channel]', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14431, N'30', N'9', N'platform', N'	游戏开发平台unity或android', N'unity', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14435, N'30', N'9', N'sdk_name', N'	Typesdk渠道名称请勿改动', N'XiaoMi', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14436, N'30', N'9', N'sdk_request_and_support', N'	渠道sdk需要支持功能模块,请勿改动,详细请参考客户端文档', NULL, 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14437, N'30', N'9', N'secret_key', N'渠道appsecret', N'[your secret key]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14438, N'30', N'9', N'SignatureKey', N'自定义签名密钥，需要和签名管理内的密钥名称一至', N'typesdk', 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14439, N'30', N'9', N'targetSdkVersion', N'编译Android SDK版本', N'21', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14440, N'30', N'9', N'channel_id', N'Typesdk渠道ID请勿改动', N'7', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14441, N'30', N'9', N'channelName', N'启动项所在包名的渠道名称，请勿改动', N'xiaomi', 1, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14444, N'30', N'9', N'switchconfig_url', N'	应用功能开关配置文件URL，开关文件建议发布至CDN，这里填写客户端开关文件下载地址', N'http://[config.download.url]:[prot]/getConfig/[cp_id]/[channel_id]/config.txt', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14446, N'30', N'21', N'app_id', N'	渠道app id 斜杠用来解决被值被自动转换为数字问题', N'[your app id]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14447, N'30', N'21', N'app_key', N'渠道buoyKey', N'[your app key]', 0, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14448, N'30', N'21', N'check_update_url', N'包更新功能接口地址，修改为包更新服务器地址，详见服务器相关文档', N'http://[check.update.url]:[port]/[cp_id]/[api]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14449, N'30', N'21', N'cp_id', N'TypeSDK的cpid，可理解为游戏ID，请修改为与服务端redis的gameid相同id', N'1001', 1, 0, 0, N'0')
GO
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14450, N'30', N'21', N'minSdkVersion', N'	最小兼容android版本，修改可能造成代码无法使用', N'14', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14451, N'30', N'21', N'package', N'	包名，需修改为发布的app包名', N'[package.name.at.channel]', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14453, N'30', N'21', N'platform', N'	游戏开发平台unity或android', N'unity', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14456, N'30', N'21', N'sdk_cp_id', N'自定义cp id，多cp时可选', N'[cp id at channel]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14457, N'30', N'21', N'sdk_name', N'	Typesdk渠道名称请勿改动', N'HuaWei', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14458, N'30', N'21', N'sdk_request_and_support', N'	渠道sdk需要支持功能模块,请勿改动,详细请参考客户端文档', NULL, 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14460, N'30', N'21', N'SignatureKey', N'自定义签名密钥，需要和签名管理内的密钥名称一至', N'typesdk', 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14461, N'30', N'21', N'targetSdkVersion', N'编译Android SDK版本', N'21', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14462, N'30', N'21', N'channel_id', N'	Typesdk渠道ID请勿改动', N'9', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14464, N'30', N'21', N'channelName', N'	启动项所在包名的渠道名称，请勿改动', N'huawei', 1, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14468, N'30', N'21', N'switchconfig_url', N'应用功能开关配置文件URL，开关文件建议发布至CDN，这里填写客户端开关文件下载地址', N'http://[config.download.url]:[prot]/getConfig/[cp_id]/[channel_id]/config.txt', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14535, N'30', N'5', N'private_key', N'请填入360SDK PRIVATEKEY，算法为： QHOPENSDK_PRIVATEKEY = MD5 (appSecret + "#" appKey) ，32 位小', N'[your private key]', 0, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14742, N'30', N'6', N'app_id', N'渠道APPID,斜杠用来解决被值被自动转换为数字问题', N'[your app id]', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14743, N'30', N'6', N'app_key', N'渠道publicKey', N'[your app key]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14744, N'30', N'6', N'channel_id', N'Typesdk渠道ID请勿改动', N'22', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14745, N'30', N'6', N'channelName', N'	启动项所在包名的渠道名称，请勿改动', N'wdj', 1, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14746, N'30', N'6', N'check_update_url', N'包更新功能接口地址，修改为包更新服务器地址，详见服务器相关文档。', N'http://[check.update.url]:[port]/[cp_id]/[api]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14747, N'30', N'6', N'cp_id', N'TypeSDK的cpid，可理解为游戏ID，请修改为与服务端redis的gameid相同id', N'1001', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14748, N'30', N'6', N'minSdkVersion', N'最小兼容android版本，修改可能造成代码无法使用', N'14', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14749, N'30', N'6', N'package', N'	包名，需修改为发布的app包名', N'[package.name.at.channel]', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14751, N'30', N'6', N'platform', N'	游戏开发平台unity或android', N'unity', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14755, N'30', N'6', N'sdk_name', N'Typesdk渠道名称请勿改动', N'WanDouJia', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14756, N'30', N'6', N'sdk_request_and_support', N'渠道sdk需要支持功能模块,请勿改动,详细请参考客户端文档', NULL, 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14757, N'30', N'6', N'secret_key', N'渠道提供的secretkey', N'[your secret key]', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14758, N'30', N'6', N'SignatureKey', N'自定义签名密钥，需要和签名管理内的密钥名称一至', N'typesdk', 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14759, N'30', N'6', N'switchconfig_url', N'应用功能开关配置文件URL，开关文件建议发布至CDN，这里填写客户端开关文件下载地址', N'http://[config.download.url]:[prot]/getConfig/[cp_id]/[channel_id]/config.txt', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14760, N'30', N'6', N'targetSdkVersion', N'	编译Android SDK版本', N'21', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14769, N'30', N'7', N'app_id', N'请填入当乐提供的 应用ID（APP_ID）', N'[your app id]', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14770, N'30', N'7', N'app_key', N'请填入当乐提供的 应用密钥（APP_KEY）', N'[your app key]', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14771, N'30', N'7', N'channel_id', N'渠道ID，请勿改动', N'47', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14772, N'30', N'7', N'channelName', N'启动项所在包名的渠道名称，请勿改动', N'downjoy', 1, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14773, N'30', N'7', N'check_update_url', N'包更新功能接口地址，修改为包更新服务器地址，详见服务器相关文档。', N'http://[check.update.url]:[port]/[cp_id]/[api]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14774, N'30', N'7', N'cp_id', N'渠道cp id，可理解为游戏ID，请修改为自定义ID', N'1001', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14775, N'30', N'7', N'minSdkVersion', N'最小兼容android版本，修改可能造成代码无法使用', N'14', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14776, N'30', N'7', N'package', N'包名，需修改为发布的app包名', N'[package.name.at.channel]', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14778, N'30', N'7', N'platform', N'游戏开发平台unity、android、ios，请勿修改', N'unity', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14779, N'30', N'7', N'product_id', N'请填入当乐提供的厂商ID(MERCHANT_ID)', N'[your product id]', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14782, N'30', N'7', N'sdk_name', N'自定义渠道id，需要和服务端配置一致', N'DangLe', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14783, N'30', N'7', N'sdk_request_and_support', N'自定义flag，通知游戏此渠道支持渠道退出弹窗，需屏蔽游戏自身退出弹窗', N'support_exit_window', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14784, N'30', N'7', N'secret_key', N'请填入当乐提供的支付密钥(PAYMENT_KEY)', N'[your secret key]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14785, N'30', N'7', N'SignatureKey', N'自定义签名密钥，需要和签名管理内的密钥名称一至', N'typesdk', 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14786, N'30', N'7', N'switchconfig_url', N'app功能开关配置文件URL，开关文件建议发布至CDN，这里填写开关文件下载地址。', N'http://[config.download.url]:[prot]/getConfig/[cp_id]/[channel_id]/config.txt', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (14787, N'30', N'7', N'targetSdkVersion', N'编译Android SDK版本', N'21', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15198, N'30', N'5', NULL, NULL, NULL, 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15199, N'30', N'5', NULL, NULL, NULL, 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15200, N'30', N'5', NULL, NULL, NULL, 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15201, N'30', N'5', NULL, NULL, NULL, 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15202, N'30', N'36', N'app_id', N'渠道app id 斜杠用来解决被值被自动转换为数字问题', N'[your app id]', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15203, N'30', N'36', N'app_key', N'渠道app key', N'[your app key]', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15204, N'30', N'36', N'channel_id', N'	Typesdk渠道ID请勿改动', N'6', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15205, N'30', N'36', N'channelName', N'	启动项所在包名的渠道名称，请勿改动', N'youku', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15206, N'30', N'36', N'check_update_url', N'包更新功能接口地址，修改为包更新服务器地址，详见服务器相关文档。', N'http://[check.update.url]:[port]/[cp_id]/[api]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15207, N'30', N'36', N'cp_id', N'TypeSDK的cpid，可理解为游戏ID，请修改为与服务端redis的gameid相同id', N'1001', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15208, N'30', N'36', N'minSdkVersion', N'	最小兼容android版本，修改可能造成代码无法使用', N'14', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15209, N'30', N'36', N'package', N'包名', N'[package.name.at.channel]', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15210, N'30', N'36', N'pay_call_back_url', N' 客户端定义支付回调地址，修改为SDK服务端360回调URL', N'http://[sdk.server.url]/[cp_id]/[channel_id]/Pay', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15211, N'30', N'36', N'platform', N'	游戏开发平台unity或android', N'unity', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15212, N'30', N'36', N'private_key', N'渠道paykey', N'[your private key]', 0, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15216, N'30', N'36', N'sdk_name', N'	Typesdk渠道名称请勿改动', N'YouKu', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15217, N'30', N'36', N'sdk_request_and_support', N'	渠道sdk需要支持功能模块,请勿改动,详细请参考客户端文档', NULL, 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15218, N'30', N'36', N'secret_key', N'渠道AppSecret', N'[your secret key]', 1, 1, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15219, N'30', N'36', N'SignatureKey', N'自定义签名密钥，需要和签名管理内的密钥名称一至', N'typesdk', 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15220, N'30', N'36', N'switchconfig_url', N'应用功能开关配置文件URL，开关文件建议发布至CDN，这里填写客户端开关文件下载地址', N'http://[config.download.url]:[prot]/getConfig/[cp_id]/[channel_id]/config.txt', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15221, N'30', N'36', N'targetSdkVersion', N'编译Android SDK版本', N'21', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15222, N'30', N'8', N'CPID', N'渠道CPID', N'[your cp id at channel]', 0, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15223, N'29', N'21', N'app_id', N'渠道app id', N'[your app id]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15224, N'29', N'21', N'app_key', N'渠道app key', N'[your app key]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15225, N'29', N'21', N'channel_id', N'渠道id', NULL, 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15226, N'29', N'21', N'channelName', N'启动项所在包名的渠道名称', NULL, 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15227, N'29', N'21', N'check_update_url', N'包更新功能接口地址', N'http://[check.update.url]:[port]/[cp_id]/[api]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15228, N'29', N'21', N'cp_id', N'渠道cp id', NULL, 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15229, N'29', N'21', N'minSdkVersion', N'最小兼容android版本', NULL, 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15230, N'29', N'21', N'package', N'包名', N'[package.name.at.channel]', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15231, N'29', N'21', N'pay_call_back_url', N'客户端定义支付回调地址，部分渠道需要创建订单时候提交。', N'http://[sdk.server.url]/[cp_id]/[channel_id]/Pay', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15232, N'29', N'21', N'platform', N'ios、android', NULL, 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15233, N'29', N'21', N'private_key', N'私钥', N'[your private key]', 0, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15234, N'29', N'21', N'product_id', N'渠道 product id', N'[your product id]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15235, N'29', N'21', N'product_key', N'渠道 product key', NULL, 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15236, N'29', N'21', N'sdk_cp_id', N'自定义cp id，多cp时可选', N'[cp id at channel]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15237, N'29', N'21', N'sdk_name', N'自定义渠道id，需要和服务端配置一致', NULL, 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15238, N'29', N'21', N'sdk_request_and_support', N'自定义flag，说明当前sdk需要支持功能模块', NULL, 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15239, N'29', N'21', N'SDKKey', N'Explain', N'StringValue', 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15240, N'29', N'21', N'secret_key', N'渠道secret key', N'[your secret key]', 1, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15241, N'29', N'21', N'SignatureKey', N'自定义签名密钥，需要和签名管理内的密钥名称一至', NULL, 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15242, N'29', N'21', N'switchconfig_url', N'开关配置文件地址', N'http://[config.download.url]:[prot]/getConfig/[cp_id]/[channel_id]/config.txt', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15243, N'29', N'21', N'targetSdkVersion', N'编译版本', NULL, 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15244, N'30', N'21', N'product_key', N'渠道pubPayKey', N'[your public pay key]', 0, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15245, N'30', N'21', N'secret_key', N'渠道priPayKey', N'[your secret key]', 0, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15246, N'30', N'21', N'PublicKey', N'登入公钥', N'[your public key]', 0, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15247, N'30', N'21', N'CPID', N'渠道CPID', N'[your cp id at channel]', 0, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15248, N'30', N'26', N'product_key', N'渠道publicKey', N'[your public key]', 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15249, N'30', N'34', N'sdk_cp_id', N'渠道CPID', N'[cp id at channel]', 0, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15250, N'30', N'36', NULL, NULL, NULL, 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (15251, N'30', N'36', N'wx_path', N'微信路径', N'.', 0, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (16223, N'30', N'7', N'sdk_cp_id', N'当乐的厂商id', N'[cp id at channel]', 1, 1, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (16224, N'30', N'21', N'huawei_key_url', N'华为获取密钥接口URL', N'http://[sdk.server.url]/[cp_id]/9/CreateChannelOrder', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (16225, N'30', N'34', N'pay_call_back_url', N'Vivo渠道需要在客户端定义支付回调地址，修改为SDK服务端Vivo回调URL。', N'http://[sdk.server.url]/[cp_id]/[channel_id]/Pay', 0, 0, 1, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (16226, N'30', N'21', NULL, NULL, NULL, 0, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (16227, N'30', N'21', N'pay_call_back_url', NULL, N'http://[sdk.server.url]/[cp_id]/[channel_id]/Pay', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (16228, N'30', N'21', N'company', N'公司名称（必填）', N'[您公司中文名全称]', 1, 0, 0, N'0')
INSERT [dbo].[sdk_PlatformConfig] ([Id], [GameName], [PlatformName], [SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer], [PlugInID]) VALUES (16229, N'30', N'34', N'package_path', N'将包名转换成目录格式（必填）', N'[your/package/name]', 0, 1, 0, N'0')
GO
SET IDENTITY_INSERT [dbo].[sdk_PlatformConfig] OFF
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'app_id', N'渠道app id', NULL, 1, 0, 1)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'app_key', N'渠道app key', NULL, 1, 0, 1)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'channel_id', N'渠道id', NULL, 1, 0, 1)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'channelName', N'启动项所在包名的渠道名称', NULL, 1, 0, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'check_update_url', N'包更新功能接口地址', NULL, 1, 0, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'cp_id', N'渠道cp id', NULL, 1, 0, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'minSdkVersion', N'最小兼容android版本', NULL, 0, 1, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'package', N'包名', NULL, 0, 1, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'pay_call_back_url', N'客户端定义支付回调地址，部分渠道需要创建订单时候提交。', NULL, 1, 0, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'platform', N'ios、android', NULL, 1, 0, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'private_key', N'私钥', NULL, 0, 0, 1)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'product_id', N'渠道 product id', NULL, 1, 0, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'product_key', N'渠道 product key', NULL, 1, 0, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'sdk_cp_id', N'自定义cp id，多cp时可选', NULL, 1, 0, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'sdk_name', N'自定义渠道id，需要和服务端配置一致', NULL, 1, 0, 1)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'sdk_request_and_support', N'自定义flag，说明当前sdk需要支持功能模块', NULL, 1, 0, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'SDKKey', N'Explain', N'StringValue', 0, 0, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'secret_key', N'渠道secret key', NULL, 1, 0, 1)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'SignatureKey', N'自定义签名密钥，需要和签名管理内的密钥名称一至', NULL, 0, 0, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'switchconfig_url', N'开关配置文件地址', NULL, 1, 0, 0)
INSERT [dbo].[sdk_PlatformConfigKey] ([SDKKey], [Explain], [StringValue], [isCPSetting], [isBuilding], [isServer]) VALUES (N'targetSdkVersion', N'编译版本', NULL, 0, 1, 0)
INSERT [dbo].[sdk_PlatformStatus] ([Id], [PlatformStatusName]) VALUES (1, N'已接入')
INSERT [dbo].[sdk_PlatformStatus] ([Id], [PlatformStatusName]) VALUES (2, N'接入调试')
INSERT [dbo].[sdk_PlatformStatus] ([Id], [PlatformStatusName]) VALUES (99, N'未接入')
SET IDENTITY_INSERT [dbo].[sdk_PlatformVersion] ON 

INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (5204, 38, N'4.0', N'admin@typesdk.com', CAST(0x0000A61A0125BFBC AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (5210, 26, N'2.2.0', N'admin@typesdk.com', CAST(0x0000A61A0135D5B4 AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (6233, 6, N'5.2.3', N'admin@typesdk.com', CAST(0x0000A63600BF4434 AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (7215, 9, N'4.6.11', N'admin@typesdk.com', CAST(0x0000A639011C3D84 AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (7226, 36, N'2.7.1', N'admin@typesdk.com', CAST(0x0000A63E01335FA5 AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (9216, 34, N'2.0.6', N'admin@typesdk.com', CAST(0x0000A64A00EDAFDF AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (9218, 5, N'1.3.6_492', N'admin@typesdk.com', CAST(0x0000A6A200DF7EC2 AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (9219, 10, N'3.7.2', N'admin@typesdk.com', CAST(0x0000A6A2014582FA AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (9220, 8, N'5.2.3.5', N'admin@typesdk.com', CAST(0x0000A6A3012704AF AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (9223, 7, N'4.3.1', N'admin@typesdk.com', CAST(0x0000A6AA00E91CB6 AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (9224, 34, N'2.0.9', N'admin@typesdk.com', CAST(0x0000A6AA010AC673 AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (9225, 21, N'7.1.1.301', N'admin@typesdk.com', CAST(0x0000A6AA011A679C AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (9226, 7, N'4.3.3', N'demo@typesdk.com', CAST(0x0000A6AC00B462E3 AS DateTime), 1)
INSERT [dbo].[sdk_PlatformVersion] ([ID], [PlatformID], [Version], [CreateUser], [CollectDatetime], [SystemID]) VALUES (9227, 5, N'1.3.6_496', N'demo@typesdk.com', CAST(0x0000A6AC00C368E5 AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[sdk_PlatformVersion] OFF
SET IDENTITY_INSERT [dbo].[sdk_PlugInList] ON 

INSERT [dbo].[sdk_PlugInList] ([ID], [PlugInName], [PlugInDisplayName], [CollectDatetime]) VALUES (1, N'LeBian', N'乐变', CAST(0x0000A61A01084F64 AS DateTime))
INSERT [dbo].[sdk_PlugInList] ([ID], [PlugInName], [PlugInDisplayName], [CollectDatetime]) VALUES (3, N'DataEye', N'DataEye', CAST(0x0000A6580162B094 AS DateTime))
INSERT [dbo].[sdk_PlugInList] ([ID], [PlugInName], [PlugInDisplayName], [CollectDatetime]) VALUES (4, N'Um', N'友盟', CAST(0x0000A6580162D073 AS DateTime))
SET IDENTITY_INSERT [dbo].[sdk_PlugInList] OFF
SET IDENTITY_INSERT [dbo].[sdk_PlugInVersion] ON 

INSERT [dbo].[sdk_PlugInVersion] ([ID], [PlugInID], [PlugInVersion], [CollectDatetime]) VALUES (1, 1, N'4.8', CAST(0x0000A61A010857AB AS DateTime))
INSERT [dbo].[sdk_PlugInVersion] ([ID], [PlugInID], [PlugInVersion], [CollectDatetime]) VALUES (2, 1, N'5.2', CAST(0x0000A625011EFBBB AS DateTime))
SET IDENTITY_INSERT [dbo].[sdk_PlugInVersion] OFF
SET IDENTITY_INSERT [dbo].[sdk_SignatureKey] ON 

INSERT [dbo].[sdk_SignatureKey] ([Id], [KeyName], [KeyStore], [KeyStorePassword], [KeyAlias], [KeyAliasPassword]) VALUES (2014, N'typesdk', N'/data/typesdk/share/signkey/typesdk.keystore', N'typesdk', N'typesdk.keystore', N'typesdk')
SET IDENTITY_INSERT [dbo].[sdk_SignatureKey] OFF
SET IDENTITY_INSERT [dbo].[sdk_TypeSdkVersion] ON 

INSERT [dbo].[sdk_TypeSdkVersion] ([ID], [MyVersion], [CreateUser], [CollectDatetime], [PlatFormID]) VALUES (4015, N'1.0', N'demo@typesdk.com', CAST(0x0000A64000000000 AS DateTime), 2)
INSERT [dbo].[sdk_TypeSdkVersion] ([ID], [MyVersion], [CreateUser], [CollectDatetime], [PlatFormID]) VALUES (4017, N'2.0', N'demo@typesdk.com', CAST(0x0000A6A200E80521 AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[sdk_TypeSdkVersion] OFF
SET IDENTITY_INSERT [dbo].[sdk_UploadPackageInfo] ON 

INSERT [dbo].[sdk_UploadPackageInfo] ([ID], [GameVersion], [PageageTable], [CollectDatetime], [FileSize], [UploadUser], [GameName], [GamePlatFrom], [StrCollectDatetime], [FileName], [GameID]) VALUES (11726, N'1.0', N'typeclient012', CAST(0x0000A6AD01371460 AS DateTime), CAST(15.00 AS Decimal(18, 2)), N'demo@typesdk.com', N'demo', N'Android', N'20161029151646148', NULL, 30)
SET IDENTITY_INSERT [dbo].[sdk_UploadPackageInfo] OFF
INSERT [dbo].[server_platform] ([platformid], [platformname], [platformdisplayname], [systemid], [ver], [force], [gameVerMin], [gameVerMax], [updateURL], [ClientMD5], [ClientURL], [nullity], [collectdatetime], [createUser], [modifydatetime], [modifyUser], [synchrodata]) VALUES (1, N'UC', N'UC', 1, N'3.4.15.3', 0, 101, 105, N'http://www.123.com/', N'shabishabishabishabi', N'http://1.1.1.1/aaaa.apk', 0, CAST(0x0000A649012FB9A5 AS DateTime), N'TypeSDK@gdegame.com', CAST(0x0000A64901327487 AS DateTime), N'TypeSDK@gdegame.com', 0)
INSERT [dbo].[server_platform] ([platformid], [platformname], [platformdisplayname], [systemid], [ver], [force], [gameVerMin], [gameVerMax], [updateURL], [ClientMD5], [ClientURL], [nullity], [collectdatetime], [createUser], [modifydatetime], [modifyUser], [synchrodata]) VALUES (2, N'YingYongBao', N'应用宝', 1, N'3.4.15.3', 0, 101, 105, N'http://www.123.com/', N'shabishabishabishabi', N'http://1.1.1.1/aaaa.apk', 0, CAST(0x0000A649013305B5 AS DateTime), N'TypeSDK@gdegame.com', NULL, NULL, 0)
INSERT [dbo].[server_platform] ([platformid], [platformname], [platformdisplayname], [systemid], [ver], [force], [gameVerMin], [gameVerMax], [updateURL], [ClientMD5], [ClientURL], [nullity], [collectdatetime], [createUser], [modifydatetime], [modifyUser], [synchrodata]) VALUES (3, N'360', N'360', 1, N'3.4.15.3', 0, 101, 105, N'http://www.123.com/', N'shabishabishabishabi', N'http://1.1.1.1/aaaa.apk', 0, CAST(0x0000A64A0129065B AS DateTime), N'TypeSDK@gdegame.com', NULL, NULL, 0)
INSERT [dbo].[server_platform] ([platformid], [platformname], [platformdisplayname], [systemid], [ver], [force], [gameVerMin], [gameVerMax], [updateURL], [ClientMD5], [ClientURL], [nullity], [collectdatetime], [createUser], [modifydatetime], [modifyUser], [synchrodata]) VALUES (501, N'iOS官服', N'iOS', 2, N'3.4.15.3', 0, 101, 105, N'http://www.123.com/', N'shabishabishabishabi', N'http://1.1.1.1/aaaa.apk', 0, CAST(0x0000A65F01197388 AS DateTime), N'lujiaqi@gdegame.com', NULL, NULL, 0)
SET ANSI_PADDING ON

GO
/****** Object:  Index [RoleNameIndex]    Script Date: 2016/10/31 0:35:32 ******/
CREATE UNIQUE NONCLUSTERED INDEX [RoleNameIndex] ON [dbo].[AspNetRoles]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_UserId]    Script Date: 2016/10/31 0:35:32 ******/
CREATE NONCLUSTERED INDEX [IX_UserId] ON [dbo].[AspNetUserClaims]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_UserId]    Script Date: 2016/10/31 0:35:32 ******/
CREATE NONCLUSTERED INDEX [IX_UserId] ON [dbo].[AspNetUserLogins]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_RoleId]    Script Date: 2016/10/31 0:35:32 ******/
CREATE NONCLUSTERED INDEX [IX_RoleId] ON [dbo].[AspNetUserRoles]
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_UserId]    Script Date: 2016/10/31 0:35:32 ******/
CREATE NONCLUSTERED INDEX [IX_UserId] ON [dbo].[AspNetUserRoles]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [EmailIndex]    Script Date: 2016/10/31 0:35:32 ******/
CREATE UNIQUE NONCLUSTERED INDEX [EmailIndex] ON [dbo].[AspNetUsers]
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UserNameIndex]    Script Date: 2016/10/31 0:35:32 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex] ON [dbo].[AspNetUsers]
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20160113-151923]    Script Date: 2016/10/31 0:35:32 ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160113-151923] ON [dbo].[sdk_GamePlatFromInfo]
(
	[GameID] ASC,
	[VersionPlatFromID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [NonClusteredIndex-20160129-175717]    Script Date: 2016/10/31 0:35:32 ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160129-175717] ON [dbo].[sdk_NewPackageCreateTask]
(
	[PackageTaskID] ASC,
	[CreateUser] ASC,
	[CollectDatetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [GameNameIndex]    Script Date: 2016/10/31 0:35:32 ******/
CREATE NONCLUSTERED INDEX [GameNameIndex] ON [dbo].[sdk_PlatformConfig]
(
	[GameName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PlatformNameIndex]    Script Date: 2016/10/31 0:35:32 ******/
CREATE NONCLUSTERED INDEX [PlatformNameIndex] ON [dbo].[sdk_PlatformConfig]
(
	[PlatformName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [gamename-gameplatform]    Script Date: 2016/10/31 0:35:32 ******/
CREATE NONCLUSTERED INDEX [gamename-gameplatform] ON [dbo].[sdk_UploadPackageInfo]
(
	[GameName] ASC,
	[GamePlatFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AspNetUsers] ADD  CONSTRAINT [DF_AspNetUsers_CollectDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[delete_sdk_Games] ADD  CONSTRAINT [DF_sdk_Games_GameStatus]  DEFAULT ((1)) FOR [GameStatus]
GO
ALTER TABLE [dbo].[delete_sdk_GameVersion] ADD  CONSTRAINT [DF_sdk_GameVersion_GameVersionStatus]  DEFAULT ((1)) FOR [GameVersionStatus]
GO
ALTER TABLE [dbo].[sdk_AdPackageCreateTask] ADD  CONSTRAINT [DF_sdk_AdPackageCreateTask_PackageTaskStatus]  DEFAULT ((1)) FOR [PackageTaskStatus]
GO
ALTER TABLE [dbo].[sdk_AdPackageCreateTask] ADD  CONSTRAINT [DF_sdk_AdPackageCreateTask_CollectDatetime]  DEFAULT (getdate()) FOR [CollectDatetime]
GO
ALTER TABLE [dbo].[sdk_DefaultPlatform] ADD  CONSTRAINT [DF_sdk_DefaultPlatform_Nullity]  DEFAULT ((0)) FOR [Nullity]
GO
ALTER TABLE [dbo].[sdk_DefaultPlatform] ADD  CONSTRAINT [DF_sdk_DefaultPlatform_ParentID]  DEFAULT ((0)) FOR [ParentID]
GO
ALTER TABLE [dbo].[sdk_GameInfo] ADD  CONSTRAINT [DF_GameInfo_CollectDatetime]  DEFAULT (getdate()) FOR [CollectDatetime]
GO
ALTER TABLE [dbo].[sdk_GameInfo] ADD  CONSTRAINT [DF_sdk_GameInfo_IsEncryption]  DEFAULT ((0)) FOR [IsEncryption]
GO
ALTER TABLE [dbo].[sdk_GamePlatformIcon] ADD  CONSTRAINT [DF_sdk_GamePlatfromIcon_iconName]  DEFAULT (N'Default') FOR [iconName]
GO
ALTER TABLE [dbo].[sdk_GamePlatformIcon] ADD  CONSTRAINT [DF_sdk_GamePlatformIcon_UpdateDateTime]  DEFAULT (getdate()) FOR [UpdateDateTime]
GO
ALTER TABLE [dbo].[sdk_NewPackageCreateTask] ADD  CONSTRAINT [DF_sdk_NewPackageCreateTask_CollectDatetime]  DEFAULT (getdate()) FOR [CollectDatetime]
GO
ALTER TABLE [dbo].[sdk_NewPackageCreateTask] ADD  CONSTRAINT [DF_sdk_NewPackageCreateTask_PackageTaskStatus]  DEFAULT ((1)) FOR [PackageTaskStatus]
GO
ALTER TABLE [dbo].[sdk_NewPackageCreateTask] ADD  CONSTRAINT [DF_sdk_NewPackageCreateTask_IsEncryption]  DEFAULT ((0)) FOR [IsEncryption]
GO
ALTER TABLE [dbo].[sdk_NewPackageCreateTask] ADD  CONSTRAINT [DF_sdk_NewPackageCreateTask_AdID]  DEFAULT ((0)) FOR [AdID]
GO
ALTER TABLE [dbo].[sdk_NewPackageCreateTask_IOS] ADD  CONSTRAINT [DF_sdk_NewPackageCreateTask_IOS_CollectDatetime]  DEFAULT (getdate()) FOR [CollectDatetime]
GO
ALTER TABLE [dbo].[sdk_NewPackageCreateTask_IOS] ADD  CONSTRAINT [DF_sdk_NewPackageCreateTask_IOS_PackageTaskStatus]  DEFAULT ((1)) FOR [PackageTaskStatus]
GO
ALTER TABLE [dbo].[sdk_Package] ADD  CONSTRAINT [DF_sdk_Package_createDatetime]  DEFAULT (getdate()) FOR [createDatetime]
GO
ALTER TABLE [dbo].[sdk_Package] ADD  CONSTRAINT [DF_sdk_Package_createUser]  DEFAULT ('admin') FOR [createUser]
GO
ALTER TABLE [dbo].[sdk_PackageCreateTask] ADD  CONSTRAINT [DF_sdk_PackageCreateTask_CreaterName]  DEFAULT (N'admin') FOR [CreaterName]
GO
ALTER TABLE [dbo].[sdk_PackageCreateTask] ADD  CONSTRAINT [DF_sdk_PackageCreateTask_CreateDatetime]  DEFAULT (getdate()) FOR [CreateDatetime]
GO
ALTER TABLE [dbo].[sdk_PackageCreateTask] ADD  CONSTRAINT [DF_sdk_PackageCreateTask_GameVersionName]  DEFAULT ((0)) FOR [GameVersionName]
GO
ALTER TABLE [dbo].[sdk_PlatformConfig] ADD  CONSTRAINT [DF_sdk_PlatformConfig_isCPSetting]  DEFAULT ((0)) FOR [isCPSetting]
GO
ALTER TABLE [dbo].[sdk_PlatformConfig] ADD  CONSTRAINT [DF_sdk_PlatformConfig_isBuilding]  DEFAULT ((0)) FOR [isBuilding]
GO
ALTER TABLE [dbo].[sdk_PlatformConfig] ADD  CONSTRAINT [DF_sdk_PlatformConfig_isServer]  DEFAULT ((0)) FOR [isServer]
GO
ALTER TABLE [dbo].[sdk_PlatformConfigKey] ADD  CONSTRAINT [DF_sdk_PlatformConfigKey_isCPSetting]  DEFAULT ((0)) FOR [isCPSetting]
GO
ALTER TABLE [dbo].[sdk_PlatformConfigKey] ADD  CONSTRAINT [DF_sdk_PlatformConfigKey_isBuilding]  DEFAULT ((0)) FOR [isBuilding]
GO
ALTER TABLE [dbo].[sdk_PlatformConfigKey] ADD  CONSTRAINT [DF_sdk_PlatformConfigKey_isServer]  DEFAULT ((0)) FOR [isServer]
GO
ALTER TABLE [dbo].[sdk_PlatformConfigProductList] ADD  CONSTRAINT [DF_sdk_PlatformConfigProductList_price]  DEFAULT ((0)) FOR [price]
GO
ALTER TABLE [dbo].[sdk_PlatformConfigProductList] ADD  CONSTRAINT [DF_sdk_PlatformConfigProductList_type]  DEFAULT ((0)) FOR [type]
GO
ALTER TABLE [dbo].[sdk_PlatformVersion] ADD  CONSTRAINT [DF_PlatformVersion_CollectDatetime]  DEFAULT (getdate()) FOR [CollectDatetime]
GO
ALTER TABLE [dbo].[sdk_PlugInList] ADD  CONSTRAINT [DF_PlugInList_CollectDatetime]  DEFAULT (getdate()) FOR [CollectDatetime]
GO
ALTER TABLE [dbo].[sdk_PlugInVersion] ADD  CONSTRAINT [DF_PlugVersion_CollectDatetime]  DEFAULT (getdate()) FOR [CollectDatetime]
GO
ALTER TABLE [dbo].[sdk_TypeSdkVersion] ADD  CONSTRAINT [DF_GdeGamePlatformVersion_CollectDatetime]  DEFAULT (getdate()) FOR [CollectDatetime]
GO
ALTER TABLE [dbo].[sdk_UploadPackageInfo] ADD  CONSTRAINT [DF_sdk_UploadPackageInfo_GameVersion]  DEFAULT (N'版本号') FOR [GameVersion]
GO
ALTER TABLE [dbo].[sdk_UploadPackageInfo] ADD  CONSTRAINT [DF_sdk_UploadPackageInfo_CollectDatetime]  DEFAULT (getdate()) FOR [CollectDatetime]
GO
ALTER TABLE [dbo].[server_game_commodityList] ADD  CONSTRAINT [DF_server_game_commodityList_collectdatetime]  DEFAULT (getdate()) FOR [collectdatetime]
GO
ALTER TABLE [dbo].[server_platform] ADD  CONSTRAINT [DF_server_Platform_nullity]  DEFAULT ((0)) FOR [nullity]
GO
ALTER TABLE [dbo].[server_platform] ADD  CONSTRAINT [DF_Table_1_CollectDatetime]  DEFAULT (getdate()) FOR [collectdatetime]
GO
ALTER TABLE [dbo].[server_platform] ADD  CONSTRAINT [DF_server_Platform_synchrodata]  DEFAULT ((0)) FOR [synchrodata]
GO
ALTER TABLE [dbo].[server_platform_attrs] ADD  CONSTRAINT [DF_server_platform_attrs_collectdatetime]  DEFAULT (getdate()) FOR [collectdatetime]
GO
ALTER TABLE [dbo].[server_platform_gameInfo] ADD  CONSTRAINT [DF_server_platform_gameInfo_nullity]  DEFAULT ((0)) FOR [nullity]
GO
ALTER TABLE [dbo].[server_platform_gameInfo] ADD  CONSTRAINT [DF_server_platform_gameInfo_collectdatetime]  DEFAULT (getdate()) FOR [collectdatetime]
GO
ALTER TABLE [dbo].[server_platform_gameInfo] ADD  CONSTRAINT [DF_server_platform_gameInfo_synchrodata]  DEFAULT ((0)) FOR [synchrodata]
GO
ALTER TABLE [dbo].[server_platform_gameInfo] ADD  CONSTRAINT [DF_server_platform_gameInfo_paramChange]  DEFAULT ((0)) FOR [paramChange]
GO
ALTER TABLE [dbo].[server_platform_operationLog] ADD  CONSTRAINT [DF_server_platform_operationLog_platformid]  DEFAULT ((0)) FOR [platformid]
GO
ALTER TABLE [dbo].[server_platform_operationLog] ADD  CONSTRAINT [DF_server_platform_operationLog_gameid]  DEFAULT ((0)) FOR [gameid]
GO
ALTER TABLE [dbo].[server_platform_operationLog] ADD  CONSTRAINT [DF_server_platform_operationLog_collectdatetime]  DEFAULT (getdate()) FOR [collectdatetime]
GO
ALTER TABLE [dbo].[AspNetUserClaims]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserClaims] CHECK CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserLogins]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserLogins] CHECK CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'渠道简称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_DefaultPlatform', @level2type=N'COLUMN',@level2name=N'PlatformName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'渠道名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_DefaultPlatform', @level2type=N'COLUMN',@level2name=N'PlatformDisplayName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'渠道状态' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_DefaultPlatform', @level2type=N'COLUMN',@level2name=N'PlatformStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'渠道图片' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_DefaultPlatform', @level2type=N'COLUMN',@level2name=N'PlatformIcon'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'平台ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_DefaultPlatformConfig', @level2type=N'COLUMN',@level2name=N'SystemID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'游戏ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'GameID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'游戏简称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'GameName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'游戏名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'GameDisplayName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Android版本号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'AndroidVersionID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ISO版本号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'IOSVersionID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Android秘钥ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'AndroidKeyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IOS秘钥ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'IOSKeyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'游戏图标' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'GameIcon'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'CreateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'CollectDatetime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'ModifyDatetime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'更新人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'ModifyUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'游戏全拼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'GameNameSpell'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'开发工具版本' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'UnityVer'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'产品名称 IOS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_GameInfo', @level2type=N'COLUMN',@level2name=N'ProductName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'平台ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_icon', @level2type=N'COLUMN',@level2name=N'SystemID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask', @level2type=N'COLUMN',@level2name=N'RecID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'任务创建人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask', @level2type=N'COLUMN',@level2name=N'CreateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'渠道ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask', @level2type=N'COLUMN',@level2name=N'PlatFormID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'打包任务状态（1：未处理 2：处理中 3：已处理）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask', @level2type=N'COLUMN',@level2name=N'PackageTaskStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'任务启动时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask', @level2type=N'COLUMN',@level2name=N'StartDatetime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'批次任务ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask', @level2type=N'COLUMN',@level2name=N'CreateTaskID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'打包服务器地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask', @level2type=N'COLUMN',@level2name=N'ServerAddr'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'文件地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask', @level2type=N'COLUMN',@level2name=N'FileAddr'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'文件名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask', @level2type=N'COLUMN',@level2name=N'FileName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'包地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask', @level2type=N'COLUMN',@level2name=N'PackageAddr'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'包名字' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask', @level2type=N'COLUMN',@level2name=N'PackageName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask_IOS', @level2type=N'COLUMN',@level2name=N'RecID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'任务创建人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask_IOS', @level2type=N'COLUMN',@level2name=N'CreateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'渠道ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask_IOS', @level2type=N'COLUMN',@level2name=N'PlatFormID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'打包任务状态（1：未处理 2：处理中 3：已处理）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask_IOS', @level2type=N'COLUMN',@level2name=N'PackageTaskStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'任务启动时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask_IOS', @level2type=N'COLUMN',@level2name=N'StartDatetime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'批次任务ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask_IOS', @level2type=N'COLUMN',@level2name=N'CreateTaskID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'打包服务器地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask_IOS', @level2type=N'COLUMN',@level2name=N'ServerAddr'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'文件地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask_IOS', @level2type=N'COLUMN',@level2name=N'FileAddr'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'文件名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask_IOS', @level2type=N'COLUMN',@level2name=N'FileName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'包地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask_IOS', @level2type=N'COLUMN',@level2name=N'PackageAddr'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'包名字' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_NewPackageCreateTask_IOS', @level2type=N'COLUMN',@level2name=N'PackageName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'渠道ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_PlatformVersion', @level2type=N'COLUMN',@level2name=N'PlatformID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'渠道版本' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_PlatformVersion', @level2type=N'COLUMN',@level2name=N'Version'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_PlatformVersion', @level2type=N'COLUMN',@level2name=N'CreateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'平台ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_PlatformVersion', @level2type=N'COLUMN',@level2name=N'SystemID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'数银渠道版本号' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_TypeSdkVersion', @level2type=N'COLUMN',@level2name=N'MyVersion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建用户' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_TypeSdkVersion', @level2type=N'COLUMN',@level2name=N'CreateUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'创建时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_TypeSdkVersion', @level2type=N'COLUMN',@level2name=N'CollectDatetime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'平台ID(1:Android,2:IOS)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_TypeSdkVersion', @level2type=N'COLUMN',@level2name=N'PlatFormID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_UploadPackageInfo', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SDK包标签' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_UploadPackageInfo', @level2type=N'COLUMN',@level2name=N'PageageTable'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'上传时间' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_UploadPackageInfo', @level2type=N'COLUMN',@level2name=N'CollectDatetime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'文件大小' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_UploadPackageInfo', @level2type=N'COLUMN',@level2name=N'FileSize'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'上传用户' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_UploadPackageInfo', @level2type=N'COLUMN',@level2name=N'UploadUser'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'游戏名称' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_UploadPackageInfo', @level2type=N'COLUMN',@level2name=N'GameName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'游戏平台' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_UploadPackageInfo', @level2type=N'COLUMN',@level2name=N'GamePlatFrom'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'时间字符串（用户文件夹名称）' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_UploadPackageInfo', @level2type=N'COLUMN',@level2name=N'StrCollectDatetime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'文件名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sdk_UploadPackageInfo', @level2type=N'COLUMN',@level2name=N'FileName'
GO
USE [master]
GO
ALTER DATABASE [TypeSDK] SET  READ_WRITE 
GO
