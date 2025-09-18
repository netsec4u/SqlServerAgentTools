---
document type: cmdlet
external help file: SQLServerAgentTools-help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 07/29/2025
PlatyPS schema version: 2024-05-01
title: New-SmoSqlAgentAlert
---

# New-SmoSqlAgentAlert

## SYNOPSIS

Creates a agent alert.

## SYNTAX

### SqlServerEventMessageID_ServerInstance (Default)
```
New-SmoSqlAgentAlert
	-ServerInstance <String>
	-AlertName <String>
	[-IsEnabled <Boolean>]
	-AlertType <AlertType>
	[-DatabaseName <string>]
	-MessageID <Int32>
	[-EventDescriptionKeyword <String>]
	[-JobName <String>]
	[-IncludeEventDescription <NotifyMethods>]
	[-NotificationMessage <String>]
	[-DelayBetweenResponses <Int32>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SqlServerEventSeverity_ServerInstance
```
New-SmoSqlAgentAlert
	-ServerInstance <String>
	-AlertName <String>
	[-IsEnabled <Boolean>]
	-AlertType <AlertType>
	[-DatabaseName <String>]
	-Severity <Int32>
	[-EventDescriptionKeyword <String>]
	[-JobName <String>]
	[-IncludeEventDescription <NotifyMethods>]
	[-NotificationMessage <String>]
	[-DelayBetweenResponses <Int32>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SqlServerPerformance_ServerInstance
```
New-SmoSqlAgentAlert
	-ServerInstance <String>
	-AlertName <String>
	[-IsEnabled <Boolean>]
	-AlertType <AlertType>
	-PerformanceObject <String>
	-PerformanceCounter <String>
	[-PerformanceCounterInstance <String>]
	[-ComparisonOperator <String>]
	[-PerformanceValue <Decimal>]
	[-JobName <String>]
	[-IncludeEventDescription <NotifyMethods>]
	[-NotificationMessage <String>]
	[-DelayBetweenResponses <Int32>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SqlServerWmiEvent_ServerInstance
```
New-SmoSqlAgentAlert
	-ServerInstance <String>
	-AlertName <String>
	[-IsEnabled <Boolean>]
	-AlertType <AlertType>
	-WmiEventNamespace <String>
	-WmiEventQuery <String>
	[-JobName <String>]
	[-IncludeEventDescription <NotifyMethods>]
	[-NotificationMessage <String>]
	[-DelayBetweenResponses <Int32>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SqlServerEventMessageID_SmoServer
```
New-SmoSqlAgentAlert
	-SmoServerObject <Server>
	-AlertName <String>
	[-IsEnabled <Boolean>]
	-AlertType <AlertType>
	[-DatabaseName <string>]
	-MessageID <Int32>
	[-EventDescriptionKeyword <String>]
	[-JobName <String>]
	[-IncludeEventDescription <NotifyMethods>]
	[-NotificationMessage <String>]
	[-DelayBetweenResponses <Int32>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SqlServerEventSeverity_SmoServer
```
New-SmoSqlAgentAlert
	-SmoServerObject <Server>
	-AlertName <String>
	[-IsEnabled <Boolean>]
	-AlertType <AlertType>
	[-DatabaseName <String>]
	-Severity <Int32>
	[-EventDescriptionKeyword <String>]
	[-JobName <String>]
	[-IncludeEventDescription <NotifyMethods>]
	[-NotificationMessage <String>]
	[-DelayBetweenResponses <Int32>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SqlServerPerformance_SmoServer
```
New-SmoSqlAgentAlert
	-SmoServerObject <Server>
	-AlertName <String>
	[-IsEnabled <Boolean>]
	-AlertType <AlertType>
	-PerformanceObject <String>
	-PerformanceCounter <String>
	[-PerformanceCounterInstance <String>]
	[-ComparisonOperator <String>]
	[-PerformanceValue <Decimal>]
	[-JobName <String>]
	[-IncludeEventDescription <NotifyMethods>]
	[-NotificationMessage <String>]
	[-DelayBetweenResponses <Int32>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SqlServerWmiEvent_SmoServer
```
New-SmoSqlAgentAlert
	-SmoServerObject <Server>
	-AlertName <String>
	[-IsEnabled <Boolean>]
	-AlertType <AlertType>
	-WmiEventNamespace <String>
	-WmiEventQuery <String>
	[-JobName <String>]
	[-IncludeEventDescription <NotifyMethods>]
	[-NotificationMessage <String>]
	[-DelayBetweenResponses <Int32>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

Creates a agent alert.

## EXAMPLES

### EXAMPLE 1

New-SmoSqlAgentAlert -ServerInstance . -AlertName MyAlert -AlertType SqlServerEvent -MessageID 823

Creates agent alert for events with message ID 823.

### EXAMPLE 2

New-SmoSqlAgentAlert -SmoServerObject $SmoServerObject -AlertName MyAlert -AlertType SqlServerEvent -MessageID 823

Creates agent alert for events with message ID 823 using Smo server object.

### EXAMPLE 3

New-SmoSqlAgentAlert -ServerInstance . -AlertName TestServerEvent -AlertType SqlServerEvent -Severity 16

Creates agent alert for events with severity 16.

### EXAMPLE 4

New-SqlAgentAlert -ServerInstance . -AlertName TestPerformanceCondition -AlertType SqlServerPerformanceCondition -PerformanceObject 'SQL Statistics' -PerformanceCounter 'SQL Compilations/sec' -PerformanceCounterInstance '' -ComparisonOperator '>' -PerformanceValue 3000

Creates alert on performance object.

### EXAMPLE 5

New-SmoSqlAgentAlert -ServerInstance . -AlertName TestWmiEvent -AlertType WmiEvent -WmiEventNamespace '\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER' -WmiEventQuery 'SELECT * FROM DDL_DATABASE_EVENTS'

Creates alert on WMI results.

## PARAMETERS

### -AlertName

Specifies the name of alert.

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

### -AlertType

The type of alert condition.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Agent.AlertType
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

### -ComparisonOperator

The comparison operator used to compare counter to a value.
Dynamic parameter required when AlertType is SqlServerPerformanceCondition.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerPerformance_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformance_SmoServer
  Position: Named
  IsRequired: true
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

### -DatabaseName

The database in which the error must occur for the alert to fire.
Dynamic parameter available when AlertType is SqlServerEvent.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerEventMessageID_ServerInstance
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventSeverity_ServerInstance
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventMessageID_SmoServer
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventSeverity_SmoServer
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -DelayBetweenResponses

The wait period, in seconds, between responses to the alert.

```yaml
Type: System.Int32
DefaultValue: 0
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

### -EventDescriptionKeyword

The sequence of characters that the description of the SQL Server error must be like.
Transact-SQL LIKE expression pattern-matching characters can be used.
Dynamic parameter available when AlertType is SqlServerEvent.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerEventMessageID_ServerInstance
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventSeverity_ServerInstance
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventMessageID_SmoServer
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventSeverity_SmoServer
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -IncludeEventDescription

Is whether the description of the SQL Server error should be included as part of the notification message.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods
DefaultValue: NotifyEmail
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

### -IsEnabled

Indicates the current status of the alert.

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

### -JobName

The name of the job to be executed in response to this alert.

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

### -MessageID
The message error number that defines the alert.
Dynamic parameter available when AlertType is SqlServerEvent.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerEventMessageID_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventMessageID_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -NotificationMessage

Is an optional additional message sent to the operator as part of the e-mail, net send, or pager notification.

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

### -PerformanceCounter

The performance counter to monitor.
Dynamic parameter required when AlertType is SqlServerPerformanceCondition.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerPerformance_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformance_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PerformanceCounterInstance

The instance of the performance counter.
Dynamic parameter available when AlertType is SqlServerPerformanceCondition.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerPerformance_ServerInstance
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformance_SmoServer
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PerformanceObject

The performance object of the counter.
Dynamic parameter required when AlertType is SqlServerPerformanceCondition.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerPerformance_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformance_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PerformanceValue

The numeric threshold value of the counter.
Dynamic parameter required when AlertType is SqlServerPerformanceCondition.

```yaml
Type: System.Decimal
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerPerformance_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformance_SmoServer
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

SQL Server host name and instance name.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases:
- SqlServer
ParameterSets:
- Name: SqlServerEventSeverity_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventMessageID_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformance_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerWmiEvent_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Severity

The severity level (from 1 through 25) that defines the alert.
Dynamic parameter available when AlertType is SqlServerEvent.

```yaml
Type: System.Int32
DefaultValue: 0
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerEventSeverity_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventSeverity_SmoServer
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
- Name: SqlServerEventSeverity_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventMessageID_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformance_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerWmiEvent_SmoServer
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

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

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

### -WmiEventNamespace

The WMI namespace to query for events.
Dynamic parameter required when AlertType is WmiEvent.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerWmiEvent_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerWmiEvent_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WmiEventQuery

The query that specifies the WMI event for the alert.
Dynamic parameter required when AlertType is WmiEvent.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerWmiEvent_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerWmiEvent_SmoServer
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

### Microsoft.SqlServer.Management.Smo.Agent.Alert



## NOTES




## RELATED LINKS

None.

