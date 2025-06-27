---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Get-SmoSqlAgentSubSystem

## SYNOPSIS
Gets SQL Server agent subsystem.

## SYNTAX

### ServerInstance (Default)
```
Get-SmoSqlAgentSubSystem
	-ServerInstance <String>
	[-AgentSubSystem <AgentSubSystem>]
	[<CommonParameters>]
```

### SmoServer
```
Get-SmoSqlAgentSubSystem
	-SmoServerObject <Server>
	[-AgentSubSystem <AgentSubSystem>]
	[<CommonParameters>]
```

## DESCRIPTION
Gets SQL Server agent subsystem.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-SmoSqlAgentSubSystem -ServerInstance MyServer -SubSystem PowerShell
```

Lists agent PowerShell subsystem.

### EXAMPLE 2
```powershell
Get-SmoSqlAgentSubSystem -SmoServerObject $SmoServerObject -SubSystem PowerShell
```

Lists agent PowerShell subsystem using Smo server object.

## PARAMETERS

### -AgentSubSystem
The SQL Agent subsystem to get maximum worker threads.

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

### SqlServerAgent.AgentSubsystem

## NOTES

## RELATED LINKS
