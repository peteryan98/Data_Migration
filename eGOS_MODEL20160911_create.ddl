/*================================================================================*/
/* DDL SCRIPT                                                                     */
/*================================================================================*/
/*  Title    :                                                                    */
/*  FileName : eGOS_MODEL.ecm                                                     */
/*  Platform : SQL Server 2014                                                    */
/*  Version  : Concept                                                            */
/*  Date     : Friday, March 10, 2017                                             */
/*================================================================================*/
/*================================================================================*/
/* CREATE TABLES                                                                  */
/*================================================================================*/

CREATE TABLE [dbo].[2] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [IDF] VARCHAR(64) DEFAULT 'XXXX_'+replace(replace(replace(replace(replace(SYSDATETIMEOFFSET(),' -','_'),'-',''),':',''),' ',''),'.','')+'_'+Convert(varchar(32),replace(newid(),'-',''),0) NOT NULL,
  [NAME_CODE] VARCHAR(128),
  [VALUE_CODE] VARCHAR(32),
  [ACTION_CODE] VARCHAR(64),
  [ACRONYM_NAME] VARCHAR(8),
  [ALIAS] VARCHAR(8),
  [CATEGORY_CODE] VARCHAR(16),
  [TYPE_CODE] VARCHAR(16),
  [REASON_CODE] VARCHAR(16),
  [DESCRIPTION] VARCHAR(256),
  [EFFECTIVE_START_DATE] DATETIME,
  [EFFECTIVE_END_DATE] DATETIME,
  [STATUS_CODE] VARCHAR(8),
  [STATUS_DATE] DATETIME,
  [COMMENTS] VARCHAR(256),
  [REFERENCE_CODE] VARCHAR(16),
  [REFERENCE_ID] VARCHAR(64),
  [REFERENCE_NAME] VARCHAR(256),
  [VERIFICATION_IDR] BIT DEFAULT 0,
  [PRIMARY_IDR] BIT DEFAULT 0,
  [CREATED_DATE] DATETIME,
  [CREATED_BY] VARCHAR(128),
  [UPDATED_DATE] DATETIME,
  [UPDATED_BY] VARCHAR(128),
  [UPDATED_COUNT] INT DEFAULT 0,
  [LOCKED_DATE] DATETIME,
  [LOCKED_BY] VARCHAR(128),
  [LOCK_EXPIRED_DATE] DATETIME,
  [POSITION_ORDER] INT DEFAULT 0,
  [REVIEWED_DATE] DATETIME,
  [REVIEWED_BY] VARCHAR(128),
  [APPROVED_DATE] DATETIME,
  [APPROVED_BY] VARCHAR(128),
  [ACCESS_LIST] BIGINT DEFAULT 0,
  [ACCESS_LEVEL] BIGINT DEFAULT 0,
  [PARENT_CODE] VARCHAR(16),
  [VERSION] VARCHAR(64) DEFAULT 'V_1.0:INITIAL',
  CONSTRAINT [PK_2] PRIMARY KEY ([ID], [IDF])
)
GO

CREATE TABLE [dbo].[3] (
  [ID] INT IDENTITY(1,1) NOT NULL,
  [NameCode] VARCHAR(128),
  [Identifier] VARCHAR(64),
  [AcronymName] VARCHAR(8),
  [Alias] VARCHAR(8),
  [CategoryCode] VARCHAR(16),
  [TypeCode] VARCHAR(16),
  [ReasonCode] VARCHAR(16),
  [Description] VARCHAR(256),
  [EffectiveStartDate] DATETIME,
  [EffectiveEndDate] DATETIME,
  [StatusCode] VARCHAR(8),
  [StatusDate] DATETIME,
  [Comments] VARCHAR(256),
  [ReferenceCode] VARCHAR(16),
  [ReferenceID] VARCHAR(64),
  [ReferenceName] VARCHAR(256),
  [VerificationIndicator] BIT DEFAULT 0,
  [DateCreated] DATETIME,
  [CreatedBy] VARCHAR(128),
  [DateUpdated] DATETIME,
  [UpdatedBy] VARCHAR(128),
  [UpdatedCounts] INT DEFAULT 0,
  [DateLocked] DATETIME,
  [LockedBy] VARCHAR(128),
  [DateLockExpired] DATETIME,
  [PositionOrder] INT DEFAULT 0,
  [DateReviewed] DATETIME,
  [ReviewedBy] VARCHAR(128),
  [DateApproved] DATETIME,
  [ApprovedBy] VARCHAR(128),
  [AccessList] BIGINT DEFAULT 0,
  [AccessLevel] BIGINT DEFAULT 0,
  [OwnerIDCode] VARCHAR(16),
  [RelationshipCodeToParent] VARCHAR(16),
  CONSTRAINT [PK_3] PRIMARY KEY ([ID])
)
GO

