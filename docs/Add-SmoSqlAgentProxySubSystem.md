---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Add-SmoSqlAgentProxySubSystem

## SYNOPSIS
Grants a proxy access to a subsystem.

## SYNTAX

### ServerInstance (Default)
```
Add-SmoSqlAgentProxySubSystem
	-ServerInstance <String>
	[-ProxyAccountName <String>]
	[-SubSystemName <AgentSubSystem>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
Add-SmoSqlAgentProxySubSystem
	-SmoServerObject <Server>
	[-ProxyAccountName <String>]
	[-SubSystemName <AgentSubSystem>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Grants a proxy access to a subsystem.

## EXAMPLES

### EXAMPLE 1
```powershell
Add-SmoSqlAgentProxySubSystem -ServerInstance MyServer -ProxyAccountName MyPRoxyAccount -SubSystemName PowerShell
```

Adds Powershell subsystem to proxy account MyPRoxyAccount.

### EXAMPLE 2
```powershell
Add-SmoSqlAgentProxySubSystem -SmoServerObject $SmoServerObject -ProxyAccountName MyPRoxyAccount -SubSystemName PowerShell
```

Adds Powershell subsystem to proxy account MyPRoxyAccount using Smo server object.

## PARAMETERS

### -ProxyAccountName
The proxy account to add subsystem.

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
The name of the subsystem to grant access to.

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
