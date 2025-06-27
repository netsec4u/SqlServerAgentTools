---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Get-SmoSqlAgentJob

## SYNOPSIS
Gets a SQL Agent Job object for each job that is present in the target instance of SQL Agent.

## SYNTAX

### ServerInstance (Default)
```
Get-SmoSqlAgentJob
	-ServerInstance <String>
	[-JobName <String>]
	[<CommonParameters>]
```

### SmoServer
```
Get-SmoSqlAgentJob
	-SmoServerObject <Server>
	[-JobName <String>]
	[<CommonParameters>]
```

## DESCRIPTION
The Get-SmoSqlAgentJob function gets a SQL Agent Job object for each job that is present in the target instance of SQL Agent.
If the name of the job is provided, the function gets only this specific job object.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-SmoSqlAgentJob -ServerInstance MyServer
```

Lists all agent jobs.

### EXAMPLE 2
```powershell
Get-SmoSqlAgentJob -SmoServerObject $SmoServerObject
```

Lists all agent jobs using Smo server object.

### EXAMPLE 3
```powershell
Get-SmoSqlAgentJob -SmoServerObject $SmoServerObject -JobName MyJob
```

Lists agent job MyJob using Smo server object.

## PARAMETERS

### -JobName
Specifies the name of the job.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Microsoft.SqlServer.Management.Smo.Agent.Job

## NOTES

## RELATED LINKS
