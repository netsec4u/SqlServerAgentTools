---
document type: cmdlet
external help file: SqlServerAgentTools-Help.xml
HelpUri: https://github.com/netsec4u/SqlServerAgentTools/blob/main/docs/Add-SmoSqlAgentProxySubSystem.md
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 05/08/2026
PlatyPS schema version: 2024-05-01
title: Add-SmoSqlAgentProxySubSystem
---

# Add-SmoSqlAgentProxySubSystem

## SYNOPSIS

Grants a proxy access to a subsystem.

## SYNTAX

### ServerInstance (Default)

```
Add-SmoSqlAgentProxySubSystem
  -ServerInstance <string>
  [-ProxyAccountName <string>]
  [-SubSystemName <AgentSubSystem>]
  [-WhatIf]
  [-Confirm]
  [<CommonParameters>]
```

### SmoServer

```
Add-SmoSqlAgentProxySubSystem
  -SmoServerObject <Server>
  [-ProxyAccountName <string>]
  [-SubSystemName <AgentSubSystem>]
  [-WhatIf]
  [-Confirm]
  [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

Grants a proxy access to a subsystem.

## EXAMPLES

### Example 1

```powershell
Add-SmoSqlAgentProxySubSystem -ServerInstance MyServer -ProxyAccountName MyPRoxyAccount -SubSystemName PowerShell
```

Adds Powershell subsystem to proxy account MyPRoxyAccount.

### Example 2

```powershell
Add-SmoSqlAgentProxySubSystem -SmoServerObject $SmoServerObject -ProxyAccountName MyPRoxyAccount -SubSystemName PowerShell
```

Adds Powershell subsystem to proxy account MyPRoxyAccount using Smo server object.

## PARAMETERS

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases:
- cf
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

### -ProxyAccountName

The proxy account to add subsystem.

```yaml
Type: System.String
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

### -SubSystemName

The name of the subsystem to grant access to.

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

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases:
- wi
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Void



## NOTES




## RELATED LINKS

