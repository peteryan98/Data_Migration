/*================================================================================*/
/* DDL SCRIPT                                                                     */
/*================================================================================*/
/*  Title    : eGOS                                                               */
/*  FileName : NEOS20161203.ecm                                                   */
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
  [NOTE_TEXT] VARCHAR(2048),
  [BODY_TEXT] VARCHAR(MAX),
  [EFFECTIVE_START_DATE] DATETIME DEFAULT GetDate(),
  [EFFECTIVE_END_DATE] DATETIME,
  [STATUS_CODE] VARCHAR(8) DEFAULT 'ACTIVE',
  [STATUS_DATE] DATETIME DEFAULT GetDate(),
  [COMMENTS] VARCHAR(256),
  [REFERENCE_CODE] VARCHAR(16),
  [REFERENCE_ID] VARCHAR(64),
  [REFERENCE_NAME] VARCHAR(256),
  [VERIFICATION_IDR] BIT DEFAULT 0,
  [PRIMARY_IDR] BIT DEFAULT 0,
  [CREATED_DATE] DATETIME DEFAULT GetDate(),
  [CREATED_BY] VARCHAR(128) DEFAULT sUSER_NAME(),
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
  [ACCESS_LEVEL] INT DEFAULT 744,
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
AS SELECT  right('0000' + cast(Ceiling(100000*RAND()) as varchar(5)), 5)+'_XXXX_' + replace(NEWID(),'-','') AS NewUID
GO

/*================================================================================*/
/* CREATE ROUTINES                                                                */
/*================================================================================*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[fn_MG_SeekAlias]', 'FN') IS NOT NULL
   DROP FUNCTION [dbo].[fn_MG_SeekAlias]
GO
/*============================================================*/
/* Created By Peter Yan on Date:                              */
/* Description:                                               */
/*============================================================*/
CREATE FUNCTION [dbo].[fn_MG_SeekAlias]
(
  @P_Data              as varchar(1024) = NULL,
  @P_Alias             as varchar(32)   = '(',
  @P_Action            as varchar(16)   = 'GET'
)
RETURNS varchar(1024)
AS
BEGIN
  DECLARE @V_RV as varchar(1024) = @P_Data, @iPos as Int =0,  @P_AliasR as varchar(32)
  set @P_Action = UPPER(LTRIM(RTRIM(@P_Action)))
  set @P_Alias = UPPER(LTRIM(RTRIM(@P_Alias)))
  if @P_Action is null or @P_Alias is null or @P_Data is null RETURN @P_Data

     if @P_Action in ('GET')
     BEGIN
             Set @v_RV = ''
             if len(@P_Alias) < 2
             BEGIN
                     set @iPos = CharIndex(@P_Alias, @P_Data)
                     if @iPos > 0
                     BEGIN
                            if @P_Alias = '('
                               set @P_AliasR = ')'
                            else if @P_Alias = '['
                               set @P_AliasR = ']'
                            else if @P_Alias = '{'
                               set @P_AliasR = '}'
                            else if @P_Alias = '<'
                               set @P_AliasR = '>'
                            Set @v_RV = replace(Right(@P_Data, len(@P_Data) - @iPos),@P_Alias,'-')
                            if len(@v_RV) > 0
                            BEGIN
                                set @iPos = CharIndex(@P_AliasR, @v_RV)
                                if @iPos > 0 set @v_RV = Left(@v_Rv, @iPos-1)
                            END
                     END
                     if len(isNull(@v_RV,'')) > 14 set @v_RV = ''
             END
     END
     ELSE if @P_Action in ('DETELE','DEL','REMOVE')
     BEGIN
             if len(@P_Alias) < 2
             BEGIN
                     set @iPos = CharIndex(@P_Alias, @P_Data)
                     if @iPos > 0
                     BEGIN
                            if @P_Alias = '('
                               set @P_Alias = ')'
                            else if @P_Alias = '['
                               set @P_Alias = ']'
                            else if @P_Alias = '{'
                               set @P_Alias = '}'
                            else if @P_Alias = '<'
                               set @P_Alias = '>'

                            Set @v_RV = Right(@P_Data, len(@P_Data) - @iPos)
                            set @P_Data = left(@P_Data,@iPos-1)
                            if len(@v_RV) > 0
                            BEGIN
                                set @iPos = CharIndex(@P_Alias, @v_RV)
                                if @iPos > 0  set @v_RV = Right(@v_RV, len(@v_RV) - @iPos)
                            END
                            set @v_RV = @P_Data + @v_RV
                     END
             END
             ELSE
                  set @V_RV = LTRIM(RTRIM(replace(replace(@P_Data,@P_Alias,''),'  ',' ')))
         END
         RETURN @V_RV
END;
GO
GRANT EXECUTE ON [dbo].[fn_MG_SeekAlias]
    TO NEOS_UserRole
GO
--- select [dbo].[fn_MG_SeekAlias]('dasdasd(uop)','(','get')

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[fn_MG_Clean]', 'FN') IS NOT NULL
   DROP FUNCTION [dbo].[fn_MG_Clean]
GO
/*============================================================*/
/* Created By Peter Yan on Date:                              */
/* Description:                                               */
/*============================================================*/
CREATE FUNCTION [dbo].[fn_MG_Clean]
(
  @P_Data              as varchar(32) = NULL,
  @P_Format            as varchar(16) = 'C_PHONE'
)
RETURNS varchar(32)
AS
BEGIN
  DECLARE @V_RV as varchar(32) = LTRIM(RTRIM(@P_Data)), @iPos as INT
  set @P_Format = UPPER(LTRIM(RTRIM(isNull(@P_Format,'C_PHONE'))))

  if isNull(@P_Data,'') = '' return @V_RV
  if UPPER(@P_Format) = 'C_PHONE'
  BEGIN
       set @V_RV = replace(replace(replace(replace(replace(replace(UPPER(@V_RV),' EXT','X'),'EXT','X'),'(','-'),')','-'),' ',''),'.','')
       if charIndex('-',@v_RV) = 5 set @v_RV = left(@v_RV,1) +'-'+Right(@v_RV,Len(@v_RV)-1)

  END
  ELSE if UPPER(@P_Format) = 'C_PHONE_EXT'
  BEGIN
        set @iPos=charIndex('X',@v_RV)
        if @iPos > 0
           set @v_RV = Right(@v_RV, Len(@v_RV)-@iPos)
        else
           set @v_RV = ''
  END
  ELSE if UPPER(@P_Format) = 'C_EMAIL'
  BEGIN
        set @V_RV = LTRIM(RTRIM(@P_Data))
  END
  RETURN @V_RV
END;
GO
GRANT EXECUTE ON [dbo].[fn_MG_Clean]
    TO NEOS_UserRole
GO
--- select [dbo].[fn_MG_Clean]('dasdasd(uop)',Default)

IF OBJECT_ID('[dbo].[fn_NewIDF]', 'FN') IS NOT NULL
   DROP FUNCTION [dbo].[fn_NewIDF]
GO
/*============================================================*/
/* Created By Peter Yan on Date:                              */
/* Description:                                               */
/*============================================================*/
CREATE FUNCTION [dbo].[fn_NewIDF]
(
  @P_Alias      as varchar(5) = '_____',
  @P_Date       as DateTime = NULL
)
RETURNS varchar(64)
AS
BEGIN
        DECLARE @V_RV as varchar(64) = NULL, @NewID as varchar(64)
        Select @NewID= NewUID FROM dbo.vw_NewUID
        if @P_Date is null  or isDate(@P_Date) < 1
        BEGIN
           set @V_RV = replace(replace(replace(replace(replace(SYSDATETIMEOFFSET(),' -','_'),'-',''),':',''),' ',''),'.','') + RIGHT(@NewID,33)
        END
        else
        BEGIN
           set @V_RV = replace(replace(replace(replace(CONVERT(Varchar(22),@P_Date,121),'-',''),':',''),' ',''),'.','')+@NewID
        END

        -- 32 Characters
        set @V_RV = Left(@P_Alias+'_____',5) +  @V_RV
        RETURN @V_RV
END;
GO
GRANT EXECUTE ON [dbo].[fn_NewIDF]
    TO NEOS_UserRole
GO
-----select dbo.fn_NewIDF('ABC','2012/2/2')
-----select dbo.fn_NewIDF('ABC',Default)

IF OBJECT_ID('[dbo].[fn_IDFLike]', 'FN') IS NOT NULL
   DROP FUNCTION [dbo].[fn_IDFLike]
GO
/*============================================================*/
/* Created By Peter Yan on Date:                              */
/* Description:                                               */
/*============================================================*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_IDFLike]  (
       @ID as varchar(64) = NULL
) RETURNS varchar(66)
AS
BEGIN
        declare @iPos as int=0, @Str as varchar(128) = isNull(@ID, 'TST_New')
        set @iPos= CHARINDEX('_',@Str)
        if @iPos = 0
                set @str = right(replicate('_', 26)+@str,26) +'[_]' +  REPLICATE('_',37)
        else
                set @str = right(replicate('_', 26)+left(@str,@iPos-1),26) +'[_]' +  left(right(@Str,len(@str)-@iPos)+REPLICATE('_',37), 37)
        return @str
End
GO
GRANT EXECUTE ON [dbo].[fn_IDFLike]
    TO NEOS_UserRole
GO
--- select [dbo].[fn_IDFLike]('323_12')

IF OBJECT_ID('[dbo].[fn_IDFLikeExt]', 'FN') IS NOT NULL
   DROP FUNCTION [dbo].[fn_IDFLikeExt]
GO
/*============================================================*/
/* Created By Peter Yan on Date:                              */
/* Description:                                               */
/*============================================================*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_IDFLikeExt]  (
       @ID   as varchar(64) = NULL,
       @Sept as varchar(2) = '_',
       @InitLen  as int = 26,
       @Len   as int = 64
) RETURNS varchar(128)
AS
BEGIN
        set @Sept = isNull(@Sept,'_')
        set @Len = isnull(@len, 64)
        set @InitLen = isnull(@InitLen, 26)
        if @Len < @InitLen set @InitLen = @Len - len(@Sept)
        declare @iPos as int=0, @Str as varchar(128) = isNull(@ID, 'TST_New'), @RLen as Int = @Len - @InitLen-Len(@Sept)
        if len(@Sept) > 0
        BEGIN
                set @iPos= CHARINDEX(@Sept,@Str)
                if @iPos = 0
                        set @str = right(replicate(@Sept, @InitLen)+@str,@InitLen) +'['+@Sept+']' +         REPLICATE(@Sept,@Rlen)
                else
                        set @str = right(replicate(@Sept, @InitLen)+left(@str,@iPos-1),@InitLen) +'['+@Sept+']'  +  left(right(@Str,len(@str)-@iPos)+REPLICATE(@Sept,@Rlen), @Rlen)
        END
        ELSE
        BEGIN
                set @Str = right(replicate(@Sept, @InitLen)+@str,@InitLen) + REPLICATE('_',@Rlen)
        END

        return @str
END
GO
GRANT EXECUTE ON [dbo].[fn_IDFLikeExt]
    TO NEOS_UserRole
GO
--- select [dbo].[fn_IDFLikeExt]('323_12',default, default,default)

IF OBJECT_ID('[dbo].[fn_IsAuditReady]', 'FN') IS NOT NULL
   DROP FUNCTION [dbo].[fn_IsAuditReady]
GO
/*============================================================*/
/* Created By Peter Yan on Date:                              */
/* Description:                                               */
/*============================================================*/
CREATE FUNCTION [dbo].[fn_IsAuditReady]
(
  @P_Table as varchar(128) = NULL,
  @P_Check as BIT = True
)
RETURNS INT
AS
BEGIN
  DECLARE @V_RV as INT = 0, @AUDIT_DBName varchar(64) = DB_NAME() + '_AUDIT';

     if DB_ID(@AUDIT_DBName) Is NOT null
     BEGIN
          if CharIndex(']',@P_Table) > 0 set @P_Table = replace(replace(@P_Table,']',''),'[','')
          SELECT  @V_RV = Audit_IDR from Code_Registrations where TYPE_CODE = 'C_USER_TABLE' AND  Name_Code = @P_Table
     END
     RETURN @V_RV
END;
GO
GRANT EXECUTE ON [dbo].[fn_IsAuditReady]
    TO NEOS_UserRole
GO

IF OBJECT_ID('[dbo].[fn_WordToData]', 'FN') IS NOT NULL
   DROP FUNCTION [dbo].[fn_WordToData]
GO
/*============================================================*/
/* Created By Peter Yan on Date:                              */
/* Description:                                               */
/*============================================================*/
CREATE FUNCTION [dbo].[fn_WordToData]  (
@Str             varchar(Max) = NULL,
@Word            varchar(128) = NULL,
@Separator       varchar(2)   = ';',
@Action          varchar(8)   = 'ADD',
@NoTail          BIT = 0
) RETURNS VARCHAR(MAX)
AS
BEGIN
        Set @Str = LTRIM(RTRIM(@Str))
        Set @Word = LTRIM(RTRIM(@Word))
        if IsNull(@Word,'') = '' Return @Str
        if len(@Str) > 2 set @Str = @Separator +@Str+@Separator
        if CharIndex(@Separator+@Separator, @Str) > 0 set @Str = replace(@Str,@Separator+@Separator,@Separator)
        if UPPER(@Action) in ('ADD', 'INSERT')
        BEGIN
                if isNull(@Str,'') = ''
                BEGIN
                     set @Str = @Separator + @Word + @Separator
                END
                ELSE IF CharIndex(@Separator+@Word+@Separator,@Str) = 0
                BEGIN
                     set @Str = @Separator + @Word + @Str
                END
        END
        ELSE IF UPPER(@Action) in ('DEL', 'DELETE', 'REMOVE')
        BEGIN
                if CharIndex(@Separator+@Word+@Separator,@Str)  > 0 set @Str = replace(@Str,@Separator+@Word+@Separator,@Separator)
        END
        if @NoTail > 0
        BEGIN
                set @Str=SubString(@Str,2, len(@Str)-2)
        END
        Return @Str
END;
GO
GRANT EXECUTE ON [dbo].[fn_WordToData]
    TO NEOS_UserRole
GO

IF OBJECT_ID('[dbo].[fn_IsMasked]', 'FN') IS NOT NULL
   DROP FUNCTION [dbo].[fn_IsMasked]
GO
/*============================================================*/
/* Created By Peter Yan on Date:                              */
/* Description:                                               */
/*============================================================*/
CREATE FUNCTION [dbo].[fn_IsMasked]
(
  @P_Value as  INT = NULL,
  @P_Code  as  varchar(24) = NULL
)
RETURNS INT
AS
BEGIN
     DECLARE @V_RV as INT = @P_Value
     SET @P_CODE = UPPER(LTRIM(RTRIM(@P_CODE)))
     if Len(isNull(@P_Code,'')) = 0 or @V_RV < 1
             SET @V_RV = 0
     ELSE
     BEGIN
             if charIndex('C_',@P_Code) != 1 set @p_Code = 'C_'+ replace(@p_Code,'C_','')
             select @v_RV &= MASK_VALUE from dbo.REF_NITAAC_DEFINITIONS where VALUE_CODE = @P_Code
             if @@RowCount = 0 set @v_RV = 0
     END
     RETURN @V_RV
END;
GO
GRANT EXECUTE ON [dbo].[fn_IsMasked]
    TO NEOS_UserRole
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_DisplayDate]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_DisplayDate]
GO
CREATE FUNCTION [dbo].[fn_DisplayDate] (
       @Date   as DATETIME = NULL,
       @Fmt    as varchar(24) = 'mm/dd/yyyy',
       @Offset as int = -1
)
RETURNS varchar(24)
AS
BEGIN
        Declare @DateShow as varchar(24) = ''

        if isdate(@Date) = 0 goto errorHandle
        set @Fmt = LTRIM(RTRIM(@Fmt))
        Select @DateShow = Case lower(@Fmt)
                        when 'mm/dd/yyyy'                        then  convert(varchar(24), dateadd(DAY,@Offset,@date),101)
                        when 'yy.mm.dd'                          then  convert(varchar(24), dateadd(DAY,@Offset,@date),102)
                        when 'dd/mm/yyyy'                        then  convert(varchar(24), dateadd(DAY,@Offset,@date),103)
                        when 'dd.mm.yyyy'                        then  convert(varchar(24), dateadd(DAY,@Offset,@date),104)
                        when 'dd-mm-yy'                          then  convert(varchar(24), dateadd(DAY,@Offset,@date),105)
                        when 'dd mon yy'                         then  convert(varchar(24), dateadd(DAY,@Offset,@date),106)
                        when 'mon dd, yy'                        then  convert(varchar(24), dateadd(DAY,@Offset,@date),107)
                        when 'hh:mm:ss'                          then  convert(varchar(24), dateadd(NS,@Offset,@date),108)
                        when 'mon dd yyyy hh:mmap'               then  convert(varchar(24), dateadd(DAY,@Offset,@date),100)
                        when 'mon dd yyyy hh:mm ap'              then  convert(varchar(24), dateadd(DAY,@Offset,@date),100)
                        when 'hh:mm ap'                          then  right(convert(varchar(24), dateadd(DAY,@Offset,@date),100),7)
                        when 'hh:mmap'                           then  right(convert(varchar(24), dateadd(DAY,@Offset,@date),100),7)
                        when 'mon dd yyyy hh:mm:ss'              then  convert(varchar(24), dateadd(DAY,@Offset,@date),109)
                        when 'mm-dd-yy'                          then  convert(varchar(24), dateadd(DAY,@Offset,@date),110)
                        when 'yy/mm/dd'                          then  convert(varchar(24), dateadd(DAY,@Offset,@date),111)
                        when 'yymmdd'                            then  convert(varchar(24), dateadd(DAY,@Offset,@date),112)
                        when 'yyyy-mm-dd hh:mm:ss'               then  convert(varchar(24), dateadd(DAY,@Offset,@date),120)
                        when 'yyyy-mm-dd'                        then  substring(convert(varchar(24), dateadd(DAY,@Offset,@date),120),1,10)
                        when 'dd mon yyyy hh:mm:ss'              then  convert(varchar(24), dateadd(DAY,@Offset,@date),130)
                        when 'dd/mm/yy hh:mm:ss'                 then  convert(varchar(24), dateadd(DAY,@Offset,@date),131)
                        when 'month'                             then  cast(Month(@Date)    as varchar(24))
                        when 'year'                              then  cast(Year(@Date)     as varchar(24))
                        else                                           cast(@Date           as varchar(24))
                        end
        RETURN @DateShow
