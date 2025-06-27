---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Get-SmoSqlAgentOperator

## SYNOPSIS
Gets a SQL Agent Job Operator object for each operator that is present in the target instance of SQL Agent.

## SYNTAX

### ServerInstance (Default)
```
Get-SmoSqlAgentOperator
	-ServerInstance <String>
	[-OperatorName <String>]
	[<CommonParameters>]
```

### SmoServer
```
Get-SmoSqlAgentOperator
	-SmoServerObject <Server>
	[-OperatorName <String>]
	[<CommonParameters>]
```

## DESCRIPTION
The Get-SmoSqlAgentOperator function gets a SQL Agent Job object for each operator that is present in the target instance of SQL Agent.
If the name of the operator is provided, the function gets only this specific operator object.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-SmoSqlAgentOperator -ServerInstance MyServer
```

Lists agent operators.

### EXAMPLE 2
```powershell
Get-SmoSqlAgentOperator -SmoServerObject $SmoServerObject
```

Lists agent operators using Smo server object.

### EXAMPLE 3
```powershell
Get-SmoSqlAgentOperator -SmoServerObject $SmoServerObject -OperatorName MyOperator
```

Lists agent operator MyOperator using Smo server object.

## PARAMETERS

### -OperatorName
The operator name to retrieve.

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

### Microsoft.SqlServer.Management.Smo.Agent.Operator

## NOTES

## RELATED LINKS
