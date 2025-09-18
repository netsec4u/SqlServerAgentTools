---
document type: cmdlet
external help file: SQLServerAgentTools-help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 07/29/2025
PlatyPS schema version: 2024-05-01
title: Get-SmoSqlAgentJob
---

# Get-SmoSqlAgentJob

## SYNOPSIS

Gets a SQL Agent Job object for each job that is present in the target instance of SQL Agent.

## SYNTAX

### ServerInstance (Default)

```
Get-SmoSqlAgentJob
  -ServerInstance <string>
  [-JobName <string>]
  [<CommonParameters>]
```

### SmoServer

```
Get-SmoSqlAgentJob
  -SmoServerObject <Server>
  [-JobName <string>]
  [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

The Get-SmoSqlAgentJob function gets a SQL Agent Job object for each job that is present in the target instance of SQL Agent.
If the name of the job is provided, the function gets only this specific job object.

## EXAMPLES

### EXAMPLE 1

Get-SmoSqlAgentJob -ServerInstance MyServer

Lists all agent jobs.

### EXAMPLE 2

Get-SmoSqlAgentJob -SmoServerObject $SmoServerObject

Lists all agent jobs using Smo server object.

### EXAMPLE 3

Get-SmoSqlAgentJob -SmoServerObject $SmoServerObject -JobName MyJob

Lists agent job MyJob using Smo server object.

## PARAMETERS

### -JobName

Specifies the name of the job.

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

### Microsoft.SqlServer.Management.Smo.Agent.Job



## NOTES




## RELATED LINKS

None.