errorHandle:
        return @DateShow
END
GO
GRANT EXECUTE ON [dbo].[fn_DisplayDate]
    TO NEOS_UserRole
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_BusinessHours]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_BusinessHours]
GO
CREATE FUNCTION [dbo].[fn_BusinessHours] (
        @DateFrom as datetime,
        @DateTo as datetime=Null
)
RETURNS int
AS
BEGIN
        DECLARE  @BusinessHours int = 0, @CDate as DateTime, @Offset as int = 0
        if @DateTo is null set @DateTo        = GetDate()
        if @DateTo < @DateFrom
        BEGIN
                set @CDate = @DateFrom
                set @DateFrom = @DateTo
                set @DateTo = @CDate
        END
        if DATEPART(weekday, @DateFrom) % 6 = 1
        BEGIN
                if DATEPART(weekday, @DateFrom) = 1
                        set @DateFrom = left(convert(varchar(24),DateAdd(Day,1, @DateFrom),101),  10) + ' 00:01'
                else
                        set @DateFrom = left(convert(varchar(24),DateAdd(Day,2, @DateFrom),  10),  10) + ' 00:01'
        END
        if DATEPART(weekday, @DateTo) % 6 = 1
        BEGIN
                if DATEPART(weekday, @DateTo) = 1
                        set @DateTo = left(convert(varchar(24),DateAdd(Day,-2, @DateTo),  10),  10) + ' 23:01'
                else
                        set @DateTo = left(convert(varchar(24),DateAdd(Day,-1, @DateTo),  10),  10) + ' 23:01'
                set @Offset = @Offset + 1
        END
        if @DateFrom > @DateTo set @DateTo = DateAdd(Hour,-1, @DateFrom)
        --take care of weekends and Holidays
        Set @BusinessHours = DATEDIFF(HOUR, @DateFrom, @DateTo)
        set  @BusinessHours = @BusinessHours - 24*(@BusinessHours/(24*8)) + @Offset
        SELECT @BusinessHours = @BusinessHours - 24*count(Holiday_Date) from [dbo].[HOLIDAYS] where Holiday_Date >= @DateFrom and HOLIDAY_DATE <= @DateTo
        RETURN @BusinessHours
END
GO
GRANT EXECUTE ON [dbo].[fn_BusinessHours]
    TO NEOS_UserRole
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_BusinessDays]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_BusinessDays]
GO
CREATE FUNCTION [dbo].[fn_BusinessDays] (
       @DateFrom as datetime = null
)
RETURNS int
AS
BEGIN
        DECLARE @CDate as DateTime = GetDate(), @BusinessDays int = 0

        --take care of weekends and Holidays
        SELECT @BusinessDays = DATEDIFF (day, @DateFrom, @CDate) - (2 * DATEDIFF(week, @DateFrom, @CDate)) - CASE WHEN DATEPART(weekday, @DateFrom) % 6 = 1 THEN 1 ELSE 0 END - CASE WHEN DATEPART(weekday, @CDate) % 6 = 1 THEN 1 ELSE 0 END
        SELECT @BusinessDays = @BusinessDays - count(Holiday_Date) from [dbo].[HOLIDAYS] where Holiday_Date >= convert(varchar,@DateFrom,101) and holiday_date <= convert(varchar,@CDate,101)
        RETURN @BusinessDays
END
GO
GRANT EXECUTE ON [dbo].[fn_BusinessDays]
    TO NEOS_UserRole
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_IsBizDay]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_IsBizDay]
GO
CREATE FUNCTION [dbo].[fn_IsBizDay] (
        @Date as datetime=Null
)
RETURNS int
AS
BEGIN
        DECLARE  @BizDay int = 1
        if @Date is null set @Date        = GetDate()
        if DATEPART(weekday, @Date) % 6 = 1
                set @BizDay = 0
        else if (SELECT count(Holiday_Date) from [dbo].[CS_HOLIDAYS] where DateDiff(Day, HOLIDAY_DATE, @Date) = 0) = 0
                set @BizDay = 1
        RETURN @BizDay
END
GO
GRANT EXECUTE ON [dbo].[fn_IsBizDay]
    TO NEOS_UserRole
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_Max]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_Max]
GO
CREATE FUNCTION [dbo].[fn_Max] (
        @ValOne     as Int = 0,
        @ValTwo     as int = 0
)
RETURNS Int
AS
BEGIN
        Declare @Data as Int = @ValOne
        if @ValTwo > @Data set @Data = @ValTwo
        return @Data
END
GO
GRANT EXECUTE ON [dbo].[fn_Max]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_WhatIsAlias]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_WhatIsAlias]
GO
CREATE FUNCTION [dbo].[fn_WhatIsAlias] (
        @Code     as varchar(16) = '',
        @Switch   as int = -1                -- return switch default, Description from code, 1, Category from Code, 2. Code from description,                                                             -- 3 description from categroy, 4 category from description 5
)
RETURNS varchar(512)
AS
BEGIN
        Declare @Data as varchar(512) = ''
        set @Code = Upper(CAST(@Code as varchar(8)))
        if @Switch = 1
        BEGIN
                select @Data = [Description] from [dbo].[CodedAliases] where Alias = @Code        -- Description
        END
        Else if @Switch = 2
        BEGIN
                select @Data = [CategoryCode]  from [dbo].[CodedAliases] where Alias = @Code    -- category
        END
        Else if @Switch = 3
        BEGIN
                select @Data = [TypeCode]  from [dbo].[CodedAliases] where  Alias = @Code   -- TypeCode
        END
        Else if @Switch = 4
        BEGIN
                select @Data = [ReferenceID]  from [dbo].[CodedAliases] where Alias = @Code
        END
        Else if @Switch = 5
        BEGIN
                select @Data = [ReferenceName]  from [dbo].[CodedAliases] where Alias = @Code
        END
        Else if @Switch = 6
        BEGIN
                select @Data = [COMMENTS]  from [dbo].[CodedAliases] where Alias = @Code  -- Comments
        END
        Else if @Switch = 7
        BEGIN
                select @Data = [Alias]  from [dbo].[CodedAliases] where Alias = @Code  -- Alias
        END
        Else if @Switch = 8
        BEGIN
                select @Data = [CreatedBy]  from [dbo].[CodedAliases] where Alias = @Code
        END
        Else if @Switch = 9
        BEGIN
                select @Data = [DateCreated]  from [dbo].[CodedAliases] where Alias = @Code     --
        END
        Else if @Switch = 10
        BEGIN
                select @Data = [StatusCode]  from [dbo].[CodedAliases] where Alias = @Code  -- StatusCode
        END
        else
                select @Data = [NameCode]  from [dbo].[CodedAliases] where Alias = @Code
        RETURN @Data
ErrorHandle:
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_WhatIsAlias]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_RegisteredCode]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_RegisteredCode]
GO
CREATE FUNCTION [dbo].[fn_RegisteredCode] (
        @NameCode   as varchar(128) = ''                                                        -- 3 description from categroy, 4 category from description 5
)
RETURNS varchar(256)
AS
BEGIN
        Declare @Data as varchar(256) = ''
        Set @NameCode = Upper(RTRIM(LTRIM(@NameCode)))
        if len(@NameCode) > 0
        BEGIN
           if  IsNumeric(@NameCode) > 0
                 select @Data = [ValueCode] from [dbo].[CTEPESYSRegisteredCodes] where ID = cast( @NameCode as INT)
           else
           BEGIN
                 if CharIndex('[',@NameCode) > 0 set @NameCode = replace(replace(@NameCode, '[',''),']','')
                 select @Data = [ValueCode] from [dbo].[CTEPESYSRegisteredCodes] where Upper(NameCode) = @NameCode or ClassCode = @NameCode or ValueCode = @NameCode or Upper(ReferenceID) = @NameCode or Upper(ReferenceName) like '%;'+ @NameCode + ';%'
           END
        END
        RETURN @Data
ErrorHandle:
        Set @Data = 'ERR_00'
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_RegisteredCode]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_OwnerIDCode]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_OwnerIDCode]
GO
CREATE FUNCTION [dbo].[fn_OwnerIDCode] (
        @NameCode   as varchar(128) = ''                                                        -- 3 description from categroy, 4 category from description 5
)
RETURNS varchar(256)
AS
BEGIN
        Declare @Data as varchar(256) = ''
        Set @NameCode = Upper(RTRIM(LTRIM(@NameCode)))
        if len(@NameCode) > 0
        BEGIN
           if  IsNumeric(@NameCode) > 0
                 select @Data = [ValueCode] from [dbo].[RegisteredEntities] where ID = cast( @NameCode as INT)
           else
           BEGIN
                 if CharIndex('[',@NameCode) > 0 set @NameCode = replace(replace(@NameCode, '[',''),']','')
                 select @Data = [ValueCode] from [dbo].[RegisteredEntities] where Upper(NameCode) = @NameCode or ClassCode = @NameCode or ValueCode = @NameCode or Upper(ReferenceID) = @NameCode or Upper(ReferenceName) like '%;'+ @NameCode + ';%'
           END
        END
        RETURN @Data
ErrorHandle:
        Set @Data = 'ERR_00'
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_OwnerIDCode]
    TO CTEPESYS_UserRole;
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_WhatIsCategory]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_WhatIsCategory]
GO
CREATE FUNCTION [dbo].[fn_WhatIsCategory] (
        @TableName   as varchar(128) = '',                                                        -- 3 description from categroy, 4 category from description 5
        @Switch as int = -1
)
RETURNS varchar(256)
AS
BEGIN
        Declare @Data as varchar(256) = ''
        Set @TableName = Upper(RTRIM(LTRIM(@TableName)))
        if len(@TableName) > 0
        BEGIN
                if @Switch =  0
                BEGIN
                        select @Data = [ID] from [dbo].[CodedCategoryCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  1
                BEGIN
                        select @Data = [StatusCode] from [dbo].[CodedCategoryCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  2
                BEGIN
                        select @Data = [CategoryCode] from [dbo].[CodedCategoryCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  3
                BEGIN
                        select @Data = [TypeCode] from [dbo].[CodedCategoryCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  4
                BEGIN
                        select @Data = [Alias] from [dbo].[CodedCategoryCodes] where Upper(NameCode) Like @TableName + '%'
                END
                else if @Switch =  5
                BEGIN
                        select @Data = [Comments] from [dbo].[CodedCategoryCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  9
                BEGIN
                        select @Data = [Description] from [dbo].[CodedCategoryCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  10
                BEGIN
                        select @Data = [NameCode] from [dbo].[CodedCategoryCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else
                BEGIN
                        select @Data = [ValueCode] from [dbo].[CodedCategoryCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
        END
        RETURN @Data
ErrorHandle:
        Set @Data = 'ERR_00'
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_WhatIsCategory]
    TO CTEPESYS_UserRole;
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_WhatIsType]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_WhatIsType]
GO
CREATE FUNCTION [dbo].[fn_WhatIsType] (
        @TableName   as varchar(128) = '',                                                        -- 3 description from categroy, 4 category from description 5
        @Switch as int = -1
)
RETURNS varchar(256)
AS
BEGIN
        Declare @Data as varchar(256) = ''
        Set @TableName = Upper(RTRIM(LTRIM(@TableName)))
        if len(@TableName) > 0
        BEGIN
                if @Switch =  0
                BEGIN
                        select @Data = [ID] from [dbo].[CodedTypeCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  1
                BEGIN
                        select @Data = [StatusCode] from [dbo].[CodedTypeCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  2
                BEGIN
                        select @Data = [CategoryCode] from [dbo].[CodedTypeCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  3
                BEGIN
                        select @Data = [TypeCode] from [dbo].[CodedTypeCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  4
                BEGIN
                        select @Data = [Alias] from [dbo].[CodedTypeCodes] where Upper(NameCode) Like @TableName + '%'
                END
                else if @Switch =  5
                BEGIN
                        select @Data = [Comments] from [dbo].[CodedTypeodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  9
                BEGIN
                        select @Data = [Description] from [dbo].[CodedTypeCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  10
                BEGIN
                        select @Data = [NameCode] from [dbo].[CodedTypeCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else
                BEGIN
                        select @Data = [ValueCode] from [dbo].[CodedTypeCodes] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
        END
        RETURN @Data
ErrorHandle:
        Set @Data = 'ERR_00'
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_WhatIsType]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_WhatIsOrganization]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_WhatIsOrganization]
GO
CREATE FUNCTION [dbo].[fn_WhatIsOrganization] (
        @TableName   as varchar(128) = '',                                                        -- 3 description from categroy, 4 category from description 5
        @Switch as int = -1
)
RETURNS varchar(256)
AS
BEGIN
        Declare @Data as varchar(256) = ''
        Set @TableName = Upper(RTRIM(LTRIM(@TableName)))
        if len(@TableName) > 0
        BEGIN
                if @Switch =  0
                BEGIN
                        select @Data = [ID] from [dbo].[Organizations] where ValueCode = @TableName or Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  1
                BEGIN
                        select @Data = [StatusCode] from [dbo].[Organizations] where ValueCode = @TableName or Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  2
                BEGIN
                        select @Data = [CategoryCode] from [dbo].[Organizations] where ValueCode = @TableName or Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  3
                BEGIN
                        select @Data = [TypeCode] from [dbo].[Organizations] where ValueCode = @TableName or Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  4
                BEGIN
                        select @Data = [Alias] from [dbo].[Organizations] where ValueCode = @TableName or Upper(NameCode) Like @TableName + '%'
                END
                else if @Switch =  5
                BEGIN
                        select @Data = [Comments] from [dbo].[Organizations] where ValueCode = @TableName or Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  9
                BEGIN
                        select @Data = [Description] from [dbo].[Organizations] where ValueCode = @TableName or Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  10
                BEGIN
                        select @Data = [NameCode] from [dbo].[Organizations] where ValueCode = @TableName or Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else
                BEGIN
                        select @Data = [ValueCode] from [dbo].[Organizations] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
        END
        RETURN @Data
ErrorHandle:
        Set @Data = 'ERR_00'
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_WhatIsOrganization]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_WhatIsGroup]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_WhatIsGroup]
GO
CREATE FUNCTION [dbo].[fn_WhatIsGroup] (
        @TableName   as varchar(128) = '',                                                        -- 3 description from categroy, 4 category from description 5
        @Switch as int = -1
)
RETURNS varchar(256)
AS
BEGIN
        Declare @Data as varchar(256) = ''
        Set @TableName = Upper(RTRIM(LTRIM(@TableName)))
        if len(@TableName) > 0
        BEGIN
                if @Switch =  0
                BEGIN
                        select @Data = [ID] from [dbo].[CodedGroups] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  1
                BEGIN
                        select @Data = [StatusCode] from [dbo].[CodedGroups] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  2
                BEGIN
                        select @Data = [CategoryCode] from [dbo].[CodedGroups] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  3
                BEGIN
                        select @Data = [TypeCode] from [dbo].[CodedGroups] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  4
                BEGIN
                        select @Data = [Alias] from [dbo].[CodedGroups] where Upper(NameCode) Like @TableName + '%'
                END
                else if @Switch =  5
                BEGIN
                        select @Data = [Comments] from [dbo].[CodedGroups] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  9
                BEGIN
                        select @Data = [Description] from [dbo].[CodedGroups] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  10
                BEGIN
                        select @Data = [NameCode] from [dbo].[CodedGroups] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else
                BEGIN
                        select @Data = [ValueCode] from [dbo].[CodedGroups] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
        END
        RETURN @Data
ErrorHandle:
        Set @Data = 'ERR_00'
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_WhatIsGroup]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_WhatIsRole]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_WhatIsRole]
GO
CREATE FUNCTION [dbo].[fn_WhatIsRole] (
        @TableName   as varchar(128) = '',                                                        -- 3 description from categroy, 4 category from description 5
        @Switch as int = -1
)
RETURNS varchar(256)
AS
BEGIN
        Declare @Data as varchar(256) = ''
        Set @TableName = Upper(RTRIM(LTRIM(@TableName)))
        if len(@TableName) > 0
        BEGIN
                if @Switch =  0
                BEGIN
                        select @Data = [ID] from [dbo].[CodedRoles] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  1
                BEGIN
                        select @Data = [StatusCode] from [dbo].[CodedRoles] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  2
                BEGIN
                        select @Data = [CategoryCode] from [dbo].[CodedRoles] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  3
                BEGIN
                        select @Data = [TypeCode] from [dbo].[CodedRoles] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  4
                BEGIN
                        select @Data = [Alias] from [dbo].[CodedRoles] where Upper(NameCode) Like @TableName + '%'
                END
                else if @Switch =  5
                BEGIN
                        select @Data = [Comments] from [dbo].[CodedRoles] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  9
                BEGIN
                        select @Data = [Description] from [dbo].[CodedRoles] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else if @Switch =  10
                BEGIN
                        select @Data = [NameCode] from [dbo].[CodedRoles] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
                else
                BEGIN
                        select @Data = [ValueCode] from [dbo].[CodedRoles] where Upper(NameCode) Like @TableName + '%' or @TableName = Alias
                END
        END
        RETURN @Data
ErrorHandle:
        Set @Data = 'ERR_00'
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_WhatIsRole]
    TO CTEPESYS_UserRole;
Go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_ActionForRepeatTime]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_ActionForRepeatTime]
GO
CREATE FUNCTION [dbo].[fn_ActionForRepeatTime] (
       @Num as int = 0,
       @ReptCode as varchar(16) = 'C_ONCE',
       @LastDate as DateTime = Null
)
RETURNS Int
AS
BEGIN
        Declare @Act as Int = 0, @NextTime as DateTime = GetDate()

        if @ReptCode = 'C_ONCE'
            Set @NextTime = DateAdd(SECOND, @Num, @LastDate)
        else if left(@ReptCode,5) = 'C_SEC'
            Set @NextTime = DateAdd(SECOND, @Num, @LastDate)
        else if Left(@ReptCode,5) = 'C_MIN'
            Set @NextTime = DateAdd(MINUTE, @Num, @LastDate)
        else if Left(@ReptCode,6) = 'C_HOUR'
            Set @NextTime = DateAdd(HOUR, @Num, @LastDate)
        else if Left(@ReptCode,4) = 'C_DA'
            Set @NextTime = DateAdd(DAY, @Num, @LastDate)
        else if Left(@ReptCode,6) = 'C_WEEK'
            Set @NextTime = DateAdd(WEEK, @Num, @LastDate)
        else if Left(@ReptCode,7) = 'C_MONTH'
            Set @NextTime = DateAdd(MONTH, @Num, @LastDate)
        else if Left(@ReptCode,6) = 'C_YEAR'
            Set @NextTime = DateAdd(YEAR, @Num, @LastDate)
        else
            Goto ErrorHandle
        if @NextTime is null and @Num > 0
           set @Act = 2
        else if DateDiff(Second, @NextTime, GetDate()) >= 0 and @Num > 0
            set @Act = 1
        else
            set @Act = 0
        RETURN @Act
