---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Add-SmoSqlAgentJobSchedule

## SYNOPSIS
Add schedule to Agent job.

## SYNTAX

### ServerInstance (Default)
```
Add-SmoSqlAgentJobSchedule
	-ServerInstance <String>
	-JobName <String>
	-ScheduleName <String>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
Add-SmoSqlAgentJobSchedule
	-SmoServerObject <Server>
	-JobName <String>
	-ScheduleName <String>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Add schedule to Agent job.

## EXAMPLES

### EXAMPLE 1
```powershell
Add-SmoSqlAgentJobSchedule -ServerInstance MyServer -JobName MyJob -ScheduleName MySchedule
```

Adds schedule MySchedule to agent job MyJob.

### EXAMPLE 2
```powershell
Add-SmoSqlAgentJobSchedule -SmoServerObject $SmoServerObject -JobName MyJob -ScheduleName MySchedule
```

Adds schedule MySchedule to agent job MyJob using Smo server object.

## PARAMETERS

### -JobName
The name of the job to which the schedule is added.

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

### -ScheduleName
Then name of the schedule.

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

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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

### System.Void

## NOTES

## RELATED LINKS
