---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Remove-SmoSqlAgentCategory

## SYNOPSIS
Removes the specified category.

## SYNTAX

### ServerInstance (Default)
```
Remove-SmoSqlAgentCategory
	-ServerInstance <String>
	-Class <String>
	-CategoryName <String>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
Remove-SmoSqlAgentCategory
	-SmoServerObject <Server>
	-Class <String>
	-CategoryName <String>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Removes the specified category of jobs, alerts, or operators from the current server.

## EXAMPLES

### EXAMPLE 1
```powershell
Remove-SmoSqlAgentCategory -ServerInstance MyServer -Class Alert -CategoryName MyCategory
```

Removes agent category MyCategory in class Alert.

### EXAMPLE 2
```powershell
Remove-SmoSqlAgentCategory -SmoServerObject $SmoServerObject -Class Alert -CategoryName MyCategory
```

Removes agent category MyCategory in class Alert using Smo server object.

## PARAMETERS

### -CategoryName
The name of the category to be removed.

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

### -Class
The class of the category.

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