ErrorHandle:
        Set @Act = -1
        Return @Act
END

GO
GRANT EXECUTE ON [dbo].[fn_ActionForRepeatTime]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_GetCommunication]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_GetCommunication]
GO
CREATE FUNCTION [dbo].[fn_GetCommunication] (
       @OwnerID as int = NULL,
       @OwnerIDCode as varchar(16) = NULL,
       @CommCode as varchar(16) = 'C_EMAIL'
)
RETURNS varchar(256)
AS
BEGIN
        Declare @Data as varchar(256) = ''
        set @OwnerIDCode = UPPER(LTRIM(RTRIM(@OwnerIDCode)))
        if isNull(@OwnerID,0) < 1 or  isNull(@OwnerIDCode,'') = '' Goto ERRLOG
        set @CommCode = UPPER(LTRIM(RTRIM(@CommCode)))
        if Left(@OwnerIDCode,2) <> 'E_' set @OwnerID = dbo.fn_OwnerIDCode(@OwnerIDCode)

        if @CommCode = 'C_EMAIL'
        BEGIN
           select Top 1 @Data = CASE WHEN isNull(Email,'') = '' THEN AlternativeEmail ELSE Email END from TelecomAddresses where OwnerID =@OwnerID and OwnerIDCode = @OwnerIDCode order by PrimaryIndicator DESC
           if Len(@Data) < 2 select @Data = AlternativeEmail from TelecomAddresses where OwnerID =@OwnerID and OwnerIDCode = @OwnerIDCode  order by PrimaryIndicator DESC
        END
        else if @CommCode = 'C_URL'
           select  Top 1 @Data = URL from TelecomAddresses where OwnerID =@OwnerID and OwnerIDCode = @OwnerIDCode  order by PrimaryIndicator DESC
        else if @CommCode = 'C_FACEBOOK'
           select  Top 1 @Data = Facebook from TelecomAddresses where OwnerID =@OwnerID and OwnerIDCode = @OwnerIDCode   order by PrimaryIndicator DESC
        else if @CommCode = 'C_TWITTER'
           select  Top 1 @Data = Twitter from TelecomAddresses where OwnerID =@OwnerID and OwnerIDCode = @OwnerIDCode   order by PrimaryIndicator DESC
        else if @CommCode = 'C_PHONE'
           select  Top 1 @Data = CASE WHEN IsNull(Phone,'') = '' THEN AlternativePhone ELSE Phone END from TelecomAddresses where OwnerID =@OwnerID and OwnerIDCode = @OwnerIDCode  order by PrimaryIndicator DESC
        else if @CommCode = 'C_MOBILE'
           select  Top 1 @Data = Mobile from TelecomAddresses where OwnerID =@OwnerID and OwnerIDCode = @OwnerIDCode  order by PrimaryIndicator DESC
        else if @CommCode = 'C_EMAIL'
        BEGIN
           select  Top 1 @Data = Phone from TelecomAddresses where OwnerID =@OwnerID and OwnerIDCode = @OwnerIDCode  order by PrimaryIndicator DESC
           if Len(@Data) < 2 select @Data = AlternativePhone from TelecomAddresses where OwnerID =@OwnerID and OwnerIDCode = @OwnerIDCode  order by PrimaryIndicator DESC
        END
        else
           set @Data = ''
        RETURN @Data
ERRLOG:
        Set @Data = ''
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_GetCommunication]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_Status]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_Status]
GO
CREATE FUNCTION [dbo].[fn_Status] (
        @NameCode as varchar(128)= '',
        @STATUS as varchar(8) = 'ACTIVE'
)
RETURNS int
AS
BEGIN
        DECLARE  @RtCode int = 0
        set @STATUS = UPPER(LTRIM(RTRIM(@STATUS)))
        if (select StatusCode from CTEPESYSRegisteredCodes where ValueCode = dbo.fn_OwnerIDCode(@NameCode)) = @STATUS
           set @RtCode = 1
        RETURN @RtCode
END
GO
GRANT EXECUTE ON [dbo].[fn_Status]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_Flag]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_Flag]
GO
CREATE FUNCTION [dbo].[fn_Flag] (
        @NameCode as varchar(128)= '',
        @FlagCode as varchar(16) = 'C_STATUS',
        @STATUS as varchar(8) = 'ACTIVE'
)
RETURNS int
AS
BEGIN
        DECLARE  @RtCode int = 0, @ValueCode as varchar(16) =  dbo.fn_OwnerIDCode(@NameCode)
        set @STATUS = UPPER(LTRIM(RTRIM(@STATUS)))

        if CharIndex('[',@NameCode) > 0 set @NameCode = replace(replace(@NameCode, '[',''),']','')
        if @FlagCode = 'C_STATUS'
        BEGIN
          if (select StatusCode from RegisteredEntities where ValueCode = @ValueCode) = @STATUS
           set @RtCode = 1
        END
        else if @FlagCode = 'C_AUDIT'
        BEGIN
           if (select top 1 Cast(AuditIndicator as varchar(8)) from RegisteredEntities where ValueCode = @ValueCode) = @STATUS
              set @RtCode = 1
        END
        else
          set @RtCode = -1
        RETURN @RtCode
END
GO
GRANT EXECUTE ON [dbo].[fn_Flag]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_GetUsersByGroup]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_GetUsersByGroup]
GO
CREATE FUNCTION [dbo].[fn_GetUsersByGroup] (
        @GroupCode varchar(256) = 'C_NITU',  -- multiple Names with separator ','
        @ResultCode varchar(16) = 'C_EMAIL'
)
RETURNS varchar(MAX)
AS
BEGIN
        Declare @RecCount int = 0, @LoopCnt int = 0, @Pos as int = 1, @Num as int, @NextPos as int = 0, @Cnt as int  = 0
        Declare @Users varchar(3000)='', @User_Id as varchar(150), @NameFlag as varchar(16) = ''
        Declare @UNT as table (RowID INT IDENTITY(1,1) NOT NULL, Contact varchar(256) NULL)

        set @GroupCode = lower(LTRIM(RTRIM(@GroupCode)))
        if len(@GroupCode) = 0
                goto ErrorHandle
        else if CHARINDEX(N';', @GroupCode) > 0
                set @GroupCode = replace(@GroupCode,';',',')
        SET @Num = 0
        SET @Pos = 1
        WHILE(@Pos <= LEN(@GroupCode))
        BEGIN
                SELECT @NextPos = CHARINDEX(N',', @GroupCode,  @Pos)
                IF (@NextPos = 0 OR @NextPos IS NULL)
                        SELECT @NextPos = LEN(@GroupCode) + 1
                SELECT @NameFlag = RTRIM(LTRIM(SUBSTRING(@GroupCode, @Pos, @NextPos - @Pos)))
                SELECT @Pos = @NextPos+1
                SET @Num = @Num + 1
                if @ResultCode = 'C_EMAIL'
                        insert into @UNT (Contact) select distinct a.Email from [dbo].[CodedGroups] g inner join [dbo].[GroupPersons] m on m.GroupID = g.ID inner join TelecomAddresses a on a.OwnerID = m.PersonID and a.OwnerIDCode = 'E_PERSON'
                        where g.ValueCode = @NameFlag and m.StatusCode = 'ACTIVE' and a.EMAIL not in (select contact from @UNT)
                else if @ResultCode = 'C_URL'
                        insert into @UNT (Contact) select distinct a.URL from [dbo].[CodedGroups] g inner join [dbo].[GroupPersons] m on m.GroupID = g.ID inner join TelecomAddresses a on a.OwnerID = m.PersonID and a.OwnerIDCode = 'E_PERSON'
                        where g.ValueCode = @NameFlag and m.StatusCode = 'ACTIVE' and a.URL not in (select contact from @UNT)
                else if @ResultCode = 'C_FACEBOOK'
                        insert into @UNT (Contact) select distinct a.Facebook from [dbo].[CodedGroups] g inner join [dbo].[GroupPersons] m on m.GroupID = g.ID inner join TelecomAddresses a on a.OwnerID = m.PersonID and a.OwnerIDCode = 'E_PERSON'
                        where g.ValueCode = @NameFlag and m.StatusCode = 'ACTIVE' and a.Facebook not in (select contact from @UNT)
                else if @ResultCode = 'C_TWITTER'
                        insert into @UNT (Contact) select distinct a.Twitter from [dbo].[CodedGroups] g inner join [dbo].[GroupPersons] m on m.GroupID = g.ID inner join TelecomAddresses a on a.OwnerID = m.PersonID and a.OwnerIDCode = 'E_PERSON'
                        where g.ValueCode = @NameFlag and m.StatusCode = 'ACTIVE' and a.Twitter not in (select contact from @UNT)
                else if @ResultCode = 'C_LINKEDIN'
                        insert into @UNT (Contact) select distinct a.LinkedIn from [dbo].[CodedGroups] g inner join [dbo].[GroupPersons] m on m.GroupID = g.ID inner join TelecomAddresses a on a.OwnerID = m.PersonID and a.OwnerIDCode = 'E_PERSON'
                        where g.ValueCode = @NameFlag and m.StatusCode = 'ACTIVE' and a.LinkedIn not in (select contact from @UNT)
                else if @ResultCode = 'C_RSS'
                        insert into @UNT (Contact) select distinct a.RSS from [dbo].[CodedGroups] g inner join [dbo].[GroupPersons] m on m.GroupID = g.ID inner join TelecomAddresses a on a.OwnerID = m.PersonID and a.OwnerIDCode = 'E_PERSON'
                        where g.ValueCode = @NameFlag and m.StatusCode = 'ACTIVE' and a.RSS not in (select contact from @UNT)
                else if @ResultCode = 'C_SMS' or @ResultCode = 'C_TXT_MSG'
                        insert into @UNT (Contact) select distinct a.SMSText from [dbo].[CodedGroups] g inner join [dbo].[GroupPersons] m on m.GroupID = g.ID inner join TelecomAddresses a on a.OwnerID = m.PersonID and a.OwnerIDCode = 'E_PERSON'
                        where g.ValueCode = @NameFlag and m.StatusCode = 'ACTIVE' and a.SMSText not in (select contact from @UNT)
                else if @ResultCode = 'C_PHONE' or @ResultCode = 'C_PHN_BUSINESS'
                        insert into @UNT (Contact) select distinct a.Phone from [dbo].[CodedGroups] g inner join [dbo].[GroupPersons] m on m.GroupID = g.ID inner join TelecomAddresses a on a.OwnerID = m.PersonID and a.OwnerIDCode = 'E_PERSON'
                        where g.ValueCode = @NameFlag and m.StatusCode = 'ACTIVE' and a.TypeCode in ( 'C_BUSINESS', 'C_WORK') and  a.Phone not in (select contact from @UNT)
                else if @ResultCode = 'C_PHN_HOME' or @ResultCode = 'C_PHN_VACATION'
                        insert into @UNT (Contact) select distinct a.Phone from [dbo].[CodedGroups] g inner join [dbo].[GroupPersons] m on m.GroupID = g.ID inner join TelecomAddresses a on a.OwnerID = m.PersonID and a.OwnerIDCode = 'E_PERSON'
                        where g.ValueCode = @NameFlag and m.StatusCode = 'ACTIVE' and  a.TypeCode in ( 'C_HOME', 'C_VACATION' ) and  a.Phone not in (select contact from @UNT)
                else if @ResultCode = 'C_MOBILE' or @ResultCode = 'C_CELL'
                        insert into @UNT (Contact) select distinct a.Mobile from [dbo].[CodedGroups] g inner join [dbo].[GroupPersons] m on m.GroupID = g.ID inner join TelecomAddresses a on a.OwnerID = m.PersonID and a.OwnerIDCode = 'E_PERSON'
                        where g.ValueCode = @NameFlag and m.StatusCode = 'ACTIVE' and a.Mobile not in (select contact from @UNT)
                else if @ResultCode = 'C_NAME' or @ResultCode = 'C_FULLNAME'
                        insert into @UNT (Contact) select distinct RTRIM(a.LastName + ', ' + a.FirstName + ' ' + isNull(a.MiddleName,'')) from [dbo].[CodedGroups] g inner join [dbo].[GroupPersons] m on m.GroupID = g.ID inner join Persons a on a.ID = m.PersonID
                        where g.ValueCode = @NameFlag and m.StatusCode = 'ACTIVE' and RTRIM(a.LastName + ', ' + a.FirstName + ' ' + isNull(a.MiddleName,'')) not in (select contact from @UNT)
                else if @ResultCode = 'C_ADDRESS' or @ResultCode = 'C_ADR_BUSINESS'
                        insert into @UNT (Contact) select distinct a.NameCode from [dbo].[CodedGroups] g inner join [dbo].[GroupPersons] m on m.GroupID = g.ID inner join Addresses a on a.OwnerID = m.PersonID and a.OwnerIDCode = 'E_PERSON'
                        where g.ValueCode = @NameFlag and m.StatusCode = 'ACTIVE' and a.NameCode not in (select contact from @UNT)

        END
        SET @LoopCnt = 1
        select @RecCount = Count(RowID) from @UNT
        WHILE @RecCount >= @LoopCnt
        BEGIN
                SELECT @User_Id = Contact from @UNT WHERE RowID = @LoopCnt
                SET @Users =  (@Users + ';' + @User_Id)
                Set  @LoopCnt =  @LoopCnt + 1
        END
        if len(@Users) > 1
                Set @Users = substring(@Users, 2, len(@Users) -1 )
        RETURN @Users
ErrorHandle:
        return @Users
END;
GO
GRANT EXECUTE ON [dbo].[fn_GetUsersByGroup]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_GetFullName]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_GetFullName]
GO
CREATE FUNCTION [dbo].[fn_GetFullName] (
        @NameCode varchar(512) = '',                  -- multiple Names with separator ';', or ','
        @TypeCode varchar(16)  = 'C_ORAGNIZATION'     -- or Vendor/user, Company, Contact, Contract, Department, Agency, Office, ...
)
RETURNS Varchar(MAX)
AS
BEGIN
        Declare @FullName as varchar(MAX) = @TypeCode, @DBName as varchar(128) = UPPER(DB_Name())

        set @NameCode = LTRIM(RTRIM(@NameCode))
        set @TypeCode = Upper(LTRIM(RTRIM(@TypeCode)))
        if len(@NameCode) = 0
                goto ErrorHandle
        else if charIndex(',', @NameCode) > 0
                set @NameCode = replace(@NameCode,',',';')
        if charIndex(';', @NameCode) > 0
        BEGIN
                declare @Pos as int = 1, @NextPos as int = 0, @NameID as varchar(64) =''
                set @NameCode = ''
                WHILE(@Pos <= LEN(@NameCode))
                BEGIN
                        SELECT @NextPos = CHARINDEX(N';', @NameCode,  @Pos)
                        IF (@NextPos = 0 OR @NextPos IS NULL)                SELECT @NextPos = LEN(@NameCode) + 1
                        SELECT @NameID = RTRIM(LTRIM(SUBSTRING(@NameCode, @Pos, @NextPos - @Pos)))
                        SELECT @Pos = @NextPos+1
                        set @FullName = [dbo].fn_GetFullName(@NameID,@TypeCode) + ';' + @FullName
                END
                if len (@FullName) < 3
                        set @FullName = @TypeCode
                else
                        set @FullName = SubString( @FullName, 1, len(@FullName) - 1)
        END
        else if Left(@DBName,8) = 'CTEPESYS'
        BEGIN
                if @TypeCode = 'C_PERSON'
                BEGIN
                        select @FullName = RTRIM(p.LastName + ', ' + p.FirstName + ' ' + isnull(p.MiddleName,''))
                        from [dbo].Persons p inner join TelecomAddresses a on p.ID = a.OwnerID and a.OwnerIDCode = 'E_PERSON'
                        where cast(p.ID as varchar(16)) = @NameCode or a.Email = @NameCode or a.AlternativeEmail = @NameCode
                END
                else if @TypeCode = 'C_USER' or @TypeCode = 'C_ACCOUNT'
                BEGIN
                        select @FullName = p.NameCode
                        from [dbo].[Profiles] p Left join TelecomAddresses a on p.OwnerID = a.OwnerID and a.OwnerIDCode = p.OwnerIDCode
                        where a.NameCode = @NameCode or p.ModuleCode = 'C_PERSON' and (cast(p.OwnerID as varchar(16)) = @NameCode or cast(p.ID as varchar(16)) = @NameCode or a.Email = @NameCode or a.AlternativeEmail = @NameCode)
                END
                else if @TypeCode = 'C_GROUP'
                BEGIN
                        select @FullName = p.NameCode
                        from [dbo].[CodedGroups] p Left join TelecomAddresses a on p.ID = a.OwnerID and a.OwnerIDCode = 'E_GROUP'
                        where a.NameCode = @NameCode or p.NameCode = @NameCode or cast(p.ID as varchar(16)) = @NameCode or p.ValueCode = @NameCode or a.Email = @NameCode or a.AlternativeEmail = @NameCode
                END
                else if @TypeCode = 'C_ORGANIZATION'
                BEGIN
                        select @FullName = p.NameCode
                        From [dbo].[Organizations] p Left join TelecomAddresses a on p.ID = a.OwnerID and a.OwnerIDCode = 'E_ORGANIZATION'
                        where a.NameCode = @NameCode or p.NameCode = @NameCode or cast(p.ID as varchar(16)) = @NameCode or p.ValueCode = @NameCode or a.Email = @NameCode or a.AlternativeEmail = @NameCode

                END
                else if @TypeCode = 'C_STUDY'
                        select @FullName = [Description]
                        from [dbo].[StudyProtocols]
                        where NameCode=@NameCode or cast(ID as varchar(16)) = @NameCode
                else if @TypeCode = 'C_AGENT'
                BEGIN
                        select @FullName = p.Description
                        from [dbo].[CodedAgents] p
                        where ValueCode =  @NameCode or cast(p.ID as varchar(16)) = @NameCode
                END
                else if @TypeCode = 'C_DISEASE'
                BEGIN
                        select @FullName = p.Description
                        from [dbo].[CodedDiseases] p
                        Where ValueCode =  @NameCode or cast(p.ID as varchar(16)) = @NameCode
                END
                else
                BEGIN
                    set @FullName = @TypeCode
                END
        END
        RETURN @FullName
