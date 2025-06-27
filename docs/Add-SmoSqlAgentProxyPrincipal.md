---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Add-SmoSqlAgentProxyPrincipal

## SYNOPSIS
Adds proxy account principals.

## SYNTAX

### ServerInstance (Default)
```
Add-SmoSqlAgentProxyPrincipal
	-ServerInstance <String>
	-ProxyAccountName <String>
	-PrincipalName <String[]>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
Add-SmoSqlAgentProxyPrincipal
	-SmoServerObject <Server>
	-ProxyAccountName <String>
	-PrincipalName <String[]>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Adds SQL Server logins, server roles to grant access to the proxy account.

## EXAMPLES

### EXAMPLE 1
```powershell
Add-SmoSqlAgentProxyPrincipal -ServerInstance MyServer -ProxyAccountName MyProxy -PrincipalName 'domain\jdoe'
```

Adds principal "domain\jdoe" to proxy MyProxy.

### EXAMPLE 2
```powershell
Add-SmoSqlAgentProxyPrincipal -SmoServerObject $SmoServerObject -ProxyAccountName MyProxy -PrincipalName 'domain\jdoe'
```

Adds principal "domain\jdoe" to proxy MyProxy using Smo server object.

## PARAMETERS

### -PrincipalName
The name of the new credential for the proxy.

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

### -ProxyAccountName
The name of the proxy to add principal.

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
