---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Set-SmoSqlAgentSubSystem

## SYNOPSIS
Sets maximum worker threads for agent subsystem.

## SYNTAX

### ServerInstance (Default)
```
Set-SmoSqlAgentSubSystem
	-ServerInstance <String>
	-AgentSubSystem <AgentSubSystem>
	-MaxWorkerThreads <Int32>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
Set-SmoSqlAgentSubSystem
	-SmoServerObject <Server>
	-AgentSubSystem <AgentSubSystem>
	-MaxWorkerThreads <Int32>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Sets maximum worker threads for agent subsystem.

## EXAMPLES

### EXAMPLE 1
```powershell
Set-SmoSqlAgentSubSystem -ServerInstance MyServer -SubSystem PowerShell -MaxWorkerThreads 20
```

Sets PowerShell agent subsystem max worker threads to 20.

### EXAMPLE 2
```powershell
Set-SmoSqlAgentSubSystem -SmoServerObject $SmoServerObject -SubSystem PowerShell -MaxWorkerThreads 20
```

Sets PowerShell agent subsystem max worker threads to 20 using Smo server object.

## PARAMETERS

### -AgentSubSystem
The SQL Agent subsystem to set maximum worker threads.

```yaml
Type: AgentSubSystem
Parameter Sets: (All)
Aliases:
Accepted values: TransactSql, ActiveScripting, CmdExec, Snapshot, LogReader, Distribution, Merge, QueueReader, AnalysisQuery, AnalysisCommand, Ssis, PowerShell

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxWorkerThreads
The maximum number of worker threads.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
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

### SqlServerAgent.MsxEncryptChannelOption

## NOTES

## RELATED LINKS