ErrorHandle:
        Return @FullName
END
GO
GRANT EXECUTE ON [dbo].[fn_GetFullName]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_GetEmailsByOID]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_GetEmailsByOID]
GO
CREATE FUNCTION [dbo].[fn_GetEmailsByOID] (
        @OID as varchar(16) = '',
        @OwnerIDCode as varchar(16) = 'E_PERSON'
)
RETURNS varchar(128)
AS
BEGIN
        Declare @RtCode as varchar(128) = '', @OwnerID as int = 0

        if isnumeric(@OID) > 0 set @OwnerID = cast(@OID as int)

        Select Top 1 @RtCode = isNull(Email,AlternativeEmail) From TelecomAddresses where ID = @OwnerID and OwnerIDCode = @OwnerIDCode order by PrimaryIndicator DESC

        RETURN @RtCode
END
GO
GRANT EXECUTE ON [dbo].[fn_GetEmailsByOID]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_GetEmails]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_GetEmails]
GO
CREATE FUNCTION [dbo].[fn_GetEmails] (
        @Mailers as varchar(5000) = '',                              --- C_CODE:ValueCode1;ValueCode2  or C_OWNER:OwnerID1:OwnerIDCode1;OwnerID2:OwnerIDCode2
        @TypeCode as varchar(16) = 'C_EMAIL_TO'
)
RETURNS varchar(MAX)
AS
BEGIN
        Declare @RtCode as varchar(MAX) = '', @CID as int = 0, @OMailers as varchar(4500) = ''
        set @Mailers = LTRIM(RTRIM(@Mailers))
        if @TypeCode = 'C_CHANNEL' or @TypeCode = 'C_NOTIFICATION'
        BEGIN
             if isNumeric(@Mailers) > 0
                set @CID = cast(@Mailers as int)
             else
                set @CID = dbo.fn_CodedOwnerID('NotificationChannel',@Mailers)
             if @CID > 0
             Select @RtCode = @RtCode + ';' + LTRIM(isNull(a.Email,a.AlternativeEmail))
             From TelecomAddresses a inner join Profiles p on a.OwnerID = p.OwnerID and p.OwnerIDCode = a.OwnerIDCode and a.StatusCode = p.StatusCode
             inner join Subscribers s on (s.OwnerID = a.OwnerID or s.OwnerID = p.ID) and (s.OwnerIDCode =a.OwnerIDCode or s.OwnerIDCode = 'E_PROFILE') and s.StatusCode = a.StatusCode
             inner join CodedNotificationChannels c on (s.ChannelID = c.ParentID or s.ChannelID = c.ID)
             Where c.ID =  @CID and s.StatusCode = 'ACTIVE'
        END
        else if left(@TypeCode,5) = 'C_SYS'
        BEGIN
              if @Mailers = 'C_GROUP'
                   Select @RtCode =  LTRIM(isNull(a.Email,a.AlternativeEmail))
                   From TelecomAddresses a inner join CodedGroups s on a.OwnerID = s.ID and a.OwnerIDCode = 'E_GROUP'  and a.StatusCode = s.StatusCode
                   Where s.ValueCode = @TypeCode and s.StatusCode = 'ACTiVE'
              else if @Mailers = 'C_PERSON'
                   Select @RtCode =  @RtCode + ';' + LTRIM(isNull(a.Email,a.AlternativeEmail))
                   From  CodedGroups g inner join GroupPersons s on s.GroupID = g.ID and s.StatusCode = g.StatusCode
                   Inner Join TelecomAddresses a on  a.OwnerID = s.PersonID and a.OwnerIDCode = 'E_PERSON' and a.StatusCode = s.StatusCode
                   Where g.ValueCode = @TypeCode and s.StatusCode = 'ACTiVE'
              else
              BEGIN
                   Select @RtCode =  LTRIM(isNull(a.Email,a.AlternativeEmail))
                   From TelecomAddresses a inner join CodedGroups s on a.OwnerID = s.ID and a.OwnerIDCode = 'E_GROUP'  and a.StatusCode = s.StatusCode
                   Where s.ValueCode = @TypeCode and s.StatusCode = 'ACTiVE'
                   Select @RtCode =  @RtCode + ';' + LTRIM(isNull(a.Email,a.AlternativeEmail))
                   From  CodedGroups g inner join GroupPersons s on s.GroupID = g.ID and s.StatusCode = g.StatusCode
                   Inner Join TelecomAddresses a on  a.OwnerID = s.PersonID and a.OwnerIDCode = 'E_PERSON' and a.StatusCode = s.StatusCode
                   Where g.ValueCode = @TypeCode and s.StatusCode = 'ACTiVE'
              END
        END
        else
        BEGIN
           declare @iPos as int = CharIndex('#',@Mailers)
           if @iPos > 0
           BEGIN
                Set @OMailers = SUBSTRING(@Mailers, @iPos+1, Len(@Mailers) - @iPos)
                Set @Mailers = SUBSTRING(@Mailers, 1, @iPos-1)
           END
           Set @iPos = CharIndex('C_CODE:',@Mailers)

           if CharIndex('C_',@Mailers) = 0  or left(@Mailers,6) = 'C_SYS_' --- default
           BEGIN
                 set @Mailers = 'C_CODE:' + @Mailers
                 Set @iPos = 1
           END
           if @iPos > 0                           -- C_CODE:ValueCode1;ValueCode2
           BEGIN
                   Set @Mailers = LTRIM(Right(@Mailers, Len(@Mailers)-7))
                   if CharIndex(';', @Mailers) > 1
                      Select @RtCode =  @RtCode + ';' + LTRIM(isNull(a.Email,a.AlternativeEmail))
                      From ServiceLists s inner join ListItems l on s.ID = l.ListID and s.StatusCode = l.StatusCode inner join TelecomAddresses a on a.OwnerID = l.OwnerID and a.OwnerIDCode = l.OwnerIDCode and a.StatusCode = l.StatusCode
                      Where s.TypeCode = @TypeCode and l.StatusCode = 'ACTIVE' and ';'+@Mailers +';' like +'%;' + s.ReferenceID +';%'
                   else
                      Select @RtCode =  @RtCode + ';' + LTRIM(isNull(a.Email,a.AlternativeEmail))
                      From ServiceLists s inner join ListItems l on s.ID = l.ListID and s.StatusCode = l.StatusCode inner join TelecomAddresses a on a.OwnerID = l.OwnerID and a.OwnerIDCode = l.OwnerIDCode and a.StatusCode = l.StatusCode
                      Where s.TypeCode = @TypeCode and l.StatusCode = 'ACTIVE' and @Mailers = s.ReferenceID
           End
           else if CharIndex('C_OWNER:',@Mailers) = 1    -- C_OWNER:OwnerID1:OwnerIDCode1;OwnerID2:OwnerIDCode2
           BEGIN
                   Set @Mailers = LTRIM(Right(@Mailers, Len(@Mailers)-8))
                   if CharIndex(';', @Mailers) > 1
                      Select @RtCode =  @RtCode + ';' + LTRIM(isNull(a.Email,a.AlternativeEmail))
                      From ServiceLists s inner join ListItems l on s.ID = l.ListID and s.StatusCode = l.StatusCode inner join TelecomAddresses a on a.OwnerID = l.OwnerID and a.OwnerIDCode = l.OwnerIDCode and a.StatusCode = l.StatusCode
                      Where s.TypeCode = @TypeCode and l.StatusCode = 'ACTIVE' and ';'+@Mailers +';' like +'%;' + cast(s.OwnerID as varchar(16)) + ':'+ s.OwnerIDCode +';%'
                   else
                      Select @RtCode =  @RtCode + ';' + LTRIM(isNull(a.Email,a.AlternativeEmail))
                      From ServiceLists s inner join ListItems l on s.ID = l.ListID and s.StatusCode = l.StatusCode inner join TelecomAddresses a on a.OwnerID = l.OwnerID and a.OwnerIDCode = l.OwnerIDCode and a.StatusCode = l.StatusCode
                      Where s.TypeCode = @TypeCode and l.StatusCode = 'ACTIVE' and @Mailers = cast(s.OwnerID as varchar(16)) + ':' + s.OwnerIDCode
           END
        END
        if CharIndex ('@', @OMailers ) > 0 set @RtCode = @RtCode + ';' + @OMailers
        if CharIndex(';', @RtCode) = 1 set @RtCode = SubString(@RtCode,2, Len(@RtCode)-1)

        RETURN @RtCode
END
GO
GRANT EXECUTE ON [dbo].[fn_GetEmails]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_CodedValueCode]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_CodedValueCode]
GO
CREATE FUNCTION [dbo].[fn_CodedValueCode] (
        @NameCode    as varchar(128) = 'ORGANIZATION',                                    -- 3 description from categroy, 4 category from description 5
        @ID          as int = 0
)
RETURNS VarChar(16)
AS
BEGIN
        Declare @ValueCode as VarChar(16) = ''
        Set @NameCode = Upper(RTRIM(LTRIM(@NameCode)))
        if len(@NameCode) > 0 and @ID > 0
        BEGIN
                if @NameCode = 'ORGANIZATION' or @NameCode = 'ORG' or dbo.fn_OwnerIDCode(@NameCode) = 'E_ORGANIZATION'
                     select @ValueCode = ValueCode from Organizations where ID = @ID
                else if @NameCode = 'GROUP' or @NameCode = 'CODEDGROUPS' or dbo.fn_OwnerIDCode(@NameCode) = 'E_GROUP'
                     select @ValueCode = ValueCode from CodedGroups where ID = @ID
                else if @NameCode = 'PROFILE' or @NameCode = 'PROFILES' or dbo.fn_OwnerIDCode(@NameCode) = 'E_PROFILE'
                     select @ValueCode = ValueCode from Profiles where ID = @ID
                else if @NameCode = 'AGENT' or @NameCode = 'CODEDAGENTS' or dbo.fn_OwnerIDCode(@NameCode) = 'E_AGENT'
                     select @ValueCode = ValueCode from CodedAgents where ID = @ID
                else if @NameCode = 'ALIAS' or @NameCode = 'CODEDALIASES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_ALAIS'
                     select @ValueCode = ValueCode from CodedGroups where ID = @ID
                else if @NameCode = 'DATA' or @NameCode = 'CODEDDATA'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_DATA'
                     select @ValueCode = ValueCode from CodedData where ID = @ID
                else if @NameCode = 'REASON' or @NameCode = 'CODEDREASONS'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_REASON'
                     select @ValueCode = ValueCode from CodedReasons where ID = @ID
                else if @NameCode = 'DISEASE' or @NameCode = 'CODEDDISEASES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_DISEASE'
                     select @ValueCode = ValueCode from CodedDiseases where ID = @ID
                else if @NameCode = 'MESSAGE' or @NameCode = 'CODEDDMESSAGES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_MESSAGE'
                     select @ValueCode = ValueCode from CodedMessages where ID = @ID
                else if @NameCode = 'EVENT' or @NameCode = 'CODEDDEVENTS'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_EVENT'
                     select @ValueCode = ValueCode from CodedEvents where ID = @ID
                else if @NameCode = 'ROLE' or @NameCode = 'CODEROLES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_ROLE'
                     select @ValueCode = ValueCode from CodedRoles where ID = @ID
                else if @NameCode = 'DISEASE' or @NameCode = 'CODEDERRORS'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_ERROR'
                     select @ValueCode = ValueCode from CodedErrors where ID = @ID
                else if @NameCode = 'ERROR' or @NameCode = 'CODEDREASONS'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_REASON'
                     select @ValueCode = ValueCode from CodedReasons where ID = @ID
                else if @NameCode = 'ACTIVITY' or @NameCode = 'CODEDACTIVITIES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_ACTIVITY'
                     select @ValueCode = ValueCode from CodedActivities where ID = @ID
                else if @NameCode = 'REPORT' or @NameCode = 'CODEDREPORTS'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_REPORT'
                     select @ValueCode = ValueCode from CodedReports where ID = @ID
                else if @NameCode = 'TEMPLATE' or @NameCode = 'CODEDTEPLATES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_TEMPLATE'
                     select @ValueCode = ValueCode from CodedTemplates where ID = @ID
                else if @NameCode = 'COUNTRY' or @NameCode = 'CODEDCOUNTRIES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_COUNTRY'
                     select @ValueCode = ValueCode from CodedCountries where ID = @ID
                else if @NameCode = 'COUNTY' or @NameCode = 'CODEDCOUNTIES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_COUNTY'
                     select @ValueCode = ValueCode from CodedCounties where ID = @ID
                else if @NameCode = 'STATEPROVINCE' or @NameCode = 'CODEDSTATESPROVINCES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_STAT_PROV'
                     select @ValueCode = ValueCode from CodedStatesProvinces where ID = @ID
                else if @NameCode = 'VALUESET' or @NameCode = 'CODEDVALUESETS'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_VALUESET'
                     select @ValueCode = ValueCode from CodedValueSets where ID = @ID
                else if @NameCode = 'BIOMARKER' or @NameCode = 'CODEDBIOMARKERS'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_BIOMARKER'
                     select @ValueCode = ValueCode from CodedBiomarkers where ID = @ID
                else if @NameCode = 'TYPECODE' or @NameCode = 'TYPE' or @NameCode = 'CODEDTYPECODES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_TYPE_CODE'
                     select @ValueCode = ValueCode from CodedTypeCodes where ID = @ID
                else if @NameCode = 'CATEGORYCODE' or @NameCode = 'CATEGORY' or @NameCode = 'CODEDCATEGORYODES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_CATEGORY_CODE'
                     select @ValueCode = ValueCode from CodedCategoryCodes where ID = @ID
                else if @NameCode = 'LABORATORY' or @NameCode = 'CODEDLABORTORIES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_LABORATORY'
                     select @ValueCode = ValueCode from CodedLaboratories where ID = @ID
                else if @NameCode = 'DATA' or @NameCode = 'CODEDDATA'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_DATA'
                     select @ValueCode = ValueCode from CodedData where ID = @ID
                else if @NameCode = 'POSTCODE' or @NameCode = 'CODEDPOSTCODES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_POSTCODE'
                     select @ValueCode = ValueCode from CodedPostCodes where ID = @ID
                else if @NameCode = 'HOLIDAY' or @NameCode = 'CODEDHOLIDAYS'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_HOLIDAY'
                     select @ValueCode = ValueCode from CodedHolidays where ID = @ID
                else if @NameCode = 'OUTCOMEMEASURE' or @NameCode = 'CODEDOUTCOMEMEASURES'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_OUTCOME_MEAS'
                     select @ValueCode = ValueCode from CodedOutcomeMeasures where ID = @ID
                else if @NameCode = 'REGISTRATION' or @NameCode = 'REGISTRATIONCENTER' or @NameCode = 'CODEDREGISTRATIONCENTER'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_REG_CENTER'
                     select @ValueCode = ValueCode from CodedRegistrationCenters where ID = @ID
                else if @NameCode = 'MILESTONE' or @NameCode = 'CODEDMILESTONE'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_MILESTONE'
                     select @ValueCode = ValueCode from CodedMilestones where ID = @ID
                else if @NameCode = 'NOTIFICATION' or @NameCode = 'CODEDNOTIFICATIONCHANNELS'  or dbo.fn_OwnerIDCode(@NameCode) = 'E_NOTN_CHANNEL'
                     select @ValueCode = ValueCode from CodedNotificationChannels where ID = @ID
                else
                     set  @ValueCode = ''
        END
        RETURN @ValueCode
ErrorHandle:
        Return @ValueCode
END

