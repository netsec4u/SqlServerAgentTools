---
document type: cmdlet
external help file: SQLServerAgentTools-help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 07/29/2025
PlatyPS schema version: 2024-05-01
title: Get-SmoSqlAgentProxyAccount
---

# Get-SmoSqlAgentProxyAccount

## SYNOPSIS

Gets a SQL Agent Proxy Account object for each proxy account that is present in the target instance of SQL Agent.

## SYNTAX

### ServerInstance (Default)

```
Get-SmoSqlAgentProxyAccount
  -ServerInstance <string>
  [-ProxyAccountName <string>]
  [<CommonParameters>]
```

### SmoServer

```
Get-SmoSqlAgentProxyAccount
  -SmoServerObject <Server>
  [-ProxyAccountName <string>]
  [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

The Get-SmoSqlAgentProxyAccount function gets a SQL Agent Proxy Account object for each operator that is present in the target instance of SQL Agent.
If the name of the proxy account is provided, the function gets only this specific proxy account object.

## EXAMPLES

### EXAMPLE 1

Get-SmoSqlAgentProxyAccount -ServerInstance MyServer

Lists agent proxy accounts.

### EXAMPLE 2

Get-SmoSqlAgentProxyAccount -SmoServerObject $SmoServerObject

Lists agent proxy accounts using Smo server object.

### EXAMPLE 3

Get-SmoSqlAgentProxyAccount -SmoServerObject $SmoServerObject -ProxyAccountName MyProxy

Lists agent proxy MyProxy using Smo server object.

## PARAMETERS

### -ProxyAccountName

the proxy account to return.

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

### Microsoft.SqlServer.Management.Smo.Agent.ProxyAccount



## NOTES




## RELATED LINKS

None.

