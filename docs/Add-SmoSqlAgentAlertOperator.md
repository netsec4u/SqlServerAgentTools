---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Add-SmoSqlAgentAlertOperator

## SYNOPSIS
Add operator to agent alert.

## SYNTAX

### ServerInstance (Default)
```
Add-SmoSqlAgentAlertOperator
	-ServerInstance <String>
	-AlertName <String>
	-OperatorName <String[]>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
Add-SmoSqlAgentAlertOperator
	-SmoServerObject <Server>
	-AlertName <String>
	-OperatorName <String[]>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Add operator to agent alert.

## EXAMPLES

### EXAMPLE 1
```powershell
Add-SmoSqlAgentAlertOperator -ServerInstance MyServer -AlertName MyAlert -OperatorName MyOperator
```

Adds MyOperator to alert MyAlert.

### EXAMPLE 2
```powershell
Add-SmoSqlAgentAlertOperator -SmoServerObject $SmoServerObject -AlertName MyAlert -OperatorName MyOperator
```

Adds MyOperator to alert MyAlert using the Smo server object.

## PARAMETERS

### -AlertName
The name of the alert associated with this notification.

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
The operator who will be notified when the alert occurs.

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

### System.Void

## NOTES

## RELATED LINKS