GO
GRANT EXECUTE ON [dbo].[fn_CodedValueCode]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_ID]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_ID]
GO
CREATE FUNCTION [dbo].[fn_ID] (
        @NameCode  as varchar(128) = 'E_ORGANIZATION',
        @ValueCode as varchar(16) ='',
        @ID as Int = 0
)
RETURNS int
AS
BEGIN
        Declare @RID as int = NULL
        if @ID > 0
        BEGIN
                set @NameCode = dbo.fn_OwnerIDCode(@NameCode)

                if @NameCode = 'E_PROFILE'
                    Select @RID = ID From Profiles  where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_ADDRESS'
                    Select @RID = ID From Addresses where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_TEL_ADDRESS'
                    Select @RID = ID From TelecomAddresses where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_DOCUMENT'
                    Select @RID = ID From Documents where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_SUBM_REVIEW'
                    Select @RID = ID From SubmissionReviews where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_SUBM_ITEM'
                    Select @RID = ID From SubmissionItems where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_EVT_LOG'
                    Select @RID = ID From EventLogs where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_WKF_LOG'
                    Select @RID = ID From WorkflowLogs where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_TSK_LOG'
                    Select @RID = ID From TaskLogs where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_LST_ITEM'
                    Select @RID = ID From ListItems where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_SVC_LIST'
                    Select @RID = ID From ServiceLists where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_SCHR_LOG'
                    Select @RID = ID From SchedulerLogs where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_COMMENT'
                    Select @RID = ID From Comments where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_CONTACT'
                    Select @RID = ID From Contacts where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_EVT_SUBMIT'
                    Select @RID = ID From SubmittedEvents Where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_EVT_RECIEVE'
                    Select @RID = ID From ReceivedEvents where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
                else if @NameCode = 'E_DATA_ACCESS'
                    Select @RID = DataID From DataAccesses where OwnerID = @ID and OwnerIDCode = dbo.fn_OwnerIDCode(@ValueCode)
               /*

               */
        END
        RETURN @RID
END
GO
GRANT EXECUTE ON [dbo].[fn_ID]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_FullName]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_FullName]
GO
CREATE FUNCTION [dbo].[fn_FullName] (
        @NameCode  as varchar(128) = 'E_ORGANIZATION',
        @ValueCode as varchar(16) ='',
        @ID as Int = 0
)
RETURNS Varchar(2048)
AS
BEGIN
        Declare @RN as varchar(2048) = NULL
        if @ID > 0
        BEGIN
                set @NameCode = dbo.fn_OwnerIDCode(@NameCode)
                set @ValueCode = UPPER(LTRIM(RTRIM(@ValueCode)))
                if @NameCode = 'E_PROFILE'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From Profiles  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From Profiles  where ID = @ID
                    else
                       Select @RN = NameCode From Profiles  where ID = @ID
                END
                else if @NameCode = 'E_PERSON'
                BEGIN
                    if @ValueCode = 'C_BASIC'
                         Select @RN = LastName + ', ' + FirstName + case when MiddleName is not null then ' ' + MiddleName else '' End From Persons  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                         Select @RN = case When EducationLevelCode is not null then EducationLevelCode + '. ' else '' End + Case when Prefix is not null then Prefix + ' ' else '' End + dbo.fn_FullName(@NameCode,'C_BASIC', @ID) + case When Suffix is not null then ' '+ Suffix else '' END + case when TitleCode is not null then ', ' + TitleCode else '' End From Persons where ID = @ID
                    else if @ValueCode = 'C_ID'
                         select @RN =  dbo.fn_FullName(@NameCode,'C_BASIC', @ID)+':' + Initial +':' +Cast(BirthDate as varchar(18)) + ':' + RaceCode From Persons  where ID = @ID
                    else
                         Select @RN =  FirstName + ' ' + LastName + case when MiddleName is not null then ' ' + MiddleName else '' End From Persons  where ID = @ID
                END
                else if @NameCode = 'E_ORGANIZATION'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From Organizations  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From Organizations  where ID = @ID
                    else
                       Select @RN = NameCode From Organizations  where ID = @ID
                END
                else if @NameCode = 'E_GROUP'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedGroups  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedGroups  where ID = @ID
                    else
                       Select @RN = NameCode From CodedGroups  where ID = @ID
                END
                else if @NameCode = 'E_ROLE'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedRoles  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedRoles  where ID = @ID
                    else
                       Select @RN = NameCode From CodedRoles  where ID = @ID
                END
                else if @NameCode = 'E_MESSAGE'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedMessages  where ID = @ID
                    else if @ValueCode = 'C_MESSAGE'
                       select @RN = Message From CodedMessages  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedMessages  where ID = @ID
                    else
                       Select @RN = NameCode From CodedMessages  where ID = @ID
                END
                else if @NameCode = 'E_EVENT'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedEvents  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedEvents  where ID = @ID
                    else
                       Select @RN = NameCode From CodedEvents  where ID = @ID
                END
                else if @NameCode = 'E_CATEGORY'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedCategoryCodes  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedCategoryCodes  where ID = @ID
                    else
                       Select @RN = NameCode From CodedCategoryCodes  where ID = @ID
                END
                else if @NameCode = 'E_TYPE'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedTypeCodes  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedTypeCodes  where ID = @ID
                    else
                       Select @RN = NameCode From CodedTypeCodes  where ID = @ID
                END
                else if @NameCode = 'E_SCHEDULER'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedSchedulers  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedSchedulers  where ID = @ID
                    else
                       Select @RN = NameCode From CodedSchedulers  where ID = @ID
                END
                else if @NameCode = 'E_TASK'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedTasks  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedTasks  where ID = @ID
                    else
                       Select @RN = NameCode From CodedTasks  where ID = @ID
                END
                else if @NameCode = 'E_ERROR'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedErrors  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedErrors  where ID = @ID
                    else
                       Select @RN = NameCode From CodedErrors  where ID = @ID
                END
                else if @NameCode = 'E_ACTIVITY'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedActivities  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedActivities  where ID = @ID
                    else
                       Select @RN = NameCode From CodedActivities  where ID = @ID
                END
                else if @NameCode = 'E_AGENT'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedAgents  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedAgents  where ID = @ID
                    else
                       Select @RN = NameCode From CodedAgents  where ID = @ID
                END
                else if @NameCode = 'E_DISEASE'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedDiseases  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedDiseases  where ID = @ID
                    else
                       Select @RN = NameCode From CodedDiseases  where ID = @ID
                END
                else if @NameCode = 'E_VALUESET'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedValueSets  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedValueSets  where ID = @ID
                    else
                       Select @RN = NameCode From CodedValueSets  where ID = @ID
                END
                else if @NameCode = 'E_WORKFLOW'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedWorkFlows  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedWorkflows  where ID = @ID
                    else
                       Select @RN = NameCode From CodedWorkflows  where ID = @ID
                END
                else if @NameCode = 'E_ACRONYM'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From CodedAcronyms  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From CodedAcronyms  where ID = @ID
                    else
                       Select @RN = NameCode From CodedAcronyms where ID = @ID
                END
                else if @NameCode = 'E_METADATA'
                BEGIN
                    if @ValueCode = 'C_DESCRIPTION'
                       Select @RN = Description From Metadata  where ID = @ID
                    else if @ValueCode = 'C_FULL'
                       select @RN = NameCode + ':' + Description From Metadata  where ID = @ID
                    else
                       Select @RN = NameCode From Metadata  where ID = @ID
                END
                else if @NameCode = 'E_ADDRESS'
                    Select @RN = NameCode From Addresses where ID = @ID
                else if @NameCode = 'E_TEL_ADDRESS'
                    Select @RN = NameCode From TelecomAddresses where ID = @ID
                else if @NameCode = 'E_DOCUMENT'
                    Select @RN = NameCode From Documents where ID = @ID
                else if @NameCode = 'E_SUBMISSION'
                    Select @RN = NameCode From Submissions where ID = @ID
                else if @NameCode = 'E_SUBM_UNIT'
                    Select @RN = NameCode From SubmissionUnits where ID = @ID
                else if @NameCode = 'E_OWN_EVENT'
                    Select @RN = NameCode From OwnedEvents where OwnerID = @ID
                else if @NameCode = 'E_OWN_WORKFLOW'
                    Select @RN = NameCode From OwnedWorkflows where ID = @ID
                else if @NameCode = 'E_OWN_TASK'
                    Select @RN = NameCode From OwnedTasks where ID = @ID
                else if @NameCode = 'E_OWN_TICKET'
                    Select @RN = NameCode From OwnedTickets where ID = @ID
                else if @NameCode = 'E_LST_ITEM'
                    Select @RN = NameCode From ListItems where ID = @ID
                else if @NameCode = 'E_SVC_LIST'
                    Select @RN = NameCode From ServiceLists where ID = @ID
                else if @NameCode = 'E_SCHD_JOB'
                    Select @RN = NameCode From ScheduledJobs where ID = @ID
                else if @NameCode = 'E_OWN_COMMENT'
                    Select @RN = NameCode From Comments where ID = @ID
                else if @NameCode = 'E_OWN_CONTACT'
                    Select @RN = NameCode From Contacts where ID = @ID
                else if @NameCode = 'E_EVT_SUBMIT'
                    Select @RN = NameCode From SubmittedEvents Where ID = @ID
                else if @NameCode = 'E_EVT_RECIEVE'
                    Select @RN = NameCode From ReceivedEvents where ID = @ID
                else if @NameCode = 'E_DATA_ACCESS'
                    Select @RN = NameCode From DataAccesses where DataID = @ID
        END
        RETURN @RN
END
GO
GRANT EXECUTE ON [dbo].[fn_FullName]
    TO CTEPESYS_UserRole;
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_CategoryInfoByCode]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_CategoryInfoByCode]
GO
CREATE FUNCTION [dbo].[fn_CategoryInfoByCode] (
        @ValueCode   as varchar(128) = '',                                                        -- 3 description from categroy, 4 category from description 5
        @ReturnCode as varchar(16) = 'C_NAME'
)
RETURNS varchar(256)
AS
BEGIN
        Declare @Data as varchar(256) = ''
        Set @ValueCode = Upper(RTRIM(LTRIM(@ValueCode)))
        if left(@ValueCode,2) ='C_'
        BEGIN
                if @ReturnCode = 'C_ID'
                BEGIN
                        select @Data = cast([ID] as varchar(16)) from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_PARENT_ID'
                BEGIN
                        select @Data = cast([ParentID] as varchar(16)) from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_PARENT_NAME'
                BEGIN
                        select @Data = p.NameCode from [dbo].[CodedCategoryCodes] c inner join [dbo].[CodedCategoryCodes] p on p.ID = c.ParentID where c.ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_PARENT_CODE' or @ReturnCode = 'C_PARENT_VALUE'
                BEGIN
                        select @Data = p.ValueCode from [dbo].[CodedCategoryCodes] c inner join [dbo].[CodedCategoryCodes] p on p.ID = c.ParentID where c.ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_STATUS'
                BEGIN
                        select @Data = [StatusCode] from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_CATEGORY'
                BEGIN
                        select @Data = [CategoryCode] from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_TYPE'
                BEGIN
                        select @Data = [TypeCode] from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_ALIAS'
                BEGIN
                        select @Data = [Alias] from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_COMMENT'
                BEGIN
                        select @Data = [Comments] from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_DESCRIPTION'
                BEGIN
                        select @Data = [Description] from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_NAME'
                BEGIN
                        select @Data = [NameCode] from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_REFERENCE_ID'
                BEGIN
                        select @Data = [ReferenceID] from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_REFERENCE_NAME'
                BEGIN
                        select @Data = [ReferenceName] from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
                else if @ReturnCode = 'C_REFERENCE_CODE'
                BEGIN
                        select @Data = [ReferenceCode] from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
                else
                BEGIN
                        select @Data = [ValueCode] from [dbo].[CodedCategoryCodes] where ValueCode = @ValueCode
                END
        END
        RETURN @Data
ErrorHandle:
        Set @Data = 'ERR_00'
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_CategoryInfoByCode]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_ValidCode]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_ValidCode]
GO
CREATE FUNCTION [dbo].[fn_ValidCode] (
        @TypeCode as varchar(16) = 'C_REG_CODE',
        @NameCode   as varchar(128) = ''                                                        -- 3 description from categroy, 4 category from description 5
)
RETURNS Int
AS
BEGIN
        Declare @Data as Int = -1
        Set @NameCode = Upper(RTRIM(LTRIM(@NameCode)))
        if @TypeCode = 'C_REG_CODE'
        BEGIN
             Set @Data = (Select Count(ValueCode) from [dbo].[CTEPESYSRegisteredCodes] where ValueCode = @NameCode)
        END
        else if left(@TypeCode,6) = 'C_TYPE'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedTypeCodes] where ValueCode = @NameCode)
        else if left(@TypeCode,10) = 'C_CATEGORY'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedCategoryCodes] where ValueCode = @NameCode)
        else if left(@TypeCode,10) = 'C_TEMPLATE'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedTemplates] where ValueCode = @NameCode)
        else if left(@TypeCode,10) = 'C_ACTIVITY'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedActivities] where ValueCode = @NameCode)
        else if left(@TypeCode,10) = 'C_VALUESET'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedValueSets] where ValueCode = @NameCode)
        else if left(@TypeCode,9) = 'C_CHANNEL'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedNotificationChannels] where ValueCode = @NameCode)
        else if left(@TypeCode,9) = 'C_MESSAGE'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedMessages] where ValueCode = @NameCode)
        else if left(@TypeCode,9) = 'C_COUNTRY'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedCountries] where ValueCode = @NameCode)
        else if left(@TypeCode,9) = 'C_WORFLOW'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedWorkflows] where ValueCode = @NameCode)
        else if left(@TypeCode,9) = 'C_DISEASE'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedDiseases] where ValueCode = @NameCode)
        else if left(@TypeCode,6) = 'C_TASK'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedTasks] where ValueCode = @NameCode)
        else if left(@TypeCode,6) = 'C_DATA'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedData] where ValueCode = @NameCode)
        else if left(@TypeCode,6) = 'C_ROLE'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedRoles] where ValueCode = @NameCode)
        else if left(@TypeCode,7) = 'C_EVENT'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedEvents] where ValueCode = @NameCode)
        else if left(@TypeCode,7) = 'C_AGENT'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedAgents] where ValueCode = @NameCode)
        else if left(@TypeCode,7) = 'C_ERROR'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedErrors] where ValueCode = @NameCode)
        else if left(@TypeCode,7) = 'C_GROUP'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedGroups] where ValueCode = @NameCode)
        else if left(@TypeCode,8) = 'C_REASON'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedReasons] where ValueCode = @NameCode)
        else if left(@TypeCode,8) = 'C_REPORT'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedReports] where ValueCode = @NameCode)
        else if left(@TypeCode,11) = 'C_SCHEDULER'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedSchedulers] where ValueCode = @NameCode)
        else if left(@TypeCode,11) = 'C_MILESTONE'
             Set @Data = (Select Count(ValueCode) from [dbo].[CodedMileStones] where ValueCode = @NameCode)

        else
             goto ErrorHandle
        RETURN @Data
ErrorHandle:
        Set @Data = -1
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_ValidCode]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_CheckTime]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_CheckTime]
GO
CREATE FUNCTION [dbo].[fn_CheckTime] (
        @UOMCode    as varchar(16) = 'C_ONCE',
        @Interval   as int = 0,
        @LastTime   as DATETIME = NULL,
        @CurTime    as DATETIME = NULL                                                       -- 3 description from categroy, 4 category from description 5
)
RETURNS Int
AS
BEGIN
        Declare @Data as Int = -5000
        if @CurTime is null set @CurTime = GetDate()
        set @Interval = dbo.fn_Max(@Interval,0)
        if @LastTime is null
        BEGIN
           Set @Data = @Interval
           Return @Data
        END
        Set @UOMCode = Upper(RTRIM(LTRIM(@UOMCode)))
        if @UOMCode = 'C_ONCE'
        BEGIN
             if @LastTime is not null Set @Data = 0
        END
        else if @UOMCode = 'C_SECOND'
             Set @Data = DateDiff(SECOND, DateAdd(SECOND, @Interval, @LastTime), @CurTime)
        else if @UOMCode = 'C_MINUTE'
             Set @Data = DateDiff(SECOND, DateAdd(MINUTE, @Interval, @LastTime), @CurTime)
        else if @UOMCode = 'C_HOURLY'    or @UOMCode = 'C_HOUR'
             Set @Data = DateDiff(SECOND, DateAdd(HOUR,   @Interval, @LastTime), @CurTime)
        else if @UOMCode = 'C_DAILY'     or @UOMCode = 'C_DAY'
             Set @Data = DateDiff(SECOND, DateAdd(DAY,    @Interval, @LastTime), @CurTime)
        else if @UOMCode = 'C_WEEKLY'    or @UOMCode = 'C_WEEK'
             Set @Data = DateDiff(SECOND, DateAdd(WEEK,   @Interval, @LastTime), @CurTime)
        else if @UOMCode = 'C_MONTHLY'   or @UOMCode = 'C_MONTH'
             Set @Data = DateDiff(SECOND, DateAdd(MONTH,  @Interval, @LastTime), @CurTime)
        else if @UOMCode = 'C_YEARLY'    or @UOMCode = 'C_YEAR'
             Set @Data = DateDiff(SECOND, DateAdd(YEAR,   @Interval, @LastTime), @CurTime)
        else if @UOMCode = 'C_QUARTERLY' or @UOMCode = 'C_QUARTER'
             Set @Data = DateDiff(SECOND, DateAdd(MONTH, 3*@Interval,@LastTime), @CurTime)
        else
             goto ErrorHandle
        RETURN @Data