/*================================================================================*/
/* CREATE VIEWS                                                                   */
/*================================================================================*/

CREATE VIEW [dbo].[vw_NewUID]
AS SELECT replace(NEWID(),'-','') AS NewUID
GO

/*================================================================================*/
/* CREATE ROUTINES                                                                */
/*================================================================================*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[fn_NewIDF]', 'FN') IS NOT NULL
   DROP FUNCTION [dbo].[fn_NewIDF]
GO
/*============================================================*/
/* Created By Peter Yan on Date:                              */
/* Description:                                               */
/*============================================================*/
CREATE FUNCTION [dbo].[fn_NewIDF]
(
  @P_Alias      as varchar(4) = 'XXXX',
  @P_Date       as DateTime = NULL
)
RETURNS varchar(64)
AS
BEGIN
  DECLARE @V_RV as varchar(64) = NULL, @NewID as varchar(36)
        if @P_Date is null  or isDate(@P_Date) < 1
        BEGIN
           set @V_RV = replace(replace(replace(replace(replace(SYSDATETIMEOFFSET(),' -','_'),'-',''),':',''),' ',''),'.','')
        END
        else
        BEGIN
           set @V_RV = replace(replace(replace(replace(CONVERT(Varchar(22),@P_Date,121),'-',''),':',''),' ',''),'.','')+'00000_XXXX'
        END
        Select @NewID= NewUID FROM dbo.vw_NewUID    --- 32 Characters
        set @V_RV = Left(@P_Alias+'XXXX',4) +'_' +  SUBSTRING(@V_RV,1,26) + '_' + @NewID
        RETURN @V_RV
END;
GO
GRANT EXECUTE ON [dbo].[fn_NewIDF]
    TO CS_UserRole
GO
-----select dbo.fn_NewIDF('ABC','2012/2/2')
-----select dbo.fn_NewIDF('ABC',Default)

/*================================================================================*/
/* CREATE TRIGGERS                                                                */
/*================================================================================*/

IF OBJECT_ID('[TR_2_D]','TR') is not NULL
     DROP TRIGGER [TR_2_D]
GO
CREATE TRIGGER [TR_2_D]
ON [dbo].[2] AFTER DELETE AS
BEGIN
   IF db_id('NITAAC_AUDIT') IS NOT NULL
   BEGIN
      INSERT NITAAC_AUDIT.[dbo].[2] SELECT * FROM DELETED
      INSERT NITAAC_AUDIT.[dbo].[AUDIT_REPORT](SOURCE, AUDIT_ID, SOURCE_CREATED_BY, SOURCE_CREATED_DATE, SOURCE_UPDATED_BY, SOURCE_UPDATED_DATE, UPDATED_COUNT, [ACTION],[TRANSACTION], COMMENTS)
      SELECT '[dbo].[2]',IDF, CREATED_BY, CREATED_DATE, UPDATED_BY, UPDATED_DATE, UPDATED_COUNT, 'DELETE', 'DB DELETE','' From DElETED
   END
END
GO

IF OBJECT_ID('[TR_2_U]','TR') is not NULL
     DROP TRIGGER [TR_2_U]
GO

