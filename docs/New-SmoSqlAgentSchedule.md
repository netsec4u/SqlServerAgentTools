---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
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

## DESCRIPTION
Creates a schedule that can be used by any number of jobs.

## EXAMPLES

### EXAMPLE 1
```powershell
New-SmoSqlAgentSchedule -ServerInstance . -ScheduleName Test_OneTime -FrequencyType OneTime -ActiveStartTimeOfDay 15:00:00 -ActiveStartDate 2022-12-20
```

Creates a schedule to execute once at 15:00:00 on 2022-12-20.

### EXAMPLE 2
```powershell
New-SmoSqlAgentSchedule -ServerInstance . -ScheduleName Test_AutoStart -FrequencyType AutoStart
```

Creates a schedule to execute when SQL Server Agent Starts.

### EXAMPLE 3
```powershell
New-SmoSqlAgentSchedule -ServerInstance . -ScheduleName Test_OnIdle -FrequencyType OnIdle
```

Creates a schedule to execute when CPU becomes idle.

### EXAMPLE 4
```powershell
New-SmoSqlAgentSchedule -ServerInstance MyServer -ScheduleName MySchedule -FrequencyType Daily -FrequencyInterval 1 -FrequencySubDayType Minute -FrequencySubDayInterval 15 -ActiveStartTimeOfDay 0:00:00 -ActiveEndTimeOfDay 23:59:59
```

Creates a schedule that executes daily every 15 minute(s) between 12:00:00 AM and 11:59:59 PM.

### EXAMPLE 5
```powershell
New-SmoSqlAgentSchedule -ServerInstance . -ScheduleName Test_Daily -FrequencyType Daily -FrequencyInterval 1 -FrequencySubDayType Once -ActiveStartTimeOfDay 10:00:00
```

Creates a schedule that executes once daily at 10:00:00.

### EXAMPLE 6
```powershell
New-SmoSqlAgentSchedule -ServerInstance . -ScheduleName Test_MonthlyRelative -FrequencyType Weekly -FrequencyRecurrenceFactor 1 -FrequencyInterval 42 -FrequencySubDayType Once -ActiveStartTimeOfDay 04:00:00
```

Creates a schedule that executes each week on Monday, Wednesday, and Friday at 04:00:00.

### EXAMPLE 7
```powershell
New-SmoSqlAgentSchedule -ServerInstance . -ScheduleName Test_MonthlyRelative -FrequencyType MonthlyRelative -FrequencyRelativeIntervals 1 -FrequencyInterval 3 -FrequencyRecurrenceFactor 2
```

Creates a schedule that executes the first Tuesday of every 2 months.

## PARAMETERS

### -ActiveEndDate
The date on which execution of a job can stop.  Dynamic parameter required when FrequencyType is Daily, Monthly, MonthlyRelative, Onetime, Weekly.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 9999-12-31 00:00:00
Accept pipeline input: False
Accept wildcard characters: False
```

### -ActiveEndTimeOfDay
When FrequencySubDayType is not Once, when to end daily frequency interval recurrence.  Dynamic parameter required when FrequencyType is Daily, Monthly, MonthlyRelative, or Weekly.

```yaml
Type: TimeSpan
Parameter Sets: ServerInstance_FrequencySubDay, SmoServer_FrequencySubDay
Aliases:

Required: False
Position: Named
Default value: 23:59:59
Accept pipeline input: False
Accept wildcard characters: False
```

### -ActiveStartDate
The date on which execution of a job can begin.  Dynamic parameter required when FrequencyType is Daily, Monthly, MonthlyRelative, Onetime, Weekly.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Current date.
Accept pipeline input: False
Accept wildcard characters: False
```

### -ActiveStartTimeOfDay
When FrequencySubDayType is Once, when to start job.  When FrequencySubDayType is not Once, when to start daily frequency interval recurrence.  Dynamic parameter required when FrequencyType is Daily, Monthly, MonthlyRelative, Onetime, or Weekly.

```yaml
Type: TimeSpan
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 00:00:00
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencyInterval
Specifies relative interval.  Dynamic parameter required when FrequencyType is MonthlyRelative.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:
Accepted values: First, Second, Third, Fourth, Last

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencyRecurrenceFactor
The number of weeks or months between the scheduled execution of a job.  When FrequencyType is Monthly or MonthlyRelative, it is the number of months it recurs.  When FrequencyType is Weekly, it is the number of weeks it reoccurs.  Dynamic parameter required when FrequencyType is Monthly, MonthlyRelative, or Weekly.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencyRelativeIntervals
Specifies the days that a job is executed.  Dynamic parameter required when FrequencyType is Daily, Monthly, MonthlyRelative, or Weekly.

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
	Sunday		1
	Monday		2
	Tuesday		3
	Wednesday	4
	Thursday	5
	Friday		6
	Saturday	7
	day			8
	weekday		9
	weekend day	10

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencyRelativeIntervals
Specifies relative interval.  Dynamic parameter required when FrequencyType is MonthlyRelative.

```yaml
Type: FrequencyRelativeIntervals
Parameter Sets: (All)
Aliases:
Accepted values: First, Second, Third, Fourth, Last

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencySubDayInterval
Daily frequency when FrequencySubDayType is not Once.  Dynamic parameter available when FrequencyType is Daily, Monthly, MonthlyRelative, or Weekly.

```yaml
Type: Int32
Parameter Sets: ServerInstance_FrequencySubDay, SmoServer_FrequencySubDay
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencySubDayType
The sub day type.  Dynamic parameter required when FrequencyType is Daily, Monthly, MonthlyRelative, or Weekly.

```yaml
Type: FrequencySubDayTypes
Parameter Sets: ServerInstance_FrequencySubDay, SmoServer_FrequencySubDay
Aliases:
Accepted values: Unknown, Once, Second, Minute, Hour

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FrequencyType
A value indicating when a job is to be executed.

```yaml
Type: FrequencyTypes
Parameter Sets: (All)
Aliases:
Accepted values: Unknown, OneTime, Daily, Weekly, Monthly, MonthlyRelative, AutoStart, OnIdle

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsEnabled
Indicates the current status of the schedule.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScheduleName
The name of the schedule.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServerInstance
SQL Server host name and instance name.

```yaml
Type: String
Parameter Sets: ServerInstance, ServerInstance_FrequencySubDay
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
Parameter Sets: SmoServer_FrequencySubDay, SmoServer
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

### Microsoft.SqlServer.Management.Smo.Agent.JobSchedule

## NOTES

## RELATED LINKS
