---
document type: cmdlet
external help file: SqlServerAgentTools-Help.xml
HelpUri: https://github.com/netsec4u/SqlServerAgentTools/blob/main/docs/Get-SmoSqlAgentSubSystem.md
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 05/08/2026
PlatyPS schema version: 2024-05-01
title: Get-SmoSqlAgentSubSystem
---

# Get-SmoSqlAgentSubSystem

## SYNOPSIS

Gets SQL Server agent subsystem.

## SYNTAX

### ServerInstance (Default)

```
Get-SmoSqlAgentSubSystem
  -ServerInstance <string>
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

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

Gets SQL Server agent subsystem.

## EXAMPLES

### Example 1

```powershell
Get-SmoSqlAgentSubSystem -ServerInstance MyServer -SubSystem PowerShell
```

Lists agent PowerShell subsystem.

### Example 2

```powershell
Get-SmoSqlAgentSubSystem -SmoServerObject $SmoServerObject -SubSystem PowerShell
```

Lists agent PowerShell subsystem using Smo server object.

## PARAMETERS

### -AgentSubSystem

The SQL Agent subsystem to get maximum worker threads.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Agent.AgentSubSystem
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ServerInstance

The name of the SQL Server instance to connect to.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases:
- SqlServer
ParameterSets:
- Name: ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -SmoServerObject

An existing SMO Server object representing the SQL Server instance.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Server
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### SqlServerAgent.AgentSubsystem



## NOTES




## RELATED LINKS

