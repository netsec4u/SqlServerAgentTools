---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Start-SmoSqlAgentJob

## SYNOPSIS
Starts SQL Agent job.

## SYNTAX

### ServerInstance (Default)
```
Start-SmoSqlAgentJob
	-ServerInstance <String>
	-JobName <String>
	[-JobStepName <String>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
Start-SmoSqlAgentJob
	-SmoServerObject <Server>
	-JobName <String>
	[-JobStepName <String>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Starts SQL Agent job.

## EXAMPLES

### EXAMPLE 1
```powershell
Start-SmoSqlAgentJob -ServerInstance MyServer -JobName MyJob
```

Starts agent job MyJob.

### EXAMPLE 2
```powershell
Start-SmoSqlAgentJob -SmoServerObject $SmoServerObject -JobName MyJob
```

Starts agent job MyJob using Smo server object.

### EXAMPLE 3
```powershell
Start-SmoSqlAgentJob -ServerInstance MyServer -JobName MyJob -JobStepName 'MyJobStep'
```

Starts agent job MyJob at step MyJobStep.

## PARAMETERS

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

### -JobStepName
The name of the step to start job.

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
