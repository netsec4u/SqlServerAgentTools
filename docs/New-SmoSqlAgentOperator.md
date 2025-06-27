---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# New-SmoSqlAgentOperator

## SYNOPSIS
Creates an operator.

## SYNTAX

### ServerInstance (Default)
```
New-SmoSqlAgentOperator
	-ServerInstance <String>
	-OperatorName <String>
	[-IsEnabled <Boolean>]
	-OperatorEmailAddress <String>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
New-SmoSqlAgentOperator
	-SmoServerObject <Server>
	-OperatorName <String>
	[-IsEnabled <Boolean>]
	-OperatorEmailAddress <String>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Creates an operator (notification recipient) for use with alerts and jobs.

## EXAMPLES

### EXAMPLE 1
```powershell
New-SmoSqlAgentOperator -ServerInstance MyServer -OperatorName MyOperator -OperatorEmailAddress operator@domain.com
```

Creates agent operator MyOperator.

### EXAMPLE 2
```powershell
New-SmoSqlAgentOperator -SmoServerObject $SmoServerObject -OperatorName MyOperator -OperatorEmailAddress operator@domain.com
```

Creates agent operator MyOperator using Smo server object.

## PARAMETERS

### -IsEnabled
Indicates the current status of the operator.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -OperatorEmailAddress
The e-mail address of the operator.

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
The name of an operator (notification recipient).

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

### Microsoft.SqlServer.Management.Smo.Agent.Operator

## NOTES

## RELATED LINKS
