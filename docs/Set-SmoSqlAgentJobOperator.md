---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Set-SmoSqlAgentJobOperator

## SYNOPSIS
Set job operator notification methods.

## SYNTAX

### ServerInstance (Default)
```
Set-SmoSqlAgentJobOperator
	-ServerInstance <String>
	-JobName <String>
	-OperatorName <String[]>
	[-EmailLevel <CompletionAction>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
Set-SmoSqlAgentJobOperator
	-SmoServerObject <Server>
	-JobName <String>
	-OperatorName <String[]>
	[-EmailLevel <CompletionAction>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Set job operator notification methods.

## EXAMPLES

### EXAMPLE 1
```powershell
Set-SmoSqlAgentJobOperator -ServerInstance MyServer -JobName MyJob -OperatorName MyOperator -EmailLevel OnFailure
```

Set agent job operator properties on MyJob.

### EXAMPLE 2
```powershell
Set-SmoSqlAgentJobOperator -SmoServerObject $SmoServerObject -JobName MyJob -OperatorName MyOperator -EmailLevel OnFailure
```

Set agent job operator properties on MyJob using Smo server object.

## PARAMETERS

### -EmailLevel
The method by which the operator is notified.

```yaml
Type: CompletionAction
Parameter Sets: (All)
Aliases:
Accepted values: Never, OnSuccess, OnFailure, Always

Required: False
Position: Named
Default value: OnFailure
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

### -OperatorName
Specifies operator name.

```yaml
Type: String[]
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

### Microsoft.SqlServer.Management.Smo.Agent.Operator

## NOTES

## RELATED LINKS