CREATE TRIGGER [TR_2_U]
ON [dbo].[2] AFTER UPDATE AS
BEGIN
   if EXISTS (SELECT CREATED_BY from INSERTED I INNER JOIN DELETED D on I.ID = D.ID where I.UPDATED_COUNT=D.UPDATED_COUNT)
   BEGIN
           UPDATE [dbo].[2] SET UPDATED_DATE = ISNULL(T.UPDATED_DATE,GetDate()), UPDATE_By = ISNULL(T.UPDATED_BY,SUSER_NAME()), UPDATED_COUNT=T.UPDATED_COUNT + 1
           FROM [dbo].[2] T INNER JOIN DELETED D on T.ID = D.ID WHERE D.UPDATED_COUNT = T.UPDATED_COUNT
   END
   IF db_id('NITAAC_AUDIT') IS NOT NULL
   BEGIN
      INSERT NITAAC_AUDIT.[dbo].[2] SELECT * FROM DELETED
      INSERT NITAAC_AUDIT.[dbo].[AUDIT_REPORT](SOURCE, AUDIT_ID, SOURCE_CREATED_BY, SOURCE_CREATED_DATE, SOURCE_UPDATED_BY, SOURCE_UPDATED_DATE, UPDATED_COUNT, [ACTION],[TRANSACTION], COMMENTS)
      SELECT '[dbo].[2]',IDF, CREATED_BY, CREATED_DATE, UPDATED_BY, UPDATED_DATE, UPDATED_COUNT, 'UPDATE', 'DB UPDATE','Application Level' From DElETED
   END
END
GO

IF OBJECT_ID('[TR_3_D]','TR') is not NULL
     DROP TRIGGER [TR_3_D]
GO
CREATE TRIGGER [TR_3_D]
ON [dbo].[3] AFTER DELETE AS
BEGIN
   IF db_id('NITAAC_AUDIT') IS NOT NULL
   BEGIN
      INSERT NITAAC_AUDIT.[dbo].[3] SELECT * FROM DELETED
      INSERT NITAAC_AUDIT.[dbo].[AUDIT_REPORT](SOURCE, AUDIT_ID, SOURCE_CREATED_BY, SOURCE_CREATED_WHEN, SOURCE_MODIFIED_BY, SOURCE_MODIFIED_WHEN, MODIFIED_COUNT, [ACTION],[TRANSACTION], COMMENTS)
      SELECT '[dbo].[3]',CAST([DataID] as varchar(16))+':'+ CAST([OwnerID] as varchar(16)) +':'+ [OwnerIDCode], CREATEDBY, DATECREATED, UPDATEDBY, DATEUPDATED, UPDATEDCOUNTS, 'DELETE', 'DB DELETE','DateID:OwnerID:OwnerIDCode' From DElETED
   END
END
GO

IF OBJECT_ID('[TR_3_U]','TR') is not NULL
     DROP TRIGGER [TR_3_U]
GO

CREATE TRIGGER [TR_3_U]
ON [dbo].[3] AFTER UPDATE AS
BEGIN
   if EXISTS (SELECT I.ID from INSERTED I INNER JOIN DELETED D on I.ID = D.ID where I.UpdatedCounts = D.UpdatedCounts)
   BEGIN
           UPDATE [dbo].[3] SET DateUpdated = ISNULL(T.DateUpdated,GetDate()), UpdatedBy = ISNULL(T.UpdatedBy,SUSER_NAME()), UpdatedCounts = T.UpdatedCounts + 1
           from [dbo].[3] T inner join DELETED D on T.ID = D.ID where D.UpdatedCounts = T.UpdatedCounts
   END
   IF db_id('NITAAC_AUDIT') IS NOT NULL
   BEGIN
      INSERT NITAAC_AUDIT.[dbo].[3] SELECT * FROM DELETED
      INSERT NITAAC_AUDIT.[dbo].[AUDIT_REPORT](SOURCE, AUDIT_ID, SOURCE_CREATED_BY, SOURCE_CREATED_WHEN, SOURCE_MODIFIED_BY, SOURCE_MODIFIED_WHEN, MODIFIED_COUNT, [ACTION],[TRANSACTION], COMMENTS)
      SELECT '[dbo].[3]',CAST(ID as varchar(16)), CREATEDBY, DATECREATED, UPDATEDBY, DATEUPDATED, UPDATEDCOUNTS, 'UPDATE', 'DB UPDATE','Application Level' From DElETED
   END
END
GO
