---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Remove-SmoSqlAgentProxySubSystem

## SYNOPSIS
Removes subsystem from proxy account.

## SYNTAX

### ServerInstance (Default)
```
Remove-SmoSqlAgentProxySubSystem
	-ServerInstance <String>
	[-ProxyAccountName <String>]
	[-SubSystemName <AgentSubSystem>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
Remove-SmoSqlAgentProxySubSystem
	-SmoServerObject <Server>
	[-ProxyAccountName <String>]
	[-SubSystemName <AgentSubSystem>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Removes subsystem from proxy account.

## EXAMPLES

### EXAMPLE 1
```powershell
Remove-SmoSqlAgentProxySubSystem -ServerInstance MyServer -ProxyAccountName MyProxy -SubSystemName PowerShell
```

Removes PowerShell subsystem from proxy account MyProxy.

### EXAMPLE 2
```powershell
Remove-SmoSqlAgentProxySubSystem -SmoServerObject $SmoServerObject -ProxyAccountName MyProxy -SubSystemName PowerShell
```

Removes PowerShell subsystem from proxy account MyProxy using Smo server object.

## PARAMETERS

### -ProxyAccountName
The proxy account to remove Agent subsystem from.

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

### -SubSystemName
The agent subsystem to remove.

```yaml
Type: AgentSubSystem
Parameter Sets: (All)
Aliases:
Accepted values: TransactSql, ActiveScripting, CmdExec, Snapshot, LogReader, Distribution, Merge, QueueReader, AnalysisQuery, AnalysisCommand, Ssis, PowerShell

Required: False
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
