---
document type: cmdlet
external help file: SqlServerAgentTools-Help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 07/29/2025
PlatyPS schema version: 2024-05-01
title: Get-SmoSqlAgentSchedule
---

# Get-SmoSqlAgentSchedule

## SYNOPSIS

Gets a SQL Agent Schedule object for each schedule that is present in the target instance of SQL Agent.

## SYNTAX

### ServerInstance (Default)

```
Get-SmoSqlAgentSchedule
  -ServerInstance <string>
  [-ScheduleName <string>]
  [<CommonParameters>]
```

### SmoServer

```
Get-SmoSqlAgentSchedule
  -SmoServerObject <Server>
  [-ScheduleName <string>]
  [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

The Get-SmoSqlAgentSchedule function gets a SQL Agent Schedule object for each operator that is present in the target instance of SQL Agent.
If the name of the schedule is provided, the function gets only this specific schedule account object.

## EXAMPLES

### Example 1

```powershell
Get-SmoSqlAgentSchedule -ServerInstance MyServer
```

Gets SQL agent schedules from MyServer.

### Example 2

```powershell
Get-SmoSqlAgentSchedule -SmoServerObject $SmoServerObject
```

Lists agent schedule using Smo server object.

### Example 3

```powershell
Get-SmoSqlAgentSchedule -SmoServerObject $SmoServerObject -ScheduleName MySchedule
```

Lists agent schedule MySchedule using Smo server object.

## PARAMETERS

### -ScheduleName

Specifies name of the schedule.

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

### Microsoft.SqlServer.Management.Smo.Agent.JobSchedule



## NOTES




## RELATED LINKS

None.

