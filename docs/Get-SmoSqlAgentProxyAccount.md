---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Get-SmoSqlAgentProxyAccount

## SYNOPSIS
Gets a SQL Agent Proxy Account object for each proxy account that is present in the target instance of SQL Agent.

## SYNTAX

### ServerInstance (Default)
```
Get-SmoSqlAgentProxyAccount
	-ServerInstance <String>
	[-ProxyAccountName <String>]
	[<CommonParameters>]
```

### SmoServer
```
Get-SmoSqlAgentProxyAccount
	-SmoServerObject <Server>
	[-ProxyAccountName <String>]
	[<CommonParameters>]
```

## DESCRIPTION
The Get-SmoSqlAgentProxyAccount function gets a SQL Agent Proxy Account object for each operator that is present in the target instance of SQL Agent.
If the name of the proxy account is provided, the function gets only this specific proxy account object.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-SmoSqlAgentProxyAccount -ServerInstance MyServer
```

Lists agent proxy accounts.

### EXAMPLE 2
```powershell
Get-SmoSqlAgentProxyAccount -SmoServerObject $SmoServerObject
```

Lists agent proxy accounts using Smo server object.

### EXAMPLE 3
```powershell
Get-SmoSqlAgentProxyAccount -SmoServerObject $SmoServerObject -ProxyAccountName MyProxy
```

Lists agent proxy MyProxy using Smo server object.

## PARAMETERS

### -ProxyAccountName
the proxy account to return.

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

### Microsoft.SqlServer.Management.Smo.Agent.ProxyAccount

## NOTES

## RELATED LINKS
