---
document type: cmdlet
external help file: SQLServerAgentTools-help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 07/29/2025
PlatyPS schema version: 2024-05-01
title: Get-SmoSqlAgentJobServer
---

# Get-SmoSqlAgentJobServer

## SYNOPSIS

Get SQL Agent Server.

## SYNTAX

### ServerInstance (Default)

```
Get-SmoSqlAgentJobServer
  -ServerInstance <string>
  [<CommonParameters>]
```

### SmoServer

```
Get-SmoSqlAgentJobServer
  -SmoServerObject <Server>
  [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

The Get-SmoSqlAgentJobServer function gets a SQL Agent Job Server object.

## EXAMPLES

### EXAMPLE 1

Get-SmoSqlAgentJobServer -ServerInstance MyServer

Gets agent job server.

### EXAMPLE 2

Get-SmoSqlAgentJobServer -SmoServerObject $SmoServerObject

Gets agent job server using Smo server object.

## PARAMETERS

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

### Microsoft.SqlServer.Management.Smo.Agent.JobServer



## NOTES




## RELATED LINKS

None.

