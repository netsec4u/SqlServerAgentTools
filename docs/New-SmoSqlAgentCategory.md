---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# New-SmoSqlAgentCategory

## SYNOPSIS
Creates SQL Agent category.

## SYNTAX

### ServerInstance (Default)
```
New-SmoSqlAgentCategory
	-ServerInstance <String>
	-Class <String>
	-CategoryName <String>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
New-SmoSqlAgentCategory
	-SmoServerObject <Server>
	-Class <String>
	-CategoryName <String>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Creates SQL Agent Alert, Job, or Operator category

## EXAMPLES

### EXAMPLE 1
```powershell
New-SmoSqlAgentCategory -ServerInstance MyServer -Class Alert -CategoryName MyCategory
```

Creates agent category MyCategory in Alert class.

### EXAMPLE 2
```powershell
New-SmoSqlAgentCategory -SmoServerObject $SmoServerObject -Class Alert -CategoryName MyCategory
```

Creates agent category MyCategory in Alert class using Smo server object.

## PARAMETERS

### -CategoryName
The name of the category to be added.

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
The class of the category to be added.

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

### Microsoft.SqlServer.Management.Smo.Agent.AlertCategory
### Microsoft.SqlServer.Management.Smo.Agent.JobCategory
### Microsoft.SqlServer.Management.Smo.Agent.OperatorCategory

## NOTES

## RELATED LINKS