ErrorHandle:
        Set @Data = -5000
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_CheckTime]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_DateAdd]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_DateAdd]
GO
CREATE FUNCTION [dbo].[fn_DateAdd] (
        @UOMCode    as varchar(16) = 'C_ONCE',
        @Interval   as int = 0,
        @CurTime    as DATETIME = NULL                                                       -- 3 description from categroy, 4 category from description 5
)
RETURNS DATETIME
AS
BEGIN
        Declare @Data as DateTime = NULL
        set   @Interval = dbo.fn_Max(@Interval,0)
        Set @UOMCode = Upper(RTRIM(LTRIM(@UOMCode)))
        if @CurTime is null set @CurTime = GetDate()
        if @UOMCode = 'C_SECOND'
             Set @Data = DateAdd(SECOND, @Interval, @CurTime)
        else if @UOMCode = 'C_MINUTE'
             Set @Data = DateAdd(MINUTE, @Interval, @CurTime)
        else if @UOMCode = 'C_HOURLY'    or @UOMCode = 'C_HOUR'
             Set @Data = DateAdd(HOUR, @Interval, @CurTime)
        else if @UOMCode = 'C_DAILY'     or @UOMCode = 'C_DAY'
             Set @Data = DateAdd(DAY,    @Interval, @CurTime)
        else if @UOMCode = 'C_WEEKLY'    or @UOMCode = 'C_WEEK'
             Set @Data = DateAdd(WEEK,   @Interval, @CurTime)
        else if @UOMCode = 'C_MONTHLY'   or @UOMCode = 'C_MONTH'
             Set @Data = DateAdd(MONTH,  @Interval, @CurTime)
        else if @UOMCode = 'C_YEARLY'    or @UOMCode = 'C_YEAR'
             Set @Data = DateAdd(YEAR,   @Interval, @CurTime)
        else if @UOMCode = 'C_QUARTERLY' or @UOMCode = 'C_QUARTER'
             Set @Data = DateAdd(MONTH,  3*@Interval, @CurTime)
        else
             goto ErrorHandle
        RETURN @Data
ErrorHandle:
        Set @Data = NULL
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_DateAdd]
    TO CTEPESYS_UserRole;
GO

 SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_CheckValidDate]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_CheckValidDate]
GO
CREATE FUNCTION [dbo].[fn_CheckValidDate] (
        @StartDate as DATETIME = NULL,
        @EndDate   as DATETIME = NULL
)
RETURNS Int
AS
BEGIN
        Declare @RN as Int = -1, @SDATE as DateTime = GetDate()
        if @StartDate is Null return @RN
        Set @RN = case when DateDiff(SECOND, @StartDate, @SDATE) > 0  then 1 else 0 END
        if @EndDate is Not Null and @RN > 0
           Set @RN = case when DateDiff(SECOND, @SDATE, @EndDate) > 0 then 1 else 0 END
        RETURN @RN
END
GO
GRANT EXECUTE ON [dbo].[fn_CheckValidDate]
    TO CTEPESYS_UserRole;
GO

 SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_CheckEffectiveDate]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_CheckEffectiveDate]
GO
CREATE FUNCTION [dbo].[fn_CheckEffectiveDate] (
        @OwnerID as int = NULL,
        @OwnerIDCode  as varchar(16) = NULL
)
RETURNS Int
AS
BEGIN
        Declare @RN as Int = 0, @SDATE as DateTime = GetDate()
        set @OwnerIDCode = LTRIM(RTRIM(@OwnerIDCode))
        if left(@OwnerIDCode,2) <> 'E_' set @OwnerIDCode = dbo.fn_OwnerIDCode(@OwnerIDCode)
        Select @RN = Count(OwnerID) from OwnedEffectiveDates where OwnerID = @OwnerID and OwnerIDCode = @OwnerIDCode
        if @@ROWCOUNT > 0
        BEGIN
            Select @RN = Count(OwnerID) from OwnedEffectiveDates where OwnerID = @OwnerID and OwnerIDCode = @OwnerIDCode and dbo.fn_CheckValidDate(EffectiveStartDate, EffectiveEndDate) > 0
            if @@ROWCOUNT = 0 Set @RN = -1
        END
        RETURN @RN
END
GO
GRANT EXECUTE ON [dbo].[fn_CheckEffectiveDate]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_CheckDateTime]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_CheckDateTime]
GO
CREATE FUNCTION [dbo].[fn_CheckDateTime] (
        @UOMCode    as varchar(16) = 'C_ONCE',
        @Interval   as int = 0,
        @LastTime   as DATETIME = NULL,
        @CurTime    as DATETIME = NULL                                                       -- 3 description from categroy, 4 category from description 5
)
RETURNS Int
AS
BEGIN
        Declare @Data as Int = -5000
        if @CurTime is null set @CurTime = GetDate()
        set @Interval = dbo.fn_Max(@Interval,0)
        if @LastTime is null
        BEGIN
           Set @Data = @Interval
           Return @Data
        END
        Set @UOMCode = Upper(RTRIM(LTRIM(@UOMCode)))
        if @UOMCode = 'C_ONCE'
        BEGIN
             if @LastTime is not null Set @Data = 0
        END
        else if @UOMCode = 'C_SECOND'
             Set @Data = Case When DateAdd(SECOND, @Interval, @LastTime) < @CurTime then 1
                              When DateAdd(SECOND, @Interval, @LastTime) = @CurTime then 0
                              else -1
                         End
        else if @UOMCode = 'C_MINUTE'
             Set @Data = Case When DateAdd(MINUTE, @Interval, @LastTime) < @CurTime then 1
                              When DateAdd(MINUTE, @Interval, @LastTime) = @CurTime then 0
                              else -1
                         End
        else if @UOMCode = 'C_HOURLY'    or @UOMCode = 'C_HOUR'
             Set @Data = Case When DateAdd(HOUR,   @Interval, @LastTime) < @CurTime then 1
                              When DateAdd(HOUR,   @Interval, @LastTime) = @CurTime then 0
                              else -1
                         End
        else if @UOMCode = 'C_DAILY'     or @UOMCode = 'C_DAY'
             Set @Data = Case When DateAdd(DAY,    @Interval, @LastTime) < @CurTime then 1
                              When DateAdd(DAY,    @Interval, @LastTime) = @CurTime then 0
                              else -1
                         End
        else if @UOMCode = 'C_WEEKLY'    or @UOMCode = 'C_WEEK'
             Set @Data = Case When DateAdd(WEEK,   @Interval, @LastTime) < @CurTime then 1
                              When DateAdd(WEEK,   @Interval, @LastTime) = @CurTime then 0
                              else -1
                         End
        else if @UOMCode = 'C_MONTHLY'   or @UOMCode = 'C_MONTH'
             Set @Data = Case When DateAdd(MONTH,  @Interval, @LastTime) < @CurTime then 1
                              When DateAdd(MONTH,  @Interval, @LastTime) = @CurTime then 0
                              else -1
                         End
        else if @UOMCode = 'C_YEARLY'    or @UOMCode = 'C_YEAR'
             Set @Data = Case When DateAdd(YEAR,   @Interval, @LastTime) < @CurTime then 1
                              When DateAdd(YEAR,   @Interval, @LastTime) = @CurTime then 0
                              else -1
                         End
        else if @UOMCode = 'C_QUARTERLY' or @UOMCode = 'C_QUARTER'
             Set @Data = Case When DateAdd(MONTH, 3*@Interval,@LastTime) < @CurTime then 1
                              When DateAdd(MONTH, 3*@Interval,@LastTime) = @CurTime then 0
                              else -1
                         End
        else
             goto ErrorHandle
        RETURN @Data
ErrorHandle:
        Set @Data = -5000
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_CheckDateTime]
    TO CTEPESYS_UserRole;
GO

  SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_CheckValidCodedID]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_CheckValidCodedID]
GO
CREATE FUNCTION [dbo].[fn_CheckValidCodedID] (
        @ID         as int = NULL,
        @NameCode   as VarChar(128) = 'E_ENTITY'
)
RETURNS Int
AS
BEGIN
        Declare @RN as Int = -1, @sSQL as NVARCHAR(1000), @pDef as NVARCHAR(256)
        set @NameCode = LTRIM(RTRIM(@NameCode))
        if left(@NameCode, 2) <> 'E_'  Set @NameCode = dbo.fn_OwnerIDCode(@NameCode)
        Select @NameCode = NameCode From RegisteredEntities where ValueCode = @NameCode
        if isNull(@ID,0) = 0 or @@ROWCOUNT < 1 Return @RN

        SET @pDef = N'@ID int, @tbName NVARCHAR(128), @Cnt Int OUTPUT';
        Set @sSQL = N'Select  @Cnt = Count(StatusCode) from ' + @NameCode + ' Where ID = @ID';
        exec sp_executesql @sSQL, @pDef, @ID, @tbName=@NameCode, @Cnt=@RN OUTPUT

        RETURN @RN

END
GO
GRANT EXECUTE ON [dbo].[fn_CheckValidCodedID]
    TO CTEPESYS_UserRole;
GO

 SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_CheckExpirationTime]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_CheckExpirationTime]
GO
CREATE FUNCTION [dbo].[fn_CheckExpirationTime] (
        @ChkDate   as DATETIME = NULL,
        @CurDate   as DATETIME = NULL
)
RETURNS Int
AS
BEGIN
        Declare @RN as Int = 0
        if @CurDate is Null set @CurDate = GetDate()
        if @ChkDate is Null set @ChkDate = DateAdd(MINUTE, 1, @CurDate)

        Set @RN = case when @ChkDate <= @CurDate then 1 else -1 end

        RETURN @RN
END
GO
GRANT EXECUTE ON [dbo].[fn_CheckExpirationTime]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_GetCom]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_GetCom]
GO
CREATE FUNCTION [dbo].[fn_GetCom] (
       @IDCode as varchar(256) = NULL,
       @TypeCode as varchar(16) = 'C_GROUP',
       @CommCode as varchar(16) = 'C_EMAIL'
)
RETURNS varchar(MAX)
AS
BEGIN
        Declare @Data as varchar(MAX) = '', @OID as int = NULL
        set @TypeCode = UPPER(LTRIM(RTRIM(@TypeCode)))
        set @CommCode = UPPER(LTRIM(RTRIM(@CommCode)))
        if @TypeCode = 'C_GROUP'
        BEGIN
                Select @Data = @Data + ';' +
                CASE  @CommCode
                WHEN 'C_EMAIL'     THEN  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                WHEN 'C_PHONE'     THEN  case when isNull(t.Phone,'') = '' then isNull(t.AlternativePhone,'') else t.Phone END
                WHEN 'C_MOBILE'    THEN  isNull(t.Mobile,'')
                WHEN 'C_URL'       THEN  isNull(t.URL,'')
                WHEN 'C_LINKEDIN'  THEN  isNull(t.LinkedIn,'')
--                WHEN 'C_RSS'       THEN  isNull(t.RSS,'')
--                WHEN 'C_SMS'       THEN  isNull(t.SMSText,'')
                WHEN 'C_FACEBOOK'  THEN  isNull(t.Facebook,'')
                WHEN 'C_WIKIMEDIA' THEN  isNull(t.WikiMedia,'')
                ELSE                     isNull(t.Twitter,'')
                END
                From TelecomAddresses t inner join
                CodedGroups g on t.OwnerID = g.ID and g.StatusCode = t.StatusCode and t.OwnerIDCode = 'E_GROUP'
                WHERE g.ValueCode = @IDCode and g.StatusCode = 'ACTIVE'
                and t.PrimaryIndicator = 1
--                order by t.PrimaryIndicator DESC
        END
        else if @TypeCode = 'C_GRP_PERSON'
        BEGIN
                Select @Data = @Data + ';' +
                CASE  @CommCode
                WHEN 'C_EMAIL'     THEN  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                WHEN 'C_PHONE'     THEN  case when isNull(t.Phone,'') = '' then isNull(t.AlternativePhone,'') else t.Phone END
                WHEN 'C_MOBILE'    THEN  isNull(t.Mobile,'')
                WHEN 'C_URL'       THEN  isNull(t.URL,'')
                WHEN 'C_LINKEDIN'  THEN  isNull(t.LinkedIn,'')
--                WHEN 'C_RSS'       THEN  isNull(t.RSS,'')
--                WHEN 'C_SMS'       THEN  isNull(t.SMSText,'')
                WHEN 'C_FACEBOOK'  THEN  isNull(t.Facebook,'')
                WHEN 'C_WIKIMEDIA' THEN  isNull(t.WikiMedia,'')
                ELSE                     isNull(t.Twitter,'')
                END
                From TelecomAddresses t
                inner join GroupPersons g on t.OwnerID = g.PersonID and g.StatusCode = t.StatusCode and t.OwnerIDCode = 'E_PERSON'
                Inner Join CodedGroups cg on g.GroupID =  cg.ID and g.StatusCode = cg.StatusCode
                WHERE cg.ValueCode = @IDCode and g.StatusCode = 'ACTIVE'
                and t.PrimaryIndicator = 1
--                order by t.PrimaryIndicator DESC
        END
        else if @TypeCode = 'C_GRP_0RG'
        BEGIN
                Select @Data = @Data + ';' +
                CASE  @CommCode
                WHEN 'C_EMAIL'     THEN  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                WHEN 'C_PHONE'     THEN  case when isNull(t.Phone,'') = '' then isNull(t.AlternativePhone,'') else t.Phone END
                WHEN 'C_MOBILE'    THEN  isNull(t.Mobile,'')
                WHEN 'C_URL'       THEN  isNull(t.URL,'')
                WHEN 'C_LINKEDIN'  THEN  isNull(t.LinkedIn,'')
--                WHEN 'C_RSS'       THEN  isNull(t.RSS,'')
--                WHEN 'C_SMS'       THEN  isNull(t.SMSText,'')
                WHEN 'C_FACEBOOK'  THEN  isNull(t.Facebook,'')
                WHEN 'C_WIKIMEDIA' THEN  isNull(t.WikiMedia,'')
                ELSE                     isNull(t.Twitter,'')
                END
                From TelecomAddresses t
                inner join GroupOrganizations g on t.OwnerID = g.OrganizationID and g.StatusCode = t.StatusCode and t.OwnerIDCode = 'E_Organization'
                Inner Join CodedGroups cg on g.GroupID =  cg.ID and g.StatusCode = cg.StatusCode
                WHERE cg.ValueCode = @IDCode and g.StatusCode = 'ACTIVE'
                and t.PrimaryIndicator = 1
--                order by t.PrimaryIndicator DESC
        END
        else if @TypeCode = 'C_SVC_LIST' or  @TypeCode = 'C_LIST'
        BEGIN
                if @CommCode = 'C_EMAIL'
                BEGIN
                       Set @OID = CharIndex('#',@IDCode)
                       if @OID > 0
                       BEGIN
                               if charIndex('@', left(@IDCode,@OID)) > 0
                               BEGIN
                                       set @Data = Left(@IDCode,@OID-1)
                                       set @IDCode = Right(@IDCode,Len(@IDCode)-@OID)
                               END
                               else if charIndex('@', Right(@IDCode,Len(@IDCode)-@OID)) > 0
                               BEGIN
                                       set @Data = Right(@IDCode,Len(@IDCode)-@OID)
                                       set @IDCode = Left(@IDCode,@OID-1)
                               END
                               else -- drip right part
                                   set @IDCode = Left(@IDCode,@OID-1)
                       END
                       if CharIndex('C_CODE:', @IDCode) > 0
                       BEGIN
                          set @IDCode = replace(@IDCode, 'C_CODE:','')
                          Select @Data = @Data + ';' +  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                          From TelecomAddresses t
                          Inner Join ListItems i on t.OwnerID = i.OwnerID and t.OwnerIDCode = i.OwnerIDCode and t.StatusCode = i.StatusCode
                          inner join ServiceLists g on g.ID = i.ListID and g.StatusCode = i.StatusCode
                          WHERE g.ReferenceCode = @CommCode and  g.StatusCode = 'ACTIVE'
                          and t.PrimaryIndicator = 1
                          and ';'+ @IDCode + ';' Like '%;'+g.ReferenceID +';%'
                       END
                       else if CharIndex('C_OWNER:', @IDCode) > 0
                       BEGIN
                          set @IDCode = replace(@IDCode, 'C_OWNER:','')
                          Select @Data = @Data + ';' +  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                          From TelecomAddresses t
                          Inner Join ListItems i on t.OwnerID = i.OwnerID and t.OwnerIDCode = i.OwnerIDCode and t.StatusCode = i.StatusCode
                          inner join ServiceLists g on g.ID = i.ListID and g.StatusCode = i.StatusCode
                          WHERE g.ReferenceCode = @CommCode and  g.StatusCode = 'ACTIVE'
                          and t.PrimaryIndicator = 1
                          and ';'+ @IDCode + ';' Like '%;'+cast(g.OwnerID as varchar(16))+':'+g.OwnerIDCode+';%'
                       END
                       else if CharIndex('C_NAME:', @IDCode) > 0
                       BEGIN
                          set @IDCode = replace(@IDCode, 'C_NAME:','')
                          Select @Data = @Data + ';' +  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                          From TelecomAddresses t
                          Inner Join ListItems i on t.OwnerID = i.OwnerID and t.OwnerIDCode = i.OwnerIDCode and t.StatusCode = i.StatusCode
                          inner join ServiceLists g on g.ID = i.ListID and g.StatusCode = i.StatusCode
                          WHERE g.ReferenceCode = @CommCode and  g.StatusCode = 'ACTIVE'
                          and t.PrimaryIndicator = 1
                          and ';'+ @IDCode + ';' Like '%;'+g.NameCode+';%'
                       END
                       else -- default
                       BEGIN
                          Select @Data = @Data + ';' +  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                          From TelecomAddresses t
                          Inner Join ListItems i on t.OwnerID = i.OwnerID and t.OwnerIDCode = i.OwnerIDCode and t.StatusCode = i.StatusCode
                          inner join ServiceLists g on g.ID = i.ListID and g.StatusCode = i.StatusCode
                          WHERE g.ReferenceCode = @CommCode and  g.StatusCode = 'ACTIVE'
                          and t.PrimaryIndicator = 1
                          and ';'+ @IDCode + ';' Like '%;'+g.ReferenceID +';%'
                       END

                END
                else
                 Select @Data = @Data + ';' +
                 CASE  @CommCode
                 WHEN 'C_EMAIL'     THEN  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                 WHEN 'C_PHONE'     THEN  case when isNull(t.Phone,'') = '' then isNull(t.AlternativePhone,'') else t.Phone END
                 WHEN 'C_MOBILE'    THEN  isNull(t.Mobile,'')
                 WHEN 'C_URL'       THEN  isNull(t.URL,'')
                 WHEN 'C_LINKEDIN'  THEN  isNull(t.LinkedIn,'')
