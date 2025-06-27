---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Get-SmoSqlAgentAlert

## SYNOPSIS
Get SQL Agent alert.

## SYNTAX

### ServerInstance (Default)
```
Get-SmoSqlAgentAlert
	-ServerInstance <String>
	[-AlertName <String>]
	[<CommonParameters>]
```

### SmoServer
```
Get-SmoSqlAgentAlert
	-SmoServerObject <Server>
	[-AlertName <String>]
	[<CommonParameters>]
```

## DESCRIPTION
Get SQL Agent alert.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-SmoSqlAgentAlert -ServerInstance MyServer
```

Lists all agent alerts.

### EXAMPLE 2
```powershell
Get-SmoSqlAgentAlert -SmoServerObject $SmoServerObject
```

Lists all agent alerts using Smo server object.

### EXAMPLE 3
```powershell
Get-SmoSqlAgentAlert -SmoServerObject $SmoServerObject -AlertName MyAlert
```

Lists agent alert MyAlert using Smo server object.

## PARAMETERS

### -AlertName
Specifies the name of alert.

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

### Microsoft.SqlServer.Management.Smo.Agent.Alert

## NOTES

## RELATED LINKS
