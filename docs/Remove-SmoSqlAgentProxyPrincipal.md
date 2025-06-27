---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Remove-SmoSqlAgentProxyPrincipal

## SYNOPSIS
Removes principal from proxy account.

## SYNTAX

### ServerInstance (Default)
```
Remove-SmoSqlAgentProxyPrincipal
	-ServerInstance <String>
	-ProxyAccountName <String>
	-PrincipalName <String[]>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
Remove-SmoSqlAgentProxyPrincipal
	-SmoServerObject <Server>
	-ProxyAccountName <String>
	-PrincipalName <String[]>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Removes principal from proxy account.

## EXAMPLES

### EXAMPLE 1
```powershell
Remove-SmoSqlAgentProxyPrincipal -ServerInstance MyServer -ProxyAccountName MyProxy -PrincipalName MyPrincipal
```

Removes principal MyPrincipal from MyProxy agent proxy.

### EXAMPLE 2
```powershell
Remove-SmoSqlAgentProxyPrincipal -SmoServerObject $SmoServerObject -ProxyAccountName MyProxy -PrincipalName MyPrincipal
```

Removes principal MyPrincipal from MyProxy agent proxy using Smo server object.

## PARAMETERS

### -PrincipalName
The name of principal to remove.

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
Proxy account to remove principal from.

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