--                WHEN 'C_RSS'       THEN  isNull(t.RSS,'')
--                WHEN 'C_SMS'       THEN  isNull(t.SMSText,'')
                 WHEN 'C_FACEBOOK'  THEN  isNull(t.Facebook,'')
                 WHEN 'C_WIKIMEDIA' THEN  isNull(t.WikiMedia,'')
                 ELSE                     isNull(t.Twitter,'')
                 END
                 From TelecomAddresses t
                 Inner Join ListItems i on t.OwnerID = i.OwnerID and t.OwnerIDCode = i.OwnerIDCode and t.StatusCode = i.StatusCode
                 inner join ServiceLists g on g.ID = i.ListID and g.StatusCode = i.StatusCode
                 WHERE (g.CategoryCode in ('C_PERSON','C_ORGANIZATION','C_GROUP') or g.CategoryCode = 'C_SERVICE' and i.CategoryCode in ('C_PERSON','C_ORGANIZATION','C_GROUP') )
                 and  g.StatusCode = 'ACTIVE' and (';'+@IDCode+';' Like '%;'+g.ReferenceID +';%' or g.NameCode = @IDCode)
                 and t.PrimaryIndicator = 1
--                order by t.PrimaryIndicator DESC
        END
        else if @TypeCode = 'C_EMAIL_TO' or @TypeCode = 'C_EMAIL_CC' or @TypeCode = 'C_EMAIL_BCC'
        BEGIN   -- mail list
               if isNumeric(@CommCode) > 0
               BEGIN
                  set @OID = cast(@CommCode as int)
                  if left(@IDCode,2) = 'E_'
                     set @CommCode = @IDCode
                  else
                     set @CommCode = dbo.fn_OwnerIDCode(@IDCode)
                   Select @Data = @Data + ';' +  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                   From TelecomAddresses t
                   Inner Join ListItems i on t.OwnerID = i.OwnerID and t.OwnerIDCode = i.OwnerIDCode and t.StatusCode = i.StatusCode
                   inner join ServiceLists g on g.ID = i.ListID and g.StatusCode = i.StatusCode
                   WHERE g.TypeCode = @TypeCode and g.ReferenceCode = 'C_EMAIL' and  g.StatusCode = 'ACTIVE' and  g.OwnerID = @OID and g.OwnerIDCode = @CommCode
                   order by t.PrimaryIndicator DESC
               END
               else
               BEGIN
                       Set @OID = CharIndex('#',@IDCode)
                       if @OID > 0
                       BEGIN
                               if charIndex('@', left(@IDCode,@OID)) > 0
                               BEGIN
                                       set @Data = Left(@IDCode,@OID-1)
                                       set @IDCode = Right(@IDCode,Len(@IDCode)-@OID)
                               END
                               else if charIndex('@', Right(@IDCode,Len(@IDCode)-@OID)) > 0
                               BEGIN
                                       set @Data = Right(@IDCode,Len(@IDCode)-@OID)
                                       set @IDCode = Left(@IDCode,@OID-1)
                               END
                               else -- drip right part
                                   set @IDCode = Left(@IDCode,@OID-1)
                       END

                       if CharIndex('C_CODE:', @IDCode) > 0
                       BEGIN
                          set @IDCode = replace(@IDCode, 'C_CODE:','')
                          Select @Data = @Data + ';' +  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                          From TelecomAddresses t
                          Inner Join ListItems i on t.OwnerID = i.OwnerID and t.OwnerIDCode = i.OwnerIDCode and t.StatusCode = i.StatusCode
                          inner join ServiceLists g on g.ID = i.ListID and g.StatusCode = i.StatusCode
                          WHERE g.TypeCode = @TypeCode and g.ReferenceCode = 'C_EMAIL' and  g.StatusCode = 'ACTIVE'
                          and t.PrimaryIndicator = 1
                          and ';'+ @IDCode + ';' Like '%;'+g.ReferenceID +';%'
                       END
                       else if CharIndex('C_OWNER:', @IDCode) > 0
                       BEGIN
                          set @IDCode = replace(@IDCode, 'C_OWNER:','')
                          Select @Data = @Data + ';' +  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                          From TelecomAddresses t
                          Inner Join ListItems i on t.OwnerID = i.OwnerID and t.OwnerIDCode = i.OwnerIDCode and t.StatusCode = i.StatusCode
                          inner join ServiceLists g on g.ID = i.ListID and g.StatusCode = i.StatusCode
                          WHERE g.TypeCode = @TypeCode and g.ReferenceCode = 'C_EMAIL' and  g.StatusCode = 'ACTIVE'
                          and t.PrimaryIndicator = 1
                          and ';'+ @IDCode + ';' Like '%;'+cast(g.OwnerID as varchar(16))+':'+g.OwnerIDCode+';%'
                       END
                       else -- default
                       BEGIN
                          Select @Data = @Data + ';' +  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                          From TelecomAddresses t
                          Inner Join ListItems i on t.OwnerID = i.OwnerID and t.OwnerIDCode = i.OwnerIDCode and t.StatusCode = i.StatusCode
                          inner join ServiceLists g on g.ID = i.ListID and g.StatusCode = i.StatusCode
                          WHERE g.TypeCode = @TypeCode and g.ReferenceCode = 'C_EMAIL' and  g.StatusCode = 'ACTIVE'
                          and t.PrimaryIndicator = 1
                          and ';'+ @IDCode + ';' Like '%;'+g.ReferenceID +';%'
                       END
                END

        END
        else if @TypeCode = 'C_OWNER'
        BEGIN  ---OwnerID1:OwnerIDCode1;OwnerID2:OwnerIDCode2
                Select @Data = @Data + ';' +
                CASE  @CommCode
                WHEN 'C_EMAIL'     THEN  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                WHEN 'C_PHONE'     THEN  case when isNull(t.Phone,'') = '' then isNull(t.AlternativePhone,'') else t.Phone END
                WHEN 'C_MOBILE'    THEN  isNull(t.Mobile,'')
                WHEN 'C_URL'       THEN  isNull(t.URL,'')
                WHEN 'C_LINKEDIN'  THEN  isNull(t.LinkedIn,'')
                WHEN 'C_FACEBOOK'  THEN  isNull(t.Facebook,'')
                WHEN 'C_WIKIMEDIA' THEN  isNull(t.WikiMedia,'')
--                WHEN 'C_SMS'       THEN  isNull(t.SMSText,'')
--                WHEN 'C_RSS'       THEN  isNull(t.RSS,'')
                ELSE                     isNull(t.Twitter,'')
                END
                From TelecomAddresses t
                Where t.StatusCode = 'ACTIVE' and ';'+ @IDCode + ';' like '%;' + cast(t.OwnerID as varchar(16)) +':' + t.OwnerIDCode + ';%'
                and t.PrimaryIndicator = 1
--                order by t.PrimaryIndicator DESC
        END
        else if @TypeCode = 'C_CHANNEL' or @TypeCode = 'C_NOTIFICATION'
        BEGIN
             Set @OID = CharIndex('#',@IDCode)
             if @OID > 0
             BEGIN
                               if charIndex('@', left(@IDCode,@OID)) > 0
                               BEGIN
                                       set @Data = Left(@IDCode,@OID-1)
                                       set @IDCode = Right(@IDCode,Len(@IDCode)-@OID)
                               END
                               else if charIndex('@', Right(@IDCode,Len(@IDCode)-@OID)) > 0
                               BEGIN
                                       set @Data = Right(@IDCode,Len(@IDCode)-@OID)
                                       set @IDCode = Left(@IDCode,@OID-1)
                               END
                               else -- drip right part
                                   set @IDCode = Left(@IDCode,@OID-1)
             END

             if CharIndex('C_CODE:', @IDCode) > 0
             BEGIN
                Set @IDCode = replace(@IDCode, 'C_CODE:','')
                Select @Data = @Data + ';' +
                CASE  @CommCode
                WHEN 'C_EMAIL'     THEN  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                WHEN 'C_PHONE'     THEN  case when isNull(t.Phone,'') = '' then isNull(t.AlternativePhone,'') else t.Phone END
                WHEN 'C_MOBILE'    THEN  isNull(t.Mobile,'')
                ELSE                     isNull(t.URL,'')
                END
                From CodedNotificationChannels c
                Inner join Subscribers s on (s.ChannelID = c.ParentID or s.ChannelID = c.ID) and c.StatusCode = s.StatusCode
                inner join TelecomAddresses t on s.OwnerID = t.OwnerID and s.OwnerIDCode =t.OwnerIDCode and t.StatusCode = s.StatusCode
                Where s.StatusCode = 'ACTIVE'
                and t.PrimaryIndicator = 1
                and ';'+@IDCode +';' like '%;'+ c.ValueCode + ';%'
                --- Service, List Subscribers
                Select @Data = @Data + ';' +
                CASE  @CommCode
                WHEN 'C_EMAIL'     THEN  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                WHEN 'C_PHONE'     THEN  case when isNull(t.Phone,'') = '' then isNull(t.AlternativePhone,'') else t.Phone END
                WHEN 'C_MOBILE'    THEN  isNull(t.Mobile,'')
                ELSE                     isNull(t.URL,'')
                END
                From CodedNotificationChannels c
                Inner join Subscribers s on (s.ChannelID = c.ParentID or s.ChannelID = c.ID) and c.StatusCode = s.StatusCode
                Inner Join ServiceLists l on s.OwnerID = l.OwnerID and s.OwnerIDCode =l.OwnerIDCode and l.StatusCode = s.StatusCode
                Inner Join ListItems i on i.ListID = l.ID and i.StatusCode = i.StatusCode
                Inner Join TelecomAddresses t on i.OwnerID = t.OwnerID and i.OwnerIDCode =t.OwnerIDCode and t.StatusCode = i.StatusCode
                Where s.StatusCode = 'ACTIVE'
                and t.PrimaryIndicator = 1
                and ';'+@IDCode +';' like '%;'+ c.ValueCode + ';%'
            END
            else
            BEGIN
                Set @IDCode = replace(@IDCode, 'C_ID:','')
                Select @Data = @Data + ';' +
                CASE  @CommCode
                WHEN 'C_EMAIL'     THEN  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                WHEN 'C_PHONE'     THEN  case when isNull(t.Phone,'') = '' then isNull(t.AlternativePhone,'') else t.Phone END
                WHEN 'C_MOBILE'    THEN  isNull(t.Mobile,'')
                ELSE                     isNull(t.URL,'')
                END
                From CodedNotificationChannels c
                Inner join Subscribers s on (s.ChannelID = c.ParentID or s.ChannelID = c.ID) and c.StatusCode = s.StatusCode
                inner join TelecomAddresses t on s.OwnerID = t.OwnerID and s.OwnerIDCode =t.OwnerIDCode and t.StatusCode = s.StatusCode
                Where c.ID =  @OID and s.StatusCode = 'ACTIVE'
                and t.PrimaryIndicator = 1
                and ';'+@IDCode +';' like '%;'+ cast(c.ID as varchar(16)) + ';%'
                --- Service, List Subscribers
                Select @Data = @Data + ';' +
                CASE  @CommCode
                WHEN 'C_EMAIL'     THEN  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                WHEN 'C_PHONE'     THEN  case when isNull(t.Phone,'') = '' then isNull(t.AlternativePhone,'') else t.Phone END
                WHEN 'C_MOBILE'    THEN  isNull(t.Mobile,'')
                ELSE                     isNull(t.URL,'')
                END
                From CodedNotificationChannels c
                Inner join Subscribers s on (s.ChannelID = c.ParentID or s.ChannelID = c.ID) and c.StatusCode = s.StatusCode
                Inner Join ServiceLists l on s.OwnerID = l.OwnerID and s.OwnerIDCode =l.OwnerIDCode and l.StatusCode = s.StatusCode
                Inner Join ListItems i on i.ListID = l.ID and i.StatusCode = i.StatusCode
                Inner Join TelecomAddresses t on i.OwnerID = t.OwnerID and i.OwnerIDCode =t.OwnerIDCode and t.StatusCode = i.StatusCode
                Where c.ID =  @OID and s.StatusCode = 'ACTIVE'
                and t.PrimaryIndicator = 1
                and ';'+@IDCode +';' like '%;'+ cast(c.ID as varchar(16)) + ';%'
            END
        END
        else if @TypeCode = 'C_LOGIN'
        BEGIN  ---OwnerID1:OwnerIDCode1;OwnerID2:OwnerIDCode2
            if CharIndex('C_OWNER:', @IDCode) > 0
            BEGIN
                Set @IDCode = replace(@IDCode,'C_OWNER:','')
                Select @Data = @Data + ';' +
                CASE  @CommCode
                WHEN 'C_EMAIL'     THEN  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                WHEN 'C_PHONE'     THEN  case when isNull(t.Phone,'') = '' then isNull(t.AlternativePhone,'') else t.Phone END
                WHEN 'C_MOBILE'    THEN  isNull(t.Mobile,'')
                WHEN 'C_URL'       THEN  isNull(t.URL,'')
                WHEN 'C_LINKEDIN'  THEN  isNull(t.LinkedIn,'')
                WHEN 'C_FACEBOOK'  THEN  isNull(t.Facebook,'')
                WHEN 'C_WIKIMEDIA' THEN  isNull(t.WikiMedia,'')
--                WHEN 'C_SMS'       THEN  isNull(t.SMSText,'')
--                WHEN 'C_RSS'       THEN  isNull(t.RSS,'')
                ELSE                     isNull(t.Twitter,'')
                END
                From TelecomAddresses t
                inner join Profiles p on t.StatusCode = p.StatusCode and t.OwnerID = p.OwnerID and t.OwnerIDCode = p.OwnerIDCode
                Where t.StatusCode = 'ACTIVE' and ';'+ @IDCode + ';' like '%;' + cast(t.OwnerID as varchar(16)) +':' + t.OwnerIDCode + ';%'
                and t.PrimaryIndicator = 1
            END
            else if CharIndex('C_CODE:', @IDCode) > 0
            BEGIN
                Set @IDCode = replace(@IDCode,'C_CODE:','')
                Select @Data = @Data + ';' +
                CASE  @CommCode
                WHEN 'C_EMAIL'     THEN  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                WHEN 'C_PHONE'     THEN  case when isNull(t.Phone,'') = '' then isNull(t.AlternativePhone,'') else t.Phone END
                WHEN 'C_MOBILE'    THEN  isNull(t.Mobile,'')
                WHEN 'C_URL'       THEN  isNull(t.URL,'')
                WHEN 'C_LINKEDIN'  THEN  isNull(t.LinkedIn,'')
                WHEN 'C_FACEBOOK'  THEN  isNull(t.Facebook,'')
                WHEN 'C_WIKIMEDIA' THEN  isNull(t.WikiMedia,'')
--                WHEN 'C_SMS'       THEN  isNull(t.SMSText,'')
--                WHEN 'C_RSS'       THEN  isNull(t.RSS,'')
                ELSE                     isNull(t.Twitter,'')
                END
                From TelecomAddresses t
                inner join Profiles p on t.StatusCode = p.StatusCode and t.OwnerID = p.OwnerID and t.OwnerIDCode = p.OwnerIDCode
                Where t.StatusCode = 'ACTIVE' and (';'+ @IDCode + ';' like '%;' + p.ValueCode + ';%'  or ';'+ @IDCode + ';' like '%;' + p.NameCode + ';%')
                and t.PrimaryIndicator = 1
            END
            else
            BEGIN
                if CharIndex('C_LOGINNAME:', @IDCode) > 0 Set @IDCode = replace(@IDCode,'C_LOGINNAME:','')
                if CharIndex('C_LOGINID:', @IDCode) > 0 Set @IDCode = replace(@IDCode,'C_LOGINID:','')
                Select @Data = @Data + ';' +
                CASE  @CommCode
                WHEN 'C_EMAIL'     THEN  case when isNull(t.Email,'') = '' then isNull(t.AlternativeEmail,'') else t.Email END
                WHEN 'C_PHONE'     THEN  case when isNull(t.Phone,'') = '' then isNull(t.AlternativePhone,'') else t.Phone END
                WHEN 'C_MOBILE'    THEN  isNull(t.Mobile,'')
                WHEN 'C_URL'       THEN  isNull(t.URL,'')
                WHEN 'C_LINKEDIN'  THEN  isNull(t.LinkedIn,'')
                WHEN 'C_FACEBOOK'  THEN  isNull(t.Facebook,'')
                WHEN 'C_WIKIMEDIA' THEN  isNull(t.WikiMedia,'')
--                WHEN 'C_SMS'       THEN  isNull(t.SMSText,'')
--                WHEN 'C_RSS'       THEN  isNull(t.RSS,'')
                ELSE                     isNull(t.Twitter,'')
                END
                From TelecomAddresses t
                inner join Profiles p on t.StatusCode = p.StatusCode and t.OwnerID = p.OwnerID and t.OwnerIDCode = p.OwnerIDCode
                Where t.StatusCode = 'ACTIVE' and (';'+ @IDCode + ';' like '%;' + p.LoginName + ';%'  or ';'+ @IDCode + ';' like '%;' + p.LoginID + ';%')
                and t.PrimaryIndicator = 1
            END
--                order by t.PrimaryIndicator DESC
        END
        else
            Goto ERRLOG

        if len(@Data) > 1
        BEGIN
             set @Data = replace(@Data,';;',';')
             if left(@Data,1) = ';'  Set @Data = Right(@Data, Len(@Data) -1)
        END
        RETURN @Data
ERRLOG:
        Set @Data = ''
        Return @Data
END
GO
GRANT EXECUTE ON [dbo].[fn_GetCom]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_IsLockedBy]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_IsLockedBy]
GO
CREATE FUNCTION [dbo].[fn_IsLockedBy] (
       @OwnerID as Int = NULL,
       @OwnerIDCode as varchar(16) = NULL
)
RETURNS varchar(128)
AS
BEGIN
        Declare @Data as varchar(128) = NULL
        if isNull(@OwnerID,0) < 1 or isNull(@OwnerIDCode,'') = '' GoTO ERRLOG
        Select @DATA = isNull(ResetBy,CreatedBy) From OwnedLocks where OwnerID = @OwnerID and OwnerIDCode = @OwnerIDCode
        Return @DATA
