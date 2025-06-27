---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Read-SmoSqlAgentJobHistory

## SYNOPSIS
Reads a SQL Agent Job history.

## SYNTAX

### ServerInstance (Default)
```
Read-SmoSqlAgentJobHistory
	-ServerInstance <String>
	-JobName <String>
	[-CompletionResult <CompletionResult[]>]
	[-MessageID <Int32>]
	[-Severity <Int32>]
	[-StartRunDate <DateTime>]
	[-EndRunDate <DateTime>]
	[<CommonParameters>]
```

### SmoServer
```
Read-SmoSqlAgentJobHistory
	-SmoServerObject <Server>
	-JobName <String>
	[-CompletionResult <CompletionResult[]>]
	[-MessageID <Int32>]
	[-Severity <Int32>]
	[-StartRunDate <DateTime>]
	[-EndRunDate <DateTime>]
	[<CommonParameters>]
```

## DESCRIPTION
Reads a SQL Agent Job history.

## EXAMPLES

### EXAMPLE 1
```powershell
Read-SmoSqlAgentJobHistory -ServerInstance MyServer -JobName MyJob
```

Lists agent job history for MyJob.

### EXAMPLE 2
```powershell
Read-SmoSqlAgentJobHistory -SmoServerObject $SmoServerObject -JobName MyJob
```

Lists agent job history using specified SMO connection for job MyJob.

## PARAMETERS

### -CompletionResult
Specifies the job completion status result.

```yaml
Type: CompletionResult[]
Parameter Sets: (All)
Aliases:
Accepted values: Failed, Succeeded, Retry, Cancelled, InProgress, Unknown

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndRunDate
Specifies end run date.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JobName
Specifies the name of the job.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MessageID
Specifies message ID.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServerInstance
SQL Server host name and instance name.

```yaml
Type: String
Parameter Sets: ServerInstance
Aliases: SqlServer

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Severity
Specifies severity.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -SmoServerObject
SQL Server Management Object.

```yaml
Type: Server
Parameter Sets: SmoServer
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartRunDate
Specifies start run date.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### SqlServerAgent.JobHistory

## NOTES

## RELATED LINKS
