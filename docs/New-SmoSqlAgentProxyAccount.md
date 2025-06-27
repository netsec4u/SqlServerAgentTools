---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# New-SmoSqlAgentProxyAccount

## SYNOPSIS
Creates the specified SQL Server Agent proxy.

## SYNTAX

### ServerInstance (Default)
```
New-SmoSqlAgentProxyAccount
	-ServerInstance <String>
	-ProxyAccountName <String>
	-CredentialName <String>
	-Description <String>
	-AgentSubSystem <AgentSubSystem[]>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
New-SmoSqlAgentProxyAccount
	-SmoServerObject <Server>
	-ProxyAccountName <String>
	-CredentialName <String>
	-Description <String>
	-AgentSubSystem <AgentSubSystem[]>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Creates the specified SQL Server Agent proxy.

## EXAMPLES

### EXAMPLE 1
```powershell
New-SmoSqlAgentProxyAccount -ServerInstance MyServer -ProxyAccountName MyProxyName -CredentialName MyCredential -AgentSubSystem PowerShell
```

Creates agent proxy account MyProxyName in the PowerShell agent subsystem.

### EXAMPLE 2
```powershell
New-SmoSqlAgentProxyAccount -SmoServerObject $SmoServerObject -ProxyAccountName MyProxyName -CredentialName MyCredential -AgentSubSystem PowerShell
```

Creates agent proxy account MyProxyName in the PowerShell agent subsystem using Smo server object.

## PARAMETERS

### -AgentSubSystem
The name of the subsystem to grant access to.

```yaml
Type: AgentSubSystem[]
Parameter Sets: (All)
Aliases:
Accepted values: TransactSql, ActiveScripting, CmdExec, Snapshot, LogReader, Distribution, Merge, QueueReader, AnalysisQuery, AnalysisCommand, Ssis, PowerShell

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CredentialName
The name of the credential for the proxy.

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

### -Description
A description of the proxy.

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

### -ProxyAccountName
The name of the proxy to create.

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

### Microsoft.SqlServer.Management.Smo.Agent.ProxyAccount

## NOTES

## RELATED LINKS
