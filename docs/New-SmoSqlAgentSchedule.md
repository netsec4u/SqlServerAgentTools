---
document type: cmdlet
external help file: SqlServerAgentTools-Help.xml
HelpUri: https://github.com/netsec4u/SqlServerAgentTools/blob/main/docs/New-SmoSqlAgentSchedule.md
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 05/08/2026
PlatyPS schema version: 2024-05-01
title: New-SmoSqlAgentSchedule
---

# New-SmoSqlAgentSchedule

## SYNOPSIS

Creates a SQL Agent schedule.

## SYNTAX

### ServerInstance (Default)
```
New-SmoSqlAgentSchedule
	-ServerInstance <String>
	-ScheduleName <String>
	[-IsEnabled <Boolean>]
	-FrequencyType <FrequencyTypes>
	[-FrequencyRelativeIntervals <FrequencyRelativeIntervals>]
	[-FrequencyInterval <Int32>]
	[-FrequencyRecurrenceFactor <Int32>]
	[-ActiveStartTimeOfDay <TimeSpan>]
	[-ActiveStartDate <DateTime>]
	[-ActiveEndDate <DateTime>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### ServerInstance_FrequencySubDay
```
New-SmoSqlAgentSchedule
	-ServerInstance <String>
	-ScheduleName <String>
	[-IsEnabled <Boolean>]
	-FrequencyType <FrequencyTypes>
	[-FrequencyRelativeIntervals <FrequencyRelativeIntervals>]
	[-FrequencyInterval <Int32>]
	[-FrequencyRecurrenceFactor <Int32>]
	-FrequencySubDayType <FrequencySubDayTypes>
	[-FrequencySubDayInterval <Int32>]
	[-ActiveStartTimeOfDay <TimeSpan>]
	[-ActiveEndTimeOfDay <TimeSpan>]
	[-ActiveStartDate <DateTime>]
	[-ActiveEndDate <DateTime>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer_FrequencySubDay
```
New-SmoSqlAgentSchedule
	-SmoServerObject <Server>
	-ScheduleName <String>
	[-IsEnabled <Boolean>]
	-FrequencyType <FrequencyTypes>
	[-FrequencyRelativeIntervals <FrequencyRelativeIntervals>]
	[-FrequencyInterval <Int32>]
	[-FrequencyRecurrenceFactor <Int32>]
	-FrequencySubDayType <FrequencySubDayTypes>
	[-FrequencySubDayInterval <Int32>]
	[-ActiveStartTimeOfDay <TimeSpan>]
	[-ActiveEndTimeOfDay <TimeSpan>]
	[-ActiveStartDate <DateTime>]
	[-ActiveEndDate <DateTime>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
New-SmoSqlAgentSchedule
	-SmoServerObject <Server>
	-ScheduleName <String>
	[-IsEnabled <Boolean>]
	-FrequencyType <FrequencyTypes>
	[-FrequencyRelativeIntervals <FrequencyRelativeIntervals>]
	[-FrequencyInterval <Int32>]
	[-FrequencyRecurrenceFactor <Int32>]
	[-ActiveStartTimeOfDay <TimeSpan>]
	[-ActiveStartDate <DateTime>]
	[-ActiveEndDate <DateTime>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

Creates a schedule that can be used by any number of jobs.

## EXAMPLES

### Example 1

```powershell
New-SmoSqlAgentSchedule -ServerInstance . -ScheduleName Test_OneTime -FrequencyType OneTime -ActiveStartTimeOfDay 15:00:00 -ActiveStartDate 2022-12-20
```

Creates a schedule to execute once at 15:00:00 on 2022-12-20.

### Example 2

```powershell
New-SmoSqlAgentSchedule -ServerInstance . -ScheduleName Test_AutoStart -FrequencyType AutoStart
```

Creates a schedule to execute when SQL Server Agent Starts.

### Example 3

```powershell
New-SmoSqlAgentSchedule -ServerInstance . -ScheduleName Test_OnIdle -FrequencyType OnIdle
```

Creates a schedule to execute when CPU becomes idle.

### Example 4

```powershell
New-SmoSqlAgentSchedule -ServerInstance MyServer -ScheduleName MySchedule -FrequencyType Daily -FrequencyInterval 1 -FrequencySubDayType Minute -FrequencySubDayInterval 15 -ActiveStartTimeOfDay 0:00:00 -ActiveEndTimeOfDay 23:59:59
```

Creates a schedule that executes daily every 15 minute(s) between 12:00:00 AM and 11:59:59 PM.

### Example 5

```powershell
New-SmoSqlAgentSchedule -ServerInstance . -ScheduleName Test_Daily -FrequencyType Daily -FrequencyInterval 1 -FrequencySubDayType Once -ActiveStartTimeOfDay 10:00:00
```

Creates a schedule that executes once daily at 10:00:00.

### Example 6

```powershell
New-SmoSqlAgentSchedule -ServerInstance . -ScheduleName Test_MonthlyRelative -FrequencyType Weekly -FrequencyRecurrenceFactor 1 -FrequencyInterval 42 -FrequencySubDayType Once -ActiveStartTimeOfDay 04:00:00
```

Creates a schedule that executes each week on Monday, Wednesday, and Friday at 04:00:00.

### Example 7

```powershell
New-SmoSqlAgentSchedule -ServerInstance . -ScheduleName Test_MonthlyRelative -FrequencyType MonthlyRelative -FrequencyRelativeIntervals 1 -FrequencyInterval 3 -FrequencyRecurrenceFactor 2
```

Creates a schedule that executes the first Tuesday of every 2 months.

## PARAMETERS

### -ActiveEndDate

The date on which execution of a job can stop.
Dynamic parameter required when FrequencyType is Daily, Monthly, MonthlyRelative, Onetime, Weekly.

```yaml
Type: System.DateTime
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

### -ActiveEndTimeOfDay

When FrequencySubDayType is not Once, when to end daily frequency interval recurrence.
Dynamic parameter required when FrequencyType is Daily, Monthly, MonthlyRelative, or Weekly.

```yaml
Type: System.TimeSpan
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ServerInstance_FrequencySubDay
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SmoServer_FrequencySubDay
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ActiveStartDate

The date on which execution of a job can begin.
Dynamic parameter required when FrequencyType is Daily, Monthly, MonthlyRelative, Onetime, Weekly.

```yaml
Type: System.DateTime
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

### -ActiveStartTimeOfDay

When FrequencySubDayType is Once, when to start job.
When FrequencySubDayType is not Once, when to start daily frequency interval recurrence.
Dynamic parameter required when FrequencyType is Daily, Monthly, MonthlyRelative, Onetime, or Weekly.

```yaml
Type: System.TimeSpan
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

### -FrequencyInterval

Specifies relative interval.
Dynamic parameter required when FrequencyType is MonthlyRelative.

```yaml
Type: System.Int32
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

### -FrequencyRecurrenceFactor

The number of weeks or months between the scheduled execution of a job.
When FrequencyType is Monthly or MonthlyRelative, it is the number of months it recurs.
When FrequencyType is Weekly, it is the number of weeks it reoccurs.
Dynamic parameter required when FrequencyType is Monthly, MonthlyRelative, or Weekly.

```yaml
Type: System.Int32
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

### -FrequencyRelativeIntervals

Specifies the days that a job is executed.
Dynamic parameter required when FrequencyType is Daily, Monthly, MonthlyRelative, or Weekly.

When FrequencyType is Daily, it is the number of days it recurs.

When FrequencyType is Weekly, it is the sum of weekly values.

	Weekly		Values
	Sunday		1
	Monday		2
	Tuesday		4
	Wednesday	8
	Thursday	16
	Friday		32
	Saturday	64

When FrequencyType is Monthly, it is the month day number.

When FrequencyType is MonthlyRelative, is the relative values listed.

	MonthlyRelative Values
	Sunday			1
	Monday			2
	Tuesday			3
	Wednesday		4
	Thursday		5
	Friday			6
	Saturday		7
	day					8
	weekday			9
	weekend day	10

```yaml
Type: System.Int32
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

### -FrequencySubDayInterval

Daily frequency when FrequencySubDayType is not Once.
Dynamic parameter available when FrequencyType is Daily, Monthly, MonthlyRelative, or Weekly.

```yaml
Type: System.Int32
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ServerInstance_FrequencySubDay
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SmoServer_FrequencySubDay
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FrequencySubDayType

The sub day type.
Dynamic parameter required when FrequencyType is Daily, Monthly, MonthlyRelative, or Weekly.

```yaml
Type: Microsoft.SqlServer.Management.SMO.Agent.FrequencySubDayTypes
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ServerInstance_FrequencySubDay
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SmoServer_FrequencySubDay
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FrequencyType

A value indicating when a job is to be executed.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Agent.FrequencyTypes
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -IsEnabled

Indicates the current status of the schedule.

```yaml
Type: System.Boolean
DefaultValue: True
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

### -ScheduleName

The name of the schedule.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
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
- Name: ServerInstance_FrequencySubDay
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
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
- Name: SmoServer_FrequencySubDay
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
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

### Microsoft.SqlServer.Management.Smo.Agent.JobSchedule



## NOTES

Duration start date and end date not implemented.


## RELATED LINKS

