---
document type: cmdlet
external help file: SqlServerAgentTools-Help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 03/31/2026
PlatyPS schema version: 2024-05-01
title: Set-SmoSqlAgentAlert
---

# Set-SmoSqlAgentAlert

## SYNOPSIS

Sets the properties of a SQL Server Agent alert.

## SYNTAX

### SqlServerEventMessageID_ServerInstance (Default)

```
Set-SmoSqlAgentAlert
  -ServerInstance <string>
  -AlertName <string>
  -MessageID <Object>
  [-IsEnabled <bool>]
  [-DatabaseName <Object>]
  [-EventDescriptionKeyword <Object>]
  [-JobName <string>]
  [-IncludeEventDescription <NotifyMethods>]
  [-NotificationMessage <string>]
  [-DelayBetweenResponses <int>]
  [-WhatIf]
  [-Confirm]
  [<CommonParameters>]
```

### WmiEvent_ServerInstance

```
Set-SmoSqlAgentAlert
  -ServerInstance <string>
  -AlertName <string>
  -WmiEventNamespace <Object>
  -WmiEventQuery <Object>
  [-IsEnabled <bool>]
  [-JobName <string>]
  [-IncludeEventDescription <NotifyMethods>]
  [-NotificationMessage <string>]
  [-DelayBetweenResponses <int>]
  [-WhatIf]
  [-Confirm]
  [<CommonParameters>]
```

### SqlServerPerformanceCondition_ServerInstance

```
Set-SmoSqlAgentAlert
  -ServerInstance <string>
  -AlertName <string>
  -PerformanceObject <Object>
  -PerformanceCounter <Object>
  -ComparisonOperator <Object>
  -PerformanceValue <Object>
  [-IsEnabled <bool>]
  [-PerformanceCounterInstance <Object>]
  [-JobName <string>]
  [-IncludeEventDescription <NotifyMethods>]
  [-NotificationMessage <string>]
  [-DelayBetweenResponses <int>]
  [-WhatIf]
  [-Confirm]
  [<CommonParameters>]
```

### SqlServerEventSeverity_ServerInstance

```
Set-SmoSqlAgentAlert
  -ServerInstance <string>
  -AlertName <string>
  -Severity <Object>
  [-IsEnabled <bool>]
  [-DatabaseName <Object>]
  [-EventDescriptionKeyword <Object>]
  [-JobName <string>]
  [-IncludeEventDescription <NotifyMethods>]
  [-NotificationMessage <string>]
  [-DelayBetweenResponses <int>]
  [-WhatIf]
  [-Confirm]
  [<CommonParameters>]
```

### WmiEvent_SmoServer

```
Set-SmoSqlAgentAlert
  -SmoServerObject <Server>
  -AlertName <string>
  -WmiEventNamespace <Object>
  -WmiEventQuery <Object>
  [-IsEnabled <bool>]
  [-JobName <string>]
  [-IncludeEventDescription <NotifyMethods>]
  [-NotificationMessage <string>]
  [-DelayBetweenResponses <int>]
  [-WhatIf]
  [-Confirm]
  [<CommonParameters>]
```

### SqlServerPerformanceCondition_SmoServer

```
Set-SmoSqlAgentAlert
  -SmoServerObject <Server>
  -AlertName <string>
  -PerformanceObject <Object>
  -PerformanceCounter <Object>
  -ComparisonOperator <Object>
  -PerformanceValue <Object>
  [-IsEnabled <bool>]
  [-PerformanceCounterInstance <Object>]
  [-JobName <string>]
  [-IncludeEventDescription <NotifyMethods>]
  [-NotificationMessage <string>]
  [-DelayBetweenResponses <int>]
  [-WhatIf]
  [-Confirm]
  [<CommonParameters>]
```

### SqlServerEventSeverity_SmoServer

```
Set-SmoSqlAgentAlert
  -SmoServerObject <Server>
  -AlertName <string>
  -Severity <Object>
  [-IsEnabled <bool>]
  [-DatabaseName <Object>]
  [-EventDescriptionKeyword <Object>]
  [-JobName <string>]
  [-IncludeEventDescription <NotifyMethods>]
  [-NotificationMessage <string>]
  [-DelayBetweenResponses <int>]
  [-WhatIf]
  [-Confirm]
  [<CommonParameters>]
```

### SqlServerEventMessageID_SmoServer