ERRLOG:
       set @DATA = 'Bad Input'
           Return @DATA
END
GO
GRANT EXECUTE ON [dbo].[fn_IsLockedBy]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_NoDup]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_NoDup]
GO
CREATE FUNCTION [dbo].[fn_NoDup] (
        @NameCode as varchar(MAX)= '',
        @Sep as varchar(8) = ';'
)
RETURNS Varchar(Max)
AS
BEGIN
        DECLARE  @DATA as varchar(MAX)='', @pos as int = 0, @Email as varchar(128)
        set @NameCode = LTrim(RTrim(@NameCode))
        if CharIndex(@Sep+@Sep,@NameCode) > 0 Set @NameCode = replace(@NameCode,@Sep+@Sep,@Sep)
        if CharIndex(' ',@NameCode) > 0 Set @NameCode = replace(@NameCode,' ','')
        if Len(@NameCode) > Len(@Sep)+1 and right(@NameCode,Len(@Sep)) <> @Sep Set @NameCode = @NameCode + @Sep
        Set @Pos = CharIndex(@Sep,@NameCode)
        While @Pos > Len(@Sep)+2
        BEGIN
                Set @Email = Left(@NameCode,@Pos)
                Set @NameCode = Right(@NameCode, len(@NameCode)-@Pos)
                if CharIndex(@Sep+@Email,@Sep+@NameCode) > 0
                BEGIN
                   Set @NameCode = Replace(@Sep+@NameCode, @Sep+@Email,@Sep)
                   While CharIndex(@Sep+@Email,@NameCode) > 0
                         Set @NameCode = Replace(@NameCode, @Sep+@Email,@Sep)
                   if Len(@NameCode) > Len(@Sep)+1 Set @NameCOde = Substring(@NameCode,len(@Sep)+1,Len(@NameCode)-Len(@Sep))
                END
                Set @Pos = CharIndex(@Sep,@NameCode)
                Set @Data = @Data + @Email
        END
        --if len(@NameCode) > 2 set @Data = @Data + @NameCode
                if Len(@Data) > 0 set @Data = Left(@Data,Len(@Data)-Len(@Sep))
        RETURN @DATA
ERRLOG:
        set @Data = NULL
        return @Data
END
GO
GRANT EXECUTE ON [dbo].[fn_NoDup]
    TO CTEPESYS_UserRole;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_RemoveFrom]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_RemoveFrom]
GO
CREATE FUNCTION [dbo].[fn_RemoveFrom] (
        @RemovingList as Varchar(2048) = NULL,
        @SourceList as varchar(MAX)= '',
        @Sep as varchar(8) = ';'
)
RETURNS Varchar(Max)
AS
BEGIN
        DECLARE  @DATA as varchar(MAX)=@SourceList, @pos as int = 0, @Email as varchar(128)
        Set @DATA = LTrim(RTrim(@DATA))
        Set @RemovingList = LTrim(RTrim(@RemovingList))
        if CharIndex(@Sep+@Sep,@DATA) > 0 Set @DATA = replace(@DATA,@Sep+@Sep,@Sep)
        if CharIndex(@Sep+@Sep,@RemovingList) > 0 Set @RemovingList = replace(@RemovingList,@Sep+@Sep,@Sep)
        if CharIndex(' ',@DATA) > 0 Set @DATA = replace(@DATA,' ','')
        if CharIndex(' ',@RemovingList) > 0 Set @RemovingList = replace(@RemovingList,' ','')
        if Len(@DATA) > Len(@Sep)+1 and right(@DATA,Len(@Sep)) <> @Sep Set @DATA = @DATA + @Sep
        if Len(@RemovingList) > Len(@Sep)+1 and right(@RemovingList,Len(@Sep)) <> @Sep Set @RemovingList = @RemovingList + @Sep
        Set @Pos = CharIndex(@Sep,@RemovingList)
        While @Pos > Len(@Sep)+2
        BEGIN
                Set @Email = Left(@RemovingList,@Pos)
                Set @RemovingList = Right(@RemovingList, len(@RemovingList)-@Pos)

                if CharIndex(@Sep+@Email,@Sep+@Data) > 0
                BEGIN
                   Set @Data = Replace(@Sep+@Data, @Sep+@Email,@Sep)
                   While CharIndex(@Sep+@Email,@Data) > 0
                        Set @Data = Replace(@Data, @Sep+@Email,@Sep)
                   if Len(@Data) > Len(@Sep)+1 Set @Data = Substring(@Data,len(@Sep)+1,Len(@Data)-Len(@Sep))
                END
                Set @Pos = CharIndex(@Sep,@RemovingList)
        END
        --if len(@Data) > 2 set @Data = @Data + @Email
        if Len(@Data) > 0 set @Data = Left(@Data,Len(@Data)-Len(@Sep))
        RETURN @DATA
ERRLOG:
        set @Data = NULL
        return @Data
END
GO
GRANT EXECUTE ON [dbo].[fn_RemoveFrom]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_GetComSeg]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_GetComSeg]
GO
CREATE FUNCTION [dbo].[fn_GetComSeg] (
       @NameCode as varchar(256) = NULL,
       @CommCode as varchar(16) = 'C_EMAIL',
       @Sep as varchar(8) = ';'
)
RETURNS varchar(MAX)
AS
BEGIN
        Declare @Data as varchar(MAX) = '', @OID as int = NULL
        set @NameCode = UPPER(LTRIM(RTRIM(@NameCode)))
        if isNull(@NameCode,'') = '' or len(@NameCode) < 2    return  @Data
        if charIndex('C_GROUP:',@NameCode) = 1
        BEGIN
          Set @NameCode = replace(@NameCode,'C_GROUP:','')
          Set @Data = dbo.fn_GetCom(@NameCode,'C_GROUP',@CommCode)
        END
        else if charIndex('C_OWNER:',@NameCode) = 1
        BEGIN
          Set @NameCode = replace(@NameCode,'C_OWNER:','')
          Set @Data = dbo.fn_GetCom(@NameCode,'C_OWNER',@CommCode)
        END
        else if charIndex('C_NOTIIFICATION:',@NameCode) = 1 or charIndex('C_CHANNEL:',@NameCode) = 1
        BEGIN
          Set @NameCode = replace(replace(@NameCode,'C_NOTIFICATION:',''),'C_CHANNEL:','')
          Set @Data = dbo.fn_GetCom(@NameCode,'C_NOTIFICAITON',@CommCode)
        END
        else if charIndex('C_SVC_LIST:',@NameCode) = 1 or charIndex('C_LIST:',@NameCode) = 1
        BEGIN
          Set @NameCode = replace(replace(@NameCode,'C_SVC_LIST:',''),'C_LIST:','')
          Set @Data = dbo.fn_GetCom(@NameCode,'C_SVC_LIST',@CommCode)
        END
        else if charIndex('C_GRP_PERSON:',@NameCode) = 1
        BEGIN
          Set @NameCode = replace(@NameCode,'C_GRP_PERSON:','')
          Set @Data = dbo.fn_GetCom(@NameCode,'C_GRP_PERSON',@CommCode)
        END
        else if charIndex('C_GRP_ORG:',@NameCode) = 1
        BEGIN
          Set @NameCode = replace(@NameCode,'C_GRP_ORG:','')
          Set @Data = dbo.fn_GetCom(@NameCode,'C_GRP_ORG',@CommCode)
        END
        else if charIndex('C_LOGIN:',@NameCode) = 1
        BEGIN
          Set @NameCode = replace(@NameCode,'C_LOGIN:','')
          Set @Data = dbo.fn_GetCom(@NameCode,'C_LOGIN',@CommCode)
        END
        else if charIndex('C_EMAIL_TO:',@NameCode) = 1
        BEGIN
          Set @NameCode = replace(@NameCode,'C_EMAIL_TO:','')
          Set @Data = dbo.fn_GetCom(@NameCode,'C_EMAIL_TO',@CommCode)
        END
        else if charIndex('C_EMAIL_CC:',@NameCode) = 1
        BEGIN
          Set @NameCode = replace(@NameCode,'C_EMAIL_CC:','')
          Set @Data = dbo.fn_GetCom(@NameCode,'C_EMAIL_CC',@CommCode)
        END
        else if charIndex('C_EMAIL_BCC:',@NameCode) = 1
        BEGIN
          Set @NameCode = replace(@NameCode,'C_EMAIL_BCC:','')
          Set @Data = dbo.fn_GetCom(@NameCode,'C_EMAIL_BCC',@CommCode)
        END
        if Len(@Data) > 0 and len(@Sep) > 0 Set @Data = dbo.fn_NoDup(@Data,@Sep)
        Return @Data

ERRLOG:
        set @Data=''
        return @Data
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_GetComRef]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_GetComRef]
GO
CREATE FUNCTION [dbo].[fn_GetComRef] (
       @NameCode as varchar(256) = NULL,
       @CommCode as varchar(16) = 'C_EMAIL',
       @Sep as varchar(8) = ';'
)
RETURNS varchar(MAX)
AS
BEGIN
        Declare @Data as varchar(MAX) = '', @OID as int = NULL
        set @NameCode = UPPER(LTRIM(RTRIM(@NameCode)))
        if charIndex(' ',@NameCode) > 0 set @NameCode = Replace(@NameCode,' ','')
        if isNull(@NameCode,'') = '' or len(@NameCode) < 2  return  @Data
        if Right(@NameCode,1) <> '#' Set @NameCode = @NameCode + '#'
        Set @OID = charIndex('#',@NameCode)
        While @OID > 0
        BEGIN
                if @OID > 2 Set @Data = @Data +';'+ dbo.fn_GetComSeg(Left(@NameCode, @OID-1), @CommCode, @Sep)
                Set @NameCode = Right(@NameCode, Len(@NameCode)-@OID)
                set @OID = CharIndex('#',@NameCode)
        END
        if charIndex(';;',@Data) > 0 set @Data = Replace(@Data,';;',';')
        if left(@Data,1) = ';' set @Data = SubString(@Data,2,Len(@Data)-1)
        if len(@Data) > 0 and len(@Sep) > 0 set @Data = dbo.fn_NoDup(@Data,@Sep)
        Return @Data
ERRLOG:
        set @Data=''
        return @Data
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:        Returns
-- =============================================
IF OBJECT_ID (N'[dbo].[fn_CurDateAdd]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[fn_CurDateAdd]
GO
CREATE FUNCTION [dbo].[fn_CurDateAdd] (
        @UOMCode    as varchar(16) = 'C_ONCE',
        @Interval   as int = 0,
        @LastTime    as DATETIME = NULL,                                                       -- 3 description from categroy, 4 category from description 5
        @CurTime    as DATETIME=NULL
)
RETURNS DATETIME
AS
BEGIN
        Declare @Data as DateTime = NULL
        set   @Interval = dbo.fn_Max(@Interval,0)
        Set @UOMCode = Upper(RTRIM(LTRIM(@UOMCode)))
        if @CurTime is null set @CurTime = GetDate()

        if @LastTime is null
           set @Data = dbo.fn_DateAdd(@UOMCode,@Interval, @CurTime)
        else if @Interval > 0
        BEGIN
           set @Data = dbo.fn_DateAdd(@UOMCode,@Interval, @LastTime)
           if @Data <=@CurTime
           BEGIN
               Set @Data = Dateadd(Day, Datediff(Day, @Data, @CurTime), @Data)
           END
           While @Data <= @CurTime
           BEGIN
                set @Data = dbo.fn_DateAdd(@UOMCode,@Interval, @Data)
           END
        END
        else if @Interval < 0
        BEGIN
           set @Data = dbo.fn_DateAdd(@UOMCode,@Interval, @LastTime)
           if @Data > @CurTime
           BEGIN
               Set @Data = Dateadd(Day, Datediff(Day, @Data, @CurTime), @Data)
           END
           While @Data > @CurTime
           BEGIN
                set @Data = dbo.fn_DateAdd(@UOMCode,@Interval, @Data)
           END
        END
        else
             goto ErrorHandle
        RETURN @Data
ErrorHandle:
        Set @Data = NULL
        Return @Data
END

GO
GRANT EXECUTE ON [dbo].[fn_CurDateAdd]
    TO CTEPESYS_UserRole;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[fn_IsAudiitReadyExt]', 'FN') IS NOT NULL
   DROP FUNCTION [dbo].[fn_IsAudiitReadyExt]
GO
/*============================================================*/
/* Created By Peter Yan on Date:                              */
/* Description:                                               */
/*============================================================*/
CREATE FUNCTION [dbo].[fn_IsAudiitReadyExt]
(
  @P_Table as varchar(128) = NULL,
  @P_Check as BIT = True
)
RETURNS INT
AS
BEGIN
  DECLARE @V_RV as INT = 0, @AUDIT_DBName varchar(64) = DB_NAME() + '_AUDIT';

  BEGIN TRY
     if DB_ID(@AUDIT_DBName) Is NOT null
     BEGIN
          SELECT  @V_RV = Audit from Code_Registrations where NameCode = @P_Table
     END
  END TRY
  RETURN @V_RV
  BEGIN CATCH
        if ERROR_NUMBER() <> 0
        BEGIN
                declare @errMsg as varchar(4000) = ERROR_MESSAGE() + ' ErrCode:'+ cast(ERROR_NUMBER() as varchar(4)), @SenderID as varchar(64) = SUSER_NAME()
                exec sp_DBLog_Message @Method='[dbo].[fn_IsAudiitReadyExt]', @Class=@TRP_ID, @Description=@ErrMsg, @ErrorMessage=@errMsg, @LoggedInUserID=@SenderID, @Mail='No'
        END
        RETURN @V_RV
  END CATCH
END;
GO
GRANT EXECUTE ON [dbo].[fn_IsAudiitReadyExt]
    TO eGOS_UserRole
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[sp_GetIDNumber]', 'P') IS NOT NULL
   DROP PROCEDURE [dbo].[sp_GetIDNumber]
GO

/*============================================================*/
/* Created By Peter Yan on Date:                              */
/* Description:                                               */
/*============================================================*/
CREATE PROCEDURE [dbo].[sp_GetIDNumber]
  @P_IDF       as varchar(64)   = NULL,
  @P_TYPE      as varchar(16)   = 'C_ORDER',
  @P_APP       as varchar(64)   = 'C_SP',
  @P_ORG_IDF   as varchar(64)   = NULL,
  @P_USER      as varchar(128)  = NULL,
  @P_DATE      as DATETIME      = NULL,
  @P_STATUS    as varchar(16)   = NULL,
  @ReturnValue as varchar(16)   = '' OUTPUT
  AS
BEGIN
  Set @P_USER   = ISNULL(@P_USER, SUSER_NAME())
  Set @P_STATUS = ISNULL(@P_STATUS, 'ACTIVE')
  SET @P_DATE   = ISNULL(@P_DATE, GETDATE())

  if len(IsNULL(@P_APP,'C_SP')) = 64   set @P_APP = 'C_' + replace(LEFT(@P_APP,3),'X','')

  IF @P_TYPE in ('C_ORDER','C_TO')
  BEGIN
      IF @P_APP in ('C_SP', 'C_SP3', 'C_CS', 'C_GSS')
      BEGIN
          INSERT REF_NITAAC_IDS(NAME_CODE, LOCKED_BY, LOCKED_DATE, LOCK_EXPIRED_DATE, ORGANIZATION_IDF, CREATED_DATE, CREATED_BY, CATEGORY_CODE, TYPE_CODE, STATUS_CODE, STATUS_DATE, DESCRIPTION)
          VALUES('Task Order', @P_USER, @P_DATE, DateAdd(DAY, 1, @P_DATE), @P_ORG_IDF, @P_DATE, @P_USER, @P_APP, @P_TYPE, @P_STATUS, @P_DATE, '')
          if @@ROWCOUNT > 0
          BEGIN
             Set @ReturnValue = 'TO_' + RIGHT('00000000'+Cast(IDENT_CURRENT('REF_NITAAC_IDS') as varchar(8)),8)
             UPDATE REF_NITAAC_IDS set VALUE_CODE = @ReturnValue WHERE ORGANIZATION_IDF = @P_ORG_IDF AND CREATED_BY = @P_USER AND CREATED_DATE = @P_DATE AND ORDER_NUMBER = cast(RIGHT(@ReturnValue,8) as int)
          END
      END
  END
  ELSE IF @P_TYPE in ('C_PROPOSAL', 'C_BID')
  BEGIN
          SELECT @ReturnValue = ACRONYM_NAME + '_' +  RIGHT('00000000'+Cast(PROPOSAL_NUMBER as varchar(8)),8) From CONTRACTS WHERE CONTRACTOR_IDF = @P_ORG_IDF AND ISNULL(LOCKED_BY,'') = '' AND STATUS_CODE = 'ACTIVE'
          if @@ROWCOUNT > 0
          BEGIN
                UPDATE CONTRACTS Set LAST_PROPOSAL_NUMBER = PROPOSAL_NUMBER, PROPOSAL_NUMBER = PROPOSAL_NUMBER + 1, LOCKED_BY = @P_USER, LOCKED_DATE = @P_DATE, LOCK_EXPIRED_DATE = DateAdd(Day, 1, @P_DATE), UPDATED_BY = @P_USER, UPDATED_DATE = @P_DATE, UPDATED_COUNT = UPDATED_COUNT + 1
                WHERE CONTRACTOR_IDF = @P_ORG_IDF AND ISNULL(LOCKED_BY,'') = '' AND STATUS_CODE = 'ACTIVE'
          END
  END
 --- ELSE IF @P_TYPE IN ('','')
END;
GO
GRANT EXECUTE ON [dbo].[sp_GetIDNumber]
    TO NEOS_UserRole
GO

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
