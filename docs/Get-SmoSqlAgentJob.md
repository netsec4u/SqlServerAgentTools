---
document type: cmdlet
external help file: SqlServerAgentTools-Help.xml
HelpUri: https://github.com/netsec4u/SqlServerAgentTools/blob/main/docs/Get-SmoSqlAgentJob.md
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 05/08/2026
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

### Example 1

```powershell
Get-SmoSqlAgentJob -ServerInstance MyServer
```

Lists all agent jobs.

### Example 2

```powershell
Get-SmoSqlAgentJob -SmoServerObject $SmoServerObject
```

Lists all agent jobs using Smo server object.

### Example 3

```powershell
Get-SmoSqlAgentJob -SmoServerObject $SmoServerObject -JobName MyJob
```

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

### Microsoft.SqlServer.Management.Smo.Agent.Job



## NOTES




## RELATED LINKS

