---
document type: cmdlet
external help file: SQLServerAgentTools-help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 07/29/2025
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

### EXAMPLE 1

Get-SmoSqlAgentSubSystem -ServerInstance MyServer -SubSystem PowerShell

Lists agent PowerShell subsystem.

### EXAMPLE 2

Get-SmoSqlAgentSubSystem -SmoServerObject $SmoServerObject -SubSystem PowerShell

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

SQL Server host name and instance name.

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

SQL Server Management Object.

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

None.