```
Set-SmoSqlAgentAlert
  -SmoServerObject <Server>
  -AlertName <string>
  -MessageID <Object>
  [-IsEnabled <bool>]
  [-DatabaseName <Object>]
  [-EventDescriptionKeyword <Object>]
  [-JobName <string>]
  [-IncludeEventDescription <NotifyMethods>]
  [-NotificationMessage <string>]
  [-DelayBetweenResponses <int>]
  [-WhatIf]
  [-Confirm]
  [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

Sets the properties of a SQL Server Agent alert.

## EXAMPLES

### Example 1

```powershell
Set-SmoSqlAgentAlert -ServerInstance MyServer -AlertName  'AlwaysOn - AG is Offline' -MessageID 41404
```

Sets the alert named 'AlwaysOn - AG is Offline' on the SQL Server instance 'MyServer' to trigger on message ID 41404.

### Example 2

```powershell
Set-SmoSqlAgentAlert -ServerInstance MyServer -AlertName DeadlockEvent -WmiEventNamespace '\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER' -WmiEventQuery 'SELECT * FROM DEADLOCK_GRAPH'
```

Sets the alert named 'DeadlockEvent' on the SQL Server instance 'MyServer' to trigger on the WMI event for deadlock graphs.

### Example 3

```powershell
Set-SmoSqlAgentAlert -ServerInstance MyServer -AlertName 'Blocked Process Alert' -PerformanceObject 'General Statistics' -PerformanceCounter 'Processes blocked' -PerformanceCounterInstance '' -ComparisonOperator '>' -PerformanceValue 0
```

Sets the alert named 'Blocked Process Alert' on the SQL Server instance 'MyServer' to trigger when the 'Processes blocked' performance counter for the 'General Statistics' object is greater than 0.

### Example 4

```powershell
Set-SmoSqlAgentAlert -ServerInstance MyServer -AlertName 'Fatal Error: Table Integrity Suspect' -Severity 22
```

Sets the alert named 'Fatal Error: Table Integrity Suspect' on the SQL Server instance 'MyServer' to trigger on severity level 22 errors.

### Example 5

```powershell
$SmoServerObject = Connect-SmoServer -ServerInstance .
Set-SmoSqlAgentAlert -SmoServerObject $SmoServerObject -AlertName  'AlwaysOn - AG is Offline' -MessageID 41404

```

Sets the alert named 'AlwaysOn - AG is Offline' on the local SQL Server instance to trigger on message ID 41404 using an SMO Server object.

### Example 6

```powershell
$SmoServerObject = Connect-SmoServer -ServerInstance .
Set-SmoSqlAgentAlert -SmoServerObject $SmoServerObject -AlertName DeadlockEvent -WmiEventNamespace '\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER' -WmiEventQuery 'SELECT * FROM DEADLOCK_GRAPH'
```

Sets the alert named 'DeadlockEvent' on the local SQL Server instance to trigger on the WMI event for deadlock graphs using an SMO Server object.

### Example 7

```powershell
$SmoServerObject = Connect-SmoServer -ServerInstance .
Set-SmoSqlAgentAlert -SmoServerObject $SmoServerObject -AlertName 'Blocked Process Alert' -PerformanceObject 'General Statistics' -PerformanceCounter 'Processes blocked' -PerformanceCounterInstance '' -ComparisonOperator '>' -PerformanceValue 0
```

Sets the alert named 'Blocked Process Alert' on the local SQL Server instance to trigger when the 'Processes blocked' performance counter for the 'General Statistics' object is greater than 0 using an SMO Server object.

### Example 8

```powershell
$SmoServerObject = Connect-SmoServer -ServerInstance .
Set-SmoSqlAgentAlert -SmoServerObject $SmoServerObject -AlertName 'Fatal Error: Table Integrity Suspect' -Severity 22
```

Sets the alert named 'Fatal Error: Table Integrity Suspect' on the local SQL Server instance to trigger on severity level 22 errors using an SMO Server object.

## PARAMETERS

### -AlertName

The name of the SQL Agent Alert to update.

```yaml
Type: System.String
DefaultValue: ''
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

The comparison operator for the performance condition.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerPerformanceCondition_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformanceCondition_ServerInstance
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
DefaultValue: ''
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

The name of the database to trigger the alert on. This is only applicable for certain types of alerts.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerEventSeverity_SmoServer
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
- Name: SqlServerEventSeverity_ServerInstance
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventMessageID_ServerInstance
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

The delay between responses for the alert.

```yaml
Type: System.Int32
DefaultValue: ''
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

The keyword to trigger the alert on based on the event description. This is only applicable for certain types of alerts.
```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerEventSeverity_SmoServer
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
- Name: SqlServerEventSeverity_ServerInstance
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventMessageID_ServerInstance
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

Includes the event description in the notification. This is only applicable for certain types of alerts.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods
DefaultValue: ''
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

Indicates whether the alert is enabled.

```yaml
Type: System.Boolean
DefaultValue: ''
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

The name of the job to execute when the alert is triggered.

```yaml
Type: System.String
DefaultValue: ''
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

The ID of the message to trigger the alert on.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerEventMessageID_SmoServer
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
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -NotificationMessage

The message to include in the notification when the alert is triggered.

```yaml
Type: System.String
DefaultValue: ''
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

The performance counter to trigger the alert on.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerPerformanceCondition_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformanceCondition_ServerInstance
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

The instance of the performance counter to trigger the alert on. This is only applicable for certain types of performance counters.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerPerformanceCondition_SmoServer
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformanceCondition_ServerInstance
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

The performance object to trigger the alert on.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerPerformanceCondition_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformanceCondition_ServerInstance
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

The value of the performance counter to trigger the alert on.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerPerformanceCondition_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformanceCondition_ServerInstance
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

The name of the SQL Server instance to configure the alert on.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- SqlServer
ParameterSets:
- Name: WmiEvent_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformanceCondition_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
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
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Severity

The severity level to trigger the alert on.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: SqlServerEventSeverity_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerEventSeverity_ServerInstance
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

The SMO Server object representing the SQL Server instance to configure the alert on.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Server
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: WmiEvent_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SqlServerPerformanceCondition_SmoServer
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

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
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

The WMI namespace to trigger the alert on. This is only applicable for WMI event alerts.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: WmiEvent_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: WmiEvent_ServerInstance
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

The WMI event query (WQL) to trigger the alert on. This is only applicable for WMI event alerts.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: WmiEvent_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: WmiEvent_ServerInstance
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



